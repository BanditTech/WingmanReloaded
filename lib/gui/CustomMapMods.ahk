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
        LV_Add("",AffixName,v["Name"],ItemCraftingNamingMaping(v["str"]),v["DropChance"],"Good","1")
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
          LV_Modify(Index,"Check",,,,,v["Mod Type"],v["Weight"])
      }
    }
    ;; Style
    Loop % LV_GetCount("Column")
      LV_ModifyCol(A_Index,"AutoHdr")
    LV_ModifyCol(1, "Sort")
    Return
  }

  RefreshSextantList()
  {
    AffixName:= ""
    Mods := LoadOnDemand("Sextant")
    aux := ItemCraftingBaseSelector . " Sextant"
    For k, v in Mods
    {
      If(v["Item"] == aux)
      {
        If(RegExMatch(v["Weight"], "`am)default (\d+)",RxMatch)){
          LV_Add("",v["Item"],FirstLineToWRFormat(v["Mod"]),RxMatch1,"Good")
        }Else{
          LV_Add("",v["Item"],FirstLineToWRFormat(v["Mod"]),"0","Good")
        }
      }

    }
    Mods := []
    ;;Check Box
    Loop % LV_GetCount()
    {
      Index := A_Index
      LV_GetText(OutputVar, A_Index , 2)
      For k, v in WR.CustomSextantMods.SextantMods
      {
        If (v["Sextant Enchant"] == OutputVar){
          LV_Modify(Index,"Check",,,,v["Mod Type"])
        }
      }
    }
    ;; Style
    Loop % LV_GetCount("Column")
      LV_ModifyCol(A_Index,"AutoHdr")
    LV_ModifyCol(2,"700")
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

  CustomSextantModsUI:
    Gui, CustomSextantModsUI: New
    Gui, CustomSextantModsUI: Default
    Gui, CustomSextantModsUI: +AlwaysOnTop -MinimizeBox
    Gui, CustomSextantModsUI: Add, ListView , w1200 h350 -wrap -Multi Grid Checked gMyListViewSextant vlistview1, Sextant Type|Sextant Enchant|Mod Weight|Mod Type
    RefreshSextantList()
    Gui, CustomSextantModsUI: Add, Button, gSaveSextantData x+5 w120 h30 center, Save Sextant Modifiers
    Gui, CustomSextantModsUI: Add, Button, gResetSextantData w120 h30 center, Reset Sextant Modifiers
    Gui, CustomSextantModsUI: Show, , Custom Sextant Mods
  Return

  MyListViewSextant:
    if (A_GuiEvent = "DoubleClick")
    {
      RowNumber := A_EventInfo
      LV_GetText(OutputVar1, RowNumber,4)
      Gui, CustomUI: New
      Gui, CustomUI: +AlwaysOnTop -MinimizeBox
      Gui, CustomUI: Add, Text,, Mod Type:
      Gui, CustomUI: Add, DropDownList, vCSP_ModType, Good|Bad
      GuiControl, ChooseString, CSP_ModType, %OutputVar1%
      Gui, CustomUI: Add, Button, gSaveRowLVS y+8 w120 h30 center, Save
      Gui, CustomUI: Show, , Edit Sextant Mod
    }
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

  SaveRowLVM:
    Gui, CustomUI: Submit, NoHide
    Gui, CustomMapModsUI:Default
    LV_Modify(RowNumber,,,,,,CMP_ModType,CMP_Weight)
    Gui, CustomUI: Hide
  Return

  SaveRowLVS:
    Gui, CustomUI: Submit, NoHide
    Gui, CustomSextantModsUI:Default
    LV_Modify(RowNumber,,,,,CSP_ModType)
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
    Gui, CustomSextantModsUI:Default
    Loop % LV_GetCount()
      LV_Modify(A_Index,"-Check")
    WR.CustomMapMods.MapMods := []
    Settings("CustomMapMods","Save")
  Return

  SaveSextantData:
    Gui, CustomSextantModsUI:Default
    TrueIndex:=0
    WR.CustomSextantMods.SextantMods := []
    RowNumber := 0
    Loop
    {
      RowNumber := LV_GetNext(RowNumber,"C")
      If not RowNumber
        Break
      TrueIndex++
      LV_GetText(SextantType, RowNumber, 1)
      LV_GetText(SextantEnchant, RowNumber, 2)
      LV_GetText(ModType, RowNumber, 4)
      aux:={"Sextant Type":SextantType,"Sextant Enchant":SextantEnchant,"Mod Type":ModType}
      WR.CustomSextantMods.SextantMods.Push(aux)
    }
    Settings("CustomSextantMods","Save")
  Return

  ResetSextantData:
    Gui, CustomSextantModsUI:Default
    Loop % LV_GetCount()
      LV_Modify(A_Index,"-Check")
    WR.CustomSextantMods.SextantMods := []
    Settings("CustomSextantMods","Save")
  Return