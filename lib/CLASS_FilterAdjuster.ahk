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
		file := FileOpen(This.FilePath, "w")
		split := StrSplit(This.Content, This.PositionalText)
		file.Write(split.1)
		file.WriteLine(This.PositionalText "`r`n")
		file.WriteLine(This.MarkerText)
		file.Write(This.MarkerText)
		file.Write(split.2)
		file.Close()
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