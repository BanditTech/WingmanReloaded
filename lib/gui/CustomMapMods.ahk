; Wingman Crafting Labels - By DanMarzola

RowNumber := 0

RefreshList(){
  For k, v in WR.CustomMapMods.CustomMods
  {
    if (v["Enable"] == 1){
      LV_Add("Check",v["Map Modifier"],v["Mod Type"],v["Weight"])
    }else{
      LV_Add("",v["Map Modifier"],v["Mod Type"],v["Weight"])
    }
    
  }
  LV_ModifyCol()
  LV_ModifyCol(3, 100)
}
Return

CustomMapModsUI:
  Gui, CustomMapModsUI1: New
  Gui, CustomMapModsUI1: Default
  Gui, CustomMapModsUI1: +AlwaysOnTop -MinimizeBox +LabelCustomUndesirable
  Gui, CustomMapModsUI1: Add, ListView ,  w600 h300 -wrap -Multi Grid Checked gMyListView vlistview1, Map Modifier|Mod Type|Weight
  RefreshList()
  Gui, CustomMapModsUI1: Add, Button, gNewRow x+5 w120 h30 center, Add New Map Modifier
  Gui, CustomMapModsUI1: Add, Button, gSaveData w120 h30 center, Save Map Modifiers
  Gui, CustomMapModsUI1: Add, Button, gResetData w120 h30 center, Reset Map Modifiers
  Gui, CustomMapModsUI1: Show, , Custom Map Mods
Return


MyListView:
if (A_GuiEvent = "DoubleClick")
{
  RowNumber :=  A_EventInfo
  LV_GetText(OutputVar1, RowNumber,1)
  LV_GetText(OutputVar2, RowNumber,2)
  if(OutputVar2 == "Good")
  {
    OutputVar2 := 1
  }else if(OutputVar2 == "Bad"){
    OutputVar2 := 2
  }else if(OutputVar2 == "Impossible"){
    OutputVar2 := 3
  }
  LV_GetText(OutputVar3, RowNumber,3)
  Gui, CustomMapModsUI2: New
  Gui, CustomMapModsUI2: +AlwaysOnTop -MinimizeBox
  Gui, CustomMapModsUI2: Add, Text,, Map Modifier:
  Gui, CustomMapModsUI2: Add, Edit, w400 r2 vA_Edit, %OutputVar1%
  Gui, CustomMapModsUI2: Add, Text,, Mod Type:
  Gui, CustomMapModsUI2: Add, DropDownList, vCMP_ModType Choose%OutputVar2%, Good|Bad|Impossible
  Gui, CustomMapModsUI2: Add, Text,,Weight:
  Gui, CustomMapModsUI2: Add, Edit, Number w40, %OutputVar3%
  Gui, CustomMapModsUI2: Add, UpDown,Range1-100 vCMP_Weight, %OutputVar3%
  Gui, CustomMapModsUI2: Add, Button, gSaveRowCUM y+8 w120 h30 center, Save Modifier
  Gui, CustomMapModsUI2: Add, Button, gRemoveRowCUM x+5 w120 h30 center, Remove Modifier
  Gui, CustomMapModsUI2: Show, , Edit Row %RowNumber%
}
return

SaveRowCUM:
  Gui, CustomMapModsUI2: Submit, NoHide
  msgbox, %A_Edit% %CMP_ModType% %CMP_Weight%
  Gui, CustomMapModsUI1:Default
  LV_Modify(RowNumber,,A_Edit,CMP_ModType,CMP_Weight)
  Gui, CustomMapModsUI2: Hide
return

CustomUndesirableContextMenu:	
Tooltip,% "Clicked " A_GuiEvent " " A_EventInfo
return

RemoveRowCUM:
  Gui, CustomMapModsUI1:Default
  LV_Delete(RowNumber)
  Gui, CustomMapModsUI2: Hide
return


SaveData:
Gui, CustomMapModsUI1:Default
WR.CustomMapMods.CustomMods := []
checkedrow := LV_GetNext(0, "C")
Loop % LV_GetCount()
{
    checked := 0
    rowindex := A_Index
    Loop % LV_GetCount(Column){
      LV_GetText(RetrievedText%A_Index%, rowindex, A_Index)
    }
    if(rowindex == checkedrow){
      checkedrow := LV_GetNext(checkedrow, "C")
      checked := 1
    }
    aux := {"Map Modifier":RetrievedText1,"Mod Type":RetrievedText2,"Weight":RetrievedText3,"Enable": checked}
    WR.CustomMapMods.CustomMods.Push(aux)
    
}
submit()
Return

ResetData:
Gui, CustomMapModsUI1:Default
WR.CustomMapMods.CustomMods := WR.CustomMapMods.Default.Clone()
LV_Delete()
RefreshList()
return

NewRow:
Gui, CustomMapModsUI1:Default
LV_Add("","thebbandit can't be nerfed", "Impossible", "1")
return