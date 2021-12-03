#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
  ; #Warn  ; The rest of this area is for global settings
  SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
  SaveDir := RegExReplace(A_ScriptDir, "data$", "save")
  SetWorkingDir %SaveDir%

  Global xpos, ypos, Maxed
  OnMessage(0x115, "OnScroll") ; WM_VSCROLL  ;necessary for scrollable gui windows (must be added before gui lines)
  OnMessage(0x114, "OnScroll") ; WM_HSCROLL  ;necessary for scrollable gui windows (must be added before gui lines)
  Global scriptPOEWingman := "PoE-Wingman.ahk ahk_exe AutoHotkey.exe"
  Global scriptPOEWingmanSecondary := "WingmanReloaded ahk_exe AutoHotkey.exe"
  global POEGameArr := ["PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe", "PathOfExile_KG.exe", "PathOfExile_x64_KG.exe"]
  for n, exe in POEGameArr
    GroupAdd, POEGameGroup, ahk_exe %exe%
  Global CLFStashTabDefault := 1
  IniRead, CLFStashTabDefault, LootFilter.ini, LootFilter, CLFStashTabDefault , 1
  Global LootFilter := {}

  FileRead, JSONtext, %A_ScriptDir%/WR_Prop.json
  temp := JSON.Load(JSONtext)

  textListProp:="" 
  For k, v in temp
    textListProp .= (!textListProp ? "" : "|") v

  FileRead, JSONtext, %A_ScriptDir%/WR_Pseudo.json
  temp := JSON.Load(JSONtext)

  textListAffix:="" 
  For k, v in temp
    textListAffix .= (!textListAffix ? "" : "|") v

  FileRead, JSONtext, %A_ScriptDir%/WR_Affix.json
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


Menu, MyMenuBar, Add, &Load CLF from file, LoadArray
Menu, MyMenuBar, Add ; with no more options, this is a seperator
Menu, MyMenuBar, Add, &Save CLF to file, SaveArray
Menu, MyMenuBar, Add
Menu, MyMenuBar, Add, Add New Group, AddGroup
Menu, MyMenuBar, Add 
Menu, MyMenuBar, Add, Import Group From Clipboard, ImportGroup

LoadArray()

Redraw:
  Gui, +Resize -MinimizeBox +0x300000  ; WS_VSCROLL | WS_HSCROLL  ;necessary for scrollable gui windows 
              ;+Resize (allows resize of windows)
  Gui, Add, Text, Section y+-5 w1 h1
  Tooltip, Building menu... 
  IniRead, Maxed, LootFilter.ini, Settings, Maxed, 0
  IniRead, xpos, LootFilter.ini, Settings, xpos, first
  IniRead, ypos, LootFilter.ini, Settings, ypos, first

  ; Gui, add, button, gAddGroup xs y+20, Add new Group
  Gui, add, DropDownList, gUpdateStashDefault vCLFStashTabDefault xs y+20 w40, %CLFStashTabDefault%||%textListStashTabs%
  Gui, Add, Text, x+5 yp+3 , Assign default stash tab for new or imported groups
  ; Gui, add, button, gPrintout x+10 yp, Print Array
  ;Gui, add, button, gPrintJSON x+10 yp, JSON string
  ; Gui, add, button, gLoadArray x+10 yp-1, Load Loot Filter
  ; Gui, add, button, gSaveArray x+10 yp, Save Loot Filter
  ; Gui, add, button, gImportGroup x+10 yp, Import Loot Filter
  ;Gui, add, button, gRefreshGUI x+10 yp, Refresh Menu
  ;Gui, add, button, gTestEval x+10 yp, Test Eval vs 5
  Gui, Menu, MyMenuBar ; Attach MyMenuBar to the GUI
  Gui, Add, Text, Section xm yp+52 w1 h1

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
  Gui, Add, Text, Section x+45 ym+52 w1 h1
  BuildMenu(100,199)
  }
  if activeGKeys200 
  {
  Gui, Add, Text, Section x+45 ym+52 w1 h1
  BuildMenu(200,999)
  }
  tooltip
  Gui, +AlwaysOnTop
  if ((xpos="first") || !(xpos && ypos))
    Gui, show, w740 h575 ; if first run, show gui at default positon
  else
    Gui, show, w740 h575 x%xpos% y%ypos%
  If (Maxed)
    WinMaximize, LootFilter
  Gui,  +LastFound        ;necessary for scrollable gui windows (allow scrolling with mouse wheel - must be added after gui lines)
  GroupAdd, MyGui, % "ahk_id " . WinExist()    ;necessary for scrollable gui windows (allow scrolling with mouse wheel - must be added after gui lines)
