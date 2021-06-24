FlaskMenu(){
	Global
	static Built := {}, which := 1
	RegExMatch(A_GuiControl, "\d+", slot)

	If !Built[slot]
	{
		Built[slot] := True
		Gui, Flask%slot%: new, AlwaysOnTop
		Gui, Flask%slot%: Font, cBlack

		Gui, Flask%slot%: Add, GroupBox, section xm ym w500 h300, Flask Slot %slot%

		Gui, Flask%slot%: Add, GroupBox, section center xs+10 yp+20 w100 h45, Cooldown
		Gui, Flask%slot%: Add, Edit,  center     vFlask%slot%CD  xs+10   yp+20  w80  h17, %  WR.Flask[slot].CD

		Gui, Flask%slot%: Add, GroupBox, center xs y+15 w100 h45, Keys to Press
		Gui, Flask%slot%: Add, Edit,    center   vFlask%slot%Key       xs+10   yp+20   w80  h17, %   WR.Flask[slot].Key

		Gui, Flask%slot%: Add, GroupBox, center xs y+15 w100 h55, CD Group
		Gui, Flask%slot%: Add, DropDownList, % "vFlask" slot "Group xs+10 yp+20 w80" , f1|f2|f3|f4|f5|Mana|Life|ES|QuickSilver|Defense
		GuiControl,Flask%slot%: ChooseString, Flask%slot%Group,% WR.Flask[slot].Group

		Gui, Flask%slot%: Add, GroupBox, center xs y+20 w100 h55, Group Cooldown
		Gui, Flask%slot%: Add, Edit,  center     vFlask%slot%GroupCD  xs+10   yp+20  w80  h17, %  WR.Flask[slot].GroupCD

		Gui, Flask%slot%: Add, GroupBox, Section center xs+110 ys w360 h40, Trigger with Debuff
		Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "Curse  xs+15 w54 yp+20 Checked"  WR.Flask[slot].Curse , Curse
		Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "Shock    xp+55 wp    yp Checked" WR.Flask[slot].Shock , Shock
		Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "Bleed    xp+55 wp    yp Checked" WR.Flask[slot].Bleed , Bleed
		Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "Freeze   xp+55 wp    yp Checked" WR.Flask[slot].Freeze, Freeze
		Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "Ignite   xp+55 wp    yp Checked" WR.Flask[slot].Ignite, Ignite
		Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "Poison   xp+55 wp    yp Checked" WR.Flask[slot].Poison, Poison


		Gui, Flask%slot%: Add, GroupBox, Section center xs y+15 w100 h45, Pop All Flasks
		Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "PopAll  xs+10   yp+20 Checked" WR.Flask[slot].PopAll, Include

		Gui, Flask%slot%: Add, GroupBox, center xs y+20 w100 h45, Trigger on Move
		Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "Move xs+10   yp+20 Checked" WR.Flask[slot].Move , Enable

		Gui, Flask%slot%: Add, GroupBox, center xs y+20 w100 h95, Trigger with Attack
		Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "MainAttack xs+10 yp+20 Checked" WR.Flask[slot].MainAttack, Main
		Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "MainAttackRelease xs+10 y+5 Checked" WR.Flask[slot].MainAttackRelease, Main Release
		Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "SecondaryAttack xs+10   y+5 Checked" WR.Flask[slot].SecondaryAttack, Secondary
		Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "SecondaryAttackRelease xs+10   y+5 Checked" WR.Flask[slot].SecondaryAttackRelease, Sec. Release
		
		backColor := "3b3a3a"
		Gui, Flask%slot%: Add, GroupBox, Section center xs+125 ys w240 h215, Resource Triggers
		setColor := "Red"
		Gui, Flask%slot%: Font, s16, Consolas
		Gui, Flask%slot%: Add, Text, xs+10 ys+18 c%setColor%, L`%
		Gui, Flask%slot%: Add, Text,% "vFlask" slot "Life hwndFlask" slot "LifeHWND x+0 yp w40 c" setColor " center", % WR.Flask[slot].Life
		ControlGetPos, x, y, w, h, ,% "ahk_id " Flask%slot%LifeHWND
		x:=Scale_PositionFromDPI(x), y:=Scale_PositionFromDPI(y), w:=Scale_PositionFromDPI(w), h:=Scale_PositionFromDPI(h)
		Flask%slot%Life_Slider := new Progress_Slider("Flask" Slot, "Flask" slot "Life_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Flask[slot].Life , backColor , setColor , 1 , "Flask" slot "Life" , 0 , 0 , 1)
		setColor := "51DEFF"
		Gui, Flask%slot%: Font,
		Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "ResetCooldownAtHealthPercentage xs+22 y+6 Checked" WR.Flask[slot].ResetCooldownAtHealthPercentage, Reset cooldown at health:
		Gui, Flask%slot%: Add, Edit, % "r1 vFlask" slot "ResetCooldownAtHealthPercentageInput Number x+0 yp-3 w30 h17", % WR.Flask[slot].ResetCooldownAtHealthPercentageInput
		Gui, Flask%slot%: Add, Text, x+2 yp+3, `%
		
		Gui, Flask%slot%: Font, s16, Consolas
		Gui, Flask%slot%: Add, Text, xs+10 y+13 c%setColor%, E`%
		Gui, Flask%slot%: Add, Text,% "vFlask" slot "ES hwndFlask" slot "ESHWND x+0 yp w40 c" setColor " center", % WR.Flask[slot].ES
		ControlGetPos, x, y, w, h, ,% "ahk_id " Flask%slot%ESHWND
		x:=Scale_PositionFromDPI(x), y:=Scale_PositionFromDPI(y), w:=Scale_PositionFromDPI(w), h:=Scale_PositionFromDPI(h)
		Flask%slot%ES_Slider := new Progress_Slider("Flask" Slot, "Flask" slot "ES_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Flask[slot].ES , backColor , setColor , 1 , "Flask" slot "ES" , 0 , 0 , 1)
		setColor := "Blue"
		Gui, Flask%slot%: Font,
		Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "ResetCooldownAtEnergyShieldPercentage xs+12 y+6 Checked" WR.Flask[slot].ResetCooldownAtEnergyShieldPercentage, Reset cooldown at energy shield:
		Gui, Flask%slot%: Add, Edit, % "r1 vFlask" slot "ResetCooldownAtEnergyShieldPercentageInput Number x+0 yp-3 w30 h17", % WR.Flask[slot].ResetCooldownAtEnergyShieldPercentageInput
		Gui, Flask%slot%: Add, Text, x+2 yp+3, `%
		
		Gui, Flask%slot%: Font, s16, Consolas
		Gui, Flask%slot%: Add, Text, xs+10 y+13 c%setColor%, M`%
		Gui, Flask%slot%: Add, Text,% "vFlask" slot "Mana hwndFlask" slot "ManaHWND x+0 yp w40 c" setColor " center", % WR.Flask[slot].Mana
		Gui, Flask%slot%: Font,
		Gui, Flask%slot%: Add, Checkbox, % "vFlask" slot "ResetCooldownAtManaPercentage xs+25 y+6 Checked" WR.Flask[slot].ResetCooldownAtManaPercentage, Reset cooldown at mana:
		Gui, Flask%slot%: Add, Edit, % "r1 vFlask" slot "ResetCooldownAtManaPercentageInput Number x+0 yp-3 w30 h17", % WR.Flask[slot].ResetCooldownAtManaPercentageInput
		Gui, Flask%slot%: Add, Text, x+2 yp+3, `%

		ControlGetPos, x, y, w, h, ,% "ahk_id " Flask%slot%ManaHWND
		x:=Scale_PositionFromDPI(x), y:=Scale_PositionFromDPI(y), w:=Scale_PositionFromDPI(w), h:=Scale_PositionFromDPI(h)
		Flask%slot%Mana_Slider := new Progress_Slider("Flask" Slot, "Flask" slot "Mana_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Flask[slot].Mana , backColor , setColor , 1 , "Flask" slot "Mana" , 0 , 0 , 1)
		Gui, Flask%slot%: Add, Text, xs+10 y+43 , Slider Trigger Condition:
		Gui, Flask%slot%: Add, Radio, % "vFlask" slot "Condition  x+5   yp-5 h22 Checked" (WR.Flask[slot].Condition==1?1:0), Any
		Gui, Flask%slot%: Add, Radio, %                              " x+5 hp  yp Checked" (WR.Flask[slot].Condition==2?1:0), All

		Gui, Flask%slot%: show, AutoSize
	}
	Return

	FlaskSaveValues:
		for k, kind in ["CD", "GroupCD", "Key", "MainAttackRelease", "SecondaryAttackRelease", "MainAttack", "SecondaryAttack", "PopAll", "Move", "Group", "Condition", "Curse", "Shock", "Bleed", "Freeze", "Ignite", "Poison", "ResetCooldownAtHealthPercentage",  "ResetCooldownAtHealthPercentageInput", "ResetCooldownAtEnergyShieldPercentage", "ResetCooldownAtEnergyShieldPercentageInput", "ResetCooldownAtManaPercentage", "ResetCooldownAtManaPercentageInput"]
			WR.Flask[which][kind] := Flask%which%%kind%
		for k, kind in ["Life", "ES", "Mana"]
			WR.Flask[which][kind] := Flask%which%%kind%_Slider.Slider_Value 
		FileDelete, %A_ScriptDir%\save\Flask.json
		JSONtext := JSON.Dump(WR.Flask,,2)
		FileAppend, %JSONtext%, %A_ScriptDir%\save\Flask.json
	Return
	Flask1GuiClose:
	Flask1GuiEscape:
	Flask2GuiClose:
	Flask2GuiEscape:
	Flask3GuiClose:
	Flask3GuiEscape:
	Flask4GuiClose:
	Flask4GuiEscape:
	Flask5GuiClose:
	Flask5GuiEscape:
		RegExMatch(A_ThisLabel, "\d+", val)
		Built[val] := False
		Gui, Submit, NoHide
		which := val
		Gosub, FlaskSaveValues
		Gui, Flask%val%: Destroy
	Return
}
