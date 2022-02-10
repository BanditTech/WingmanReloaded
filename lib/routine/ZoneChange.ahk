ZoneChange(){
  Static Changes := 0
	Static OldLoc := 0
	; Zone change can be evaluated for number or in town/hideout or not
	Changes++
	ThisLoc := OnTown || OnHideout
	; Evaluate if we are now in town, and are not coming from a town or hideout
	If (ThisLoc && OldLoc != ThisLoc) {
		CraftingBasesRequest(YesCraftingBaseAutoUpdateOnZone)
	}
	; We store the OldLoc temporarily for custom routines to use
	TempOld := OldLoc
	; Set OldLoc to the new one for next run
	OldLoc := ThisLoc
	#Include *i %A_ScriptDir%\save\MyCustomZoneChange.ahk
}

func(){
  static oldloc := 0
  thisloc := OnHideout || OnTown
  If (thisloc && oldloc != thisloc) {
    otherfuncs()
    oldloc := thisloc
  } Else {
    oldloc := thisloc
  }
}