return

RedrawNewGroup:
  Gui,2: -Resize +AlwaysOnTop -DPIScale -MinimizeBox -MaximizeBox  +0x200000  ; WS_VSCROLL | WS_HSCROLL  ;necessary for scrollable gui windows 
              ;+Resize (allows resize of windows)
  Gui,2: Add, Text, Section y+-5 w1 h1
  Gui,2: add, button, gFinishAddGroup xs y+20 HwndFinishButton, Click here to Finish and Return to CLF
  Gui,2: add, button, gRemNewGroup vgroupKey x+100 yp HwndDeleteButton, Delete Group
  Gui,2: add, text, x+55 yp+6 center, Press tab to search the selected keys
  Tooltip, Building menu... 
  BuildNewGroupMenu(groupKey)
  tooltip
  Gui,2: show, w650 h475 , Add or Edit a Group
  DisableCloseButton()
  Gui,2:  +LastFound        ;necessary for scrollable gui windows (allow scrolling with mouse wheel - must be added after gui lines)
  GroupAdd, MyGui, % "ahk_id " . WinExist()    ;necessary for scrollable gui windows (allow scrolling with mouse wheel - must be added after gui lines)
return

DisableCloseButton(hWnd="") 
{
  If hWnd=
    hWnd:=WinExist("A")
  hSysMenu:=DllCall("GetSystemMenu","Int",hWnd,"Int",FALSE)
  nCnt:=DllCall("GetMenuItemCount","Int",hSysMenu)
  DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-1,"Uint","0x400")
  DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-2,"Uint","0x400")
  DllCall("DrawMenuBar","Int",hWnd)
Return ""
}

ImportGroup:
  Gui, Submit, NoHide
  LootFilterEmpty:=0
  Loop, % LootFilter.Count() + 1
  {
    ++LootFilterEmpty
    groupstr := ReplaceDigit000("Group" LootFilterEmpty)
    if LootFilter.HasKey(groupstr)
      continue
    Else
      break
  }
  LootFilter[groupstr] := JSON.Load(Clipboard)
  LootFilter[groupstr]["Data"]["StashTab"]:=CLFStashTabDefault
  Gui, Destroy
  GoSub, Redraw
Return

ChangeButtonNamesVar: 
  IfWinNotExist, Export String
    Return ; Keep waiting.
  SetTimer, ChangeButtonNamesVar, off 
  WinActivate 
  ControlSetText, Button1, Continue, Export String
  ControlSetText, Button2, Duplicate, Export String
Return

ReformatJSON(String)
{
  String := RegExReplace(String, "O`am)(?<!\])(?<!\],)\n *("".*""\: [\d""])", " $1")
  String := RegExReplace(String, "O`am)(?<!\])(?<!\],)(?<!\})\n *(\})", " }")
  String := RegExReplace(String, "O`am)\n *(""~ElementList"")", " $1")
  String := RegExReplace(String, "O`am) *\]\n( *)\}", "$1]}")
  Return String
}

ExportGroup:
  Gui, Submit, NoHide
  StringSplit, buttonstr, A_GuiControl, _
  GKey := buttonstr2
  Clipboard := ReformatJSON(JSON.Dump(LootFilter[GKey],,1))
  SetTimer, ChangeButtonNamesVar, 10
  MsgBox 262147, Export String,% Clipboard "`n`n Copied to the clipboard`n`nPress duplicate button to Add a copy"
  IfMsgBox, Yes
    Return
  IfMsgBox, No
    GoSub, ImportGroup
