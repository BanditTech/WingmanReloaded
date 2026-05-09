  SaveDir := RegExReplace(A_ScriptDir, "data$", "save")
  SetWorkingDir(SaveDir)

  Global xpos, ypos, Maxed
  OnMessage(0x115, OnScroll) ; WM_VSCROLL  ;necessary for scrollable gui windows (must be added before gui lines)
  OnMessage(0x114, OnScroll) ; WM_HSCROLL  ;necessary for scrollable gui windows (must be added before gui lines)
  Global scriptPOEWingman := "PoE-Wingman.ahk ahk_exe AutoHotkey.exe"
  Global scriptPOEWingmanSecondary := "WingmanReloaded ahk_exe AutoHotkey.exe"
  global POEGameArr := ["PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe", "PathOfExile_KG.exe", "PathOfExile_x64_KG.exe"]
  for n, exe in POEGameArr
    GroupAdd("POEGameGroup", "ahk_exe " exe)
  Global CLFStashTabDefault := 1
  CLFStashTabDefault := IniRead("LootFilter.ini", "LootFilter", "CLFStashTabDefault", 1)
  Global LootFilter := {}

  JSONtext := FileRead(A_ScriptDir "/WR_Prop.json")
  temp := JSON.Load(JSONtext)

  textListProp:=""
  For k, v in temp
    textListProp .= (!textListProp ? "" : "|") v

  JSONtext := FileRead(A_ScriptDir "/WR_Pseudo.json")
  temp := JSON.Load(JSONtext)

  textListAffix:=""
  For k, v in temp
    textListAffix .= (!textListAffix ? "" : "|") v

  JSONtext := FileRead(A_ScriptDir "/WR_Affix.json")
  temp := JSON.Load(JSONtext)

  For k, v in temp
    textListAffix .= (!textListAffix ? "" : "|") v

  JSONtext := temp := ""

  Eval := [ "<","<=","=","!=",">=",">","~","~=",">0<",">0<=" ]
  textListEval:=""
  For k, v in Eval
    textListEval .= (!textListEval ? "" : "|") v
  StashTabs := [-2]
  Loop 99
    StashTabs.Push(A_Index)
  textListStashTabs:=""
  For k, v in StashTabs
    textListStashTabs .= (!textListStashTabs ? "" : "|") v


  MyMenuBar := MenuBar()
  MyMenuBar.Add("&Load CLF from file", LoadArray_Menu)
  MyMenuBar.Add() ; with no more options, this is a seperator
  MyMenuBar.Add("&Save CLF to file", SaveArray_Menu)
  MyMenuBar.Add()
  MyMenuBar.Add("Add New Group", AddGroup)
  MyMenuBar.Add()
  MyMenuBar.Add("Import Group From Clipboard", ImportGroup)

  LoadArray()

