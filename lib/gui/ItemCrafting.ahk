; Main UI

ModsUI:
  If (ItemCraftingCategorySelector ~= "Sextant") {
    GoTo, CustomSextantModsUI
  }
  Gui, ModsUI1: New
  Gui, ModsUI1: Default
  Gui, ModsUI1: +AlwaysOnTop -MinimizeBox
  Gui, ModsUI1: Add, Text,, Prefix List
  Gui, ModsUI1: Add, ListView , w1200 h350 -wrap -Multi Grid Checked vLVP, Influence|Affix Name|ILvL|Detail|Mod Weight|Code
  Gui, ModsUI1: Add, Text,, Suffix List
  Gui, ModsUI1: Add, ListView , w1200 h350 -wrap -Multi Grid Checked vLVS, Influence|Affix Name|ILvL|Detail|Mod Weight|Code
  RefreshModList(ItemCraftingCategorySelector,ItemCraftingSubCategorySelector)
  Gui, ModsUI1: Add, Button, gSaveItemCrafting x+5 w120 h30 center, Save
  Gui, ModsUI1: Add, Button, gResetItemCrafting w120 h30 center, Reset
  Gui, ModsUI1: Show, , Category %ItemCraftingCategorySelector% SubCategory %ItemCraftingSubCategorySelector% Affix List
Return

ResetItemCrafting:
  Gui, ListView, LVP
  Loop % LV_GetCount()
    LV_Modify(A_Index,"-Check")
  Gui, ListView, LVS
  Loop % LV_GetCount()
    LV_Modify(A_Index,"-Check")
  WR.ItemCrafting[ItemCraftingCategorySelector][ItemCraftingSubCategorySelector] := []
  Settings("ItemCrafting","Save")
Return

SaveItemCrafting:
  TrueIndex:=0
  WR.ItemCrafting[ItemCraftingCategorySelector][ItemCraftingSubCategorySelector] := []

  RowNumber := 0
  Gui, ListView, LVP
  Loop
  {
    RowNumber := LV_GetNext(RowNumber,"C")
    If not RowNumber
      Break
    TrueIndex++
    LV_GetText(ModLine, RowNumber,4)
    LV_GetText(Affix, RowNumber,2)
    MatchLineForItemCraft(ModLine,1,WR.ItemCrafting[ItemCraftingCategorySelector][ItemCraftingSubCategorySelector],TrueIndex,Affix)
  }

  RowNumber := 0
  Gui, ListView, LVS
  Loop
  {

    RowNumber := LV_GetNext(RowNumber,"C")
    If not RowNumber
      Break
    TrueIndex++
    LV_GetText(ModLine, RowNumber,4)
    LV_GetText(Affix, RowNumber,2)
    MatchLineForItemCraft(ModLine,2,WR.ItemCrafting[ItemCraftingCategorySelector][ItemCraftingSubCategorySelector],TrueIndex,Affix)
  }

  Settings("ItemCrafting","Save")
Return

SaveItemCraftingMenu:
Return

ItemCraftingSubmit:
  If (A_GuiControl ~= "ItemCraftingCategorySelector") {
    SaveINI("Item Crafting Settings")
    aux := ""
    for a,b in POEData[ItemCraftingCategorySelector]
    {
      aux .= b "|"
    }
    GuiControl, , ItemCraftingSubCategorySelector, |%aux%
  }
  If (A_GuiControl ~= "ItemCraftingSubCategorySelector") {
    SaveINI("Item Crafting Settings")
  }
Return

;; Functions