Return

EditGroup:
  Gui, Submit
  StringSplit, buttonstr, A_GuiControl, _
  Global groupKey := buttonstr2
  Gui, 2: Destroy
  GoSub, RedrawNewGroup
Return

AddGroup:
  Gui, Submit
  LootFilterEmpty:=0
  Loop, % (LootFilter.Count() + 1)
  {
    ++LootFilterEmpty
    groupstr := ReplaceDigit000("Group" LootFilterEmpty)
    if LootFilter.HasKey(groupstr)
      continue
    Else
      break
  }
  LootFilter[groupstr] := {"Prop": [], "Affix": [], "Data":{"OrCount": 1, "StashTab": CLFStashTabDefault}}
  Global groupKey := groupstr
  Gui, 2: Destroy
  GoSub, RedrawNewGroup
Return

FinishAddGroup:
  Gui, Submit
  Gui,2: Destroy
  Gui, 1: Default
  SaveWinPos()
  Gui, Destroy
  GoSub, Redraw
Return


AddNewGroupDDL:
  Gui, Submit, NoHide
  StringSplit, buttonstr, A_GuiControl, %A_Space%
  SKey := buttonstr3
  GKey := buttonstr5
  LootFilter[GKey][SKey].Push({"#Key":"Blank","Eval":">=","Min":0,"OrFlag":0})
  SaveWinPos()
  Gui,2: Destroy
  GoSub, RedrawNewGroup
Return

BuildMenu(Min,Max,AllEdit:=0)
{
  Global
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
      Gui, Add, GroupBox,% " section xs y+15 w675 h" (LootFilter[GKey][SKey].Count() + 1) * 25 ,%SKey%
      Gui, Font, Bold s10 cBlack
      For AKey, Val in selectedItems
      {
        Gui, Add,  Text, w668 xs+5 yp+25 h19, % (LootFilter[GKey][SKey][AKey]["OrFlag"]?"OR ":"") LootFilter[GKey][SKey][AKey]["#Key"] "  " LootFilter[GKey][SKey][AKey]["Eval"] "  " LootFilter[GKey][SKey][AKey]["Min"]
      }
      Gui, Font,
      Gui, add, button, xs yp+25 w1 h1,
    }
    Gui, Add, Text, y+15 , % GKey "  Stash Tab: " LootFilter[GKey]["Data"]["StashTab"] "   OR #: " LootFilter[GKey]["Data"]["OrCount"] "   "
    strLootFilterEdit := "LootFilter_" . GKey . "_Edit"
    Gui, Add, Button, v%strLootFilterEdit% gEditGroup w40 h21 x+0 yp-3, Edit
    strLootFilterExport := "LootFilter_" . GKey . "_Export"
    Gui, Add, Button, v%strLootFilterExport% gExportGroup w40 h21 x+5, Export
    Gui, Add, Button,gRemGroup x+5 yp-1 ,% "Rem: " gkeyarr
    Gui, Font, Bold s10 cBlack
    Gui, Add, GroupBox, % "w685 h" . totalHeight - 15 . " xs-3 yp-" . totalHeight - 45, %GKey%
    Gui, add, button, x+0 y+20 w1 h1,
    Gui, Font
  }
Return
}

