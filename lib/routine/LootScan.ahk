; LootScan - Finds matching colors under the cursor while key pressed
LootScan(Reset:=0){
		Static LV_LastClick := 0
		Global LootVacuumActive
		If (!ComboHex || Reset)
		{
			ComboHex := Hex2FindText(LootColors,0,0,"",3,3)
			If Reset
				Return
		}
		If (A_TickCount - LV_LastClick <= LVdelay)
			Return
		If (LootVacuumActive&&LootVacuum)
		{
			If AreaScale
			{
				MouseGetPos mX, mY
				ClampGameScreen(x := mX - AreaScale, y := mY - AreaScale)
				ClampGameScreen(xx := mX + AreaScale, yy := mY + AreaScale)
				If (loot := FindText(x,y,xx,yy,0,0,ComboHex,0,0,,,,5))
				{
					ScanPx := loot.1.x + 10, ScanPy := loot.1.y + 10
					, ScanId := loot.1.id
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
					loot := FindText(x,y,xx,yy,0,0,DelveStr,0,0)
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

			}
			Else
			{
				MouseGetPos mX, mY
				PixelGetColor, scolor, mX, mY, RGB
				If (indexOf(scolor,LootColors) )
					If ( LootVacuumActive )
					{
						click %mX%, %mY%
						LV_LastClick := A_TickCount
					}
			}
		}
		Else
			LootVacuumActive := False
	Return

	LootScanCommand:
		If !LootVacuumActive
		{
			LootVacuumActive:=True
		}
		If (LootVacuum && LootVacuumTapZ && !LootVacuumTapZEnd && GuiCheck() && CheckTime("Seconds",LootVacuumTapZSec,"RestackLoot")) {
			Send {z}
			Sleep, 10
			Send {z}
		}
	Return
	LootScanCommandRelease:
		If LootVacuumActive
		{
			LootVacuumActive:=False
		}
		If (LootVacuum && LootVacuumTapZ && LootVacuumTapZEnd && GuiCheck() && CheckTime("Seconds",LootVacuumTapZSec,"RestackLoot")) {
			Send {z}
			Sleep, 10
			Send {z}
		}
	Return

	LootScan_Click:
		LP := GetKeyState("LButton","P"), RP := GetKeyState("RButton","P")
		If (LP || RP)
		{
			If LP
				Click, up
			If RP
				Click, Right, up
			Sleep, 30
		}
		; MouseMove, ScanPx, ScanPy
		BlockInput, MouseMove
		Click %ScanPx%, %ScanPy%
		BlockInput, Mousemoveoff
		If (GetKeyState("RButton","P"))
			Click, Right, down
	Return
}
