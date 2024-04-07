; QuickPortal - Open Town Portal
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
QuickPortal(){
	QuickPortalCommand:
		If (OnTown || OnHideout || OnMines)
			Return
		if (hotkeyOpenPortal == A_Space) {
			Notify("Hotkey Unset","Set the keybinding to match the in-game Open Portal key.",3)
			Return
		}
		
		SetActionTimings()
		Critical
		BlockInput MouseMove
		MouseGetPos xx, yy

		; Release both the left and right mouse keys
		lState := GetKeyState("LButton","P")
		rState := GetKeyState("RButton","P")
		If (lState || rState) {
			if (lState)
				Click, up
			if (rState)
				Click, Right, up
			RandomSleep(75,90)
		}

		; Close the inventory if we have it open, required to click in the center of screen.
		If (OnInventory && GuiStatus("OnInventory")) {
			SendHotkey(hotkeyInventory)
			RandomSleep(75,90)
		}
		
		centerX := GameX + Round(GameW/2)
		centerY := GameY + Round(GameH*0.48148148148148148148148148148148)

		; First click at center of screen to stop movement
		LeftClick(centerX,centerY)
		; Open the Portal using in-game key
		SendHotkey(hotkeyOpenPortal)
		RandomSleep(90,120)
		; Click the center of screen to use the portal.
		LeftClick(centerX,centerY)

		BlockInput MouseMoveOff
		RandomSleep(300,600)
	return
}
