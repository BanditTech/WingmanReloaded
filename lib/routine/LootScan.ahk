; LootScan - Finds matching colors under the cursor while key pressed
Global LootVacuumActive := False
LootScan(Reset:=0){
		Static LV_LastClick := 0
		Global LootVacuumActive, ComboHex, ComboHexX, ComboHexY
		Global SetKeyDelayValue1, SetKeyDelayValue2, SetMouseDelayValue, SetDefaultMouseSpeedValue
		Global LootColors, LVdelay, LootVacuum
		Global OnMines, YesLootDelve, YesLootChests, DelveStr, ChestStr
		AreaScale := 15
		MaxArea := 600
		SetKeyDelay(SetKeyDelayValue1, SetKeyDelayValue2, "Play")
		SetMouseDelay(SetMouseDelayValue)
		SetDefaultMouseSpeed(SetDefaultMouseSpeedValue)
		If (!ComboHex || Reset)
		{
			; vary=5 (FindText accuracy 0.95) allows ~12 units of per-channel
			; variance so filter-imported colors (which differ from rendered
			; pixels by ~1-3 units due to PoE's gamma/AA/blending) still match.
			; Manually-resampled exact-pixel values stay well inside this.
			ComboHex := Hex2FindText(LootColors,5,0,"",30,8)
			ComboHexX := Hex2FindText(LootColors,5,0,"",30,1)
			ComboHexY := Hex2FindText(LootColors,5,0,"",1,30)
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
					MouseGetPos(&mX, &mY)
					x := mX - GrowingAreaScale, y := mY - GrowingAreaScale
					ClampGameScreen(&x, &y)
					xx := mX + GrowingAreaScale, yy := mY + GrowingAreaScale
					ClampGameScreen(&xx, &yy)
					If (loot := FindText(&FT_X, &FT_Y, x,y,xx,yy,0,0,ComboHex,0,0,,,,5))
					{
						ScanPx := loot[1].x
						ScanPy := loot[1].y
						width := loot[1].3
						height := loot[1].4
						loot_x := loot[1].1
						loot_xx := loot_x + width
						loot_y := loot[1].2
						loot_yy := loot_y + height

						; FindCenterX
						x1 := loot_x
						x2 := loot_xx
						; FindLeftEdge
						match := loot
						Loop {
							xx := match[1].1
							x := xx - match[1].3
							match := FindText(&FT_X, &FT_Y, x,loot_y,xx,loot_yy,0,0,ComboHexX,0,0,,,,9)
						} Until !match
						x1 := xx
						; FindRightEdge
						match := loot
						Loop {
							x := match[1].1 + match[1].3
							xx := x + match[1].3
							match := FindText(&FT_X, &FT_Y, x,loot_y,xx,loot_yy,0,0,ComboHexX,0,0,,,,9)
						} Until !match
						x2 := x
						ScanPx := (x1 + x2) / 2

						; FindCenterY
						x := x1, y := loot_y - 22
						ClampGameScreen(&x, &y)
						xx := x1 + 10, yy := loot_yy + 22
						ClampGameScreen(&xx, &yy)
						if (match := FindText(&FT_X, &FT_Y, x,y,xx,yy,0,0,ComboHexY,0,0,,,,9))
							ScanPy := match[1].y

						If ( LootVacuumActive )
							LootScan_Click()
						LV_LastClick := A_TickCount
						Return
					}
					If OnMines && YesLootDelve
					{
						MouseGetPos(&mX, &mY)
						x := mX - (AreaScale + 80), y := mY - (AreaScale + 80)
						ClampGameScreen(&x, &y)
						xx := mX + (AreaScale + 80), yy := mY + (AreaScale + 80)
						ClampGameScreen(&xx, &yy)
						loot := FindText(&FT_X, &FT_Y, x,y,xx,yy,0.1,0.1,DelveStr,0,0)
					}
					Else If YesLootChests
					{
						MouseGetPos(&mX, &mY)
						x := mX - (AreaScale + 80), y := mY - (AreaScale + 80)
						ClampGameScreen(&x, &y)
						xx := mX + (AreaScale + 80), yy := mY + (AreaScale + 80)
						ClampGameScreen(&xx, &yy)
						loot := FindText(&FT_X, &FT_Y, x,y,xx,yy,0.1,0.1,ChestStr,0,0)
					}
					If (loot)
					{
						ScanPx := loot[1].1, ScanPy := loot[1].y
						, ScanPy += 30
						If (OnMines && !(loot[1].id ~= "cache" || loot[1].id ~= "vein"))
							ScanPx += loot[1].3
						LootScan_Click()
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

		MouseMove(ScanPx, ScanPy)
		Sleep(10)

		Click(ScanPx " " ScanPy)
		BlockInput("Mousemoveoff")
		If (GetKeyState("RButton","P"))
			Click("Right down")
	}
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
