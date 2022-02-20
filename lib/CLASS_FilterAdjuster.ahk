Class FilterAdjuster {
	Run(FilePath,NewContent,MarkerText:="",PositionalText:=""){
		This.SetFilterFile(FilePath)
		This.SetMarkerText(MarkerText,PositionalText)
		If This.CheckMarkers() {
			This.ReplaceContent(IsObject(NewContent)?This.CompileString(NewContent):NewContent)
			Return True
		} Else {
			Return This.CheckMarkers()
		}
	}
	CompileString(Object){
		string := ""
		For k, v in Object {
			string .= (string?"`r`n":"") v
		}
		Return string
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
		file.WriteLine(This.MarkerText "`r`n")
		file.WriteLine(NewContent)
		file.Write(This.MarkerText)
		file.Write(split.3)
		file.Close()
		This.GetContent()
	}
}