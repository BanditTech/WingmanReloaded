; Controller functions
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Controller(inputType:="Main")
{
	Static __init__ := XInput_Init()
	Static JoyLHoldCount:=0, JoyRHoldCount:=0,  JoyMultiplier := 4, YAxisMultiplier := .6
	Static x_POVscale := 5, y_POVscale := 5, HeldCountPOV := 0
	Global MainAttackPressedActive, SecondaryAttackPressedActive, MovementHotkeyActive, LootVacuumActive
	Global Controller, Controller_Active, YesOHBFound
	If (inputType = "Main")
	{
		If !Controller("Refresh")
			Return False
		Controller("JoystickL")
		Controller("JoystickR")
		Controller("Buttons")
		Controller("DPad")
	}
	If (inputType = "Refresh")
	{
		if State := XInput_GetState(Controller_Active) 
		{
			; LX,LY,RX,RY,LT,RT,A,B,X,Y,LB,RB,L3,R3,BACK,START,UP,DOWN,LEFT,RIGHT
			Controller.LX             := PercentAxis( State.sThumbLX )
			Controller.LY             := PercentAxis( State.sThumbLY )
			Controller.RX             := PercentAxis( State.sThumbRX )
			Controller.RY             := PercentAxis( State.sThumbRY )
			Controller.LT             := State.bLeftTrigger
			Controller.RT             := State.bRightTrigger
			Controller.UP             := XInputButtonIsDown( "PovUp", State.wButtons )
			Controller.DOWN           := XInputButtonIsDown( "PovDown", State.wButtons )
			Controller.LEFT           := XInputButtonIsDown( "PovLeft", State.wButtons )
			Controller.RIGHT          := XInputButtonIsDown( "PovRight", State.wButtons )
			Controller.Btn.A          := XInputButtonIsDown( "A", State.wButtons )
			Controller.Btn.B          := XInputButtonIsDown( "B", State.wButtons )
			Controller.Btn.X          := XInputButtonIsDown( "X", State.wButtons )
			Controller.Btn.Y          := XInputButtonIsDown( "Y", State.wButtons )
			Controller.Btn.LB         := XInputButtonIsDown( "LB", State.wButtons )
			Controller.Btn.RB         := XInputButtonIsDown( "RB", State.wButtons )
			Controller.Btn.L3         := XInputButtonIsDown( "LStick", State.wButtons )
			Controller.Btn.R3         := XInputButtonIsDown( "RStick", State.wButtons )
			Controller.Btn.BACK       := XInputButtonIsDown( "Back", State.wButtons )
			Controller.Btn.START      := XInputButtonIsDown( "Start", State.wButtons )
			Return True
		}
		Else
		{
			If !DetectJoystick()
				Return False
		}
	}
	Else If (inputType = "JoystickL")
	{
		moveX := DeadZone(Controller.LX)
		moveY := DeadZone(Controller.LY)
		If (moveX || moveY)
		{
			If !GuiStatus("",0)
				MouseMove,% ScrCenter.X + Controller.LX * (ScrCenter.X/100), % ScrCenter.Yadjusted - Controller.LY * (ScrCenter.Y/100)
			Else
				MouseMove,% ScrCenter.X + Controller.LX * (ScrCenter.X/120), % ScrCenter.Yadjusted - Controller.LY * (ScrCenter.Y/120)
			++JoyLHoldCount
			If (!MovementHotkeyActive
			&& JoyLHoldCount > 1
			&& GuiStatus("",0)
			&& ((YesOHB && (YesOHBFound || OnTown)) || !YesOHB) )
			{
				Click, Down
				MovementHotkeyActive := True
			}
			If (YesTriggerUtilityKey && MovementHotkeyActive
			&& (Abs(Controller.LX) >= 60 || Abs(Controller.LY) >= 70 )
			&& JoyLHoldCount > 3
			&& GuiStatus("",0)
			&& ((YesOHB && YesOHBFound) || !YesOHB) )
			{
				Trigger(WR.Utility[TriggerUtilityKey])
			}
		}
		Else
		{
			If MovementHotkeyActive
			{
				Click, Up
				MovementHotkeyActive := False
			}
			JoyLHoldCount := 0
			Return
		}
	}
	Else If (inputType = "JoystickR")
	{
		moveX := DeadZone(Controller.RX)
		moveY := DeadZone(Controller.RY)
		If (moveX || moveY)
		{
			If (GuiStatus("",0) && ((YesOHB && (YesOHBFound || OnTown)) || !YesOHB))
			&& !(Controller.LT || Controller.RT)
				MouseMove,% ScrCenter.X + Controller.RX * (ScrCenter.X/100), % ScrCenter.Yadjusted - Controller.RY * (ScrCenter.Y/100)
			Else
				MouseMove, % Controller.RX, % -Controller.RY,0,R
			++JoyRHoldCount
			If (!MainAttackPressedActive && JoyRHoldCount > 2 && YesTriggerJoystickRightKey)
			&& (GuiStatus("",0) && ((YesOHB && YesOHBFound) || !YesOHB))
			&& !(Controller.LT || Controller.RT)
			{
				SendHotkey(hotkeyControllerJoystickRight,"down")
				MainAttackPressedActive := True
			}
		}
		Else
		{
			If (MainAttackPressedActive && YesTriggerJoystickRightKey)
			{
				SendHotkey(hotkeyControllerJoystickRight,"up")
				MainAttackPressedActive := False
			}
			JoyRHoldCount := 0
			Return
		}
	}
	Else If (inputType = "Buttons")
	{
		Static StateA := 0, StateB := 0, StateX := 0, StateY := 0, StateLB := 0, StateRB := 0, StateL3 := 0, StateR3 := 0, StateBACK := 0, StateSTART := 0
		For Key, s in Controller.Btn
		{
			If (s != State%Key%)
			{
				If (s && State%Key% = 0)
				{
					If (hotkeyControllerButton%Key% = hotkeyLootScan && LootVacuum)
					{
						SendHotkey(hotkeyControllerButton%Key%,"down")
						LootVacuumActive := True
						State%Key% := 1
					}
					Else If (hotkeyControllerButton%Key% = "Logout")
					{
						SetTimer, LogoutCommand, -1
						State%Key% := 1
					}
					Else If (hotkeyControllerButton%Key% = "PopFlasks")
					{
						SetTimer, PopFlasks, -1
						State%Key% := 1
					}
					Else If (hotkeyControllerButton%Key% = "QuickPortal")
					{
						SetTimer, QuickPortal, -1
						State%Key% := 1
					}
					Else If (hotkeyControllerButton%Key% = "GemSwap")
					{
						SetTimer, GemSwap, -1
						State%Key% := 1
					}
					Else If (hotkeyControllerButton%Key% = "ItemSort")
					{
						SetTimer, ItemSortCommand, -1
						State%Key% := 1
					}
					Else If (hotkeyControllerButton%Key% = hotkeyMainAttack)
					{
						SendHotkey(hotkeyControllerButton%Key%,"down")
						State%Key% := 1
						MainAttackPressedActive := True
					}
					Else If (hotkeyControllerButton%Key% = hotkeySecondaryAttack)
					{
						SendHotkey(hotkeyControllerButton%Key%,"down")
						State%Key% := 1
						SecondaryAttackPressedActive := True
					}
					Else
					{
						SendHotkey(hotkeyControllerButton%Key%,"down")
						State%Key% := 1
					}
				}
				Else If (!s && State%Key% = 1)
				{
					If (hotkeyControllerButton%Key% = hotkeyLootScan && LootVacuum)
					{
						SendHotkey(hotkeyControllerButton%Key%,"up")
						LootVacuumActive := False
						State%Key% := 0
					}
					Else If (hotkeyControllerButton%Key% = "Logout")
						State%Key% := 0
					Else If (hotkeyControllerButton%Key% = "PopFlasks")
						State%Key% := 0
					Else If (hotkeyControllerButton%Key% = "QuickPortal")
						State%Key% := 0
					Else If (hotkeyControllerButton%Key% = "GemSwap")
						State%Key% := 0
					Else If (hotkeyControllerButton%Key% = "ItemSort")
						State%Key% := 0
					Else If (hotkeyControllerButton%Key% = hotkeyMainAttack)
					{
						SendHotkey(hotkeyControllerButton%Key%,"up")
						State%Key% := 0
						MainAttackPressedActive := 0
					}
					Else If (hotkeyControllerButton%Key% = hotkeySecondaryAttack)
					{
						SendHotkey(hotkeyControllerButton%Key%,"up")
						State%Key% := 0
						SecondaryAttackPressedActive := 0
					}
					Else
					{
						SendHotkey(hotkeyControllerButton%Key%,"up")
						State%Key% := 0
					}
				}
			}
		}
	}
	Else If (inputType = "DPad")
	{
		if (Controller.Up || Controller.Down || Controller.Left || Controller.Right)
		{
			If (GuiStatus("",0) && !YesXButtonFound)
			{
				if (Controller.Up) ; Up
					y_finalPOV := -y_POVscale-HeldCountPOV*2
				else if (Controller.Down) ; Down
					y_finalPOV := +y_POVscale+HeldCountPOV*2
				else
					y_finalPOV := 0
				if (Controller.Left) ; Left
					x_finalPOV := -x_POVscale-HeldCountPOV*2
				else if (Controller.Right) ; Right
					x_finalPOV := +x_POVscale+HeldCountPOV*2
				else
					x_finalPOV := 0
				If (x_finalPOV || y_finalPOV)
				{
					MouseMove, %x_finalPOV%, %y_finalPOV%, 0, R
					HeldCountPOV+=1
				}
			}
			Else
			{
				If Controller.Up
					SnapToInventoryGrid("Up")
				If Controller.Down
					SnapToInventoryGrid("Down")
				If Controller.Left
					SnapToInventoryGrid("Left")
				If Controller.Right
					SnapToInventoryGrid("Right")
			}
		}
		Else If (HeldCountPOV > 1)
		{
			HeldCountPOV := 0
		}
	}
	Return
}
DetectJoystick()
{
	If XInput_GetState(Controller_Active)
		Return Controller_Active
	Else
	{
		Loop, 4
		{
			If XInput_GetState(A_Index)
			{
				Return Controller_Active := A_Index
			}
		}
		Return False
	}
}
DeadZone(val, deadzone:=10){
	Return (Abs(val)<deadzone?False:True)
}
CapRange(var,min:=0,max:=65535){
	return (var > max ? max : (var < min ? min : var))
}
PercentAxis(axisPos){
	If (axisPos = 0)
		Return False
	Else If (axisPos > 0)
		Positive := True
	Else
		Positive := False
	Percentage := Round((axisPos / (Positive?32767:32768)) * 100 ,6)
	Return Percentage 
}
SnapToInventoryGrid(Direction:="Left"){
	Global InvGrid
	Outside := False
	m := UpdateMousePosition()
	If !(OnStash || OnInventory)
		Return False
	If InArea(m.X,m.Y,InvGrid.Corners.Stash.X1,InvGrid.Corners.Stash.Y1,InvGrid.Corners.Stash.X2,InvGrid.Corners.Stash.Y2) && OnStash
	{
		gridArea := "StashQuad"
	}
	Else If InArea(m.X,m.Y,InvGrid.Corners.VendorRec.X1,InvGrid.Corners.VendorRec.Y1,InvGrid.Corners.VendorRec.X2,InvGrid.Corners.VendorRec.Y2) && OnVendor
	{
		gridArea := "VendorRec"
	}
	Else If InArea(m.X,m.Y,InvGrid.Corners.VendorOff.X1,InvGrid.Corners.VendorOff.Y1,InvGrid.Corners.VendorOff.X2,InvGrid.Corners.VendorOff.Y2) && OnVendor
	{
		gridArea := "VendorOff"
	}
	Else If InArea(m.X,m.Y,InvGrid.Corners.Inventory.X1,InvGrid.Corners.Inventory.Y1,InvGrid.Corners.Inventory.X2,InvGrid.Corners.Inventory.Y2) && OnInventory
	{
		gridArea := "Inventory"
	}
	Else If InArea(m.X,m.Y,GameX,GameY,GameX+GameW/2,GameY+GameH) ; On Left
	{
		If OnStash
			gridArea := "StashQuad"
		Else If OnVendor
			gridArea := "VendorOff"
		Else If OnInventory
			gridArea := "Inventory"
		Outside := True
	}
	Else If InArea(m.X,m.Y,GameX+GameW/2,GameY,GameX+GameW,GameY+GameH) ; On Right
	{
		If OnInventory
			gridArea := "Inventory"
		Else If OnStash
			gridArea := "StashQuad"
		Else If OnVendor
			gridArea := "VendorOff"
		Outside := True
	}
	gPos := GridPosition(m.X,m.Y,gridArea)

	If Outside
	{
		MoveToGridPosition(gPos.C,gPos.R,gridArea)
	}
	Else
		MoveToGridPosition(gPos.C,gPos.R,gridArea,Direction)
	return
}
MoveToGridPosition(c,r,gridArea:="StashQuad",Direction:="None"){
	Global InvGrid
	If (gridArea = "VendorOff" && r = 1 && Direction = "Up")
		gridArea := "VendorRec", r := 6
	Else If ( (gridArea = "VendorOff" || gridArea = "VendorRec") && c = 12 && Direction = "Right")
		gridArea := "Inventory", c := 0
	Else If (gridArea = "VendorRec" && r = 5 && Direction = "Down")
		gridArea := "VendorOff", r := 0
	Else If (gridArea = "Inventory" && c = 1 && Direction = "Left")
	{
		If OnStash
			gridArea := "StashQuad", c := 25
		Else If OnVendor
			gridArea := "VendorOff", c := 13
	}
	Else If (gridArea = "StashQuad" && c = 24 && Direction = "Right")
		gridArea := "Inventory", c := 0, r := (r//5>0?r//5:1)

	If (Direction = "Left")
		c := (c-1>0?c-1:c)
	Else If (Direction = "Right")
		c := (c+1<=InvGrid[gridArea].X.Count()?c+1:c)
	Else If (Direction = "Up")
		r := (r-1>0?r-1:r)
	Else If (Direction = "Down")
		r := (r+1<=InvGrid[gridArea].Y.Count()?r+1:r)

	MouseMove,% InvGrid[gridArea].X[c],% InvGrid[gridArea].Y[r]
	Return
}
GridPosition(x,y,gridArea:="StashQuad"){
	Global InvGrid
	sR := InvGrid.SlotSpacing + InvGrid.SlotRadius
	sRQ := InvGrid.SlotSpacing + InvGrid.SlotRadius//2
	Partial := {}
	Best := {"Distance":-1,"C":1,"R":1}

	For C, xVal in InvGrid[gridArea].X
	{
		For R, yVal in InvGrid[gridArea].Y
		{
			If (gridArea = "StashQuad")
			{
				x1:=xVal - sRQ, x2:=xVal + sRQ
				y1:=yVal - sRQ, y2:=yVal + sRQ
			}
			Else
			{
				x1:=xVal - sR, x2:=xVal + sR
				y1:=yVal - sR, y2:=yVal + sR
			}
			If InArea(x,y,x1,y1,x2,y2)
			{
				; Notify("Mouse Exact","Grid C" C " R" R )
				Return {"C":C,"R":R}
			}
			Else
			{
				tempObj := {}
				tempObj.Distance := DistanceTo(x,y,xVal,yVal)
				tempObj.C := C
				tempObj.R := R
				Partial.Push(tempObj)
			}
		}
	}
	For k, match in Partial
	{
		If (Best.Distance = -1 || match.Distance <= Best.Distance)
			Best := match
	}
	Partial := ""
	; Notify("Mouse Closest",Best.Distance " distance is C" Best.C " R" Best.R)
	Return Best
}
InArea(x,y,x1,y1,x2,y2){
	If ( (x >= x1) && (x <= x2) ) && ( (y >= y1) && (y <= y2) )
		Return True
	Else
		Return False
}
DistanceTo(x,y,px,py){
	Return (Abs(x-px) + Abs(y-py))
}
UpdateMousePosition(){
	Global mouseX, mouseY, mouseWin, mouseControl
	MouseGetPos, mouseX, mouseY, mouseWin, mouseControl
	; tooltip, % mouseX " , " mouseY " - " mouseWin " : " mouseControl
	return {"X":mouseX,"Y":mouseY,"hWin":mouseWin,"Ctrl":mouseControl}
}