BuildNewGroupMenu(GKey)
{
  Global
  For SKey, selectedItems in LootFilter[GKey]
  {
    If ( SKey = "Data" )
      Continue
    Gui,2: Add, GroupBox,% " section xs y+18 w37 h" (LootFilter[GKey][SKey].Count() + 1) * 25 ,% "  OR"
    Gui,2: Add, GroupBox,% " x+2 yp w247 h" (LootFilter[GKey][SKey].Count() + 1) * 25 ,%SKey%
    Gui,2: Add, GroupBox,% " x+2 yp w54 h" (LootFilter[GKey][SKey].Count() + 1) * 25 ,Eval:
    Gui,2: Add, GroupBox,% " x+2 yp w254 h" (LootFilter[GKey][SKey].Count() + 1) * 25 ,Min:
    For AKey, Val in selectedItems
    {
      ; If (InStr(AKey, "Eval") || InStr(AKey, "Min") || InStr(AKey, "OrFlag"))
      ;   Continue
      strLootFilterGSA := "LootFilter_" GKey "_" SKey "_" AKey "_#Key"
      %strLootFilterGSA% := LootFilter[GKey][SKey][AKey]["#Key"]
      strLootFilterGSAEval := "LootFilter_" GKey "_" SKey "_" AKey "_Eval"
      %strLootFilterGSAEval% := LootFilter[GKey][SKey][AKey]["Eval"]
      strLootFilterGSAMin := "LootFilter_" GKey "_" SKey "_" AKey "_Min"
      %strLootFilterGSAMin% := LootFilter[GKey][SKey][AKey]["Min"]
      strLootFilterGSAOrFlag := "LootFilter_" GKey "_" SKey "_" AKey "_OrFlag"
      %strLootFilterGSAOrFlag% := LootFilter[GKey][SKey][AKey]["OrFlag"]
      ischecked := LootFilter[GKey][SKey][AKey]["OrFlag"]
      ;MsgBox % AKey
      Gui,2: Add,  Checkbox, v%strLootFilterGSAOrFlag% gUpdateLootFilterDDL Right checked%ischecked% xs+2 yp+25 ,% ""
      Gui,2: Add,  ComboBox, v%strLootFilterGSA% gUpdateLootFilterDDL x+9 w240, % LootFilter[GKey][SKey][AKey]["#Key"] "||" textList%SKey%
      Gui,2: Add, DropDownList, v%strLootFilterGSAEval% gUpdateLootFilterDDL x+9 w50, % LootFilter[GKey][SKey][AKey]["Eval"] "||" textListEval
      Gui,2: Add, Edit, v%strLootFilterGSAMin% gUpdateLootFilterDDL x+6 w250 h21, % LootFilter[GKey][SKey][AKey]["Min"]
      %strLootFilterGSAMin%_Remove := False
      Gui,2: Add, Button, v%strLootFilterGSAMin%_Remove gRemoveNewMenuItem x+6 w21 h21, X
    }
    Gui,2: add, button, gAddNewGroupDDL xs yp+25, Add new %SKey% to %GKey%
  }
  strLootFilterGroupStash := "LootFilter_" . GKey . "_StashTab"
  %strLootFilterGroupStash% := LootFilter[GKey]["Data"]["StashTab"]
  Gui,2: Add, Text, y+12, %GKey% Stash Tab:
  Gui,2: Add,  DropDownList, v%strLootFilterGroupStash% gUpdateGroupInfo w40 x+5 yp-6, % LootFilter[GKey]["Data"]["StashTab"] "||" textListStashTabs
  strLootFilterGroupOrCount := "LootFilter_" . GKey . "_OrCount"
  %strLootFilterGroupOrCount% := LootFilter[GKey]["Data"]["OrCount"]
  Gui,2: Add, Text, x+5 yp+6, Min OR #:
  Gui,2: Add,  DropDownList, v%strLootFilterGroupOrCount% gUpdateGroupInfo w40 x+5 yp-6, % LootFilter[GKey]["Data"]["OrCount"] "||1|2|3|4|5|6|7|8|9|10|11|12"
  strLootFilterExport := "LootFilter_" . GKey . "_Export"
  Gui,2: Add, Button, v%strLootFilterExport% gExportGroup w60 h21 x+5, Export
  Return
}

LoadArray:
  LoadArray()
  SaveWinPos()
  Gui, Destroy
  GoSub, Redraw
return

LoadArray()
{
  FileRead, JSONtext, LootFilter.json
  LootFilter := JSON.Load(JSONtext)
  If !LootFilter
    LootFilter:={}
Return
}

SaveArray()
{
  SaveArray:
  Gui, Submit, NoHide
  ; JSONtext := ReformatJSON(JSON.Dump(LootFilter,,1))
  JSONtext := ReformatJSON(JSON.Dump(LootFilter,,1))
  ; JSONtext := JSON.Dump(LootFilter,,1)
  FileDelete, LootFilter.json
  FileAppend, %JSONtext%, LootFilter.json
  Return
}

