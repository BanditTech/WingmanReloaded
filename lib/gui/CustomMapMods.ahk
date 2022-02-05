; Wingman Crafting Labels - By DanMarzola

RowNumber := 0

ItemCraftingNamingMaping(Content) 
{
  Output := ""
  Content := RegExReplace(Content,"\<br\/?\>"," | ")
  Content := RegExReplace(Content,"\<.*?\>","")
  Content := RegExReplace(Content,"&ndash;","-")
  Content := StrSplit(Content, " | ")
  for k, v in Content{
    if (v ~= "increased Quantity of Items found in this Area" || v ~= "increased Rarity of Items found in this Area" || v ~= "increased Pack size" || v ~= "^[a-z]" || v ~= "^0\%"){
      Continue
    }Else{
      Output .= (k==1?"":" | ") . v
    }
  }

  Return Output
}

RefreshMapList()
{
  AffixName:= ""
  Mods := LoadOnDemand("Map(TOP)")
    For k, v in Mods["normal"]
    {
      if(v["DropChance"] != 0)
      {
        StringUpper, vi, vi, T
        If(v["ModGenerationTypeID"] == 1){
          AffixName := "Prefix"
        }Else{
          AffixName := "Suffix"
        }
        LV_Add("",AffixName,v["Name"],ItemCraftingNamingMaping(v["str"]),v["DropChance"],"Impossible","1")
      }
    }
  Mods := []
  ;;Check Box
  Loop % LV_GetCount()
  {
    Index := A_Index
    LV_GetText(OutputVar, A_Index , 2)
    For k, v in WR.CustomMapMods.MapMods
    {
      If (v["Map Affix"] == OutputVar)
        LV_Modify(Index,"Check")
    }
  }
  ;; Style
  Loop % LV_GetCount("Column")
    LV_ModifyCol(A_Index,"AutoHdr")
  LV_ModifyCol(1, "Sort")
Return
}

CustomMapModsUI:
  Gui, CustomMapModsUI1: New
  Gui, CustomMapModsUI1: Default
  Gui, CustomMapModsUI1: +AlwaysOnTop -MinimizeBox +LabelCustomUndesirable
  Gui, CustomMapModsUI1: Add, ListView ,  w1200 h350 -wrap -Multi Grid Checked gMyListView vlistview1, Affix Type|Affix Name|Detail|Mod Weight|Mod Type|Weight
  RefreshMapList()
  Gui, CustomMapModsUI1: Add, Button, gSaveData x+5 w120 h30 center, Save Map Modifiers
  Gui, CustomMapModsUI1: Add, Button, gResetData w120 h30 center, Reset Map Modifiers
  Gui, CustomMapModsUI1: Show, , Custom Map Mods
Return


MyListView:
if (A_GuiEvent = "DoubleClick")
{
  RowNumber :=  A_EventInfo
  LV_GetText(OutputVar1, RowNumber,5)
  LV_GetText(OutputVar2, RowNumber,6)
  Gui, CustomMapModsUI2: New
  Gui, CustomMapModsUI2: +AlwaysOnTop -MinimizeBox
  Gui, CustomMapModsUI2: Add, Text,, Mod Type:
  Gui, CustomMapModsUI2: Add, DropDownList, vCMP_ModType, Good|Bad|Impossible
  GuiControl, ChooseString, CMP_ModType, %OutputVar1%
  Gui, CustomMapModsUI2: Add, Text,,Weight:
  Gui, CustomMapModsUI2: Add, Edit, Number w40, %OutputVar2%
  Gui, CustomMapModsUI2: Add, UpDown,Range1-100 vCMP_Weight, %OutputVar2%
  Gui, CustomMapModsUI2: Add, Button, gSaveRowCUM y+8 w120 h30 center, Save
  Gui, CustomMapModsUI2: Show, , Edit Map Mod
}
return

SaveRowCUM:
  Gui, CustomMapModsUI2: Submit, NoHide
  Gui, CustomMapModsUI1:Default
  LV_Modify(RowNumber,,,,,,CMP_ModType,CMP_Weight)
  Gui, CustomMapModsUI2: Hide
return

CustomUndesirableContextMenu:	
Tooltip,% "Clicked " A_GuiEvent " " A_EventInfo
return

SaveData:
Gui, CustomMapModsUI1:Default
  TrueIndex:=0
  WR.CustomMapMods.MapMods := []
  RowNumber := 0
  Loop
  {
    RowNumber := LV_GetNext(RowNumber,"C")
    If not RowNumber
      Break
    TrueIndex++
    LV_GetText(MapAffix, RowNumber, 2)
    LV_GetText(Detail, RowNumber, 3)
    LV_GetText(ModType, RowNumber, 5)
    LV_GetText(Weight, RowNumber, 6)
    aux:={"ID":TrueIndex,"Map Affix":MapAffix,"Map Detail":Detail,"Mod Type":ModType,"Weight":Weight}
    WR.CustomMapMods.MapMods.Push(aux)
  }
  Settings("CustomMapMods","Save")

Return

ResetData:
Gui, CustomMapModsUI1:Default
  Loop % LV_GetCount()
    LV_Modify(A_Index,"-Check")
  WR.CustomMapMods.MapMods := []
  Settings("CustomMapMods","Save")
Return