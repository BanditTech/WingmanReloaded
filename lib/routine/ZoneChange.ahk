ZoneChange(){
	Static Changes := 0
	Static OldLoc := 0

	Strings := []
	; Zone change can be evaluated for number or in town/hideout or not
	Changes++
	ThisLoc := OnTown || OnHideout
	Strings.Push("Zone changed to " currentlocation)
	; Evaluate if we are now in town, and are not coming from a town or hideout
	Strings.Push("This zone is considered a " (OnTown?"Town":OnHideout?"Hideout":"Playable Area"))
	If (ThisLoc && OldLoc != ThisLoc) {
		Strings.Push("Refreshing Crafting Bases")
		RunRefresh := True
	}
	; We store the OldLoc temporarily for custom routines to use
	TempOld := OldLoc
	; Set OldLoc to the new one for next run
	OldLoc := ThisLoc
	Log("Zone Change ",Strings*)
	If (RunRefresh) {
		CraftingBasesRequest(YesCraftingBaseAutoUpdateOnZone)
	}
	#Include *i %A_ScriptDir%\save\MyCustomZoneChange.ahk
}
