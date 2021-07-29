; QuickPortal - Open Town Portal
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
QuickPortal(ChickenFlag := False){
	QuickPortalCommand:
		If (OnTown || OnHideout || OnMines)
			Return
		Critical
		; BlockInput On
		BlockInput MouseMove
		If (GetKeyState("LButton","P"))
			Click, up
		If (GetKeyState("RButton","P"))
			Click, Right, up
		MouseGetPos xx, yy
		RandomSleep(53,87)

		If !(OnInventory)
		{
			SendHotkey(hotkeyInventory)
			RandomSleep(56,68)
		}
		Found := False
		For C, vv in WR.Restock {
			For R, v in vv {
				If (v.Restock && v.RestockName = "Portal"){
					Found := True
					Break
				}
			}
		}
		If !Found {
			Log("Portal Scroll is not configured in inventory slot options")
			Return False
		}
		x := InventoryGridX[C], Y := InventoryGridY[R]
		o := RandClick(X,Y)
		RightClick(o.X, o.Y)

		SendHotkey(hotkeyInventory)
		If YesClickPortal || ChickenFlag
		{
			Sleep, 75*Latency
			LeftClick(GameX + Round(GameW/2),GameY + Round(GameH/2.427))
		}
		Else
			MouseMove, xx, yy, 0
		; BlockInput Off
		BlockInput MouseMoveOff
		RandomSleep(300,600)
		Thread, NoTimers, False    ;End Critical
	return
}
