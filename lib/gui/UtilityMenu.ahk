UtilityMenu(){
	Global
	static Built := {}, which := 1
	RegExMatch(A_GuiControl, "\d+", slot)

	If !Built[slot]
	{
		Built[slot] := True
		Gui, Utility%slot%: new, AlwaysOnTop
		Gui, Utility%slot%: Font, cBlack

		Gui, Utility%slot%: Add, GroupBox, section xm ym w500 h410, Utility Slot %slot%

		Gui, Utility%slot%: Add, GroupBox, Section center xs+10 yp+20 w110 h65, Enable Utility
		Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "Enable xs+10   yp+20 Checked" WR.Utility[slot].Enable , Enable
		Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "OnCD xs+10   y+8 Checked" WR.Utility[slot].OnCD , Cast on CD

		Gui, Utility%slot%: Add, GroupBox, center xs y+15 w110 h45, Cooldown
		Gui, Utility%slot%: Add, Edit,  center     vUtility%slot%CD  xs+10   yp+20  w80  h17, %  WR.Utility[slot].CD

		Gui, Utility%slot%: Add, GroupBox, center xs y+15 w110 h45, Keys to Press
		Gui, Utility%slot%: Add, Edit,    center   vUtility%slot%Key       xs+10   yp+20   w80  h17, %   WR.Utility[slot].Key

		Gui, Utility%slot%: Add, GroupBox, center xs y+15 w110 h55, CD Group
		Gui, Utility%slot%: Add, DropDownList, % "vUtility" slot "Group xs+10 yp+20 w80" , u1|u2|u3|u4|u5|u6|u7|u8|u9|u10|Mana|Life|ES|QuickSilver|Defense
		GuiControl,Utility%slot%: ChooseString, Utility%slot%Group,% WR.Utility[slot].Group

		Gui, Utility%slot%: Add, GroupBox, center xs y+20 w110 h55, Group Cooldown
		Gui, Utility%slot%: Add, Edit,  center     vUtility%slot%GroupCD  xs+10   yp+20  w80  h17, %  WR.Utility[slot].GroupCD

		Gui, Utility%slot%: Add, GroupBox, Section center xs+120 ys w360 h40, Trigger with Debuff
		Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "Curse  xs+15 w54 yp+20 Checked"  WR.Utility[slot].Curse , Curse
		Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "Shock    xp+55 wp    yp Checked" WR.Utility[slot].Shock , Shock
		Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "Bleed    xp+55 wp    yp Checked" WR.Utility[slot].Bleed , Bleed
		Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "Freeze   xp+55 wp    yp Checked" WR.Utility[slot].Freeze, Freeze
		Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "Ignite   xp+55 wp    yp Checked" WR.Utility[slot].Ignite, Ignite
		Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "Poison   xp+55 wp    yp Checked" WR.Utility[slot].Poison, Poison

		; Trigger when sample not found
		Gui, Utility%slot%: Add, GroupBox, Section center xs y+10 w360 h120, Trigger when Sample String not found
		Gui, Utility%slot%: Add, Edit,  center     vUtility%slot%Icon  xs+10   yp+20  w230  h17, %  WR.Utility[slot].Icon
		Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "IconShown x+10 yp hp Checked" WR.Utility[slot].IconShown , Invert to Shown


		Gui, Utility%slot%: Add, Text, xs+10  y+12 , Search Area:
		Gui, Utility%slot%: Add, Radio, % "vUtility" slot "IconSearch  x+4   yp-4 h22 Checked" (WR.Utility[slot].IconSearch==1?1:0), Buff
		Gui, Utility%slot%: Add, Radio, %                              " x+3 hp  yp Checked" (WR.Utility[slot].IconSearch==2?1:0), DeBuff
		Gui, Utility%slot%: Add, Radio, %                              " x+3 hp  yp Checked" (WR.Utility[slot].IconSearch==3?1:0), Custom


		Gui, Utility%slot%: Add, Button, gUtilityIconArea x+5 yp hp-2  vUtility%slot%IconArea_Show, Show
		Gui, Utility%slot%: Add, Button, gUtilityIconArea x+5 yp wp hp vUtility%slot%IconArea_Set, Set
		Utility%slot%IconArea := WR.Utility[slot].IconArea

		Gui, Utility%slot%: Add, GroupBox,  center       xs+10   y+3  w340  h43, Allowed Variance for 1 or 0

		Gui, Utility%slot%: Add, Text,  center       xp+30   yp+20  w70  h18, Variance 1
		Gui, Utility%slot%: Add, Edit,  center       x+5   yp-2  w50  hp
		Gui, Utility%slot%: Add, UpDown, range0-100 x+0 yp hp vUtility%slot%IconVar1, %  WR.Utility[slot].IconVar1 * 100

		Gui, Utility%slot%: Add, Text,  center       x+10   yp+2  w70  hp, Variance 0
		Gui, Utility%slot%: Add, Edit,  center       x+5   yp-2  w50  hp
		Gui, Utility%slot%: Add, UpDown, range0-100 x+0 yp hp vUtility%slot%IconVar0, %  WR.Utility[slot].IconVar0 * 100




		Gui, Utility%slot%: Add, GroupBox, Section center xs y+18 w120 h45, Pop All Flasks
		Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "PopAll xs+10   yp+20 Checked" WR.Utility[slot].PopAll , Include

		Gui, Utility%slot%: Add, GroupBox, center xs y+20 w120 h45, Trigger on Move
		Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "Move xs+10   yp+20 Checked" WR.Utility[slot].Move , Enable

		Gui, Utility%slot%: Add, GroupBox, center xs y+20 w120 h115, Trigger with Attack
		Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "MainAttackOnly xs+10 yp+20 Checked" WR.Utility[slot].MainAttackOnly, Main Attack Only	
		Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "MainAttack xs+10 yp+20 Checked" WR.Utility[slot].MainAttack, Main
		Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "MainAttackRelease xs+10 y+5 Checked" WR.Utility[slot].MainAttackRelease, Main Release
		Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "SecondaryAttack xs+10   y+5 Checked" WR.Utility[slot].SecondaryAttack, Secondary
		Gui, Utility%slot%: Add, Checkbox, % "vUtility" slot "SecondaryAttackRelease xs+10   y+5 Checked" WR.Utility[slot].SecondaryAttackRelease, Sec. Release

		backColor := "3b3a3a"
		Gui, Utility%slot%: Add, GroupBox, Section center xs+125 ys w240 h150, Resource Triggers
		setColor := "Red"
		Gui, Utility%slot%: Font, s16, Consolas
		Gui, Utility%slot%: Add, Text, xs+13 ys+18 c%setColor%, L`%
		Gui, Utility%slot%: Add, Text,% "vUtility" slot "Life hwndUtility" slot "LifeHWND x+0 yp w40 c" setColor " center", % WR.Utility[slot].Life
		ControlGetPos, x, y, w, h, ,% "ahk_id " Utility%slot%LifeHWND
		x:=Scale_PositionFromDPI(x), y:=Scale_PositionFromDPI(y), w:=Scale_PositionFromDPI(w), h:=Scale_PositionFromDPI(h)
		Utility%slot%Life_Slider := new Progress_Slider("Utility" Slot, "Utility" slot "Life_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Utility[slot].Life , backColor , setColor , 1 , "Utility" slot "Life" , 0 , 0 , 1)
		setColor := "51DEFF"
		Gui, Utility%slot%: Add, Text, xs+13 y+13 c%setColor%, E`%
		Gui, Utility%slot%: Add, Text,% "vUtility" slot "ES hwndUtility" slot "ESHWND x+0 yp w40 c" setColor " center", % WR.Utility[slot].ES
		ControlGetPos, x, y, w, h, ,% "ahk_id " Utility%slot%ESHWND
		x:=Scale_PositionFromDPI(x), y:=Scale_PositionFromDPI(y), w:=Scale_PositionFromDPI(w), h:=Scale_PositionFromDPI(h)
		Utility%slot%ES_Slider := new Progress_Slider("Utility" Slot, "Utility" slot "ES_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Utility[slot].ES , backColor , setColor , 1 , "Utility" slot "ES" , 0 , 0 , 1)
		setColor := "Blue"
		Gui, Utility%slot%: Add, Text, xs+13 y+13 c%setColor%, M`%
		Gui, Utility%slot%: Add, Text,% "vUtility" slot "Mana hwndUtility" slot "ManaHWND x+0 yp w40 c" setColor " center", % WR.Utility[slot].Mana
		Gui, Utility%slot%: Font,
		ControlGetPos, x, y, w, h, ,% "ahk_id " Utility%slot%ManaHWND
		x:=Scale_PositionFromDPI(x), y:=Scale_PositionFromDPI(y), w:=Scale_PositionFromDPI(w), h:=Scale_PositionFromDPI(h)
		Utility%slot%Mana_Slider := new Progress_Slider("Utility" Slot, "Utility" slot "Mana_Slide" , x+40 , y-h+2 , 145 , h-5 , 0 , 100 , WR.Utility[slot].Mana , backColor , setColor , 1 , "Utility" slot "Mana" , 0 , 0 , 1)
		Gui, Utility%slot%: Add, Text, xs+10 y+13 , Resource Trigger Condition:
		Gui, Utility%slot%: Add, Radio, % "vUtility" slot "Condition  x+5   yp-5 h22 Checked" (WR.Utility[slot].Condition==1?1:0), Any
		Gui, Utility%slot%: Add, Radio, %                              " x+5 hp  yp Checked" (WR.Utility[slot].Condition==2?1:0), All


		Gui, Utility%slot%: show, AutoSize
	}
	Return
	UtilityIconArea:
		RegExMatch(A_GuiControl, "\d+", slot)
		action := StrSplit(A_GuiControl, "_")[2]
		If (action == "Show") {
			If (Utility%slot%IconArea.X1 != "" && Utility%slot%IconArea.Y1 != "" && Utility%slot%IconArea.X2 != "" && Utility%slot%IconArea.Y2 != "")
				MouseTip(Utility%slot%IconArea)
			Else
				Notify("Custom Area has not been set","",2)
		} Else If (action == "Set") {
			Utility%slot%IconArea := LetUserSelectRect()
			MouseTip(Utility%slot%IconArea)
		}
	Return

	UtilitySaveValues:
		for k, kind in ["Enable", "OnCD", "CD", "GroupCD", "Key", "MainAttackOnly", "MainAttack", "SecondaryAttack", "MainAttackRelease", "SecondaryAttackRelease", "PopAll", "Icon", "IconShown", "IconSearch", "IconArea", "Move", "Group", "Condition", "Curse", "Shock", "Bleed", "Freeze", "Ignite", "Poison"]
			WR.Utility[which][kind] := Utility%which%%kind%
		for k, kind in ["Life", "ES", "Mana"]
			WR.Utility[which][kind] := Utility%which%%kind%_Slider.Slider_Value 
		for k, kind in ["IconVar1", "IconVar0"]
			WR.Utility[which][kind] := Round(Utility%which%%kind% / 100,2)

		FileDelete, %A_ScriptDir%\save\Utility.json
		JSONtext := JSON.Dump(WR.Utility,,2)
		FileAppend, %JSONtext%, %A_ScriptDir%\save\Utility.json
	Return
	Utility1GuiClose:
	Utility1GuiEscape:
	Utility2GuiClose:
	Utility2GuiEscape:
	Utility3GuiClose:
	Utility3GuiEscape:
	Utility4GuiClose:
	Utility4GuiEscape:
	Utility5GuiClose:
	Utility5GuiEscape:
	Utility6GuiClose:
	Utility6GuiEscape:
	Utility7GuiClose:
	Utility7GuiEscape:
	Utility8GuiClose:
	Utility8GuiEscape:
	Utility9GuiClose:
	Utility9GuiEscape:
	Utility10GuiClose:
	Utility10GuiEscape:
		RegExMatch(A_ThisLabel, "\d+", val)
		Built[val] := False
		Gui, Submit, NoHide
		which := val
		Gosub, UtilitySaveValues
		Gui, Utility%val%: Destroy
	Return
}