Redraw(*) {
  Global LootFilterGui, xpos, ypos, Maxed, CLFStashTabDefault, LootFilter
  Global textListStashTabs, activeGKeys100, activeGKeys200, MyMenuBar
  LootFilterGui := Gui()
  LootFilterGui.Opt("+Resize -MinimizeBox +0x300000")  ; WS_VSCROLL | WS_HSCROLL  ;necessary for scrollable gui windows
              ;+Resize (allows resize of windows)
  LootFilterGui.Add("Text", "Section y+-5 w1 h1")
  ToolTip("Building menu...")
  Maxed := IniRead("LootFilter.ini", "Settings", "Maxed", 0)
  xpos := IniRead("LootFilter.ini", "Settings", "xpos", "first")
  ypos := IniRead("LootFilter.ini", "Settings", "ypos", "first")

  ; LootFilterGui.Add("Button", "gAddGroup xs y+20", "Add new Group")
  LootFilter_CLFStashTabDefault := LootFilterGui.Add("DropDownList", "xs y+20 w40", CLFStashTabDefault "||" textListStashTabs)
  LootFilter_CLFStashTabDefault.OnEvent("Change", UpdateStashDefault)
  LootFilterGui.Add("Text", "x+5 yp+3", "Assign default stash tab for new or imported groups")
  ; LootFilterGui.Add("Button", "gPrintout x+10 yp", "Print Array")
  ;LootFilterGui.Add("Button", "gPrintJSON x+10 yp", "JSON string")
  ; LootFilterGui.Add("Button", "gLoadArray x+10 yp-1", "Load Loot Filter")
  ; LootFilterGui.Add("Button", "gSaveArray x+10 yp", "Save Loot Filter")
  ; LootFilterGui.Add("Button", "gImportGroup x+10 yp", "Import Loot Filter")
  ;LootFilterGui.Add("Button", "gRefreshGUI x+10 yp", "Refresh Menu")
  ;LootFilterGui.Add("Button", "gTestEval x+10 yp", "Test Eval vs 5")
  LootFilterGui.MenuBar := MyMenuBar ; Attach MyMenuBar to the GUI
  LootFilterGui.Add("Text", "Section xm yp+52 w1 h1")

  activeGKeys100 := False
  activeGKeys200 := False
  For GKey, Groups in LootFilter
  {
    gkeyarr := StrSplit(GKey, , , 6)

    if (gkeyarr[6] > 99 && gkeyarr[6] < 200)
      activeGKeys100 := True
    else if (gkeyarr[6] > 199 && gkeyarr[6] < 999)
      activeGKeys200 := True
  }

  BuildMenu(1,99)
  if activeGKeys100
  {
  LootFilterGui.Add("Text", "Section x+45 ym+52 w1 h1")
  BuildMenu(100,199)
  }
  if activeGKeys200
  {
  LootFilterGui.Add("Text", "Section x+45 ym+52 w1 h1")
  BuildMenu(200,999)
  }
  ToolTip()
  LootFilterGui.Opt("+AlwaysOnTop")
  LootFilterGui.OnEvent("Size", GuiSize)
  LootFilterGui.OnEvent("Close", GuiClose)
  LootFilterGui.OnEvent("Escape", GuiEscape)
  if ((xpos="first") || !(xpos && ypos))
    LootFilterGui.Show("w740 h575") ; if first run, show gui at default positon
  else
    LootFilterGui.Show("w740 h575 x" xpos " y" ypos)
  If (Maxed)
    WinMaximize("LootFilter")
  LootFilterGui.Opt("+LastFound")        ;necessary for scrollable gui windows (allow scrolling with mouse wheel - must be added after gui lines)
  GroupAdd("MyGui", "ahk_id " . WinExist())    ;necessary for scrollable gui windows (allow scrolling with mouse wheel - must be added after gui lines)
}

RedrawNewGroup(*) {
  Global LootFilterGui2, groupKey
  LootFilterGui2 := Gui()
  LootFilterGui2.Opt("-Resize +AlwaysOnTop -DPIScale -MinimizeBox -MaximizeBox +0x200000")  ; WS_VSCROLL | WS_HSCROLL  ;necessary for scrollable gui windows
              ;+Resize (allows resize of windows)
  LootFilterGui2.Add("Text", "Section y+-5 w1 h1")
  btnFinish := LootFilterGui2.Add("Button", "xs y+20", "Click here to Finish and Return to CLF")
  btnFinish.OnEvent("Click", FinishAddGroup)
  FinishButton := btnFinish.Hwnd
  btnDelete := LootFilterGui2.Add("Button", "x+100 yp", "Delete Group")
  btnDelete.OnEvent("Click", RemNewGroup)
  DeleteButton := btnDelete.Hwnd
  LootFilterGui2.Add("Text", "x+55 yp+6 center", "Press tab to search the selected keys")
  ToolTip("Building menu...")
  BuildNewGroupMenu(groupKey)
  ToolTip()
  LootFilterGui2.Show("w650 h475", "Add or Edit a Group")
  DisableCloseButton()
  LootFilterGui2.Opt("+LastFound")        ;necessary for scrollable gui windows (allow scrolling with mouse wheel - must be added after gui lines)
  GroupAdd("MyGui", "ahk_id " . WinExist())    ;necessary for scrollable gui windows (allow scrolling with mouse wheel - must be added after gui lines)
}

DisableCloseButton(hWnd:="")
{
  If hWnd=""
    hWnd:=WinExist("A")
  hSysMenu:=DllCall("GetSystemMenu","Int",hWnd,"Int",False)
  nCnt:=DllCall("GetMenuItemCount","Int",hSysMenu)
  DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-1,"Uint","0x400")
  DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-2,"Uint","0x400")
  DllCall("DrawMenuBar","Int",hWnd)
Return ""
}

