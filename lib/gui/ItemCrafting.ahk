; Main UI

ModsUI:
  If (ItemCraftingBaseSelector ~= "Awakened|Elevated") {
    GoTo, CustomSextantModsUI
  }
  Gui, ModsUI1: New
  Gui, ModsUI1: Default
  Gui, ModsUI1: +AlwaysOnTop -MinimizeBox
  Gui, ModsUI1: Add, Text,, Prefix List
  Gui, ModsUI1: Add, ListView , w1200 h350 -wrap -Multi Grid Checked vLVP, Influence|Affix Name|ILvL|Detail|Mod Weight|Code
  Gui, ModsUI1: Add, Text,, Suffix List
  Gui, ModsUI1: Add, ListView , w1200 h350 -wrap -Multi Grid Checked vLVS, Influence|Affix Name|ILvL|Detail|Mod Weight|Code
  RefreshModList(ItemCraftingBaseSelector)
  Gui, ModsUI1: Add, Button, gSaveItemCrafting x+5 w120 h30 center, Save
  Gui, ModsUI1: Add, Button, gResetItemCrafting w120 h30 center, Reset
  Gui, ModsUI1: Show, , %ItemCraftingBaseSelector% Affix List 
Return

ResetItemCrafting:
  Gui, ListView, LVP
  Loop % LV_GetCount()
    LV_Modify(A_Index,"-Check")
  Gui, ListView, LVS
  Loop % LV_GetCount()
    LV_Modify(A_Index,"-Check")
  WR.ItemCrafting[ItemCraftingBaseSelector] := []
  Settings("ItemCrafting","Save")
Return

SaveItemCrafting:
  TrueIndex:=0
  WR.ItemCrafting[ItemCraftingBaseSelector] := []

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
    MatchLineForItemCraft(ModLine,1,WR.ItemCrafting[ItemCraftingBaseSelector],TrueIndex,Affix)
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
    MatchLineForItemCraft(ModLine,2,WR.ItemCrafting[ItemCraftingBaseSelector],TrueIndex,Affix)
  }

  Settings("ItemCrafting","Save")
Return

SaveItemCraftingMenu:
Return

ItemCraftingSubmit:
  SaveINI("Item Crafting Settings")
  If (A_GuiControl ~= "categorySelector") {
    GuiControl, , ItemCraftingBaseSelector, % "|" WR.MenuDDLstr[ItemCraftingcategorySelector]
    GuiControl, ChooseString, ItemCraftingBaseSelector,% WR.MenuDDLselect[ItemCraftingcategorySelector]
  }
  If (A_GuiControl ~= "BaseSelector") {
    WR.MenuDDLselect[ItemCraftingcategorySelector] := ItemCraftingBaseSelector
    Settings("MenuDDLselect","Save")
  }
Return

;; Functions

MatchLineForItemCraft(FullLine,ModGenerationTypeID,ObjectToPush,MyID,Affix)
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
    aux := {"Mod":OriginalFullLine,"Affix":Affix,"ModGenerationTypeID":ModGenerationTypeID,"ModWRFormat":Mod,"ValueWRFormatLow":FinalValueLow,"ValueWRFormatHigh":FinalValueHigh,"RNMod":Repeat,"ID":MyID}
    ObjectToPush.push(aux) 
  }
}

LoadOnDemand(content)
{
  content := RegExReplace(content," ","")
  FileRead, JSONtext, %A_ScriptDir%\data\Mods%content%.json
Return JSON.Load(JSONtext)
}

RefreshModList(type)
{
  Mods := LoadOnDemand(type)
  For ki ,vi in ["normal","elder","shaper","crusader","redeemer","hunter","warlord"]
  {
    For k, v in Mods[vi]
    {
      if(v["DropChance"] != 0)
      {
        If (v["ModGenerationTypeID"] == 1)
        {
          Gui, ListView, LVP
          StringUpper, vi, vi, T
          LV_Add("",vi,v["Name"],v["Level"],ItemCraftingNaming(v["str"]),v["DropChance"],v["Code"])
        }else {
          Gui, ListView, LVS
          StringUpper, vi, vi, T
          LV_Add("",vi,v["Name"],v["Level"],ItemCraftingNaming(v["str"]),v["DropChance"],v["Code"])
        }
      }
    }
  }
  Mods := []
  ;;Check Box
  Gui, ListView, LVP
  Loop % LV_GetCount()
  {
    Index := A_Index
    LV_GetText(OutputVar, A_Index , 4)
    For k, v in WR.ItemCrafting[ItemCraftingBaseSelector]
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
    For k, v in WR.ItemCrafting[ItemCraftingBaseSelector]
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