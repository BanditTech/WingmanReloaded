; Wingman Crafting Labels - By DanMarzola
CustomString:
Global CustomStringBase
StringTextList := ""
StringText := "str"
StringTab := "tab"
For k, v in CustomStringBases
{
  StringTextList .= (!StringTextList ? "" : ", `r`n") . CustomStringBases[k][StringText] . ",  " . CustomStringBases[k][StringTab]
}

Gui, CustomString: New
Gui, CustomString: +AlwaysOnTop -MinimizeBox
Gui, CustomString: Add, Button, default gupdateEverything    x225 y180  w150 h23,   Save Configuration
Gui, CustomString: Add, Edit, vCustomStringBase xm+5 ym+28 w400
Gui, CustomString: Add, Edit, vCustomStringTaba xm+405 ym+28 w50
Gui, CustomString: Add, UpDown, vCustomStringTab Range1-200 w50
Gui, CustomString: Add, Tab2, vInventoryGuiTabs x3 y3 w600 h300 -wrap , Custom String Settings
Gui, CustomString: Tab, Custom String Settings
Gui, CustomString: Add, Edit, vCustomStringList ReadOnly y+28 w500 r8 , %StringTextList%
Gui, CustomString: Add, Button, gAddCustomStringBase y+8 w60 r2 center, Add String
Gui, CustomString: Add, Button, gRemoveCustomStringBase x+5 w60 r2 center, Remove String
Gui, CustomString: Add, Button, gResetCustomStringBase x+5 w60 r2 center, Reset All
Gui, CustomString: Show, , Edit Crafting Tiers
Return

AddCustomStringBase:
Gui, Submit, nohide

StringTextList := ""
NewCustomStrings := []
CustomStringIndex := 1

For k, v in CustomStringBases
{
  NewCustomString := []
  ThisCustomString := CustomStringBases[k]
  If HasVal(ThisCustomString, CustomStringBase)
  {
    Return
  }
  NewCustomStrings.InsertAt(CustomStringIndex, "" CustomStringIndex)
  NewCustomStrings[CustomStringIndex] := ThisCustomString
  CustomStringIndex := CustomStringIndex+1
}

CustomStringBaseArr := []
CustomStringBaseArr[StringText] := CustomStringBase
CustomStringBaseArr[StringTab] := CustomStringTab
NewCustomStrings.Push(CustomStringBaseArr)

For k, v in NewCustomStrings
{
  StringTextList .= (!StringTextList ? "" : ", `r`n") . NewCustomStrings[k][StringText] . ",  " . NewCustomStrings[k][StringTab]
}
CustomStringBases := NewCustomStrings.Clone()
GuiControl,, CustomStringList, %StringTextList%
Return

RemoveCustomStringBase:
Gui, Submit, nohide

StringTextList := ""
NewCustomStrings := []
CustomStringIndex := 1
For k, v in CustomStringBases
{
  NewCustomString := []
  ThisCustomString := CustomStringBases[k]
  If !HasVal(ThisCustomString, CustomStringBase)
  {
    NewCustomStrings.InsertAt(CustomStringIndex, "" CustomStringIndex)
    NewCustomStrings[CustomStringIndex] := ThisCustomString
    CustomStringIndex := CustomStringIndex+1
  }
}

For k, v in NewCustomStrings
{
  StringTextList .= (!StringTextList ? "" : ", `r`n") . NewCustomStrings[k][StringText] . ",  " . NewCustomStrings[k][StringTab]
}
CustomStringBases := NewCustomStrings.Clone()
GuiControl,, CustomStringList, %StringTextList%
Return

ResetCustomStringBase:

StringTextList := ""
NewCustomStrings :=  JSON.Load(DefaultCustomStringBases).Clone()

For k, v in NewCustomStrings
{
  StringTextList .= (!StringTextList ? "" : ", `r`n") . NewCustomStrings[k][StringText] . ",  " . NewCustomStrings[k][StringTab]
}
CustomStringBases := NewCustomStrings.Clone()
GuiControl,, CustomStringList, %StringTextList%
Return