ImportGroup(*) {
  Global LootFilter, CLFStashTabDefault
  LootFilterEmpty:=0
  Loop LootFilter.Count() + 1
  {
    ++LootFilterEmpty
    groupstr := ReplaceDigit000("Group" LootFilterEmpty)
    if LootFilter.HasKey(groupstr)
      continue
    Else
      break
  }
  LootFilter[groupstr] := JSON.Load(A_Clipboard)
  LootFilter[groupstr]["Data"]["StashTab"]:=CLFStashTabDefault
  LootFilterGui.Destroy()
  Redraw()
}

ChangeButtonNamesVar(*) {
  if !WinExist("Export String")
    Return ; Keep waiting.
  SetTimer(ChangeButtonNamesVar, 0)
  WinActivate()
  ControlSetText("Continue", "Button1", "Export String")
  ControlSetText("Duplicate", "Button2", "Export String")
}

ReformatJSON(String)
{
  String := RegExReplace(String, "O`am)(?<!\])(?<!\],)\n *("".*""\: [\d""])", " $1")
  String := RegExReplace(String, "O`am)(?<!\])(?<!\],)(?<!\})\n *(\})", " }")
  String := RegExReplace(String, "O`am)\n *(""~ElementList"")", " $1")
  String := RegExReplace(String, "O`am) *\]\n( *)\}", "$1]}")
  Return String
}

ExportGroup(*) {
  Global LootFilter
  LootFilterGui.Submit(0)
  buttonstr := StrSplit(A_GuiControl, "_")
  GKey := buttonstr[2]
  A_Clipboard := ReformatJSON(JSON.Dump(LootFilter[GKey],,1))
  SetTimer(ChangeButtonNamesVar, 10)
  result := MsgBox(A_Clipboard "`n`n Copied to the clipboard`n`nPress duplicate button to Add a copy", "Export String", 262147)
  if result = "Yes"
    Return
  if result = "No"
    ImportGroup()
}

EditGroup(*) {
  Global groupKey, LootFilterGui2
  LootFilterGui.Submit()
  buttonstr := StrSplit(A_GuiControl, "_")
  groupKey := buttonstr[2]
  LootFilterGui2.Destroy()
  RedrawNewGroup()
}

AddGroup(*) {
  Global LootFilter, groupKey, CLFStashTabDefault, LootFilterGui2
  LootFilterGui.Submit()
  LootFilterEmpty:=0
  Loop (LootFilter.Count() + 1)
  {
    ++LootFilterEmpty
    groupstr := ReplaceDigit000("Group" LootFilterEmpty)
    if LootFilter.HasKey(groupstr)
      continue
    Else
      break
  }
  LootFilter[groupstr] := {"Prop": [], "Affix": [], "Data":{"OrCount": 1, "StashTab": CLFStashTabDefault}}
  groupKey := groupstr
  LootFilterGui2.Destroy()
  RedrawNewGroup()
}

FinishAddGroup(*) {
  Global LootFilterGui2
  LootFilterGui.Submit()
  LootFilterGui2.Destroy()
  SaveWinPos()
  LootFilterGui.Destroy()
  Redraw()
}


AddNewGroupDDL(*) {
  Global LootFilter, LootFilterGui2
  LootFilterGui.Submit(0)
  buttonstr := StrSplit(A_GuiControl, A_Space)
  SKey := buttonstr[3]
  GKey := buttonstr[5]
  LootFilter[GKey][SKey].Push({"#Key":"Blank","Eval":">=","Min":0,"OrFlag":0})
  SaveWinPos()
  LootFilterGui2.Destroy()
  RedrawNewGroup()
}

