CraftBasicPopUp(){
	static _init_ := CraftBasicPopUpBuild()
	Global CraftMenu, RunningToggle
	CheckRunning()

	If !(CraftMenu.Active){
		MouseGetPos itemx, itemy
		CraftMenu.SetKey(hotkeyCraftBasic)
		; CraftMenu.SetKeySpecial("Ctrl")
		selection := CraftMenu.Show()
		MouseMove %itemx%, %itemy%

		If selection
		{
			If DebugMessages
			{
				If (selection = "Maps")
					Notify("Begin Bulk Crafting Maps","",2)
				Else If (selection = "Socket")
					Notify("Socketing Selected Item","",2)
				Else If (selection = "Color")
					Notify("Coloring Selected Item","",2)
				Else If (selection = "Link")
					Notify("Linking Selected Item","",2)
				Else If (selection = "Chance")
					Notify("Chance Selected Item until Unique","Either Bulk mode or Scour",2)
				Else
					Notify("Result is:",selection,2)
			}
			WinActivate, % GameStr
			Crafting(selection)
		}
		Else WinActivate, % GameStr
	}
}
; Build crafting popup menu
CraftBasicPopUpBuild(){
	global hotkeyCraftBasic, CraftMenu
	CraftMenu := new Radial_Menu
	CraftMenu.SetSections("5")
	CraftMenu.Add("Chance","Images/Chance.png", "1")
	CraftMenu.Add("Socket","Images/Jeweller.png", "2")
	CraftMenu.Add("Color","Images/Chromatic.png", "3")
	CraftMenu.Add("Link","Images/Fusing.png", "4")
	CraftMenu.Add("Maps","Images/Maps.png", "5")
	; CraftMenu.Add2("Jeweller","Images/Jeweller.png", "4")
}
