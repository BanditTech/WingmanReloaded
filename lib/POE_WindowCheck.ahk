; PoEWindowCheck - Check for the game window.
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PoEWindowCheck()
{
	Global GamePID, NoGame, GameActive, WR
	try {
		If (GamePID := WinExist(GameStr))
		{
			NoGame := False
			GameActive := WinActive(GameStr)
			WinGetPos(,, &nGameW, &nGameH)
			newDim := (nGameW != GameW || nGameH != GameH)
			global RescaleRan, ToggleExist
			If (!GameBound || newDim )
			{
				GameBound := True
				if YesDX12 {
					FindText().BindWindow(GamePID,4)
				} else {
					FindText().BindWindow(GamePID)
				}
				s := WinGetStyle("ahk_class POEWindowClass")
				If (s & +0x80000000)
					WinSetStyle("-0x80000000", "ahk_class POEWindowClass")
			}
			If (!RescaleRan || newDim)
				Rescale()
			If ((!ToggleExist || newDim) && GameActive)
			{
				OverlayGui.Show("x" WR.loc.pixel.Gui.X " y" WR.loc.pixel.Gui.Y - 15 " NA")
				ChaosGui.Show("x" (WR.loc.pixel.GuiChaos.X - 300) " y" WR.loc.pixel.GuiChaos.Y " NA")
				GuiUpdate()
				ToggleExist := True
				NoGame := False
			}
			Else If (ToggleExist && !GameActive)
			{
				ToggleExist := False
				OverlayGui.Show("Hide")
				ChaosGui.Show("Hide")
			}
		}
		Else
		{
			NoGame := True
			If CheckTime("seconds",5,"CheckActiveType")
				CheckActiveType()
			If GameActive
				GameActive := False
			If GameBound
			{
				GameBound := False
				FindText().BindWindow()
			}
			If (ToggleExist)
			{
				OverlayGui.Show("Hide")
				ChaosGui.Show("Hide")
				ToggleExist := False
				RescaleRan := False
				NoGame := True
			}
			If (!AutoUpdateOff && ScriptUpdateTimeType != "Off" && ScriptUpdateTimeInterval != 0 && CheckTime(ScriptUpdateTimeType,ScriptUpdateTimeInterval,"updateScript"))
			{
				checkUpdate()
			}
		}
	} catch as e {
		Log("Error","PoEWindowCheck", ErrorText(e))
	}
	Return
}
