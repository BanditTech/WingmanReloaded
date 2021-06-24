; GemSwap - Swap gems between two locations
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GemSwap(){
	GemSwapCommand:
		Critical
		Keywait, Alt
		BlockInput, MouseMove
		MouseGetPos xx, yy
		RandomSleep(45,45)

		If !GuiStatus("OnInventory")
		{
			SendHotkey(hotkeyInventory)
			RandomSleep(45,45)
		}
		;First Gem or Item Swap
		If (WR.perChar.Setting.swap1Xa && WR.perChar.Setting.swap1Ya 
		&& WR.perChar.Setting.swap1Xb && WR.perChar.Setting.swap1Yb) 
		{
			If (WR.perChar.Setting.swap1Item)
			{
				LeftClick(WR.perChar.Setting.swap1Xa, WR.perChar.Setting.swap1Ya)
			}
			Else
			{
				RightClick(WR.perChar.Setting.swap1Xa, WR.perChar.Setting.swap1Ya)
			}
			RandomSleep(45,45)
			If (WR.perChar.Setting.swap1AltWeapon)
			{
				SendHotkey(hotkeyWeaponSwapKey)
				RandomSleep(90,120)
			}
			LeftClick(WR.perChar.Setting.swap1Xb, WR.perChar.Setting.swap1Yb)
			RandomSleep(90,120)
			If (WR.perChar.Setting.swap1AltWeapon)
			{
				SendHotkey(hotkeyWeaponSwapKey)
				RandomSleep(90,120)
			}
			LeftClick(WR.perChar.Setting.swap1Xa, WR.perChar.Setting.swap1Ya)
			RandomSleep(90,120)
		}
		;Second Gem of Item Swap
		If (WR.perChar.Setting.swap2Xa && WR.perChar.Setting.swap2Ya 
		&& WR.perChar.Setting.swap2Xb && WR.perChar.Setting.swap2Yb) 
		{
			If (WR.perChar.Setting.swap2Item)
			{
				LeftClick(WR.perChar.Setting.swap2Xa, WR.perChar.Setting.swap2Ya)
			}
			Else
			{
				RightClick(WR.perChar.Setting.swap2Xa, WR.perChar.Setting.swap2Ya)
			}
			RandomSleep(45,45)
			If (WR.perChar.Setting.swap2AltWeapon)
			{
				SendHotkey(hotkeyWeaponSwapKey)
				RandomSleep(90,120)
			}
			LeftClick(WR.perChar.Setting.swap2Xb, WR.perChar.Setting.swap2Yb)
			RandomSleep(90,120)
			If (WR.perChar.Setting.swap2AltWeapon)
			{
				SendHotkey(hotkeyWeaponSwapKey)
				RandomSleep(90,120)
			}
			LeftClick(WR.perChar.Setting.swap2Xa, WR.perChar.Setting.swap2Ya)
			RandomSleep(90,120)
		}
		SendHotkey(hotkeyInventory)
		MouseMove, xx, yy, 0
		BlockInput, MouseMoveOff
	return
}