UpdateLootFilterDDL:
  Gui, Submit, NoHide
  StringSplit, buttonstr, A_GuiControl, _
  GKey := buttonstr2
  SKey := buttonstr3
  AKey := buttonstr4
  EKey := buttonstr5
  LootFilter[GKey][SKey][AKey][EKey] := %A_GuiControl%
Return

UpdateGroupInfo:
  Gui, Submit, NoHide
  StringSplit, buttonstr, A_GuiControl, _
  GKey := buttonstr2
  IKey := buttonstr3
  LootFilter[GKey]["Data"][IKey] := %A_GuiControl%
Return

UpdateStashDefault:
  Gui, Submit, NoHide
  IniWrite, %CLFStashTabDefault%, LootFilter.ini, LootFilter, CLFStashTabDefault
Return

RemoveMenuItem:
  Gui, Submit, NoHide
  StringSplit, buttonstr, A_GuiControl, _
  GKey := buttonstr2
  SKey := buttonstr3
  buttonstr4 := RegExReplace(buttonstr4, "Min$", "")
  AKey := buttonstr4
  LootFilter[GKey][SKey].Remove(AKey . "Min")
  LootFilter[GKey][SKey].Remove(AKey . "Eval")
  LootFilter[GKey][SKey].Remove(AKey . "OrFlag")
  LootFilter[GKey][SKey].Remove(AKey)
  SaveWinPos()
  Gui, Destroy
  GoSub, Redraw
Return

RemoveNewMenuItem:
  Gui, Submit, NoHide
  StringSplit, buttonstr, A_GuiControl, _
  GKey := buttonstr2
  SKey := buttonstr3
  buttonstr4 := RegExReplace(buttonstr4, "Min$", "")
  AKey := buttonstr4
  LootFilter[GKey][SKey].Remove(AKey . "Min")
  LootFilter[GKey][SKey].Remove(AKey . "Eval")
  LootFilter[GKey][SKey].Remove(AKey . "OrFlag")
  LootFilter[GKey][SKey].Remove(AKey)
  SaveWinPos()
  Gui,2: Destroy
  GoSub, RedrawNewGroup
Return

RemoveNewGroupMenuItem:
  Gui, Submit, NoHide
  StringSplit, buttonstr, A_GuiControl, _
  GKey := buttonstr2
  SKey := buttonstr3
  buttonstr4 := RegExReplace(buttonstr4, "Min$", "")
  AKey := buttonstr4
  ; LootFilter[GKey][SKey].Remove(AKey . "Min")
  ; LootFilter[GKey][SKey].Remove(AKey . "Eval")
  ; LootFilter[GKey][SKey].Remove(AKey . "OrFlag")
  LootFilter[GKey][SKey].Remove(AKey)
  SaveWinPos()
  Gui,2: Destroy
  GoSub, RedrawNewGroup
Return

RemGroup:
  Gui, Submit, NoHide
  StringSplit, buttonstr, A_GuiControl, %A_Space%
  gnumber := buttonstr2
  GKey := "Group" gnumber

  LootFilter.Remove(GKey)
  SaveWinPos()
  Gui, Destroy
  GoSub, Redraw
Return

RemNewGroup:
  Gui, Submit, NoHide
  GKey := groupKey
  LootFilter.Remove(GKey)
  ; LootFilterTabs.Remove(GKey)
  Gui, 2: Destroy
  SaveWinPos()
  Gui, 1: Default
  Gui, Destroy
  GoSub, Redraw
Return

TestEval:
  Gui, Submit, NoHide
  eval := LootFilter.Group1.Affix.Affix1Eval
  if eval = >
    If (5 > LootFilter.Group1.Affix.Affix1Min)
    MsgBox, Yes
    Else
    MsgBox, No
  else if eval = =
    if (5 = LootFilter.Group1.Affix.Affix1Min)
    MsgBox, Yes
    Else
    MsgBox, No
  else if eval = <
    if (5 < LootFilter.Group1.Affix.Affix1Min)
    MsgBox, Yes
    Else
    MsgBox, No
  else if eval = !=
    if (5 != LootFilter.Group1.Affix.Affix1Min)
    MsgBox, Yes
    Else
    MsgBox, No
  else if eval = ~
    If InStr("365", LootFilter.Group1.Affix.Affix1Min)
    MsgBox, Yes
    Else
    MsgBox, No
