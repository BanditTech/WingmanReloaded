LootColorsMenu(*){
	Global LootColors, LG_Vary, LootColorsGui
	Static LG_Add, LG_Rem
	Global LootVacuum, LootVacuumTapZ, LootVacuumTapZEnd, LootVacuumTapZSec
	Global AreaScale, LVdelay, YesLootChests, ChestStr, YesLootDelve, DelveStr
	Global hotkeyLootScan, ScrCenter, GameH
	MainGui.Submit()
	CheckGamestates := False
	LootColorsGui := Gui()
	LootColorsGui.OnEvent("Close", LootColorsClose)
	LootColorsGui.OnEvent("Escape", LootColorsEscape)

	cb := LootColorsGui.Add("Checkbox", "section gUpdateExtra  vLootVacuum Checked" LootVacuum "   xm+5 ym+8 ", "Enable Loot Vacuum")
	cb.OnEvent("Click", UpdateExtra)
	cb2 := LootColorsGui.Add("Checkbox",  "vLootVacuumTapZ Checked" LootVacuumTapZ "   x+5 yp ", "Double tap Z")
	cb2.OnEvent("Click", UpdateExtra)
	cb3 := LootColorsGui.Add("Checkbox",  "vLootVacuumTapZEnd Checked" LootVacuumTapZEnd "   x+5 yp ", "on release")
	cb3.OnEvent("Click", UpdateExtra)
	LootColorsGui.Add("Text",  "x+5 yp ", LootVacuumTapZSec)
	ud := LootColorsGui.Add("UpDown",  "vLootVacuumTapZSec range1-10", LootVacuumTapZSec)
	ud.OnEvent("Change", UpdateExtra)

	ddl := LootColorsGui.Add("DropDownList", "vAreaScale w45 xm+5 y+8",  [" ","0","30","40","50","60","70","80","90","100","200","300","400","500"])
	ddl.OnEvent("Change", UpdateExtra)
	LootColorsGui["AreaScale"].Choose(AreaScale)
	LootColorsGui.Add("Text",                     "x+3 yp+5"              , "Area around mouse")
	ddl2 := LootColorsGui.Add("DropDownList", "vLVdelay w45 x+5 yp-5",  [" ","0","15","30","45","60","75","90","105","120","135","150","195","300"])
	ddl2.OnEvent("Change", UpdateExtra)
	LootColorsGui["LVdelay"].Choose(LVdelay)
	LootColorsGui.Add("Text",                     "x+3 yp+5"              , "Delay after click")
	cb4 := LootColorsGui.Add("CheckBox", "vYesLootChests Checked" YesLootChests " Right xm h22", "Open Containers?")
	cb4.OnEvent("Click", UpdateExtra)
	LootColorsGui.Opt("+Delimiter?")
	cbox := LootColorsGui.Add("ComboBox", "x+5 w210 vChestStr " , ChestStr "?" Chr(34) "1080_ChestStr" Chr(34) "?" Chr(34) "1050_ChestStr" Chr(34))
	cbox.OnEvent("Change", UpdateStringEdit)
	LootColorsGui.Opt("+Delimiter|")
	cb5 := LootColorsGui.Add("CheckBox", "vYesLootDelve Checked" YesLootDelve " Right xm h22", "Delve Containers?")
	cb5.OnEvent("Click", UpdateExtra)
	LootColorsGui.Opt("+Delimiter?")
	cbox2 := LootColorsGui.Add("ComboBox", "x+5 w210 vDelveStr " , DelveStr "?" Chr(34) "1080_DelveStr" Chr(34))
	cbox2.OnEvent("Change", UpdateStringEdit)
	LootColorsGui.Opt("+Delimiter|")
	LootColorsGui.Add("GroupBox", "section xm y+10 w330 h" 24 * (LootColors.Length / 2) + 30 , "Loot Colors:")
	savebtn := LootColorsGui.Add("Button", "yp-5 xp+70 h22 w80", "Save to INI")
	savebtn.OnEvent("Click", SaveLootColorArray)
	LG_Add := LootColorsGui.Add("Button", "vLG_Add yp x+5 h22 wp", "Add Color Set")
	LG_Add.OnEvent("Click", AdjustLootGroup)
	LG_Rem := LootColorsGui.Add("Button", "vLG_Rem yp x+5 h22 wp", "Rem Color Set")
	LG_Rem.OnEvent("Click", AdjustLootGroup)
	colorIdx := 0
	For k, color in LootColors
	{
		; color := val ; hexBGRToRGB(Format("0x{1:06X}",val))
		If !Mod(k,2) ;Check for a remainder when dividing by 2, this groups the colors
		{
			LootColorsGui.Add("Progress", "x+1 yp w50 h20 c" color " BackgroundBlack",100)
			resBtn := LootColorsGui.Add("Button", "yp x+5 h20", "Resample " colorIdx)
			resBtn.OnEvent("Click", ResampleLootColor)
			continue
		}
		colorIdx++
		If (A_Index == 1)
		{
			LootColorsGui.Add("Text", "yp+38 xs+10", "Background " colorIdx " Colors: ")
			LootColorsGui.Add("Progress", "x+10 yp-5 w50 h20 c" color " BackgroundBlack",100)
			continue
		}
		LootColorsGui.Add("Text", "yp+29 xs+10", "Background " colorIdx " Colors: ")
		LootColorsGui.Add("Progress", "x+10 yp-5 w50 h20 c" color " BackgroundBlack",100)
	}
	LootColorsGui.Show(,"Loot Vacuum settings")

	AdjustLootGroup(ctrl, *) {
		Global LootColors, LootColorsGui
		LootColorsGui.Submit()
		ind := LootColors.MaxIndex()
		If (ctrl.Name == "LG_Add")
		{
			LootColors[ind + 1] := 0xFFFFFF
			LootColors[ind + 2] := 0xFFFFFF
		}
		Else If (ctrl.Name == "LG_Rem" && ind > 2)
		{
			LootColors.Pop(ind)
			LootColors.Pop(ind - 1)
		}
		LootColorsGui.Destroy()
		LootColorsMenu()
	}

	ResampleLootColor(ctrl, *) {
		Global LootColors, LootColorsGui, hotkeyLootScan, ScrCenter, GameH
		Global PauseTooltips
		; Thread, NoTimers, True ; Critical
		RemoveToolTip()
		PauseTooltips := 1
		groupNumber := StrSplit(ctrl.Text, A_Space)[2]
		MO_Index := (BG_Index := groupNumber * 2) - 1
		if WinExist("ahk_group POEGameGroup")
		{
			WinActivate("ahk_group POEGameGroup")
		} else {
			MsgBox("PoE Window does not exist. `nCannot sample the loot color.")
			Return
		}
		ToolTip("Press `"A`" to sample loot background"
			. "`nHold Escape and press `"A`" to cancel"
			, ScrCenter.X - 115 , ScrCenter.Y - GameH // 3)
		KeyWait("a", "D L")
		ToolTip()
		KeyWait("a")
		If GetKeyState("Escape", "P")
		{
			MsgBox("Escape key was held`n"
			. "Canceling the sample!")
			LootColorsGui.Show()
			Exit
		}
		if WinActive("ahk_group POEGameGroup"){
			BlockInput("MouseMove")
			MouseGetPos(&mX, &mY)
			FindText().ScreenShot(), BG_Color := FindText().GetColor(mX,mY)
			LootColors[BG_Index] := Format("0x{1:06X}",BG_Color)
			Sleep(100)
			SendInput("{" hotkeyLootScan " down}")
			Sleep(200)
			FindText().ScreenShot(), MO_Color := FindText().GetColor(mX,mY)
			LootColors[MO_Index] := Format("0x{1:06X}",MO_Color)
			SendInput("{" hotkeyLootScan " up}")
			BlockInput("MouseMoveOff")
		} else {
			MsgBox("PoE Window is not active. `nSampling the loot color didn't work")
			LootColorsGui.Show()
			Exit
		}
		LootColorsGui.Destroy()
		PauseTooltips := 0
		LootColorsMenu()
		Thread("NoTimers", false)    ;End Critical
	}

	SaveLootColorArray(*) {
		Global LootColors
		LCstr := hexArrToStr(LootColors)
		IniWrite(LCstr, A_ScriptDir "\save\Settings.ini", "Loot Colors", "LootColors")
		LootScan(1)
		MsgBox("LootColors saved with the following hex values:"
			. "`n" . LCstr)
	}

	LootColorsClose(GuiObj) {
		Global LootColorsGui
		LootColorsGui.Destroy()
		MainMenu()
	}
	LootColorsEscape(GuiObj) {
		Global LootColorsGui
		LootColorsGui.Destroy()
		MainMenu()
	}
}
