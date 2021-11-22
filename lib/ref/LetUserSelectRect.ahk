; Rectangular selection function written by Lexikos
LetUserSelectRect(PixelToo:=0)
{
	Global Picker
	Hotkey Ifwinactive
	static r := 1
	; Create the "selection rectangle" GUIs (one for each edge).
	Loop 4 {
		Gui, Rect%A_Index%: -Caption +ToolWindow +AlwaysOnTop
		Gui, Rect%A_Index%: Color, Red
	}
	PauseTooltips := 1
	If (GamePID)
	{
		Gui, Submit
		WinActivate, %GameStr%
	}
	If PixelToo
		Ding(0,-11,"Click and hold left mouse to draw box`nUse arrow keys to move mouse,and mousewheel to zoom`nPress Ctrl to Clipboard the color and X,Y")
	Else
		Ding(0,-11,"Click and hold left mouse to begin`nUse arrow keys to move mouse,and mousewheel to zoom")
	; Wait for release of LButton
	KeyWait, LButton
	; Wait for release of Ctrl
	If PixelToo
		KeyWait, Ctrl
	; Disable LButton.
	Hotkey, *LButton, lusr_return, On
	DrawZoom("Toggle")
	Loop
	{
		; Get initial coordinates.
		MouseGetPos, xorigin, yorigin
		PixelGetColor, col, %xorigin%, %yorigin%, RGB
		Picker.SetColor(col)
		ToolTip, % (PixelToo?"   " col " @ ":"   ") xorigin "," yorigin 
		DrawZoom("Repaint")
		DrawZoom("MoveAway")
		If (GetKeyState("Ctrl", "P") && PixelToo)
		{
			Hotkey, *LButton, Off
			Tooltip
			Ding(1,-11,"")
			PauseTooltips := 0
			Clipboard := col " @ " xorigin "," yorigin
			Notify(Clipboard,"Copied to the clipboard",5)
			DrawZoom("Toggle")
			Return False
		}
	} Until GetKeyState("LButton", "P")
	Tooltip
	Ding(0,-11,"Drag the mouse then release to select the area")
	; Set timer for updating the selection rectangle.
	SetTimer, lusr_update, 10
	; Wait for user to release LButton.
	KeyWait, LButton
	; Re-enable LButton.
	Hotkey, *LButton, Off
	; Disable timer.
	SetTimer, lusr_update, Off
	; Destroy "selection rectangle" GUIs.
	Loop 4
		Gui, Rect%A_Index%: Destroy
	PauseTooltips := 0
	Ding(1,-11,"")
	DrawZoom("Toggle")
	Gui, Show
	return { "X1":X1,"Y1":Y1,"X2":X2,"Y2":Y2 }

	lusr_update:
		MouseGetPos, x, y
		if (x = xlast && y = ylast)
			; Mouse hasn't moved so there's nothing to do.
			return
		if (x < xorigin)
			x1 := x, x2 := xorigin
		else x2 := x, x1 := xorigin
		if (y < yorigin)
			y1 := y, y2 := yorigin
		else y2 := y, y1 := yorigin
		; Update the "selection rectangle".
		Gui, Rect1:Show, % "NA X" x1 " Y" y1 " W" x2-x1 " H" (r?r:1)
		Gui, Rect2:Show, % "NA X" x1 " Y" y2-r " W" x2-x1 " H" (r?r:1)
		Gui, Rect3:Show, % "NA X" x1 " Y" y1 " W" (r?r:1) " H" y2-y1
		Gui, Rect4:Show, % "NA X" x2-r " Y" y1 " W" (r?r:1) " H" y2-y1
	lusr_return:
	return
}

LetUserSelectPixel(){
	Hotkey Ifwinactive
	; Create the "selection rectangle" GUIs (one for each edge).
	PauseTooltips := 1
	If (GamePID)
	{
		Gui, Submit
		WinActivate, %GameStr%
	}
	Ding(0,-11,"Click or Press CTRL to select a location")
	; Wait for release of LButton
	KeyWait, LButton
	; Wait for release of Ctrl
	KeyWait, Ctrl
	; Disable LButton.
	Hotkey, *LButton, lusr_return, On
	DrawZoom("Toggle")
	Loop
	{
		; Get initial coordinates.
		MouseGetPos, xorigin, yorigin
		PixelGetColor, col, %xorigin%, %yorigin%, RGB
		ToolTip, % "   " col " @ " xorigin "," yorigin 
		DrawZoom("Repaint")
		DrawZoom("MoveAway")
	} Until (GetKeyState("LButton", "P") || GetKeyState("Ctrl", "P"))
	Tooltip
	; Re-enable LButton.
	Hotkey, *LButton, Off
	PauseTooltips := 0
	Ding(1,-11,"")
	DrawZoom("Toggle")
	Gui, Show
	return { "X":xorigin,"Y":yorigin,"Color":col }
}
