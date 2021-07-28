LootColorsMenu(){
	DrawLootColors:
		Static LG_Add, LG_Rem
		Global LootColors, LG_Vary
		Gui, Submit
		CheckGamestates := False
		gui,LootColors: new, LabelLootColors
		gui,LootColors: -MinimizeBox
		Gui LootColors: Add, Checkbox, section gUpdateExtra  vLootVacuum Checked%LootVacuum%   xm+5 ym+8 , Enable Loot Vacuum
		Gui LootColors: Add, Checkbox,  gUpdateExtra  vLootVacuumTapZ Checked%LootVacuumTapZ%   x+5 yp , Double tap Z
		Gui LootColors: Add, Checkbox,  gUpdateExtra  vLootVacuumTapZEnd Checked%LootVacuumTapZEnd%   x+5 yp , on release
		Gui LootColors: Add, Text,  x+5 yp , %LootVacuumTapZSec%
		Gui LootColors: Add, UpDown,  gUpdateExtra  vLootVacuumTapZSec range1-10, %LootVacuumTapZSec%

		Gui,LootColors: Add, DropDownList, gUpdateExtra vAreaScale w45 xm+5 y+8,  0|30|40|50|60|70|80|90|100|200|300|400|500
		GuiControl,LootColors: ChooseString, AreaScale, %AreaScale%
		Gui,LootColors: Add, Text,                     x+3 yp+5              , Area around mouse
		Gui,LootColors: Add, DropDownList, gUpdateExtra vLVdelay w45 x+5 yp-5,  0|15|30|45|60|75|90|105|120|135|150|195|300
		GuiControl,LootColors: ChooseString, LVdelay, %LVdelay%
		Gui,LootColors: Add, Text,                     x+3 yp+5              , Delay after click
		gui,LootColors: add, CheckBox, gUpdateExtra vYesLootChests Checked%YesLootChests% Right xm h22, Open Containers?
		Gui,LootColors:  +Delimiter?
		Gui,LootColors: Add, ComboBox, x+5 w210 vChestStr gUpdateStringEdit , %ChestStr%??"%1080_ChestStr%"?"%1050_ChestStr%"
		Gui,LootColors:  +Delimiter|
		gui,LootColors: add, CheckBox, gUpdateExtra vYesLootDelve Checked%YesLootDelve% Right xm h22, Delve Containers?
		Gui,LootColors:  +Delimiter?
		Gui,LootColors: Add, ComboBox, x+5 w210 vDelveStr gUpdateStringEdit , %DelveStr%??"%1080_DelveStr%"
		Gui,LootColors:  +Delimiter|
		gui,LootColors: add, groupbox,% "section xm y+10 w330 h" 24 * (LootColors.Count() / 2) + 30 , Loot Colors:
		gui,LootColors: add, Button, gSaveLootColorArray yp-5 xp+70 h22 w80, Save to INI
		gui,LootColors: add, Button, gAdjustLootGroup vLG_Add yp x+5 h22 wp, Add Color Set
		gui,LootColors: add, Button, gAdjustLootGroup vLG_Rem yp x+5 h22 wp, Rem Color Set
		Item := 0
		For k, color in LootColors
		{
			; color := val ; hexBGRToRGB(Format("0x{1:06X}",val))
			If !Mod(k,2) ;Check for a remainder when dividing by 2, this groups the colors
			{
				gui,LootColors: add, Progress, x+1 yp w50 h20 c%color% BackgroundBlack,100
				gui,LootColors: add, Button, gResampleLootColor yp x+5 h20,% "Resample " Item
				continue
			}
			Item++
			If A_Index = 1
			{
				gui,LootColors: add, text, yp+38 xs+10,% "Background " Item " Colors: "
				gui,LootColors: add, Progress, x+10 yp-5 w50 h20 c%color% BackgroundBlack,100
				continue
			}
			gui,LootColors: add, text, yp+29 xs+10,% "Background " Item " Colors: "
			gui,LootColors: add, Progress, x+10 yp-5 w50 h20 c%color% BackgroundBlack,100
		}
		Gui,LootColors: show,,Loot Vacuum settings
	return

	AdjustLootGroup:
		Global LootColors
		Gui, Submit
		ind := LootColors.MaxIndex()
		If (A_GuiControl = "LG_Add")
		{
			LootColors[ind + 1] := 0xFFFFFF
			LootColors[ind + 2] := 0xFFFFFF
		}
		Else If (A_GuiControl = "LG_Rem" && ind > 2)
		{
			LootColors.Pop(ind)
			LootColors.Pop(ind - 1)
		}
		Gui, LootColors: Destroy
		LootColorsMenu()
	Return

	ResampleLootColor:
		; Thread, NoTimers, True ; Critical
		RemoveToolTip()
		PauseTooltips := 1
		groupNumber := StrSplit(A_GuiControl, A_Space)[2]
		MO_Index := (BG_Index := groupNumber * 2) - 1
		IfWinExist, ahk_group POEGameGroup
		{
			WinActivate, ahk_group POEGameGroup
		} else {
			MsgBox % "PoE Window does not exist. `nCannot sample the loot color."
			Return
		}
		ToolTip,% "Press ""A"" to sample loot background"
			. "`nHold Escape and press ""A"" to cancel"
			, % ScrCenter.X - 115 , % ScrCenter.Y - GameH // 3
		KeyWait, a, D L
		ToolTip
		KeyWait, a
		If GetKeyState("Escape", "P")
		{
			MsgBox % "Escape key was held`n"
			. "Canceling the sample!"
			Gui, LootColors: Show
			Exit
		}
		if WinActive(ahk_group POEGameGroup){
			BlockInput, MouseMove
			MouseGetPos, mX, mY
			FindText.ScreenShot(), BG_Color := FindText.GetColor(mX,mY)
			LootColors[BG_Index] := Format("0x{1:06X}",BG_Color)
			Sleep, 100
			SendInput {%hotkeyLootScan% down}
			Sleep, 200
			FindText.ScreenShot(), MO_Color := FindText.GetColor(mX,mY)
			LootColors[MO_Index] := Format("0x{1:06X}",MO_Color)
			SendInput {%hotkeyLootScan% up}
			BlockInput, MouseMoveOff
		} else {
			MsgBox % "PoE Window is not active. `nSampling the loot color didn't work"
			Gui, LootColors: Show
			Exit
		}
		Gui, LootColors: Destroy
		PauseTooltips := 0
		LootColorsMenu()
		Thread, NoTimers, False    ;End Critical
	Return

	SaveLootColorArray:
		LCstr := hexArrToStr(LootColors)
		IniWrite, %LCstr%, %A_ScriptDir%\save\Settings.ini, Loot Colors, LootColors
		LootScan(1)
		MsgBox % "LootColors saved with the following hex values:"
			. "`n" . LCstr
	Return

	LootColorsClose:
	LootColorsEscape:
		Gui, LootColors: Destroy
		MainMenu()
	Return
}
