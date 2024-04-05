; QuickPortal - Open Town Portal
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
QuickPortal(){
	QuickPortalCommand:
		If (OnTown || OnHideout || OnMines)
			Return
		SetActionTimings()
		Critical
		BlockInput MouseMove
		MouseGetPos xx, yy
		If (GetKeyState("LButton","P") || GetKeyState("RButton","P")) {
			Click, up
			Click, Right, up
			RandomSleep(60,90)
		}

		SendHotkey(hotkeyOpenPortal)

		RandomSleep(60,90)

		If (OnInventory && GuiStatus("OnInventory"))
			SendHotkey(hotkeyInventory)
		RandomSleep(75,90)
		LeftClick(GameX + Round(GameW/2),GameY + Round(GameH/2.427))

		BlockInput MouseMoveOff
		RandomSleep(300,600)
	return
}