BuildMenu(Min,Max,AllEdit:=0)
{
  Global LootFilter, LootFilterGui
  For GKey, Groups in LootFilter
  {
    totalHeight := 0
    gkeyarr := StrSplit(GKey, , , 6)[6]
    if (gkeyarr < Min) || (gkeyarr > Max)
      Continue
    For SKey, selectedItems in Groups
    {
      If (SKey = "Data")
        Continue
      totalHeight += ((LootFilter[GKey][SKey].Count() + 1) * 25) + 45
      LootFilterGui.Add("GroupBox", " section xs y+15 w675 h" (LootFilter[GKey][SKey].Count() + 1) * 25, SKey)
      LootFilterGui.SetFont("Bold s10 cBlack")
      For AKey, Val in selectedItems
      {
        LootFilterGui.Add("Text", "w668 xs+5 yp+25 h19", (LootFilter[GKey][SKey][AKey]["OrFlag"]?"OR ":"") LootFilter[GKey][SKey][AKey]["#Key"] "  " LootFilter[GKey][SKey][AKey]["Eval"] "  " LootFilter[GKey][SKey][AKey]["Min"])
      }
      LootFilterGui.SetFont()
      LootFilterGui.Add("Button", "xs yp+25 w1 h1",)
    }
    LootFilterGui.Add("Text", "y+15", GKey "  Stash Tab: " LootFilter[GKey]["Data"]["StashTab"] "   OR #: " LootFilter[GKey]["Data"]["OrCount"] "   ")
    btnEdit := LootFilterGui.Add("Button", "w40 h21 x+0 yp-3", "Edit")
    btnEdit.OnEvent("Click", EditGroup)
    btnExport := LootFilterGui.Add("Button", "w40 h21 x+5", "Export")
    btnExport.OnEvent("Click", ExportGroup)
    btnRem := LootFilterGui.Add("Button", "x+5 yp-1", "Rem: " gkeyarr)
    btnRem.OnEvent("Click", RemGroup)
    LootFilterGui.SetFont("Bold s10 cBlack")
    LootFilterGui.Add("GroupBox", "w685 h" . totalHeight - 15 . " xs-3 yp-" . totalHeight - 45, GKey)
    LootFilterGui.Add("Button", "x+0 y+20 w1 h1",)
    LootFilterGui.SetFont()
  }
}

BuildNewGroupMenu(GKey)
{
  Global LootFilter, LootFilterGui2, textListEval
  For SKey, selectedItems in LootFilter[GKey]
  {
    If ( SKey = "Data" )
      Continue
    LootFilterGui2.Add("GroupBox", " section xs y+18 w37 h" (LootFilter[GKey][SKey].Count() + 1) * 25, "  OR")
    LootFilterGui2.Add("GroupBox", " x+2 yp w247 h" (LootFilter[GKey][SKey].Count() + 1) * 25, SKey)
    LootFilterGui2.Add("GroupBox", " x+2 yp w54 h" (LootFilter[GKey][SKey].Count() + 1) * 25, "Eval:")
    LootFilterGui2.Add("GroupBox", " x+2 yp w254 h" (LootFilter[GKey][SKey].Count() + 1) * 25, "Min:")
    For AKey, Val in selectedItems
    {
      ; If (InStr(AKey, "Eval") || InStr(AKey, "Min") || InStr(AKey, "OrFlag"))
      ;   Continue
      ischecked := LootFilter[GKey][SKey][AKey]["OrFlag"]
      ;MsgBox % AKey
      cbOrFlag := LootFilterGui2.Add("Checkbox", "Right checked" ischecked " xs+2 yp+25", "")
      cbOrFlag.OnEvent("Click", UpdateLootFilterDDL)
      cbOrFlag.Name := "LootFilter_" GKey "_" SKey "_" AKey "_OrFlag"
      cbKey := LootFilterGui2.Add("ComboBox", "x+9 w240", LootFilter[GKey][SKey][AKey]["#Key"] "||" textList%SKey%)
      cbKey.OnEvent("Change", UpdateLootFilterDDL)
      cbKey.Name := "LootFilter_" GKey "_" SKey "_" AKey "_#Key"
      ddlEval := LootFilterGui2.Add("DropDownList", "x+9 w50", LootFilter[GKey][SKey][AKey]["Eval"] "||" textListEval)
      ddlEval.OnEvent("Change", UpdateLootFilterDDL)
      ddlEval.Name := "LootFilter_" GKey "_" SKey "_" AKey "_Eval"
      editMin := LootFilterGui2.Add("Edit", "x+6 w250 h21", LootFilter[GKey][SKey][AKey]["Min"])
      editMin.OnEvent("Change", UpdateLootFilterDDL)
      editMin.Name := "LootFilter_" GKey "_" SKey "_" AKey "_Min"
      btnRemove := LootFilterGui2.Add("Button", "x+6 w21 h21", "X")
      btnRemove.OnEvent("Click", RemoveNewMenuItem)
      btnRemove.Name := "LootFilter_" GKey "_" SKey "_" AKey "_Min_Remove"
    }
    btnAddNew := LootFilterGui2.Add("Button", "xs yp+25", "Add new " SKey " to " GKey)
    btnAddNew.OnEvent("Click", AddNewGroupDDL)
  }
  ddlStash := LootFilterGui2.Add("Text", "y+12", GKey " Stash Tab:")
  ddlGroupStash := LootFilterGui2.Add("DropDownList", "w40 x+5 yp-6", LootFilter[GKey]["Data"]["StashTab"] "||" textListStashTabs)
  ddlGroupStash.OnEvent("Change", UpdateGroupInfo)
  ddlGroupStash.Name := "LootFilter_" GKey "_StashTab"
  LootFilterGui2.Add("Text", "x+5 yp+6", "Min OR #:")
  ddlOrCount := LootFilterGui2.Add("DropDownList", "w40 x+5 yp-6", LootFilter[GKey]["Data"]["OrCount"] "||1|2|3|4|5|6|7|8|9|10|11|12")
  ddlOrCount.OnEvent("Change", UpdateGroupInfo)
  ddlOrCount.Name := "LootFilter_" GKey "_OrCount"
  btnExport := LootFilterGui2.Add("Button", "w60 h21 x+5", "Export")
  btnExport.OnEvent("Click", ExportGroup)
  btnExport.Name := "LootFilter_" GKey "_Export"
  Return
}

