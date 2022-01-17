; Wingman Crafting Labels - By DanMarzola


RowNumber := 0

RefreshList2(){
  For k, v in Bases
  {
    If (IndexOf("str_armour",v["tags"])){
      LV_Add("Check",v["name"],"0",RegexFixLeadingZeros(v["drop_level"]),RegexFixLeadingZeros(v["properties"]["armour"]["min"]),v["properties"]["evasion"]["min"],v["properties"]["energy_shield"]["min"])
    }
  }
}
Return

RegexFixLeadingZeros(content){
Loop, 2
{
	content := RegExReplace(content, "(?<!\d)\d(?!\d)", "00$0")
	content := RegExReplace(content, "(?<!\d)\d{2}(?!\d)", "0$0")
}
return content
}


CustomCraftingBaseUI:
  Gui, CustomCraftingBaseUI1: New
  Gui, CustomCraftingBaseUI1: Default
  Gui, CustomCraftingBaseUI1: +AlwaysOnTop -MinimizeBox +LabelCustomUndesirable
  Gui, CustomCraftingBaseUI1: Add, ListView ,  w600 h300 -wrap -Multi Grid Checked gMyListView vlistview1, Base Name|Max ILvL Found|Drop Level|Base Armour|Base Evasion|Base ES
  RefreshList2()
  Gui, CustomCraftingBaseUI1: Add, Button, gNewRow x+5 w120 h30 center, Add New Map Modifier
  Gui, CustomCraftingBaseUI1: Add, Button, gSaveData w120 h30 center, Save Map Modifiers
  Gui, CustomCraftingBaseUI1: Add, Button, gResetData w120 h30 center, Reset Map Modifiers
  Gui, CustomCraftingBaseUI1: Show, , Custom Map Mods
Return


