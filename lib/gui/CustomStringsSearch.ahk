; Wingman Crafting Labels - By DanMarzola
CustomString:
Global CustomStringBase
StringTextList := ""
StringText := "str"
StringTab := "tab"
textList1 .= JSON.Dump(CustomStrings)
For k, v in CustomStrings
StringTextList .= (!StringTextList ? "" : ", `r`n") CustomStrings[k][StringText] . ",  " . CustomStrings[k][StringTab]

Gui, CustomString: New
Gui, CustomString: +AlwaysOnTop -MinimizeBox
Gui, CustomString: Add, Button, default gupdateEverything    x225 y180  w150 h23,   Save Configuration
Gui, CustomString: Add, Edit, vCustomStringBase xm+5 ym+28 w400
Gui, CustomString: Add, Edit, vCustomStringTaba xm+405 ym+28 w50
Gui, CustomString: Add, UpDown, vCustomStringTab w50
Gui, CustomString: Add, Tab2, vInventoryGuiTabs x3 y3 w600 h300 -wrap , Custom String Search
Gui, CustomString: Tab, Custom String Search
Gui, CustomString: Add, Edit, vCustomStringList ReadOnly y+28 w500 r8 , %StringTextList%
Gui, CustomString: Add, Button, gAddCustomStringBase y+8 w60 r2 center, Add String
Gui, CustomString: Add, Button, gRemoveCustomStringBase x+5 w60 r2 center, Remove String
Gui, CustomString: Add, Button, gResetCustomStringBase x+5 w60 r2 center, Reset All
Gui, CustomString: Show, , Edit Crafting Tiers
Return

AddCustomStringBase:
Gui, Submit, nohide

NewCustomStrings := []
CustomStringIndex := 1
For k, v in CustomStrings
{
  NewCustomString := []
  ThisCustomString := CustomStrings[k]
  If HasVal(ThisCustomString, CustomStringBase)
  {
    MsgBox, Already in your list!
    Return
  }
  NewCustomStrings.InsertAt(CustomStringIndex, "" CustomStringIndex)
  NewCustomStrings[CustomStringIndex] := ThisCustomString

  StringTextList .= (!StringTextList ? "" : ", `r`n") CustomStrings[k][StringText] . ",  " . CustomStrings[k][StringTab]
  CustomStringIndex := CustomStringIndex+1
}

CustomStringBaseArr := []

CustomStringBaseArr[StringText] := CustomStringBase
CustomStringBaseArr[StringTab] := CustomStringTab

NewCustomStrings.Push(CustomStringBaseArr)


GuiControl,, CustomStringList, %StringTextList%
Return

RemoveCustomStringBase:
Gui, Submit, nohide

NewCustomStrings := []
CustomStringIndex := 1
For k, v in CustomStrings
{
  NewCustomString := []
  ThisCustomString := CustomStrings[k]
  If !HasVal(ThisCustomString, CustomStringBase)
  {
    NewCustomStrings.InsertAt(CustomStringIndex, "" CustomStringIndex)
    NewCustomStrings[CustomStringIndex] := ThisCustomString

    StringTextList .= (!StringTextList ? "" : ", `r`n") CustomStrings[k][StringText] . ",  " . CustomStrings[k][StringTab]
    CustomStringIndex := CustomStringIndex+1
  }
}

CustomStringBaseArr := []

CustomStringBaseArr[StringText] := CustomStringBase
CustomStringBaseArr[StringTab] := CustomStringTab

GuiControl,, CustomStringList, %StringTextList%
Return

ResetCustomStringBase:
RegExMatch(A_GuiControl, "T" rxNum " Base", RxMatch )
CustomStringsRes := DefaultCustomStrings.Clone()
textList := ""
For k, v in CustomStringsRes
{
  StringTextList .= (!StringTextList ? "" : ", `r`n") CustomStrings[k][StringText] . ",  " . CustomStrings[k][StringTab]
}
GuiControl,, CustomStringList%RxMatch1%, %textList%
Return