LoadArray_Menu(*) {
  LoadArray()
  SaveWinPos()
  LootFilterGui.Destroy()
  Redraw()
}

LoadArray()
{
  Global LootFilter
  JSONtext := FileRead("LootFilter.json")
  LootFilter := JSON.Load(JSONtext)
  If !LootFilter
    LootFilter:={}
}

SaveArray_Menu(*) {
  SaveArray()
}

SaveArray()
{
  LootFilterGui.Submit(0)
  ; JSONtext := ReformatJSON(JSON.Dump(LootFilter,,1))
  JSONtext := ReformatJSON(JSON.Dump(LootFilter,,1))
  ; JSONtext := JSON.Dump(LootFilter,,1)
  FileDelete("LootFilter.json")
  FileAppend(JSONtext, "LootFilter.json")
}

UpdateLootFilterDDL(ctrl, *) {
  Global LootFilter
  buttonstr := StrSplit(ctrl.Name, "_")
  GKey := buttonstr[2]
  SKey := buttonstr[3]
  AKey := buttonstr[4]
  EKey := buttonstr[5]
  LootFilter[GKey][SKey][AKey][EKey] := ctrl.Value
}

UpdateGroupInfo(ctrl, *) {
  Global LootFilter
  buttonstr := StrSplit(ctrl.Name, "_")
  GKey := buttonstr[2]
  IKey := buttonstr[3]
  LootFilter[GKey]["Data"][IKey] := ctrl.Value
}

UpdateStashDefault(ctrl, *) {
  Global CLFStashTabDefault
  CLFStashTabDefault := ctrl.Value
  IniWrite(CLFStashTabDefault, "LootFilter.ini", "LootFilter", "CLFStashTabDefault")
}

RemoveMenuItem(*) {
  Global LootFilter
  LootFilterGui.Submit(0)
  buttonstr := StrSplit(A_GuiControl, "_")
  GKey := buttonstr[2]
  SKey := buttonstr[3]
  buttonstr[4] := RegExReplace(buttonstr[4], "Min$", "")
  AKey := buttonstr[4]
  LootFilter[GKey][SKey].Remove(AKey . "Min")
  LootFilter[GKey][SKey].Remove(AKey . "Eval")
  LootFilter[GKey][SKey].Remove(AKey . "OrFlag")
  LootFilter[GKey][SKey].Remove(AKey)
  SaveWinPos()
  LootFilterGui.Destroy()
  Redraw()
}

RemoveNewMenuItem(*) {
  Global LootFilter, LootFilterGui2
  LootFilterGui.Submit(0)
  buttonstr := StrSplit(A_GuiControl, "_")
  GKey := buttonstr[2]
  SKey := buttonstr[3]
  buttonstr[4] := RegExReplace(buttonstr[4], "Min$", "")
  AKey := buttonstr[4]
  LootFilter[GKey][SKey].Remove(AKey . "Min")
  LootFilter[GKey][SKey].Remove(AKey . "Eval")
  LootFilter[GKey][SKey].Remove(AKey . "OrFlag")
  LootFilter[GKey][SKey].Remove(AKey)
  SaveWinPos()
  LootFilterGui2.Destroy()
  RedrawNewGroup()
}

RemoveNewGroupMenuItem(*) {
  Global LootFilter, LootFilterGui2
  LootFilterGui.Submit(0)
  buttonstr := StrSplit(A_GuiControl, "_")
  GKey := buttonstr[2]
  SKey := buttonstr[3]
  buttonstr[4] := RegExReplace(buttonstr[4], "Min$", "")
  AKey := buttonstr[4]
  ; LootFilter[GKey][SKey].Remove(AKey . "Min")
  ; LootFilter[GKey][SKey].Remove(AKey . "Eval")
  ; LootFilter[GKey][SKey].Remove(AKey . "OrFlag")
  LootFilter[GKey][SKey].Remove(AKey)
  SaveWinPos()
  LootFilterGui2.Destroy()
  RedrawNewGroup()
}

