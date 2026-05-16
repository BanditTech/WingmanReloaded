; LootScan - Finds matching colors under the cursor while key pressed
LootScan(Reset:=0){
		SetKeyDelay(SetKeyDelayValue1, SetKeyDelayValue2, "Play")
		SetMouseDelay(SetMouseDelayValue)
		SetDefaultMouseSpeed(SetDefaultMouseSpeedValue)
		Static LV_LastClick := 0
		Global LootVacuumActive
		If (!ComboHex || Reset)
		{
			ComboHex := Hex2FindText(LootColors,0,0,"",30,8)
			ComboHexX := Hex2FindText(LootColors,0,0,"",30,1)
			ComboHexY := Hex2FindText(LootColors,0,0,"",1,30)
			If Reset
				Return
		}
		If (A_TickCount - LV_LastClick <= LVdelay)
			Return
		If (LootVacuumActive&&LootVacuum)
		{
			GrowingAreaScale := AreaScale
				While GrowingAreaScale < MaxArea
				{
					MouseGetPos mX, mY
					ClampGameScreen(x := mX - GrowingAreaScale, y := mY - GrowingAreaScale)
					ClampGameScreen(xx := mX + GrowingAreaScale, yy := mY + GrowingAreaScale)
					If (loot := FindText(x,y,xx,yy,0,0,ComboHex,0,0,,,,5))
					{
						ScanPx := loot.1.x
						ScanPy := loot.1.y
						width := loot[1][3]
						height := loot[1][4]
						loot_x := loot[1][1]
						loot_xx := loot_x + width
						loot_y := loot[1][2]
						loot_yy := loot_y + height
						
						GoSub LootScan_FindCenterX
						GoSub LootScan_FindCenterY

						If ( LootVacuumActive )
							GoSub LootScan_Click
						LV_LastClick := A_TickCount
						Return
					}
					If OnMines && YesLootDelve
					{
						MouseGetPos mX, mY
						ClampGameScreen(x := mX - (AreaScale + 80), y := mY - (AreaScale + 80))
						ClampGameScreen(xx := mX + (AreaScale + 80), yy := mY + (AreaScale + 80))
						loot := FindText(x,y,xx,yy,0.1,0.1,DelveStr,0,0)
					}
					Else If YesLootChests
					{
						MouseGetPos mX, mY
						ClampGameScreen(x := mX - (AreaScale + 80), y := mY - (AreaScale + 80))
						ClampGameScreen(xx := mX + (AreaScale + 80), yy := mY + (AreaScale + 80))
						loot := FindText(x,y,xx,yy,0.1,0.1,ChestStr,0,0)
					}
					If (loot)
					{
						ScanPx := loot.1.1, ScanPy := loot.1.y
						, ScanPy += 30
						If (OnMines && !(loot.Id ~= "cache" || loot.Id ~= "vein"))
							ScanPx += loot.3
						GoSub LootScan_Click
						LV_LastClick := A_TickCount
						Return
					}
					GrowingAreaScale += 69
				}
		}
		Else
			LootVacuumActive := False
	Return

	LootScan_Click() {
		LP := GetKeyState("LButton","P"), RP := GetKeyState("RButton","P")
		If (LP || RP)
		{
			If LP
				Click("up")
			If RP
				Click("Right up")
			Sleep(30)
		}
		BlockInput("MouseMove")

		MouseMove, ScanPx, ScanPy
		Sleep, 10

		Click(ScanPx " " ScanPy)
		BlockInput("Mousemoveoff")
		If (GetKeyState("RButton","P"))
			Click("Right down")
	}

LootScan_FindRightEdge:
		match := loot
		Loop{
			x := match[1][1] + match[1][3]
			xx := x + match[1][3]
			match := FindText(x,loot_y,xx,loot_yy,0,0,ComboHexX,0,0,,,,9)
		} Until match=0
		x2 := x
	Return
	
	LootScan_FindLeftEdge:
		match := loot
		Loop{
			xx := match[1][1]
			x := xx - match[1][3]
			match := FindText(x,loot_y,xx,loot_yy,0,0,ComboHexX,0,0,,,,9)
		} Until match=0
		x1 := xx
	Return

	LootScan_FindCenterX:
		x1 := loot_x
		x2 := loot_xx

		GoSub LootScan_FindLeftEdge
		GoSub LootScan_FindRightEdge
		ScanPx := (x1 + x2) / 2
	Return

	LootScan_FindCenterY:
		ClampGameScreen(x := x1, y := loot_y - 22)
		ClampGameScreen(xx := x1 + 10, yy := loot_yy + 22)
		if match := FindText(x,y,xx,yy,0,0,ComboHexY,0,0,,,,9)
			ScanPy := match.1.y
	Return
}
LootScanCommand(*) {
	Global LootVacuumActive
	If !LootVacuumActive
	{
		LootVacuumActive:=True
	}
	If (LootVacuum && LootVacuumTapZ && !LootVacuumTapZEnd && GuiCheck() && CheckTime("Seconds",LootVacuumTapZSec,"RestackLoot")) {
		Send("{z}")
		Sleep(10)
		Send("{z}")
	}
}
LootScanCommandRelease(*) {
	Global LootVacuumActive
	If LootVacuumActive
	{
		LootVacuumActive:=False
	}
	If (LootVacuum && LootVacuumTapZ && LootVacuumTapZEnd && GuiCheck() && CheckTime("Seconds",LootVacuumTapZSec,"RestackLoot")) {
		Send("{z}")
		Sleep(10)
		Send("{z}")
	}
}
