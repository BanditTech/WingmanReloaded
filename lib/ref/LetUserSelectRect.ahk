; Rectangular selection function written by Lexikos
LetUserSelectRect(PixelToo:=0)
{
	Global Picker
	HotIf()
	static r := 1
	; Create the "selection rectangle" GUIs (one for each edge).
	rectGuis := []
	Loop 4 {
		g := Gui("-Caption +ToolWindow +AlwaysOnTop")
		g.BackColor := "Red"
		rectGuis.Push(g)
	}
	; Declare variables before closures so they are captured by reference.
	x1 := 0, y1 := 0, x2 := 0, y2 := 0
	xlast := -1, ylast := -1
	xorigin := 0, yorigin := 0
	X1 := 0, Y1 := 0, X2 := 0, Y2 := 0

	lusr_update() {
		MouseGetPos(&x, &y)
		if (x = xlast && y = ylast)
			; Mouse hasn't moved so there's nothing to do.
			return
		xlast := x, ylast := y
		if (x < xorigin)
			x1 := x, x2 := xorigin
		else
			x2 := x, x1 := xorigin
		if (y < yorigin)
			y1 := y, y2 := yorigin
		else
			y2 := y, y1 := yorigin
		X1 := x1, Y1 := y1, X2 := x2, Y2 := y2
		; Update the "selection rectangle".
		rectGuis[1].Show("NA X" x1 " Y" y1 " W" x2-x1 " H" (r?r:1))
		rectGuis[2].Show("NA X" x1 " Y" y2-r " W" x2-x1 " H" (r?r:1))
		rectGuis[3].Show("NA X" x1 " Y" y1 " W" (r?r:1) " H" y2-y1)
		rectGuis[4].Show("NA X" x2-r " Y" y1 " W" (r?r:1) " H" y2-y1)
	}

	lusr_ret := (*) => 0

	PauseTooltips := 1
	If (GamePID)
	{
		MainGui.Hide()
		WinActivate(GameStr)
	}
	If PixelToo
		Ding(0,-11,"Click and hold left mouse to draw box`nUse arrow keys to move mouse,and mousewheel to zoom`nPress Ctrl to Clipboard the color and X,Y")
	Else
		Ding(0,-11,"Click and hold left mouse to begin`nUse arrow keys to move mouse,and mousewheel to zoom")
	; Wait for release of LButton
	KeyWait("LButton")
	; Wait for release of Ctrl
	If PixelToo
		KeyWait("Ctrl")
	; Disable LButton.
	Hotkey("*LButton", lusr_ret, "On")
	DrawZoom("Toggle")
	Loop
	{
		; Get initial coordinates.
		MouseGetPos(&xorigin, &yorigin)
		col := PixelGetColor(xorigin, yorigin, "RGB")
		Picker.SetColor(col)
		ToolTip((PixelToo ? "   " col " @ " : "   ") xorigin "," yorigin)
		DrawZoom("Repaint")
		DrawZoom("MoveAway")
		If (GetKeyState("Ctrl", "P") && PixelToo)
		{
			Hotkey("*LButton", "Off")
			ToolTip()
			Ding(1,-11,"")
			PauseTooltips := 0
			A_Clipboard := col " @ " xorigin "," yorigin
			Notify(A_Clipboard,"Copied to the clipboard",5)
			DrawZoom("Toggle")
			Return False
		}
	} Until GetKeyState("LButton", "P")
	ToolTip()
	Ding(0,-11,"Drag the mouse then release to select the area")
	; Set timer for updating the selection rectangle.
	SetTimer(lusr_update, 10)
	; Wait for user to release LButton.
	KeyWait("LButton")
	; Re-enable LButton.
	Hotkey("*LButton", "Off")
	; Disable timer.
	SetTimer(lusr_update, 0)
	; Destroy "selection rectangle" GUIs.
	for g in rectGuis {
		g.Destroy()
	}
	PauseTooltips := 0
	Ding(1,-11,"")
	DrawZoom("Toggle")
	MainGui.Show()
	return { X1:X1, Y1:Y1, X2:X2, Y2:Y2 }
}

LetUserSelectPixel(){
	HotIf()
	; Create the "selection rectangle" GUIs (one for each edge).
	PauseTooltips := 1
	If (GamePID)
	{
		MainGui.Hide()
		WinActivate(GameStr)
	}
	Ding(0,-11,"Click or Press CTRL to select a location")
	; Wait for release of LButton
	KeyWait("LButton")
	; Wait for release of Ctrl
	KeyWait("Ctrl")
	; Disable LButton.
	lusr_ret := (*) => 0
	Hotkey("*LButton", lusr_ret, "On")
	DrawZoom("Toggle")
	Loop
	{
		; Get initial coordinates.
		MouseGetPos(&xorigin, &yorigin)
		col := PixelGetColor(xorigin, yorigin, "RGB")
		ToolTip("   " col " @ " xorigin "," yorigin)
		DrawZoom("Repaint")
		DrawZoom("MoveAway")
	} Until (GetKeyState("LButton", "P") || GetKeyState("Ctrl", "P"))
	ToolTip()
	; Re-enable LButton.
	Hotkey("*LButton", "Off")
	PauseTooltips := 0
	Ding(1,-11,"")
	DrawZoom("Toggle")
	MainGui.Show()
	return { X:xorigin, Y:yorigin, Color:col }
}
