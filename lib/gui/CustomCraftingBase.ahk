; Wingman Crafting Labels - By DanMarzola

RowNumber := 0

RefreshBaseList(type){
  For k, v in Bases
  {
    If (IndexOf(type,v["tags"])){
      if(type = "str_armour"){
        LV_Add("",v["item_class"],v["name"],"0",RegexFixLeadingZeros(2,v["drop_level"]),RegexFixLeadingZeros(3,v["properties"]["armour"]["min"]))
      }else if(type = "dex_armour"){
        LV_Add("",v["item_class"],v["name"],"0",RegexFixLeadingZeros(2,v["drop_level"]),,RegexFixLeadingZeros(3,v["properties"]["evasion"]["min"]))
      }else if(type = "int_armour"){
        LV_Add("",v["item_class"],v["name"],"0",RegexFixLeadingZeros(2,v["drop_level"]),,RegexFixLeadingZeros(3,v["properties"]["energy_shield"]["min"]))
      }else if(type = "str_dex_armour"){
        LV_Add("",v["item_class"],v["name"],"0",RegexFixLeadingZeros(2,v["drop_level"]),RegexFixLeadingZeros(3,v["properties"]["armour"]["min"]),RegexFixLeadingZeros(3,v["properties"]["evasion"]["min"]))
      }else if(type = "str_int_armour"){
        LV_Add("",v["item_class"],v["name"],"0",RegexFixLeadingZeros(2,v["drop_level"]),RegexFixLeadingZeros(3,v["properties"]["armour"]["min"]),RegexFixLeadingZeros(3,v["properties"]["energy_shield"]["min"]))
      }else if(type = "dex_int_armour"){
        LV_Add("",v["item_class"],v["name"],"0",RegexFixLeadingZeros(2,v["drop_level"]),RegexFixLeadingZeros(3,v["properties"]["evasion"]["min"]),RegexFixLeadingZeros(3,v["properties"]["energy_shield"]["min"]))
      }else{
        LV_Add("",v["item_class"],v["name"],"0",RegexFixLeadingZeros(2,v["drop_level"]))
      }
    }
  }

  ;; Retrive bases from custom crafting bases json to check box
  Loop % LV_GetCount()
  {
    Index := A_Index
    LV_GetText(OutputVar, A_Index , 2)
    For k, v in WR.CustomCraftingBases.Bases{ 
      if (v.BaseName == OutputVar){
        LV_Modify(Index,"Check")
      }
    }
  }

  ;; Style
  Loop % LV_GetCount("Column")
  {
    LV_ModifyCol(A_Index,"AutoHdr")
  }
  LV_ModifyCol(1, 100)
  LV_ModifyCol(2, 200)
  LV_ModifyCol(4,"SortDesc")

}
Return

RegexFixLeadingZeros(digits,content){
  if(content==""){
    content:=
  }
  else if(digits==2){
    Loop, 2
    {
      content := RegExReplace(content, "(?<!\d)\d(?!\d)", "0$0")
    }
  }else if(digits==3){
    Loop, 2
    {
      content := RegExReplace(content, "(?<!\d)\d(?!\d)", "00$0")
      content := RegExReplace(content, "(?<!\d)\d{2}(?!\d)", "0$0")
    }
  }
  return content
}

CraftingBaseSTRUI:
  Gui, CustomCraftingBaseUI1: New
  Gui, CustomCraftingBaseUI1: Default
  Gui, CustomCraftingBaseUI1: +AlwaysOnTop -MinimizeBox +LabelCustomUndesirable
  Gui, CustomCraftingBaseUI1: Add, ListView , w700 h300 -wrap -Multi Grid Checked gMyListView vlistview1, Slot|Base Name|Max ILvL Found|Drop Level|Base Armour
  RefreshBaseList("str_armour")
  Gui, CustomCraftingBaseUI1: Add, Button, gSaveCraftingBase x+5 w120 h30 center, Save
  Gui, CustomCraftingBaseUI1: Add, Button, gResetCraftingBase w120 h30 center, Reset
  Gui, CustomCraftingBaseUI1: Show, , Str Armour
Return

