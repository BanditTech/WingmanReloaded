; Wingman Crafting Labels - By DanMarzola

RowNumber := 0

RefreshList(){
  For k, v in WR.CustomMapMods.CustomMods
  {
    LV_Add("",v["Map Modifier"],v["Mod Type"],v["Weight"])
  }
      
}
Return

CustomUndesirableModsUI:
  Gui, CustomUndesirableModsUI1: New
  Gui, CustomUndesirableModsUI1: Default
  Gui, CustomUndesirableModsUI1: +AlwaysOnTop -MinimizeBox +LabelCustomUndesirable
  Gui, CustomUndesirableModsUI1: Add, ListView ,  w600 h300 -wrap gMyListView vlistview1, Map Modifier|Mod Type|Weight
  RefreshList()
  Gui, CustomUndesirableModsUI1: Add, Button, gNewRow x+5 w120 h30 center, Add New Map Modifier
  Gui, CustomUndesirableModsUI1: Add, Button, gSaveData w120 h30 center, Save Map Modifiers
  Gui, CustomUndesirableModsUI1: Show, , Custom Undesirable Mods Base
Return


MyListView:
if (A_GuiEvent = "DoubleClick")
{
  RowNumber :=  A_EventInfo
  LV_GetText(OutputVar, RowNumber)
  Gui, CustomUndesirableModsUI2: New
  Gui, CustomUndesirableModsUI2: +AlwaysOnTop -MinimizeBox
  Gui, CustomUndesirableModsUI2: Add, Text,,Selected Modifier:
  Gui, CustomUndesirableModsUI2: Add, Edit, w400 r2 vA_Edit gSearch, %OutputVar%
  Gui, CustomUndesirableModsUI2: Add, Button, gSaveRowCUM y+8 w60 h30 center, Save Modifier
  Gui, CustomUndesirableModsUI2: Add, Button, gRemoveRowCUM x+5 w100 h30 center, Remove Modifier
  Gui, CustomUndesirableModsUI2: Show, , Edit Box
}
return

SaveRowCUM:
  if(A_Edit != ""){
    Gui, CustomUndesirableModsUI1:Default
    LV_Modify(RowNumber,,A_Edit)
  }
  Gui, CustomUndesirableModsUI2: Hide
return

CustomUndesirableContextMenu:	
Tooltip,% "Clicked " A_GuiEvent " " A_EventInfo
return

RemoveRowCUM:
  Gui, CustomUndesirableModsUI1:Default
  LV_Delete(RowNumber)
  Gui, CustomUndesirableModsUI2: Hide
return

Search:
  Gui, CustomUndesirableModsUI2: Submit, NoHide
return

SaveData:
Gui, CustomUndesirableModsUI1:Default
WR.CustomMapMods.CustomMods := []
Loop % LV_GetCount()
{
    rowindex := A_Index
    Loop % LV_GetCount(Column){
      LV_GetText(RetrievedText%A_Index%, rowindex, A_Index)
    }
    aux := {"Map Modifier":RetrievedText1,"Mod Type":RetrievedText2,"Weight":RetrievedText3}
    WR.CustomMapMods.CustomMods.Push(aux)
}
submit()
Return

NewRow:
Gui, CustomUndesirableModsUI1:Default
LV_Add("","thebbandit can't be nerfed", "Impossible", "1")
return