RemGroup(*) {
  Global LootFilter
  LootFilterGui.Submit(0)
  buttonstr := StrSplit(A_GuiControl, A_Space)
  gnumber := buttonstr[2]
  GKey := "Group" gnumber

  LootFilter.Remove(GKey)
  SaveWinPos()
  LootFilterGui.Destroy()
  Redraw()
}

RemNewGroup(*) {
  Global LootFilter, groupKey, LootFilterGui2
  LootFilterGui.Submit(0)
  GKey := groupKey
  LootFilter.Remove(GKey)
  ; LootFilterTabs.Remove(GKey)
  LootFilterGui2.Destroy()
  SaveWinPos()
  LootFilterGui.Destroy()
  Redraw()
}

TestEval(*) {
  Global LootFilter
  LootFilterGui.Submit(0)
  eval := LootFilter.Group1.Affix.Affix1Eval
  if eval = ">"
    If (5 > LootFilter.Group1.Affix.Affix1Min)
    MsgBox("Yes")
    Else
    MsgBox("No")
  else if eval = "="
    if (5 = LootFilter.Group1.Affix.Affix1Min)
    MsgBox("Yes")
    Else
    MsgBox("No")
  else if eval = "<"
    if (5 < LootFilter.Group1.Affix.Affix1Min)
    MsgBox("Yes")
    Else
    MsgBox("No")
  else if eval = "!="
    if (5 != LootFilter.Group1.Affix.Affix1Min)
    MsgBox("Yes")
    Else
    MsgBox("No")
  else if eval = "~"
    If InStr("365", LootFilter.Group1.Affix.Affix1Min)
    MsgBox("Yes")
    Else
    MsgBox("No")
}

Printout(*) {
  Array_Gui(LootFilter)
}

PrintJSON(*) {
  Global LootFilter
  LootFilterGui.Submit(0)
  arrStr := JSON.Dump(LootFilter,,1)
  MsgBox(arrStr)
  arrStr := JSON.Dump(LootFilterTabs,,1)
  MsgBox(arrStr)
}

RefreshGUI(*) {
  LootFilterGui.Submit(0)
  LootFilterGui.Destroy()
  Redraw()
}

GuiSize(thisGui, MinMax, Width, Height) {
  UpdateScrollBars(thisGui, Width, Height)
}

ScrollUpLeft(*) {  ;________Scroll Up / Left Edge (prevents blank spaces while adding new controls)_______

  SendMessage(0x115, 6, 0, , "A")     ;moves vertical scroll to windows top (to prevent "blank" areas in gui windows)
          ;"1" means move down ("3" moves down higher)
          ;"0" means move up ("2" moves up higher)
          ;"6" moves top
          ;"7" moves to bottom
          ; "A" may mean for any active windows (yet to be confirmed)

  SendMessage(0x114, 6, 0, , "A")    ;moves horizontal scroll to windows left edge (to prevent "blank" areas in gui windows)
          ;"1" means move right ("3" moves right higher)
          ;"0" means move left ("2" moves left higher)
          ;"6" moves left edge
          ;"7" moves to right edge
          ; "A" may mean for any active windows (yet to be confirmed)
  Sleep(50)
}

ScrollDownRight(*) {  ;________Scroll Down / Right Edge (prevents blank spaces while adding new controls)_______
  Sleep(50)

  SendMessage(0x115, 7, 0, , "A")     ;moves vertical scroll to windows bottom
          ;"1" means move down ("3" moves down higher)
          ;"0" means move up ("2" moves up higher)
          ;"6" moves top
          ;"7" moves to bottom
          ; "A" may mean for any active windows (yet to be confirmed)

  SendMessage(0x114, 7, 0, , "A")    ;moves horizontal scroll to windows left edge (to prevent "blank" areas in gui windows)
          ;"1" means move right ("3" moves right higher)
          ;"0" means move left ("2" moves left higher)
          ;"6" moves left edge
          ;"7" moves to right edge
          ; "A" may mean for any active windows (yet to be confirmed)
}