CraftingBaseDEXUI:
  Gui, CustomCraftingBaseUI1: New
  Gui, CustomCraftingBaseUI1: Default
  Gui, CustomCraftingBaseUI1: +AlwaysOnTop -MinimizeBox +LabelCustomUndesirable
  Gui, CustomCraftingBaseUI1: Add, ListView , w700 h300 -wrap -Multi Grid Checked gMyListView vlistview1, Slot|Base Name|Max ILvL Found|Drop Level|Base Evasion
  RefreshBaseList("dex_armour")
  Gui, CustomCraftingBaseUI1: Add, Button, gSaveCraftingBase x+5 w120 h30 center, Save
  Gui, CustomCraftingBaseUI1: Add, Button, gResetCraftingBase w120 h30 center, Reset
  Gui, CustomCraftingBaseUI1: Show, , Str Armour
Return

CraftingBaseINTUI:
  Gui, CustomCraftingBaseUI1: New
  Gui, CustomCraftingBaseUI1: Default
  Gui, CustomCraftingBaseUI1: +AlwaysOnTop -MinimizeBox +LabelCustomUndesirable
  Gui, CustomCraftingBaseUI1: Add, ListView , w700 h300 -wrap -Multi Grid Checked gMyListView vlistview1, Slot|Base Name|Max ILvL Found|Drop Level|Base Energy Shield
  RefreshBaseList("int_armour")
  Gui, CustomCraftingBaseUI1: Add, Button, gSaveCraftingBase x+5 w120 h30 center, Save
  Gui, CustomCraftingBaseUI1: Add, Button, gResetCraftingBase w120 h30 center, Reset
  Gui, CustomCraftingBaseUI1: Show, , Str Armour
Return

CraftingBaseSTRDEXUI:
  Gui, CustomCraftingBaseUI1: New
  Gui, CustomCraftingBaseUI1: Default
  Gui, CustomCraftingBaseUI1: +AlwaysOnTop -MinimizeBox +LabelCustomUndesirable
  Gui, CustomCraftingBaseUI1: Add, ListView , w700 h300 -wrap -Multi Grid Checked gMyListView vlistview1, Slot|Base Name|Max ILvL Found|Drop Level|Base Armour|Base Evasion
  RefreshBaseList("str_dex_armour")
  Gui, CustomCraftingBaseUI1: Add, Button, gSaveCraftingBase x+5 w120 h30 center, Save
  Gui, CustomCraftingBaseUI1: Add, Button, gResetCraftingBase w120 h30 center, Reset
  Gui, CustomCraftingBaseUI1: Show, , Str Armour
Return

CraftingBaseSTRINTUI:
  Gui, CustomCraftingBaseUI1: New
  Gui, CustomCraftingBaseUI1: Default
  Gui, CustomCraftingBaseUI1: +AlwaysOnTop -MinimizeBox +LabelCustomUndesirable
  Gui, CustomCraftingBaseUI1: Add, ListView , w700 h300 -wrap -Multi Grid Checked gMyListView vlistview1, Slot|Base Name|Max ILvL Found|Drop Level|Base Armour|Base Energy Shield
  RefreshBaseList("str_int_armour")
  Gui, CustomCraftingBaseUI1: Add, Button, gSaveCraftingBase x+5 w120 h30 center, Save
  Gui, CustomCraftingBaseUI1: Add, Button, gResetCraftingBase w120 h30 center, Reset
  Gui, CustomCraftingBaseUI1: Show, , Str Armour
Return

CraftingBaseDEXINTUI:
  Gui, CustomCraftingBaseUI1: New
  Gui, CustomCraftingBaseUI1: Default
  Gui, CustomCraftingBaseUI1: +AlwaysOnTop -MinimizeBox +LabelCustomUndesirable
  Gui, CustomCraftingBaseUI1: Add, ListView , w700 h300 -wrap -Multi Grid Checked gMyListView vlistview1, Slot|Base Name|Max ILvL Found|Drop Level|Base Evasion|Base Energy Shield
  RefreshBaseList("dex_int_armour")
  Gui, CustomCraftingBaseUI1: Add, Button, gSaveCraftingBase x+5 w120 h30 center, Save
  Gui, CustomCraftingBaseUI1: Add, Button, gResetCraftingBase w120 h30 center, Reset
  Gui, CustomCraftingBaseUI1: Show, , Str Armour
