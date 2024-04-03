; Wingman Crafting Labels - By DanMarzola

RowNumber := 0

ItemCraftingNamingMaping(Content)
{
  Output := ""
  Content := StrSplit(Content, " | ")
  for k, v in Content{
    if (v ~= "increased Quantity of Items found in this Area" || v ~= "increased Rarity of Items found in this Area" || v ~= "increased Pack size"){
      Continue
    }Else{
      Output .= v . (k==Content.Length()?"":" | ")
    }
  }

  Return Output
}

RefreshMapList()
{
  AffixName:= ""
  Mods := LoadOnDemand("Maps","top_tier_map")
  For k, v in Mods
  {
    LV_Add("",v["generation_type"],v["name"],ItemCraftingNamingMaping(v["text"]),v["weight"],"Good","1")
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
        LV_Modify(Index,"Check",,,,,v["Mod Type"],v["Weight"])
    }
  }
  ;; Style
  Loop % LV_GetCount("Column")
    LV_ModifyCol(A_Index,"AutoHdr")
  LV_ModifyCol(1, "Sort")
  Return
}

RefreshHeistList()
{
  AffixName:= ""
  Mods := LoadOnDemand("Contracts","Contracts")
  For k, v in Mods
  {
    LV_Add("","Contracts",v["generation_type"],v["name"],ItemCraftingNamingMaping(v["text"]),v["weight"],"Good","1")
  }
  Mods := LoadOnDemand("Blueprints","Blueprints")
  For k, v in Mods
  {
    LV_Add("","Blueprints",v["generation_type"],v["name"],ItemCraftingNamingMaping(v["text"]),v["weight"],"Good","1")
  }
  Mods := []
  ;;Check Box
  Loop % LV_GetCount()
  {
    Index := A_Index
    LV_GetText(OutputVar, A_Index , 2)
    For k, v in WR.CustomMapMods.HeistMods
    {
      If (v["Map Affix"] == OutputVar)
        LV_Modify(Index,"Check",,,,,,v["Mod Type"],v["Weight"])
    }
  }
  ;; Style
  Loop % LV_GetCount("Column")
    LV_ModifyCol(A_Index,"AutoHdr")
  LV_ModifyCol(1, "Sort")
  Return
}

CustomMapModsUI:
  Gui, CustomMapModsUI: New
  Gui, CustomMapModsUI: Default
  Gui, CustomMapModsUI: +AlwaysOnTop -MinimizeBox
  Gui, CustomMapModsUI: Add, ListView , w1200 h350 -wrap -Multi Grid Checked gMyListViewMap vlistview1, Affix Type|Affix Name|Detail|Mod Weight|Mod Type|Weight
  RefreshMapList()
  Gui, CustomMapModsUI: Add, Button, gSaveMapData x+5 w120 h30 center, Save Map Modifiers
  Gui, CustomMapModsUI: Add, Button, gResetMapData w120 h30 center, Reset Map Modifiers
  Gui, CustomMapModsUI: Show, , Custom Map Mods
Return

CustomHeistModsUI:
  Gui, CustomMapModsUI: New
  Gui, CustomMapModsUI: Default
  Gui, CustomMapModsUI: +AlwaysOnTop -MinimizeBox
  Gui, CustomMapModsUI: Add, ListView , w1200 h350 -wrap -Multi Grid Checked gMyListViewHeist vlistview1, Affix Type|Affix Name|Detail|Mod Weight|Mod Type|Weight
  RefreshHeistList()
  Gui, CustomMapModsUI: Add, Button, gSaveHeistData x+5 w120 h30 center, Save Heist Modifiers
  Gui, CustomMapModsUI: Add, Button, gResetHeistData w120 h30 center, Reset Heist Modifiers
  Gui, CustomMapModsUI: Show, , Custom Heist
Return

MyListViewMap:
  if (A_GuiEvent = "DoubleClick")
  {
    RowNumber := A_EventInfo
    LV_GetText(OutputVar1, RowNumber,5)
    LV_GetText(OutputVar2, RowNumber,6)
    Gui, CustomUI: New
    Gui, CustomUI: +AlwaysOnTop -MinimizeBox
    Gui, CustomUI: Add, Text,, Mod Type:
    Gui, CustomUI: Add, DropDownList, vCMP_ModType, Good|Bad|Impossible
    GuiControl, ChooseString, CMP_ModType, %OutputVar1%
    Gui, CustomUI: Add, Text,,Weight:
    Gui, CustomUI: Add, Edit, Number w40, %OutputVar2%
    Gui, CustomUI: Add, UpDown,Range1-100 vCMP_Weight, %OutputVar2%
    Gui, CustomUI: Add, Button, gSaveRowLVM y+8 w120 h30 center, Save
    Gui, CustomUI: Show, , Edit Map Mod
  }
Return

MyListViewHeist:
  if (A_GuiEvent = "DoubleClick")
  {
    RowNumber := A_EventInfo
    LV_GetText(OutputVar1, RowNumber,5)
    LV_GetText(OutputVar2, RowNumber,6)
    Gui, CustomUI: New
    Gui, CustomUI: +AlwaysOnTop -MinimizeBox
    Gui, CustomUI: Add, Text,, Mod Type:
    Gui, CustomUI: Add, DropDownList, vCMP_ModType, Good|Bad|Impossible
    GuiControl, ChooseString, CMP_ModType, %OutputVar1%
    Gui, CustomUI: Add, Text,,Weight:
    Gui, CustomUI: Add, Edit, Number w40, %OutputVar2%
    Gui, CustomUI: Add, UpDown,Range1-100 vCMP_Weight, %OutputVar2%
    Gui, CustomUI: Add, Button, gSaveRowLVM y+8 w120 h30 center, Save
    Gui, CustomUI: Show, , Edit Map Mod
  }
Return

SaveRowLVM:
  Gui, CustomUI: Submit, NoHide
  Gui, CustomMapModsUI:Default
  LV_Modify(RowNumber,,,,,,CMP_ModType,CMP_Weight)
  Gui, CustomUI: Hide
Return

SaveMapData:
  Gui, CustomMapModsUI:Default
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

ResetMapData:
  Gui, CustomMapModsUI:Default
  Loop % LV_GetCount()
    LV_Modify(A_Index,"-Check")
  WR.CustomMapMods.MapMods := []
  Settings("CustomMapMods","Save")
Return

SaveHeistData:
  Gui, CustomHeistModsUI:Default
  TrueIndex:=0
  WR.CustomMapMods.HeistMods := []
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
    WR.CustomMapMods.HeistMods.Push(aux)
  }
  Settings("CustomMapMods","Save")
Return

ResetHeistData:
  Gui, CustomHeistModsUI:Default
  Loop % LV_GetCount()
    LV_Modify(A_Index,"-Check")
  WR.CustomMapMods.HeistMods := []
  Settings("CustomMapMods","Save")
Return