#HotIf WinActive("ahk_group MyGui") ; Wheel up and down hook
WheelUp::
WheelDown::
+WheelUp::
+WheelDown::
{
    ; SB_LINEDOWN=1, SB_LINEUP=0, WM_HSCROLL=0x114, WM_VSCROLL=0x115
    OnScroll(InStr(A_ThisHotkey,"Down") ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, WinExist())
}
#HotIf

UpdateScrollBars(thisGui, GuiWidth, GuiHeight)
{
  static SIF_RANGE=0x1, SIF_PAGE=0x2, SIF_DISABLENOSCROLL=0x8, SB_HORZ=0, SB_VERT=1

  thisGui.Opt("+LastFound")

  ; Calculate scrolling area.
  Left := Top := 9999
  Right := Bottom := 0
  ControlList := WinGetControls()
  For ctrl in ControlList
  {
    ControlGetPos(&cX, &cY, &cW, &cH, ctrl)
    if (cX < Left)
      Left := cX
    if (cY < Top)
      Top := cY
    if (cX + cW > Right)
      Right := cX + cW
    if (cY + cH > Bottom)
      Bottom := cY + cH
  }
  Left -= 8
  Top -= 8
  Right += 8
  Bottom += 8
  ScrollWidth := Right-Left
  ScrollHeight := Bottom-Top

  ; Initialize SCROLLINFO.
  si := Buffer(28, 0)
  NumPut("UInt", 28, si) ; cbSize
  NumPut("UInt", SIF_RANGE | SIF_PAGE, si, 4) ; fMask

  ; Update horizontal scroll bar.
  NumPut("UInt", ScrollWidth, si, 12) ; nMax
  NumPut("UInt", GuiWidth, si, 16) ; nPage
  DllCall("SetScrollInfo", "uint", WinExist(), "uint", SB_HORZ, "uint", si, "int", 1)

  ; Update vertical scroll bar.
  ; NumPut("UInt", SIF_RANGE | SIF_PAGE | SIF_DISABLENOSCROLL, si, 4) ; fMask
  NumPut("UInt", ScrollHeight, si, 12) ; nMax
  NumPut("UInt", GuiHeight, si, 16) ; nPage
  DllCall("SetScrollInfo", "uint", WinExist(), "uint", SB_VERT, "uint", si, "int", 1)

  x := 0, y := 0
  if (Left < 0 && Right < GuiWidth)
    x := Abs(Left) > GuiWidth-Right ? GuiWidth-Right : Abs(Left)
  if (Top < 0 && Bottom < GuiHeight)
    y := Abs(Top) > GuiHeight-Bottom ? GuiHeight-Bottom : Abs(Top)
  if (x || y)
    DllCall("ScrollWindow", "uint", WinExist(), "int", x, "int", y, "uint", 0, "uint", 0)
}

OnScroll(wParam, lParam, msg, hwnd)
{
  static SIF_ALL=0x17, SCROLL_STEP=10

  bar := msg=0x115 ; SB_HORZ=0, SB_VERT=1

  si := Buffer(28, 0)
  NumPut("UInt", 28, si) ; cbSize
  NumPut("UInt", SIF_ALL, si, 4) ; fMask
  if !DllCall("GetScrollInfo", "uint", hwnd, "int", bar, "uint", si)
    return

  rect := Buffer(16)
  DllCall("GetClientRect", "uint", hwnd, "uint", rect)

  new_pos := NumGet(si, 20, "int") ; nPos

  action := wParam & 0xFFFF
  if action = 0 ; SB_LINEUP
    new_pos -= SCROLL_STEP * 10
  else if action = 1 ; SB_LINEDOWN
    new_pos += SCROLL_STEP * 10
  else if action = 2 ; SB_PAGEUP
    new_pos -= NumGet(rect, 12, "int") - SCROLL_STEP * 10
  else if action = 3 ; SB_PAGEDOWN
    new_pos += NumGet(rect, 12, "int") - SCROLL_STEP * 10
  else if (action = 5 || action = 4) ; SB_THUMBTRACK || SB_THUMBPOSITION
    new_pos := wParam>>16
  else if action = 6 ; SB_TOP
    new_pos := NumGet(si, 8, "int") ; nMin
  else if action = 7 ; SB_BOTTOM
    new_pos := NumGet(si, 12, "int") ; nMax
  else
    return

  min := NumGet(si, 8, "int") ; nMin
  max := NumGet(si, 12, "int") - NumGet(si, 16, "int") ; nMax-nPage
  new_pos := new_pos > max ? max : new_pos
  new_pos := new_pos < min ? min : new_pos

  old_pos := NumGet(si, 20, "int") ; nPos

  x := y := 0
  if bar = 0 ; SB_HORZ
    x := old_pos-new_pos
  else
    y := old_pos-new_pos
  ; Scroll contents of window and invalidate uncovered area.
  DllCall("ScrollWindow", "uint", hwnd, "int", x, "int", y, "uint", 0, "uint", 0)

  ; Update scroll bar.
  NumPut("Int", new_pos, si, 20) ; nPos
  DllCall("SetScrollInfo", "uint", hwnd, "int", bar, "uint", si, "int", 1)
}