Return

Printout:
  Array_Gui(LootFilter)
return

PrintJSON:
  Gui, Submit, NoHide
  arrStr := JSON.Dump(LootFilter,,1)
  MsgBox % arrStr
  arrStr := JSON.Dump(LootFilterTabs,,1)
  MsgBox % arrStr
return

RefreshGUI:
  Gui, Submit, NoHide
  Gui, Destroy
  GoSub, Redraw
Return

GuiSize:
  UpdateScrollBars(A_Gui, A_GuiWidth, A_GuiHeight)

return

ScrollUpLeft:  ;________Scroll Up / Left Edge (prevents blank spaces while adding new controls)_______

  SendMessage, 0x115, 6, 0, ,A     ;moves vertical scroll to windows top (to prevent "blank" areas in gui windows)
          ;"1" means move down ("3" moves down higher)
          ;"0" means move up ("2" moves up higher)
          ;"6" moves top
          ;"7" moves to bottom
          ; "A" may mean for any active windows (yet to be confirmed)

  SendMessage, 0x114, 6, 0, , A    ;moves horizontal scroll to windows left edge (to prevent "blank" areas in gui windows)
          ;"1" means move right ("3" moves right higher)
          ;"0" means move left ("2" moves left higher)
          ;"6" moves left edge
          ;"7" moves to right edge
          ; "A" may mean for any active windows (yet to be confirmed)
  sleep 50
return

ScrollDownRight:  ;________Scroll Down / Right Edge (prevents blank spaces while adding new controls)_______
  sleep 50

  SendMessage, 0x115, 7, 0, ,A     ;moves vertical scroll to windows bottom 
          ;"1" means move down ("3" moves down higher)
          ;"0" means move up ("2" moves up higher)
          ;"6" moves top
          ;"7" moves to bottom
          ; "A" may mean for any active windows (yet to be confirmed)

  SendMessage, 0x114, 7, 0, , A    ;moves horizontal scroll to windows left edge (to prevent "blank" areas in gui windows)
          ;"1" means move right ("3" moves right higher)
          ;"0" means move left ("2" moves left higher)
          ;"6" moves left edge
          ;"7" moves to right edge
          ; "A" may mean for any active windows (yet to be confirmed)

return

#IfWinActive ahk_group MyGui ; Wheel up and down hook
  WheelUp::
  WheelDown::
  +WheelUp::
  +WheelDown::
    ; SB_LINEDOWN=1, SB_LINEUP=0, WM_HSCROLL=0x114, WM_VSCROLL=0x115
    OnScroll(InStr(A_ThisHotkey,"Down") ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, WinExist())
  return
#IfWinActive

