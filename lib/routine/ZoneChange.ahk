ZoneChange(){
  Static Changes := 0
	Changes++
	If !Mod(Changes,2) {
		CraftingBasesRequest()
	}
}