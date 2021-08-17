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
				If (!v.Normal && v.RestockName = "Portal"){
					Found := True
					Break 2
				}
			}
		}
		If !Found {
			Notify("Missing Configuration","Assign an inventory slot to Portal Scrolls`nMake sure to select Ignore or Restock")
			Log("Error","Portal Scroll is not configured in inventory slot options","Please configure the slot in your inventory from which to draw Portal Scrolls","The slot must be configured to Restock or Ignore and select Portal in the dropdown menu")
			BlockInput MouseMoveOff
			Return False
		}
		iX := InventoryGridX[C], iY := InventoryGridY[R]
		o := RandClick(iX,iY)

		RightClick(o.X, o.Y)

		SendHotkey(hotkeyInventory)
		If YesClickPortal || ChickenFlag
		{
			Sleep, 75*Latency
			LeftClick(GameX + Round(GameW/2),GameY + Round(GameH/2.427))
		}
		Else
			MouseMove, xx, yy, 0
		BlockInput MouseMoveOff
		RandomSleep(300,600)
		Thread, NoTimers, False    ;End Critical
	return
}