PrintArray(Array, Display:=1, Level:=0)
{
  Global PrintArray
  static trailingCharacter := "****"
  Loop 4 + (Level*8)
  Tabs .= A_Space

  Output := "`r`n" . SubStr(Tabs, 5) . "{" . trailingCharacter

  For Key, Value in Array
  {
      If (IsObject(Value))
      {
        Level++
        Value := PrintArray(Value, 0, Level)
        Level--
      }

      Output .= "`r`n" . Tabs . "[" . Key . "] " . Value
  }
  Output .= "`r`n" . SubStr(Tabs, 5) . "}" . trailingCharacter

  If (!Display)
    Return Output

  PrintArrayGui := Gui()
  PrintArrayGui.Opt("+MaximizeBox +Resize")
  PrintArrayGui.SetFont("s9", "Courier New")
  PrintArrayGui.Add("Edit", "x12 y10 w450 h350 ReadOnly HScroll", Output)
  PrintArrayGui.Show("w476 h374", "PrintArray")
  PrintArrayGui.Opt("+LastFound")
  ControlSend("{Right}")
  WinWaitClose()
  Return Output
}
; Send one or two digits to a sub-script
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SendMSG(wParam:=0, lParam:=0){
  SetTitleMatchMode(3)
  DetectHiddenWindows(True)
  if WinExist(scriptPOEWingman)
    PostMessage(0x5555, wParam, lParam)  ; The message is sent  to the "last found window" due to WinExist() above.
  else if WinExist(scriptPOEWingmanSecondary)
    PostMessage(0x5555, wParam, lParam)  ; The message is sent  to the "last found window" due to WinExist() above.
  else
    MsgBox("Either Script Window Not Found", , 262147)
  DetectHiddenWindows(False)  ; Must not be turned off until after PostMessage.
  Return
}

SaveWinPos()
{
  Maxed := WinGetMinMax("LootFilter.ahk")
  WinGetPos(&xpos, &ypos, , , "LootFilter.ahk")
  IniWrite(Maxed, "LootFilter.ini", "Settings", "Maxed")
  If !Maxed
  {
    IniWrite(xpos, "LootFilter.ini", "Settings", "xpos")
    IniWrite(ypos, "LootFilter.ini", "Settings", "ypos")
  }
}

GuiEscape(*) {
  Maxed := WinGetMinMax("LootFilter.ahk")
  WinGetPos(&xpos, &ypos, , , "LootFilter.ahk")
  IniWrite(Maxed, "LootFilter.ini", "Settings", "Maxed")
  If !Maxed
  {
    IniWrite(xpos, "LootFilter.ini", "Settings", "xpos")
    IniWrite(ypos, "LootFilter.ini", "Settings", "ypos")
  }
  SendMSG(1)
  ExitApp()
}

GuiClose(*) {
  Maxed := WinGetMinMax("LootFilter.ahk")
  WinGetPos(&xpos, &ypos, , , "LootFilter.ahk")
  IniWrite(Maxed, "LootFilter.ini", "Settings", "Maxed")
  If !Maxed
  {
    IniWrite(xpos, "LootFilter.ini", "Settings", "xpos")
    IniWrite(ypos, "LootFilter.ini", "Settings", "ypos")
  }
  SendMSG(1)
  ExitApp()
}

ReplaceDigit000(Name:="Group1"){
  Return "Group" . Format("{1:03i}",StrSplit(Name,," ",6)[6])
}

#Include ..\lib\ref\JSON.ahk
#Include ..\lib\ref\DeepClone.ahk
#Include ..\lib\ref\CBMatchingGUI.ahk
#Include ..\lib\ref\OrderedAssociativeArray.ahk
#Include ..\lib\ref\OrderedArray.ahk
#Include ..\lib\Helpers.ahk