UpdateScrollBars(GuiNum, GuiWidth, GuiHeight)
{
  static SIF_RANGE=0x1, SIF_PAGE=0x2, SIF_DISABLENOSCROLL=0x8, SB_HORZ=0, SB_VERT=1
  
  Gui, %GuiNum%:Default
  Gui, +LastFound
  
  ; Calculate scrolling area.
  Left := Top := 9999
  Right := Bottom := 0
  WinGet, ControlList, ControlList
  Loop, Parse, ControlList, `n
  {
    GuiControlGet, c, Pos, %A_LoopField%
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
  VarSetCapacity(si, 28, 0)
  NumPut(28, si) ; cbSize
  NumPut(SIF_RANGE | SIF_PAGE, si, 4) ; fMask
  
  ; Update horizontal scroll bar.
  NumPut(ScrollWidth, si, 12) ; nMax
  NumPut(GuiWidth, si, 16) ; nPage
  DllCall("SetScrollInfo", "uint", WinExist(), "uint", SB_HORZ, "uint", &si, "int", 1)
  
  ; Update vertical scroll bar.
  ; NumPut(SIF_RANGE | SIF_PAGE | SIF_DISABLENOSCROLL, si, 4) ; fMask
  NumPut(ScrollHeight, si, 12) ; nMax
  NumPut(GuiHeight, si, 16) ; nPage
  DllCall("SetScrollInfo", "uint", WinExist(), "uint", SB_VERT, "uint", &si, "int", 1)
  
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
  
  VarSetCapacity(si, 28, 0)
  NumPut(28, si) ; cbSize
  NumPut(SIF_ALL, si, 4) ; fMask
  if !DllCall("GetScrollInfo", "uint", hwnd, "int", bar, "uint", &si)
    return
  
  VarSetCapacity(rect, 16)
  DllCall("GetClientRect", "uint", hwnd, "uint", &rect)
  
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
  NumPut(new_pos, si, 20, "int") ; nPos
  DllCall("SetScrollInfo", "uint", hwnd, "int", bar, "uint", &si, "int", 1)
}

PrintArray(Array, Display:=1, Level:=0)
{
  Gui, Submit, NoHide
  Global PrintArray
  static trailingCharacter := "****"    
  Loop, % 4 + (Level*8)
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
  
  Gui, PrintArray:+MaximizeBox +Resize
  Gui, PrintArray:Font, s9, Courier New
  Gui, PrintArray:Add, Edit, x12 y10 w450 h350 vPrintArray ReadOnly HScroll, %Output%
  Gui, PrintArray:Show, w476 h374, PrintArray
  Gui, PrintArray:+LastFound
  ControlSend, , {Right}
  WinWaitClose
  Return Output

  PrintArrayGuiSize:
    ;Anchor("PrintArray", "wh")
  Return

  PrintArrayGuiClose:
  Gui, PrintArray:Destroy
  Return
}
; Send one or two digits to a sub-script 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SendMSG(wParam:=0, lParam:=0){
  SetTitleMatchMode 3
  DetectHiddenWindows On
  if WinExist(scriptPOEWingman) 
    PostMessage, 0x5555, wParam, lParam  ; The message is sent  to the "last found window" due to WinExist() above.
  else if WinExist(scriptPOEWingmanSecondary)
    PostMessage, 0x5555, wParam, lParam  ; The message is sent  to the "last found window" due to WinExist() above.
  else
    MsgBox 262147, Either Script Window Not Found
  DetectHiddenWindows Off  ; Must not be turned off until after PostMessage.
  Return
}

SaveWinPos()
{
  WinGet, Maxed, MinMax, LootFilter.ahk
  WinGetPos, xpos, ypos
  IniWrite, %Maxed%, LootFilter.ini, Settings, Maxed
  If !Maxed
  {
    IniWrite, %xpos%, LootFilter.ini, Settings, xpos
    IniWrite, %ypos%, LootFilter.ini, Settings, ypos
  }
Return
}

GuiEscape:
GuiClose:
  WinGet, Maxed, MinMax, LootFilter.ahk
  WinGetPos, xpos, ypos
  IniWrite, %Maxed%, LootFilter.ini, Settings, Maxed
  If !Maxed
  {
    IniWrite, %xpos%, LootFilter.ini, Settings, xpos
    IniWrite, %ypos%, LootFilter.ini, Settings, ypos
  }
  SendMSG(1)
ExitApp

ReplaceDigit000(Name:="Group1"){
  Return "Group" . Format("{1:03i}",StrSplit(Name,," ",6)[6])
}

#Include %A_ScriptDir%\..\lib\ref\JSON.ahk
#Include %A_ScriptDir%\..\lib\ref\DeepClone.ahk
#Include %A_ScriptDir%\..\lib\ref\CBMatchingGUI.ahk
#Include %A_ScriptDir%\..\lib\ref\OrderedAssociativeArray.ahk
#Include %A_ScriptDir%\..\lib\ref\OrderedArray.ahk
#Include %A_ScriptDir%\..\lib\Helpers.ahk
