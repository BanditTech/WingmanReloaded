UtilityMenu(GuiCtrl, *){
	static Built := Map(), which := 1
	static UtilityGui := Map()
	static UtilitySliders := Map()
	static UtilityIconAreas := Map()
	RegExMatch(GuiCtrl.Text, "\d+", &slotMatch)
	slot := slotMatch[]

	If !Built.Has(slot)
	{
		Built[slot] := True
		UtilityGui[slot] := Gui("AlwaysOnTop")
		UtilityGui[slot].OnEvent("Close", UtilityGuiClose)
		UtilityGui[slot].OnEvent("Escape", UtilityGuiEscape)
		UtilityGui[slot].SetFont("cBlack")

		UtilityGui[slot].Add("GroupBox", "section xm ym w500 h410", "Utility Slot " slot)

		UtilityGui[slot].Add("GroupBox", "Section center xs+10 yp+20 w110 h65", "Enable Utility")
		UtilityGui[slot].Add("Checkbox", "vUtility" slot "Enable xs+10   yp+20 Checked" WR.Utility.%slot%.Enable , "Enable")
		UtilityGui[slot].Add("Checkbox", "vUtility" slot "OnCD xs+10   y+8 Checked" WR.Utility.%slot%.OnCD , "Cast on CD")

		UtilityGui[slot].Add("GroupBox", "center xs y+15 w110 h45", "Cooldown")
		UtilityGui[slot].Add("Edit",  "center     vUtility" slot "CD  xs+10   yp+20  w80  h17",  WR.Utility.%slot%.CD)

		UtilityGui[slot].Add("GroupBox", "center xs y+15 w110 h45", "Keys to Press")
		UtilityGui[slot].Add("Edit",    "center   vUtility" slot "Key       xs+10   yp+20   w80  h17",   WR.Utility.%slot%.Key)

		UtilityGui[slot].Add("GroupBox", "center xs y+15 w110 h55", "CD Group")
		UtilityGui[slot].Add("DropDownList", "vUtility" slot "Group xs+10 yp+20 w80" , ["u1","u2","u3","u4","u5","u6","u7","u8","u9","u10","Mana","Life","ES","QuickSilver","Defense"])
		UtilityGui[slot]["Utility" slot "Group"].Choose(WR.Utility.%slot%.Group)

		UtilityGui[slot].Add("GroupBox", "center xs y+20 w110 h55", "Group Cooldown")
		UtilityGui[slot].Add("Edit",  "center     vUtility" slot "GroupCD  xs+10   yp+20  w80  h17",  WR.Utility.%slot%.GroupCD)

		UtilityGui[slot].Add("GroupBox", "Section center xs+120 ys w360 h40", "Trigger with Debuff")
		UtilityGui[slot].Add("Checkbox", "vUtility" slot "Curse  xs+15 w54 yp+20 Checked"  WR.Utility.%slot%.Curse , "Curse")
		UtilityGui[slot].Add("Checkbox", "vUtility" slot "Shock    xp+55 wp    yp Checked" WR.Utility.%slot%.Shock , "Shock")
		UtilityGui[slot].Add("Checkbox", "vUtility" slot "Bleed    xp+55 wp    yp Checked" WR.Utility.%slot%.Bleed , "Bleed")
		UtilityGui[slot].Add("Checkbox", "vUtility" slot "Freeze   xp+55 wp    yp Checked" WR.Utility.%slot%.Freeze, "Freeze")
		UtilityGui[slot].Add("Checkbox", "vUtility" slot "Ignite   xp+55 wp    yp Checked" WR.Utility.%slot%.Ignite, "Ignite")
		UtilityGui[slot].Add("Checkbox", "vUtility" slot "Poison   xp+55 wp    yp Checked" WR.Utility.%slot%.Poison, "Poison")

		; Trigger when sample not found
		UtilityGui[slot].Add("GroupBox", "Section center xs y+10 w360 h120", "Trigger when Sample String not found")
		UtilityGui[slot].Add("Edit",  "center     vUtility" slot "Icon  xs+10   yp+20  w230  h17",  WR.Utility.%slot%.Icon)
		UtilityGui[slot].Add("Checkbox", "vUtility" slot "IconShown x+10 yp hp Checked" WR.Utility.%slot%.IconShown , "Invert to Shown")


		UtilityGui[slot].Add("Text", "xs+10  y+12 " , "Search Area:")
		UtilityGui[slot].Add("Radio", "vUtility" slot "IconSearch  x+4   yp-4 h22 Checked" (WR.Utility.%slot%.IconSearch==1?1:0), "Buff")
		UtilityGui[slot].Add("Radio",                              "x+3 hp  yp Checked" (WR.Utility.%slot%.IconSearch==2?1:0), "DeBuff")
		UtilityGui[slot].Add("Radio",                              "x+3 hp  yp Checked" (WR.Utility.%slot%.IconSearch==3?1:0), "Custom")


		showBtn := UtilityGui[slot].Add("Button", "x+5 yp hp-2  vUtility" slot "IconArea_Show", "Show")
		showBtn.OnEvent("Click", UtilityIconArea)
		setBtn := UtilityGui[slot].Add("Button", "x+5 yp wp hp vUtility" slot "IconArea_Set", "Set")
		setBtn.OnEvent("Click", UtilityIconArea)
		UtilityIconAreas[slot] := WR.Utility.%slot%.IconArea

		UtilityGui[slot].Add("GroupBox",  "center       xs+10   y+3  w340  h43", "Allowed Variance for 1 or 0")

		UtilityGui[slot].Add("Text",  "center       xp+30   yp+20  w70  h18", "Variance 1")
		UtilityGui[slot].Add("Edit",  "center       x+5   yp-2  w50  hp")
		UtilityGui[slot].Add("UpDown", "range0-100 x+0 yp hp vUtility" slot "IconVar1",  WR.Utility.%slot%.IconVar1 * 100)

		UtilityGui[slot].Add("Text",  "center       x+10   yp+2  w70  hp", "Variance 0")
		UtilityGui[slot].Add("Edit",  "center       x+5   yp-2  w50  hp")
		UtilityGui[slot].Add("UpDown", "range0-100 x+0 yp hp vUtility" slot "IconVar0",  WR.Utility.%slot%.IconVar0 * 100)




		UtilityGui[slot].Add("GroupBox", "Section center xs y+18 w120 h45", "Pop All Flasks")
		UtilityGui[slot].Add("Checkbox", "vUtility" slot "PopAll xs+10   yp+20 Checked" WR.Utility.%slot%.PopAll , "Include")

		UtilityGui[slot].Add("GroupBox", "center xs y+20 w120 h45", "Trigger on Move")
		UtilityGui[slot].Add("Checkbox", "vUtility" slot "Move xs+10   yp+20 Checked" WR.Utility.%slot%.Move , "Enable")

		UtilityGui[slot].Add("GroupBox", "center xs y+20 w120 h115", "Trigger with Attack")
		UtilityGui[slot].Add("Checkbox", "vUtility" slot "MainAttackOnly xs+10 yp+20 Checked" WR.Utility.%slot%.MainAttackOnly, "Main Attack Only")
		UtilityGui[slot].Add("Checkbox", "vUtility" slot "MainAttack xs+10 yp+20 Checked" WR.Utility.%slot%.MainAttack, "Main")
		UtilityGui[slot].Add("Checkbox", "vUtility" slot "MainAttackRelease xs+10 y+5 Checked" WR.Utility.%slot%.MainAttackRelease, "Main Release")
		UtilityGui[slot].Add("Checkbox", "vUtility" slot "SecondaryAttack xs+10   y+5 Checked" WR.Utility.%slot%.SecondaryAttack, "Secondary")
		UtilityGui[slot].Add("Checkbox", "vUtility" slot "SecondaryAttackRelease xs+10   y+5 Checked" WR.Utility.%slot%.SecondaryAttackRelease, "Sec. Release")

		backColor := "3b3a3a"
		UtilityGui[slot].Add("GroupBox", "Section center xs+125 ys w240 h150", "Resource Triggers")
		setColor := "Red"
		UtilityGui[slot].SetFont("s16", "Consolas")
		UtilityGui[slot].Add("Text", "xs+13 ys+18 c" setColor, "L`%")
		lifeCtrl := UtilityGui[slot].Add("Text", "vUtility" slot "Life x+0 yp w40 c" setColor " center", WR.Utility.%slot%.Life)
		lifeCtrl.GetPos(&x, &y, &w, &h)
		x:=Scale_PositionFromDPI(x), y:=Scale_PositionFromDPI(y), w:=Scale_PositionFromDPI(w), h:=Scale_PositionFromDPI(h)
		If !UtilitySliders.Has(slot)
			UtilitySliders[slot] := Map()
		UtilitySliders[slot]["Life"] := Progress_Slider(UtilityGui[slot], "Utility" slot "Life_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Utility.%slot%.Life , backColor , setColor , 1 , "Utility" slot "Life" , 0 , 0 , 1)
		setColor := "51DEFF"
		UtilityGui[slot].Add("Text", "xs+13 y+13 c" setColor, "E`%")
		esCtrl := UtilityGui[slot].Add("Text", "vUtility" slot "ES x+0 yp w40 c" setColor " center", WR.Utility.%slot%.ES)
		esCtrl.GetPos(&x, &y, &w, &h)
		x:=Scale_PositionFromDPI(x), y:=Scale_PositionFromDPI(y), w:=Scale_PositionFromDPI(w), h:=Scale_PositionFromDPI(h)
		UtilitySliders[slot]["ES"] := Progress_Slider(UtilityGui[slot], "Utility" slot "ES_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Utility.%slot%.ES , backColor , setColor , 1 , "Utility" slot "ES" , 0 , 0 , 1)
		setColor := "Blue"
		UtilityGui[slot].Add("Text", "xs+13 y+13 c" setColor, "M`%")
		manaCtrl := UtilityGui[slot].Add("Text", "vUtility" slot "Mana x+0 yp w40 c" setColor " center", WR.Utility.%slot%.Mana)
		UtilityGui[slot].SetFont()
		manaCtrl.GetPos(&x, &y, &w, &h)
		x:=Scale_PositionFromDPI(x), y:=Scale_PositionFromDPI(y), w:=Scale_PositionFromDPI(w), h:=Scale_PositionFromDPI(h)
		UtilitySliders[slot]["Mana"] := Progress_Slider(UtilityGui[slot], "Utility" slot "Mana_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Utility.%slot%.Mana , backColor , setColor , 1 , "Utility" slot "Mana" , 0 , 0 , 1)
		UtilityGui[slot].Add("Text", "xs+10 y+13 " , "Resource Trigger Condition:")
		UtilityGui[slot].Add("Radio", "vUtility" slot "Condition  x+5   yp-5 h22 Checked" (WR.Utility.%slot%.Condition==1?1:0), "Any")
		UtilityGui[slot].Add("Radio",                              "x+5 hp  yp Checked" (WR.Utility.%slot%.Condition==2?1:0), "All")


		UtilityGui[slot].Show("AutoSize")
	}
	Return

	UtilityIconArea(ctrl, *) {
		RegExMatch(ctrl.Name, "\d+", &slotMatch2)
		slot2 := slotMatch2[]
		action := StrSplit(ctrl.Name, "_")[2]
		If (action == "Show") {
			If (UtilityIconAreas[slot2].X1 != "" && UtilityIconAreas[slot2].Y1 != "" && UtilityIconAreas[slot2].X2 != "" && UtilityIconAreas[slot2].Y2 != "")
				MouseTip(UtilityIconAreas[slot2])
			Else
				Notify("Custom Area has not been set","",2)
		} Else If (action == "Set") {
			UtilityIconAreas[slot2] := LetUserSelectRect()
			MouseTip(UtilityIconAreas[slot2])
		}
	}

	UtilitySaveValues(val) {
		for k, kind in ["Enable", "OnCD", "CD", "GroupCD", "Key", "MainAttackOnly", "MainAttack", "SecondaryAttack", "MainAttackRelease", "SecondaryAttackRelease", "PopAll", "Icon", "IconShown", "IconSearch", "IconArea", "Move", "Group", "Condition", "Curse", "Shock", "Bleed", "Freeze", "Ignite", "Poison"]
			WR.Utility.%val%.%kind% := UtilityGui[val]["Utility" val kind].Value
		for k, kind in ["Life", "ES", "Mana"]
			WR.Utility.%val%.%kind% := UtilitySliders[val][kind].Slider_Value
		for k, kind in ["IconVar1", "IconVar0"]
			WR.Utility.%val%.%kind% := Round(UtilityGui[val]["Utility" val kind].Value / 100,2)

		If FileExist(A_ScriptDir "\save\Utility.json")

			FileDelete(A_ScriptDir "\save\Utility.json")
		JSONtext := JSON.Dump(WR.Utility, 2)
		FileAppend(JSONtext, A_ScriptDir "\save\Utility.json")
	}
	UtilityGuiClose(GuiObj) {
		val := 0
		for s, g in UtilityGui {
			if (g.Hwnd == GuiObj.Hwnd) {
				val := s
				break
			}
		}
		if !val
			return
		UtilityGui[val].Submit(0)
		which := val
		UtilitySaveValues(val)
		UtilityGui[val].Destroy()
		UtilityGui.Delete(val)
		Built.Delete(val)
	}
	UtilityGuiEscape(GuiObj) {
		val := 0
		for s, g in UtilityGui {
			if (g.Hwnd == GuiObj.Hwnd) {
				val := s
				break
			}
		}
		if !val
			return
		UtilityGui[val].Submit(0)
		which := val
		UtilitySaveValues(val)
		UtilityGui[val].Destroy()
		UtilityGui.Delete(val)
		Built.Delete(val)
	}
}
