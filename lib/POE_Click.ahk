; PoE Click v1.0.1 : Developed by Bandit
SpamClick(Toggle:="",Modifier:=""){
	Static Spam := False
	If (Toggle != "") {
		If (Toggle == 1 || Toggle == 0)
			Spam := Toggle
		Else If (Toggle = "True" || Toggle = "true" || Toggle = "on" || Toggle = "On")
			Spam := True
		Else If (Toggle = "False" || Toggle = "false" || Toggle = "off" || Toggle = "Off")
			Spam := False
	} Else
		Spam := !Spam
	If (Modifier != "") {
		If !isObject(Modifier)
			Modifier := StrSplit(Modifier,",")
		For k, mod in Modifier{
			Send {%mod% Down}
			Sleep, 60+(ClickLatency*15)
		}
	}
	While Spam {
		Send {Click}
		Sleep, 60+(ClickLatency*15)
	}
	If (Modifier != "") {
		For k, mod in Modifier{
			Send {%mod% Up}
			Sleep, 60+(ClickLatency*15)
		}
	}
}
; LeftClick - Left Click at Coord
LeftClick(x, y){
	Log("Verbose","LeftClick: " x ", " y)
	BlockInput, MouseMove
	MouseMove, x, y
	; Sleep, 90+(ClickLatency*15)
	Send {Click}
	; Sleep, 105+(ClickLatency*15)
	BlockInput, MouseMoveOff
	Return
}
; RightClick - Right Click at Coord
RightClick(x, y){
	Log("Verbose","RightClick: " x ", " y)
	BlockInput, MouseMove
	MouseMove, x, y
	; Sleep, 90+(ClickLatency*15)
	Send {Click, Right}
	; Sleep, 105+(ClickLatency*15)
	BlockInput, MouseMoveOff
	Return
}
; ShiftClick - Shift Click +Click at Coord
ShiftClick(x, y){
	Log("Verbose","ShiftClick: " x ", " y)
	BlockInput, MouseMove
	MouseMove, x, y
	; Sleep, 90+(ClickLatency*15)
	Send +{Click}
	; Sleep, 105+(ClickLatency*15)
	BlockInput, MouseMoveOff
	return
}
; CtrlClick - Ctrl Click ^Click at Coord
CtrlClick(x, y){
	Log("Verbose","CtrlClick: " x ", " y)
	BlockInput, MouseMove
	MouseMove, x, y
	; Sleep, 105+(ClickLatency*15)
	Send ^{Click}
	; Sleep, 105+(ClickLatency*15)
	BlockInput, MouseMoveOff
	return
}
; CtrlShiftClick - Ctrl + Shift Click +^Click at Coord
CtrlShiftClick(x, y){
	Log("Verbose","CtrlShiftClick: " x ", " y)
	BlockInput, MouseMove
	MouseMove, x, y
	; Sleep, 105+(ClickLatency*15)
	Send +^{Click}
	; Sleep, 105+(ClickLatency*15)
	BlockInput, MouseMoveOff
	return
}
; RandClick - Randomize Click area around middle of cell using lower left Coord
RandClick(x, y){
	Random, Rx, x+10, x+30
	Random, Ry, y-30, y-10
	If DebugMessages
		Log("Verbose","Randomize: " x ", " y " position to " Rx ", " Ry )
	return {"X": Rx, "Y": Ry}
}
; ClipItem - Capture Clip at Coord
ClipItem(x, y){
	Global RunningToggle
	BlockInput, MouseMove
	Backup := Clipboard
	Clipboard := ""
	Item := ""
	MouseMove, x, y
	; Sleep, 105+(ClipLatency*15)
	Send ^!c
	ClipWait, 0.1
	If ErrorLevel
	{
		Sleep, 120+(ClipLatency*15)
		Send ^!c
		ClipWait, 0.1
		If (ErrorLevel && ItemParseActive)
			Clipboard := Backup
	}
	Clip_Contents := Clipboard
	Clipboard := Backup
	Item := new ItemScan
	BlockInput, MouseMoveOff
	Return
}
; WisdomScroll - Identify Item at Coord
WisdomScroll(x, y){
	BlockInput, MouseMove
	Found := False
	For C, vv in WR.Restock {
		For R, v in vv {
			If (!v.Normal && v.RestockName = "Wisdom"){
				Found := True
				Break 2
			}
		}
	}
	If !Found {
		Notify("Missing Configuration","Assign an inventory slot to Wisdom Scrolls`nMake sure to select Ignore or Restock")
		Log("Error","Wisdom Scroll is not configured in inventory slot options","Please configure the slot in your inventory from which to draw Wisdom Scrolls","The slot must be configured to Restock or Ignore and select Wisdom in the dropdown menu")
		Return False
	}
	Log("Currency","Applying Wisdom onto item at " x "," y)
	XX := InventoryGridX[C], YY := InventoryGridY[R]
	o := RandClick(XX,YY)
	RightClick(o.X,o.Y)
	Sleep, 30
	LeftClick(x,y)
	BlockInput, MouseMoveOff
	return
}
