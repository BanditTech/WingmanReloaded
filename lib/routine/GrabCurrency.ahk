; GrabCurrency - Get currency fast to use on a white/blue/rare strongbox
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GrabCurrency(){
	GrabCurrencyCommand:
		Critical
		Keywait, Alt
		BlockInput, MouseMove
		MouseGetPos xx, yy
		RandomSleep(45,45)
		If (GrabCurrencyX && GrabCurrencyY)
		{
			If !GuiStatus("OnInventory")
			{
				SendHotkey(hotkeyInventory)
				RandomSleep(45,45)
			}
			RandomSleep(45,45)
			RightClick(GrabCurrencyX, GrabCurrencyY)
			RandomSleep(45,45)
			SendHotkey(hotkeyInventory)
			MouseMove, xx, yy, 0
			BlockInput, MouseMoveOff
		}
return
}
