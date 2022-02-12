#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


If (False) { ; Enable or disable menu
	Gui, New
	FontRange := [18,45]

	TypeList := ["Body Armour"
	,"Helmet"
	,"Gloves"
	,"Boots"
	,"Belt"
	,"Amulet"
	,"Rings"
	,"Weapons"]
	height := 230
	width := 185
	For k, slottype in TypeList {

		Gui, Add, Groupbox, % (A_Index=1?"xm ym":!Mod(A_Index-1,3)?"xm ys+" height + 10 :"xs+" width + 5 " ys") " Section h" height " w" width, % slottype
		Gui, Add, Checkbox, xs+5 ys+20, Adjust Font Size
		Gui, Add, Text, xs+5 y+10 w24, Min:
		Gui, Add, Edit, x+5 yp-4 ,100
		Gui, Add, UpDown, Range18-45 , 20
		Gui, Add, Text, x+5 yp+4 , % "Slot% >="
		Gui, Add, Edit, x+5 yp-4 ,100
		Gui, Add, UpDown, Range1-100 , 80
		Gui, Add, Text, xs+5 y+10 w24, Max:
		Gui, Add, Edit, x+5 yp-4 ,100
		Gui, Add, UpDown, Range18-45 , 45
		Gui, Add, Text, x+5 yp+4 , % "Slot% <="
		Gui, Add, Edit, x+5 yp-4 ,100
		Gui, Add, UpDown, Range0-99, 20
		Gui, Add, Text, xs+5 y+10, Item Level Range
		Gui, Add, Text, xs+5 y+10 w24, Min:
		Gui, Add, Edit, x+5 yp-4 , 100
		Gui, Add, UpDown, Range60-100 , 60
		Gui, Add, Text, x+5 yp+4 , Max:
		Gui, Add, Edit, x+5 yp-4 , 100
		Gui, Add, UpDown, Range74-100, 74
		Gui, Add, Edit, xs+5 y+5 , #202020
		Gui, Add, Checkbox, x+5 yp+4, Background Hex
		Gui, Add, Edit, xs+5 y+5 , #202020
		Gui, Add, Checkbox, x+5 yp+4, Border Hex
		Gui, Add, Edit, xs+5 y+5 , #202020
		Gui, Add, Checkbox, x+5 yp+4, Text Hex
		Gui, Add, Checkbox, xs+5 y+8, Disable when full	
	}

	Gui, Add, Groupbox, % "xs+" width + 5 " ys Section h55 w" width, Additional Weapon Options
	Gui, Add, Checkbox, xs+5 ys+15 , Add 2x3 weapons
	Gui, Add, Checkbox, xs+5 y+5 , Add 2x2 weapons
	Gui, Show
}


MarkerText := "# Chaos Recipe"
FilterMarkerText := "#------------------------------------`r`n#   [1001] ILVL 86`r`n#------------------------------------"
FilterMarkerText2 := "#   [1001] ILVL 86"

FileIn := "C:\Users\limited\Documents\My Games\Path of Exile\TestFile.filter"
FileOut := "C:\Users\limited\Documents\My Games\Path of Exile\OutFile.filter"
NewText := "# Lets Replace with this"
Loop, 10
FilterAdjuster.Run(FileOut,NewText)


ExitApp

Class FilterAdjuster {
	Run(FilePath,NewContent,MarkerText:="",PositionalText:=""){
		This.SetFilterFile(FilePath)
		This.SetMarkerText(MarkerText,PositionalText)
		If This.CheckMarkers() {
			This.ReplaceContent(NewContent)
			Return True
		} Else {
			Return This.CheckMarkers()
		}
	}
	SetFilterFile(FilePath){
		This.FilePath := FilePath
		This.GetContent()
	}
	GetContent(){
		This.Content := FileOpen(This.FilePath, "r").Read()
	}
	SetMarkerText(MarkerText:="",PositionalText:=""){
		Static PosText := "#------------------------------------`r`n#   [1001] ILVL 86`r`n#------------------------------------"
		Static Marker := "# Chaos Recipe"
		This.MarkerText := MarkerText ? MarkerText : Marker
		This.PositionalText := PositionalText ? PositionalText : PosText
	}
	CheckMarkers(){
		This.MarkerFlags()
		If (This.MarkerFound)
			Return True
		If (!This.MarkerFound && !This.CanInsert)
			Return "000"
		This.InsertMarkers()
		This.GetContent()
		Return True
	}
	MarkerFlags(){
		This.MarkerFound := False
		If InStr(This.Content, This.MarkerText) {
			This.MarkerFound := True
		} Else If InStr(This.Content, This.PositionalText) {
			This.CanInsert := True
		} Else {
			This.CanInsert := False
		}
	}
	InsertMarkers(){
		file := FileOpen(This.FilePath, "w")
		split := StrSplit(This.Content, This.PositionalText)
		file.Write(split.1)
		file.WriteLine(This.PositionalText "`r`n")
		file.WriteLine(This.MarkerText)
		file.Write(This.MarkerText)
		file.Write(split.2)
		file.Close()
	}
	ReplaceContent(NewContent){
		file := FileOpen(This.FilePath, "w")
		split := StrSplit(This.Content, This.MarkerText)
		file.Write(split.1)
		file.WriteLine(This.MarkerText)
		file.WriteLine(NewContent)
		file.Write(This.MarkerText)
		file.Write(split.3)
		file.Close()
		This.GetContent()
	}
}