Return

CraftingBaseAMULETUI:
  Gui, CustomCraftingBaseUI1: New
  Gui, CustomCraftingBaseUI1: Default
  Gui, CustomCraftingBaseUI1: +AlwaysOnTop -MinimizeBox +LabelCustomUndesirable
  Gui, CustomCraftingBaseUI1: Add, ListView , w700 h300 -wrap -Multi Grid Checked gMyListView vlistview1, Slot|Base Name|Max ILvL Found|Drop Level
  RefreshBaseList("amulet")
  Gui, CustomCraftingBaseUI1: Add, Button, gSaveCraftingBase x+5 w120 h30 center, Save
  Gui, CustomCraftingBaseUI1: Add, Button, gResetCraftingBase w120 h30 center, Reset
  Gui, CustomCraftingBaseUI1: Show, , Amulet
Return

CraftingBaseRINGUI:
  Gui, CustomCraftingBaseUI1: New
  Gui, CustomCraftingBaseUI1: Default
  Gui, CustomCraftingBaseUI1: +AlwaysOnTop -MinimizeBox +LabelCustomUndesirable
  Gui, CustomCraftingBaseUI1: Add, ListView , w700 h300 -wrap -Multi Grid Checked gMyListView vlistview1, Slot|Base Name|Max ILvL Found|Drop Level
  RefreshBaseList("ring")
  Gui, CustomCraftingBaseUI1: Add, Button, gSaveCraftingBase x+5 w120 h30 center, Save
  Gui, CustomCraftingBaseUI1: Add, Button, gResetCraftingBase w120 h30 center, Reset
  Gui, CustomCraftingBaseUI1: Show, , Ring
Return

CraftingBaseBELTUI:
  Gui, CustomCraftingBaseUI1: New
  Gui, CustomCraftingBaseUI1: Default
  Gui, CustomCraftingBaseUI1: +AlwaysOnTop -MinimizeBox +LabelCustomUndesirable
  Gui, CustomCraftingBaseUI1: Add, ListView , w700 h300 -wrap -Multi Grid Checked gMyListView vlistview1, Slot|Base Name|Max ILvL Found|Drop Level
  RefreshBaseList("belt")
  Gui, CustomCraftingBaseUI1: Add, Button, gSaveCraftingBase x+5 w120 h30 center, Save
  Gui, CustomCraftingBaseUI1: Add, Button, gResetCraftingBase w120 h30 center, Reset
  Gui, CustomCraftingBaseUI1: Show, , Belt
Return

ResetCraftingBase:
  Loop % LV_GetCount()
  {
    LV_Modify(A_Index,"-Check")
  }
Return

SaveCraftingBase:
  update:=false
  Counter := 0
  RowNumber := LV_GetNext(1,"C")
  Loop % LV_GetCount()
  {
    LV_GetText(BaseName, A_Index,2)
    If(Counter:=HasBase(BaseName) && RowNumber!=A_Index){
      update:=true
      WR.CustomCraftingBases.Bases.RemoveAt(Counter)
      ; I not sure why, but without this sleep/delay sometimes array skip some values
      sleep,10
    }
    RowNumber := LV_GetNext(A_Index,"C")
  }

  RowNumber := 0
  Counter := 0
  Loop
  {
    RowNumber := LV_GetNext(RowNumber,"C")
    if not RowNumber  ; The above returned zero, so there are no more selected rows.
        Break
    LV_GetText(BaseName, RowNumber,2)
    If(Counter:=HasBase(BaseName)){
      Continue
    }Else{
      update:=true
      aux:= {"BaseName":BaseName,"ILvL":"0"}
      WR.CustomCraftingBases.Bases.Push(aux)
    }
  }
  if(update){
    Settings("CustomCraftingBases","Save")
  }
Return

HasBase(Base){
  for k, v in WR.CustomCraftingBases.Bases{
    if (v.BaseName == Base){
      return k
    }
  }
return False
}

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