CustomCrafting:
  Global CustomCraftingBase
  textList1 := ""
  For k, v in WR.CustomCraftingBases.CustomBases[1]
    textList1 .= (!textList1 ? "" : ", ") v.BaseName
  baseList := ""
  textList2 := ""
  For k, v in WR.CustomCraftingBases.CustomBases[2]
    textList2 .= (!textList2 ? "" : ", ") v.BaseName
  baseList := ""
  textList3 := ""
  For k, v in WR.CustomCraftingBases.CustomBases[3]
    textList3 .= (!textList3 ? "" : ", ") v.BaseName
  baseList := ""
  textList4 := ""
  For k, v in WR.CustomCraftingBases.CustomBases[4]
    textList4 .= (!textList4 ? "" : ", ") v.BaseName
  baseList := ""
  textList5 := ""
  For k, v in WR.CustomCraftingBases.CustomBases[5]
    textList5 .= (!textList5 ? "" : ", ") v.BaseName
  baseList := ""
  textList6 := ""
  For k, v in WR.CustomCraftingBases.CustomBases[6]
    textList6 .= (!textList6 ? "" : ", ") v.BaseName
  baseList := ""
  textList7 := ""
  For k, v in WR.CustomCraftingBases.CustomBases[7]
    textList7 .= (!textList7 ? "" : ", ") v.BaseName
  baseList := ""
  textList8 := ""
  For k, v in WR.CustomCraftingBases.CustomBases[8]
    textList8 .= (!textList8 ? "" : ", ") v.BaseName
  baseList := ""
  For k, v in Bases
  {
    If ( !IndexOf("talisman",v["tags"]) 
        && ( IndexOf("amulet",v["tags"]) 
        || IndexOf("ring",v["tags"]) 
        || IndexOf("belt",v["tags"]) 
        || IndexOf("armour",v["tags"]) 
        || IndexOf("weapon",v["tags"])
        || IndexOf("jewel",v["tags"])
      || IndexOf("abyss_jewel",v["tags"]) ) )
      {
        baseList .= v["name"]"|"
      }
    }
    Gui, CustomCrafting: New
    Gui, CustomCrafting: +AlwaysOnTop -MinimizeBox
    Gui, CustomCrafting: Add, Button, default gupdateEverything x225 y180 w150 h23, Save Configuration
    Gui, CustomCrafting: Add, ComboBox, Sort vCustomCraftingBase xm+5 ym+28 w500, %baseList%
    Gui, CustomCrafting: Add, Tab2, vInventoryGuiTabs x3 y3 w600 h300 -wrap , Atlas Tier 1|STR Tier 2|DEX Tier 3|INT Tier 4|Hybrid Tier 5|Jewel Tier 6|Abyss Jewel Tier 7|Jewellery Tier 8

    Gui, CustomCrafting: Tab, Atlas Tier 1
    Gui, CustomCrafting: Add, Edit, vActiveCraftTier1 ReadOnly y+38 w500 r8 , %textList1%
    Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT1 Base
    Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT1 Base
    Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT1 Base

    Gui, CustomCrafting: Tab, STR Tier 2
    Gui, CustomCrafting: Add, Edit, vActiveCraftTier2 ReadOnly y+38 w500 r8 , %textList2%
    Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT2 Base
    Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT2 Base
    Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT2 Base

    Gui, CustomCrafting: Tab, DEX Tier 3
    Gui, CustomCrafting: Add, Edit, vActiveCraftTier3 ReadOnly y+38 w500 r8 , %textList3%
    Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT3 Base
    Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT3 Base
    Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT3 Base

    Gui, CustomCrafting: Tab, INT Tier 4
    Gui, CustomCrafting: Add, Edit, vActiveCraftTier4 ReadOnly y+38 w500 r8 , %textList4%
    Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT4 Base
    Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT4 Base
    Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT4 Base

    Gui, CustomCrafting: Tab, Hybrid Tier 5
    Gui, CustomCrafting: Add, Edit, vActiveCraftTier5 ReadOnly y+38 w500 r8 , %textList5%
    Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT5 Base
    Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT5 Base
    Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT5 Base

    Gui, CustomCrafting: Tab, Jewel Tier 6
    Gui, CustomCrafting: Add, Edit, vActiveCraftTier6 ReadOnly y+38 w500 r8 , %textList6%
    Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT6 Base
    Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT6 Base
    Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT6 Base

    Gui, CustomCrafting: Tab, Abyss Jewel Tier 7
    Gui, CustomCrafting: Add, Edit, vActiveCraftTier7 ReadOnly y+38 w500 r8 , %textList7%
    Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT7 Base
    Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT7 Base
    Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT7 Base

    Gui, CustomCrafting: Tab, Jewellery Tier 8
    Gui, CustomCrafting: Add, Edit, vActiveCraftTier8 ReadOnly y+38 w500 r8 , %textList8%
    Gui, CustomCrafting: Add, Button, gAddCustomCraftingBase y+8 w60 r2 center, Add`nT8 Base
    Gui, CustomCrafting: Add, Button, gRemoveCustomCraftingBase x+5 w60 r2 center, Remove`nT8 Base
    Gui, CustomCrafting: Add, Button, gResetCustomCraftingBase x+5 w60 r2 center, Reset`nT8 Base
    Gui, CustomCrafting: Show, , Edit Crafting Tiers
    Return

    AddCustomCraftingBase:
      Gui, Submit, nohide
      ;CraftingBasesRequest()
      RegExMatch(A_GuiControl, "T" rxNum " Base", RxMatch )
      AuxList:=[]
      For k, v in WR.CustomCraftingBases.CustomBases[RxMatch1]
        AuxList.Push(v.BaseName)
      If (CustomCraftingBase = "" || IndexOf(CustomCraftingBase,AuxList))
        Return
      CustomCraftingBaseOBJ:= {"BaseName": CustomCraftingBase, "ILvL":0}
      WR.CustomCraftingBases.CustomBases[RxMatch1].Push(CustomCraftingBaseOBJ)
      textList := ""
      For k, v in WR.CustomCraftingBases.CustomBases[RxMatch1]
        textList .= (!textList ? "" : ", ") v.BaseName
      GuiControl,, ActiveCraftTier%RxMatch1%, %textList%
    Return

    RemoveCustomCraftingBase:
      Gui, Submit, nohide
      RegExMatch(A_GuiControl, "T" rxNum " Base", RxMatch )
      AuxList:=[]
      For k, v in WR.CustomCraftingBases.CustomBases[RxMatch1]
        AuxList.Push(v.BaseName)
      If (CustomCraftingBase = "" || !IndexOf(CustomCraftingBase,AuxList))
        Return
      For k, v in AuxList
        If (v = CustomCraftingBase)
        WR.CustomCraftingBases.CustomBases[RxMatch1].RemoveAt(k)
      textList := ""
      For k, v in WR.CustomCraftingBases.CustomBases[RxMatch1]
        textList .= (!textList ? "" : ", ") v.BaseName
      GuiControl,, ActiveCraftTier%RxMatch1%, %textList%
      Gui, Show
    Return

    ResetCustomCraftingBase:
      RegExMatch(A_GuiControl, "T" rxNum " Base", RxMatch )
      WR.CustomCraftingBases.CustomBases[RxMatch1] := WR.CustomCraftingBases.Default[RxMatch1].Clone()
      textList := ""
      For k, v in WR.CustomCraftingBases.CustomBases[RxMatch1]
        textList .= (!textList ? "" : ", ") v.BaseName
      GuiControl,, ActiveCraftTier%RxMatch1%, %textList%
    Return

;; Test Function to Feed Crafting Base Obj
    CraftingBasesRequest(endAtRefresh := 0){
      If (AccountNameSTR = "")
        AccountNameSTR := POE_RequestAccount().accountName

      If(YesCraftingBaseAutoUpdate || YesCraftingBaseAutoUpdateOnStart)
      {
        Object := POE_RequestStash(StashTabCrafting,0)
      }Else{
        Return
      }
      For k, v in Object
      {
        For i, content in Object[k].items
        {
          item := new ItemBuild(content,Object[k].quadLayout)
        }
      }
    }
