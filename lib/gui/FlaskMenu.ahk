FlaskMenu(GuiCtrl, *){
	static Built := Map(), which := 1
	static FlaskGui := Map()
	static FlaskSliders := Map()
	RegExMatch(GuiCtrl.Text, "\d+", &slotMatch)
	slot := slotMatch[]

	If !Built.Has(slot)
	{
		Built[slot] := True
		FlaskGui[slot] := Gui("AlwaysOnTop")
		FlaskGui[slot].OnEvent("Close", FlaskGuiClose)
		FlaskGui[slot].OnEvent("Escape", FlaskGuiEscape)
		FlaskGui[slot].SetFont("cBlack")

		FlaskGui[slot].Add("GroupBox", "section xm ym w500 h300", "Flask Slot " slot)

		FlaskGui[slot].Add("GroupBox", "section center xs+10 yp+20 w100 h45", "Cooldown")
		FlaskGui[slot].Add("Edit",  "center     vFlask" slot "CD  xs+10   yp+20  w80  h17",  WR.Flask.%slot%.CD)

		FlaskGui[slot].Add("GroupBox", "center xs y+15 w100 h45", "Keys to Press")
		FlaskGui[slot].Add("Edit",    "center   vFlask" slot "Key       xs+10   yp+20   w80  h17",   WR.Flask.%slot%.Key)

		FlaskGui[slot].Add("GroupBox", "center xs y+15 w100 h55", "CD Group")
		FlaskGui[slot].Add("DropDownList", "vFlask" slot "Group xs+10 yp+20 w80" , ["f1","f2","f3","f4","f5","Mana","Life","ES","QuickSilver","Defense"])
		FlaskGui[slot]["Flask" slot "Group"].Choose(WR.Flask.%slot%.Group)

		FlaskGui[slot].Add("GroupBox", "center xs y+20 w100 h55", "Group Cooldown")
		FlaskGui[slot].Add("Edit",  "center     vFlask" slot "GroupCD  xs+10   yp+20  w80  h17",  WR.Flask.%slot%.GroupCD)

		FlaskGui[slot].Add("GroupBox", "Section center xs+110 ys w360 h40", "Trigger with Debuff")
		FlaskGui[slot].Add("Checkbox", "vFlask" slot "Curse  xs+15 w54 yp+20 Checked"  WR.Flask.%slot%.Curse , "Curse")
		FlaskGui[slot].Add("Checkbox", "vFlask" slot "Shock    xp+55 wp    yp Checked" WR.Flask.%slot%.Shock , "Shock")
		FlaskGui[slot].Add("Checkbox", "vFlask" slot "Bleed    xp+55 wp    yp Checked" WR.Flask.%slot%.Bleed , "Bleed")
		FlaskGui[slot].Add("Checkbox", "vFlask" slot "Freeze   xp+55 wp    yp Checked" WR.Flask.%slot%.Freeze, "Freeze")
		FlaskGui[slot].Add("Checkbox", "vFlask" slot "Ignite   xp+55 wp    yp Checked" WR.Flask.%slot%.Ignite, "Ignite")
		FlaskGui[slot].Add("Checkbox", "vFlask" slot "Poison   xp+55 wp    yp Checked" WR.Flask.%slot%.Poison, "Poison")


		FlaskGui[slot].Add("GroupBox", "Section center xs y+15 w100 h45", "Pop All Flasks")
		FlaskGui[slot].Add("Checkbox", "vFlask" slot "PopAll  xs+10   yp+20 Checked" WR.Flask.%slot%.PopAll, "Include")

		FlaskGui[slot].Add("GroupBox", "center xs y+20 w100 h45", "Trigger on Move")
		FlaskGui[slot].Add("Checkbox", "vFlask" slot "Move xs+10   yp+20 Checked" WR.Flask.%slot%.Move , "Enable")

		FlaskGui[slot].Add("GroupBox", "center xs y+20 w100 h95", "Trigger with Attack")
		FlaskGui[slot].Add("Checkbox", "vFlask" slot "MainAttack xs+10 yp+20 Checked" WR.Flask.%slot%.MainAttack, "Main")
		FlaskGui[slot].Add("Checkbox", "vFlask" slot "MainAttackRelease xs+10 y+5 Checked" WR.Flask.%slot%.MainAttackRelease, "Main Release")
		FlaskGui[slot].Add("Checkbox", "vFlask" slot "SecondaryAttack xs+10   y+5 Checked" WR.Flask.%slot%.SecondaryAttack, "Secondary")
		FlaskGui[slot].Add("Checkbox", "vFlask" slot "SecondaryAttackRelease xs+10   y+5 Checked" WR.Flask.%slot%.SecondaryAttackRelease, "Sec. Release")

		backColor := "3b3a3a"
		FlaskGui[slot].Add("GroupBox", "Section center xs+125 ys w240 h215", "Resource Triggers")
		setColor := "Red"
		FlaskGui[slot].SetFont("s16", "Consolas")
		FlaskGui[slot].Add("Text", "xs+10 ys+18 c" setColor, "L`%")
		lifeCtrl := FlaskGui[slot].Add("Text", "vFlask" slot "Life x+0 yp w40 c" setColor " center", WR.Flask.%slot%.Life)
		lifeCtrl.GetPos(&x, &y, &w, &h)
		x:=Scale_PositionFromDPI(x), y:=Scale_PositionFromDPI(y), w:=Scale_PositionFromDPI(w), h:=Scale_PositionFromDPI(h)
		If !FlaskSliders.Has(slot)
			FlaskSliders[slot] := Map()
		FlaskSliders[slot]["Life"] := Progress_Slider("Flask" Slot, "Flask" slot "Life_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Flask.%slot%.Life , backColor , setColor , 1 , "Flask" slot "Life" , 0 , 0 , 1)
		setColor := "51DEFF"
		FlaskGui[slot].SetFont()
		FlaskGui[slot].Add("Checkbox", "vFlask" slot "ResetCooldownAtHealthPercentage xs+22 y+6 Checked" WR.Flask.%slot%.ResetCooldownAtHealthPercentage, "Reset cooldown at health:")
		FlaskGui[slot].Add("Edit", "r1 vFlask" slot "ResetCooldownAtHealthPercentageInput Number x+0 yp-3 w30 h17", WR.Flask.%slot%.ResetCooldownAtHealthPercentageInput)
		FlaskGui[slot].Add("Text", "x+2 yp+3", "`%")

		FlaskGui[slot].SetFont("s16", "Consolas")
		FlaskGui[slot].Add("Text", "xs+10 y+13 c" setColor, "E`%")
		esCtrl := FlaskGui[slot].Add("Text", "vFlask" slot "ES x+0 yp w40 c" setColor " center", WR.Flask.%slot%.ES)
		esCtrl.GetPos(&x, &y, &w, &h)
		x:=Scale_PositionFromDPI(x), y:=Scale_PositionFromDPI(y), w:=Scale_PositionFromDPI(w), h:=Scale_PositionFromDPI(h)
		FlaskSliders[slot]["ES"] := Progress_Slider("Flask" Slot, "Flask" slot "ES_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Flask.%slot%.ES , backColor , setColor , 1 , "Flask" slot "ES" , 0 , 0 , 1)
		setColor := "Blue"
		FlaskGui[slot].SetFont()
		FlaskGui[slot].Add("Checkbox", "vFlask" slot "ResetCooldownAtEnergyShieldPercentage xs+12 y+6 Checked" WR.Flask.%slot%.ResetCooldownAtEnergyShieldPercentage, "Reset cooldown at energy shield:")
		FlaskGui[slot].Add("Edit", "r1 vFlask" slot "ResetCooldownAtEnergyShieldPercentageInput Number x+0 yp-3 w30 h17", WR.Flask.%slot%.ResetCooldownAtEnergyShieldPercentageInput)
		FlaskGui[slot].Add("Text", "x+2 yp+3", "`%")

		FlaskGui[slot].SetFont("s16", "Consolas")
		FlaskGui[slot].Add("Text", "xs+10 y+13 c" setColor, "M`%")
		manaCtrl := FlaskGui[slot].Add("Text", "vFlask" slot "Mana x+0 yp w40 c" setColor " center", WR.Flask.%slot%.Mana)
		FlaskGui[slot].SetFont()
		FlaskGui[slot].Add("Checkbox", "vFlask" slot "ResetCooldownAtManaPercentage xs+25 y+6 Checked" WR.Flask.%slot%.ResetCooldownAtManaPercentage, "Reset cooldown at mana:")
		FlaskGui[slot].Add("Edit", "r1 vFlask" slot "ResetCooldownAtManaPercentageInput Number x+0 yp-3 w30 h17", WR.Flask.%slot%.ResetCooldownAtManaPercentageInput)
		FlaskGui[slot].Add("Text", "x+2 yp+3", "`%")

		manaCtrl.GetPos(&x, &y, &w, &h)
		x:=Scale_PositionFromDPI(x), y:=Scale_PositionFromDPI(y), w:=Scale_PositionFromDPI(w), h:=Scale_PositionFromDPI(h)
		FlaskSliders[slot]["Mana"] := Progress_Slider("Flask" Slot, "Flask" slot "Mana_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Flask.%slot%.Mana , backColor , setColor , 1 , "Flask" slot "Mana" , 0 , 0 , 1)
		FlaskGui[slot].Add("Text", "xs+10 y+43 " , "Slider Trigger Condition:")
		FlaskGui[slot].Add("Radio", "vFlask" slot "Condition  x+5   yp-5 h22 Checked" (WR.Flask.%slot%.Condition==1?1:0), "Any")
		FlaskGui[slot].Add("Radio",                              "x+5 hp  yp Checked" (WR.Flask.%slot%.Condition==2?1:0), "All")

		FlaskGui[slot].Show("AutoSize")
	}
	Return

	FlaskSaveValues(val) {
		for k, kind in ["CD", "GroupCD", "Key", "MainAttackRelease", "SecondaryAttackRelease", "MainAttack", "SecondaryAttack", "PopAll", "Move", "Group", "Condition", "Curse", "Shock", "Bleed", "Freeze", "Ignite", "Poison", "ResetCooldownAtHealthPercentage",  "ResetCooldownAtHealthPercentageInput", "ResetCooldownAtEnergyShieldPercentage", "ResetCooldownAtEnergyShieldPercentageInput", "ResetCooldownAtManaPercentage", "ResetCooldownAtManaPercentageInput"]
			WR.Flask.%val%[kind] := FlaskGui[val]["Flask" val kind].Value
		for k, kind in ["Life", "ES", "Mana"]
			WR.Flask.%val%[kind] := FlaskSliders[val][kind].Slider_Value
		If FileExist(A_ScriptDir "\save\Flask.json")
			FileDelete(A_ScriptDir "\save\Flask.json")
		JSONtext := JSON.Dump(WR.Flask, 2)
		FileAppend(JSONtext, A_ScriptDir "\save\Flask.json")
	}
	FlaskGuiClose(GuiObj) {
		; Identify which slot by checking the gui objects
		val := 0
		for s, g in FlaskGui {
			if (g.Hwnd == GuiObj.Hwnd) {
				val := s
				break
			}
		}
		if !val
			return
		Built[val] := False
		FlaskGui[val].Submit(0)
		which := val
		FlaskSaveValues(val)
		FlaskGui[val].Destroy()
	}
	FlaskGuiEscape(GuiObj) {
		; Identify which slot by checking the gui objects
		val := 0
		for s, g in FlaskGui {
			if (g.Hwnd == GuiObj.Hwnd) {
				val := s
				break
			}
		}
		if !val
			return
		Built[val] := False
		FlaskGui[val].Submit(0)
		which := val
		FlaskSaveValues(val)
		FlaskGui[val].Destroy()
	}
}