MatchLineForItemCraft(FullLine,ModGenerationType,ObjectToPush,MyID,Affix)
{
  Item := New Itemscan()
  Repeat := 1
  IsHybridMod := False
  OriginalFullLine:=FullLine
  if(SplittedModLine := StrSplit(FullLine, " | "))
  {
    Repeat := SplittedModLine.Count()
  }
  Loop, %Repeat%
  {
    ; Start Aux
    StartingPos := 1
    FullLine := SplittedModLine[A_Index]
    HighValue:=[]
    LowValue:=[]

    ;Catch Values
    While(RegExMatch(FullLine,"O)\(" rxNum "-" rxNum "\)", RxMatch, StartingPos))
    {
      LowValue.push(RxMatch[1])
      HighValue.push(RxMatch[2])
      StartingPos := RxMatch.Pos(2)
    }
    While(RegExMatch(FullLine,"O)\(-" rxNum "--" rxNum "\)", RxMatch, StartingPos))
    {
      LowValue.push(RxMatch[1])
      HighValue.push(RxMatch[2])
      StartingPos := RxMatch.Pos(2)
    }
    ; Create WR Mod Line
    Line := RegExReplace(FullLine,"\(" rxNum "-" rxNum "\)", "$1")
    Line := RegExReplace(Line,"\(-" rxNum "--" rxNum "\)", "$1")
    Mod := RegExReplace(Line, "\+?"rxNum , "#")

    ; Check for Hybrid Mods
    If(!IsHybridMod && Item.CheckIfActualHybridMod(Mod) && Repeat > 1)
      IsHybridMod := True

    ;; Match (#-#) to (#-#)
    If(HighValue.Count() == 2 && LowValue.Count() == 2){
      FinalValueLow := (Format("{1:0.3g}",(LowValue[1] + LowValue[2]) / 2))
      FinalValueHigh := (Format("{1:0.3g}", (HighValue[1] + HighValue[2]) / 2))
      ;; Match # to (#-#) ODD Mod from Lower Tiers
    }Else If(RegExMatch(FullLine,"O)" rxNum " to \(" rxNum "-" rxNum "\)", RxMatch)){
      FinalValueLow := (Format("{1:0.3g}",(RxMatch[1] + RxMatch[2]) / 2))
      FinalValueHigh := (Format("{1:0.3g}", (RxMatch[1] + RxMatch[3]) / 2))
      ;; Match (#-#)
    }Else If(HighValue.Count() == 1){
      FinalValueLow := LowValue[1]
      FinalValueHigh := HighValue[1]
      ;; Match #
    }Else If(RegExMatch(FullLine, "O)\+?"rxNum, RxMatch)){
      FinalValueLow := RxMatch[1]
      FinalValueHigh := RxMatch[1]
      ;; Match no number
    }Else{
      FinalValueLow := True
      FinalValueHigh := True
    }
    ;; Add (Hybrid) to Hybrid Mods in WR Format
    If(IsHybridMod){
      Mod := "(Hybrid) " . Mod
    }
    aux := {"Mod":OriginalFullLine,"Affix":Affix,"ModGenerationType":ModGenerationType,"ModWRFormat":Mod,"ValueWRFormatLow":FinalValueLow,"ValueWRFormatHigh":FinalValueHigh,"RNMod":Repeat,"ID":MyID}
    ObjectToPush.push(aux)
  }
}

LoadOnDemand(a,b) {
  Return JSON.Load(FileOpen(A_ScriptDir "\data\PoE Data\" . a . "(" . b . ").json","r").Read())
}

RefreshModList(a,b)
{
  Mods := LoadOnDemand(a,b)
  For k, v in Mods
  {
    If (v["generation_type"] == "Prefix")
    {
      Gui, ListView, LVP
      LV_Add("",v["influence"],v["name"],v["required_level"],ItemCraftingNaming(v["text"]),v["weight"],k)
    }else {
      Gui, ListView, LVS
      LV_Add("",v["influence"],v["name"],v["required_level"],ItemCraftingNaming(v["text"]),v["weight"],k)
    }
  }
  Mods := []
  ;;Check Box
  Gui, ListView, LVP
  Loop % LV_GetCount()
  {
    Index := A_Index
    LV_GetText(OutputVar, A_Index , 4)
    For k, v in WR.ItemCrafting[ItemCraftingCategorySelector][ItemCraftingSubCategorySelector]
    {
      If (v.Mod == OutputVar)
        LV_Modify(Index,"Check")
    }
  }
  Gui, ListView, LVS
  Loop % LV_GetCount()
  {
    Index := A_Index
    LV_GetText(OutputVar, A_Index , 4)
    For k, v in WR.ItemCrafting[ItemCraftingCategorySelector][ItemCraftingSubCategorySelector]
    {
      If (v.Mod == OutputVar)
        LV_Modify(Index,"Check")
    }
  }
  ;; Style
  Gui, ListView, LVP
  Loop % LV_GetCount("Column")
    LV_ModifyCol(A_Index,"AutoHdr")
  Gui, ListView, LVS
  Loop % LV_GetCount("Column")
    LV_ModifyCol(A_Index,"AutoHdr")
  Return
}

ItemCraftingNaming(Content)
{
  Content := RegExReplace(Content,"\<br\/?\>"," | ")
  Content := RegExReplace(Content,"\<.*?\>","")
  Content := RegExReplace(Content,"&ndash;","-")
  Return Content
}