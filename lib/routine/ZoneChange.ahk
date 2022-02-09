ZoneChange(){
  Static Changes := 0
	Changes++
	If !Mod(Changes,2) {
		CraftingBasesRequest(YesCraftingBaseAutoUpdateOnStart)
	}
	#Include *i %A_ScriptDir%\save\MyCustomZoneChange.ahk
}