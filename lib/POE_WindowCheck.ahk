; PoEWindowCheck - Check for the game window. 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PoEWindowCheck()
{
	Global GamePID, NoGame, GameActive, YesInGameOverlay, WR
	try {
		If (GamePID := WinExist(GameStr))
		{
			GameActive := WinActive(GameStr)
			WinGetPos, , , nGameW, nGameH
			newDim := (nGameW != GameW || nGameH != GameH)
			global RescaleRan, ToggleExist
			If (!GameBound || newDim )
			{
				GameBound := True
				if YesDX12 {
					FindText.BindWindow(GamePID,4)
				} else {
					FindText.BindWindow(GamePID)
				}
				WinGet, s, Style, ahk_class POEWindowClass
				If (s & +0x80000000)
					WinSet, Style, -0x80000000, ahk_class POEWindowClass
			}
			If (!RescaleRan || newDim)
				Rescale()
			If ((!ToggleExist || newDim) && GameActive) 
			{
				Gui 2: Show,% "x" WR.loc.pixel.Gui.X " y" WR.loc.pixel.Gui.Y - 15 " NA"
				GuiUpdate()
				ToggleExist := True
				NoGame := False
			}
			Else If (ToggleExist && !GameActive)
			{
				ToggleExist := False
				Gui 2: Show, Hide
			}
		} 
		Else 
		{
			If CheckTime("seconds",5,"CheckActiveType")
				CheckActiveType()
			If GameActive
				GameActive := False
			If GameBound
			{
				GameBound := False
				FindText.BindWindow()
			}
			If (ToggleExist)
			{
				Gui 2: Show, Hide
				ToggleExist := False
				RescaleRan := False
				NoGame := True
			}
			If (!AutoUpdateOff && ScriptUpdateTimeType != "Off" && ScriptUpdateTimeInterval != 0 && CheckTime(ScriptUpdateTimeType,ScriptUpdateTimeInterval,"updateScript"))
			{
				checkUpdate()
			}
		}
	} catch e {
		Log("Error","PoEWindowCheck", ErrorText(e))
	}
	Return
}
