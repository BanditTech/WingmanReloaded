; AutoQuit - Toggle the scripts quit function on
toggleAutoQuit(){
	WR.func.Toggle.Quit := !WR.func.Toggle.Quit
	Settings("func","Save")
	GuiUpdate()
	return
}

; AutoFlask - Toggle flask usage on
toggleAutoFlask(){
	WR.func.Toggle.Flask := !WR.func.Toggle.Flask
	Settings("func","Save")
	GuiUpdate()  
	return
}
; AutoMove - Toggle movement triggers
toggleAutoMove(){
	WR.func.Toggle.Move := !WR.func.Toggle.Move  
	Settings("func","Save")
	GuiUpdate()
	return
}
; AutoUtility - Toggle utility triggers
toggleAutoUtility(){
	WR.func.Toggle.Utility := !WR.func.Toggle.Utility  
	Settings("func","Save")
	GuiUpdate()
	return
}
; Hotkey to pause the detonate mines
PauseMines(){
	PauseMinesCommand:
		if !WR.perChar.Setting.autominesEnable
		return
		static keyheld := 0
		keyheld++
		settimer, keyheldReset, 200
		if keyheld > 1
			return
		KeyWait, %hotkeyPauseMines%, T0.3 ; Wait .3 seconds until Detonate key is released.
		If ErrorLevel = 1 ; If not released, just exit out
			Exit
		keyheld := 0
		If (WR.perChar.Setting.autominesPauseSingleTap == 1)
			pauseToggle := !pauseToggle
		else if (A_PriorHotkey <> "$~" . hotkeyPauseMines || A_TimeSincePriorHotkey > WR.perChar.Setting.autominesPauseDoubleTapSpeed)
		{    ;This is a not a double tap
			pauseToggle := false
		}
		else if (A_TimeSincePriorHotkey > 50 && A_TimeSincePriorHotkey < WR.perChar.Setting.autominesPauseDoubleTapSpeed)
		{    ;This is a double tap that works if within range 25-set value
			pauseToggle := true
		}
		else if A_TimeSincePriorHotkey < 50
		{
			return
		}
		if (!pauseToggle)
		{
			Detonated := False
			PauseTooltips := 0
			Tooltip
		}
		else if (pauseToggle)
		{
			SetTimer, TDetonated, Delete
			Detonated := True
			PauseTooltips := 1
			Tooltip, Auto-Mines Paused, % A_ScreenWidth / 2 - 57, % A_ScreenHeight / 8
		}
	Return

	keyheldReset:
		keyheld := 0
	return
}

