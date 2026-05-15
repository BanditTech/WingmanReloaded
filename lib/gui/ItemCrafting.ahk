; Main UI

ModsUI(*)
{
  global ModsGui, ItemCraftingCategorySelector, ItemCraftingSubCategorySelector
  If (!HasVal(PoEData[ItemCraftingCategorySelector], ItemCraftingSubCategorySelector)) {
    ModsGui.Hide()
    MsgBox("SubCategory from " ItemCraftingCategorySelector " was not selected correctly", "Error", 0)
    ModsGui.Show()
    Return
  }
  ModsGui := Gui()
  ModsGui.Opt("+AlwaysOnTop -MinimizeBox")
  ModsGui.Add("Text",, "Prefix List")
  lvp := ModsGui.Add("ListView", "w1200 h350 -wrap -Multi Grid Checked vLVP", ["Influence","Affix Name","ILvL","Detail","Mod Weight","Code"])
  ModsGui.Add("Text",, "Suffix List")
  lvs := ModsGui.Add("ListView", "w1200 h350 -wrap -Multi Grid Checked vLVS", ["Influence","Affix Name","ILvL","Detail","Mod Weight","Code"])
  RefreshModList(ItemCraftingCategorySelector,ItemCraftingSubCategorySelector)
  btn1 := ModsGui.Add("Button", "x+5 w120 h30 center", "Save")
  btn1.OnEvent("Click", SaveItemCrafting)
  btn2 := ModsGui.Add("Button", "w120 h30 center", "Reset")
  btn2.OnEvent("Click", ResetItemCrafting)
  ModsGui.Show("", 'Category: "' ItemCraftingCategorySelector '" SubCategory: "' ItemCraftingSubCategorySelector '" - Affix List')
}

ResetItemCrafting(*)
{
  global ModsGui, ItemCraftingCategorySelector, ItemCraftingSubCategorySelector
  ModsGui["LVP"].Delete()
  ModsGui["LVS"].Delete()
  WR.ItemCrafting.%ItemCraftingCategorySelector%[ItemCraftingSubCategorySelector] := []
  Settings("ItemCrafting","Save")
}

SaveItemCrafting(*)
{
  global ModsGui, ItemCraftingCategorySelector, ItemCraftingSubCategorySelector
  TrueIndex := 0
  WR.ItemCrafting.%ItemCraftingCategorySelector%[ItemCraftingSubCategorySelector] := []

  RowNumber := 0
  Loop
  {
    RowNumber := ModsGui["LVP"].GetNext(RowNumber,"C")
    If not RowNumber
      Break
    TrueIndex++
    ModLine := ModsGui["LVP"].GetText(RowNumber,4)
    Affix   := ModsGui["LVP"].GetText(RowNumber,2)
    MatchLineForItemCraft(ModLine,"Prefix",WR.ItemCrafting.%ItemCraftingCategorySelector%[ItemCraftingSubCategorySelector],TrueIndex,Affix)
  }

  RowNumber := 0
  Loop
  {
    RowNumber := ModsGui["LVS"].GetNext(RowNumber,"C")
    If not RowNumber
      Break
    TrueIndex++
    ModLine := ModsGui["LVS"].GetText(RowNumber,4)
    Affix   := ModsGui["LVS"].GetText(RowNumber,2)
    MatchLineForItemCraft(ModLine,"Suffix",WR.ItemCrafting.%ItemCraftingCategorySelector%[ItemCraftingSubCategorySelector],TrueIndex,Affix)
  }

  Settings("ItemCrafting","Save")
}

SaveItemCraftingMenu()
{
}

FillItemCraftingSubCategoryDropdown(){
  global ItemCraftingCategorySelector
  aux := ""
  for a,b in POEData[ItemCraftingCategorySelector] {
    aux .= b "|"
  }
  MainGui["ItemCraftingSubCategorySelector"].Value := "|" aux
}

ItemCraftingSubmit(GuiCtrl, *)
{
  global ItemCraftingCategorySelector
  SaveINI(GuiCtrl.Name, "Item Crafting Settings")
  If (GuiCtrl.Name ~= "ItemCraftingCategorySelector")
    FillItemCraftingSubCategoryDropdown()
}

;; Functions

MatchLineForItemCraft(FullLine,ModGenerationType,ObjectToPush,MyID,Affix)
{
  craftItem := Itemscan()
  Repeat := 1
  IsHybridMod := False
  OriginalFullLine:=FullLine
  if(SplittedModLine := StrSplit(FullLine, " | "))
  {
    Repeat := SplittedModLine.Length
  }
  Loop Repeat
  {
    ; Start Aux
    StartingPos := 1
    FullLine := SplittedModLine[A_Index]
    HighValue:=[]
    LowValue:=[]

    ;Catch Values
    While(RegExMatch(FullLine,"\(" rxNum "-" rxNum "\)", &RxMatch, StartingPos))
    {
      LowValue.push(RxMatch[1])
      HighValue.push(RxMatch[2])
      StartingPos := RxMatch.Pos(2)
    }
    While(RegExMatch(FullLine,"\(-" rxNum "--" rxNum "\)", &RxMatch, StartingPos))
    {
      LowValue.push(RxMatch[1])
      HighValue.push(RxMatch[2])
      StartingPos := RxMatch.Pos(2)
    }
    ; Create WR Mod Line
    Line := RegExReplace(FullLine,"\(" rxNum "-" rxNum "\)", "$1")
    Line := RegExReplace(Line,"\(-" rxNum "--" rxNum "\)", "$1")
    Mod := RegExReplace(Line, "\+?" rxNum , "#")

    ; Check for Hybrid Mods
    If(!IsHybridMod && craftItem.CheckIfActualHybridMod(Mod) && Repeat > 1)
      IsHybridMod := True

    ;; Match (#-#) to (#-#)
    If(HighValue.Length == 2 && LowValue.Length == 2){
      FinalValueLow := (Format("{1:0.3g}",(LowValue[1] + LowValue[2]) / 2))
      FinalValueHigh := (Format("{1:0.3g}", (HighValue[1] + HighValue[2]) / 2))
      ;; Match # to (#-#) ODD Mod from Lower Tiers
    }Else If(RegExMatch(FullLine,"" rxNum " to \(" rxNum "-" rxNum "\)", &RxMatch)){
      FinalValueLow := (Format("{1:0.3g}",(RxMatch[1] + RxMatch[2]) / 2))
      FinalValueHigh := (Format("{1:0.3g}", (RxMatch[1] + RxMatch[3]) / 2))
      ;; Match (#-#)
    }Else If(HighValue.Length == 1){
      FinalValueLow := LowValue[1]
      FinalValueHigh := HighValue[1]
      ;; ODD Case with Reduced Affix
      if (FinalValueHigh < FinalValueLow){
        aux := FinalValueLow
        FinalValueLow := FinalValueHigh
        FinalValueHigh := aux
      }
      ;; Match #
    }Else If(RegExMatch(FullLine, "\+?" rxNum, &RxMatch)){
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
    aux := {Mod:OriginalFullLine, Affix:Affix, ModGenerationType:ModGenerationType, ModWRFormat:Mod, ValueWRFormatLow:FinalValueLow, ValueWRFormatHigh:FinalValueHigh, RNMod:Repeat, ID:MyID}
    ObjectToPush.push(aux)
  }
}

LoadOnDemand(a,b) {
  Return JSON.LoadFile(A_ScriptDir "\data\PoE Data\" . a . "(" . b . ").json")
}

RefreshModList(a,b)
{
  global ModsGui, ItemCraftingCategorySelector, ItemCraftingSubCategorySelector
  Mods := LoadOnDemand(a,b)
  For k, v in Mods
  {
    If (v["generation_type"] == "Prefix")
    {
      ModsGui["LVP"].Add("",v["influence"],v["name"],v["required_level"],ItemCraftingNaming(v["text"]),v["weight"],k)
    }else {
      ModsGui["LVS"].Add("",v["influence"],v["name"],v["required_level"],ItemCraftingNaming(v["text"]),v["weight"],k)
    }
  }
  Mods := []
  ;;Check Box
  Loop ModsGui["LVP"].GetCount()
  {
    Index := A_Index
    OutputVar := ModsGui["LVP"].GetText(A_Index, 4)
    For k, v in WR.ItemCrafting.%ItemCraftingCategorySelector%[ItemCraftingSubCategorySelector]
    {
      If (v.Mod == OutputVar)
        ModsGui["LVP"].Modify(Index,"Check")
    }
  }
  Loop ModsGui["LVS"].GetCount()
  {
    Index := A_Index
    OutputVar := ModsGui["LVS"].GetText(A_Index, 4)
    For k, v in WR.ItemCrafting.%ItemCraftingCategorySelector%[ItemCraftingSubCategorySelector]
    {
      If (v.Mod == OutputVar)
        ModsGui["LVS"].Modify(Index,"Check")
    }
  }
  ;; Style
  Loop ModsGui["LVP"].GetCount("Column")
    ModsGui["LVP"].ModifyCol(A_Index,"AutoHdr")
  Loop ModsGui["LVS"].GetCount("Column")
    ModsGui["LVS"].ModifyCol(A_Index,"AutoHdr")
  Return
}

ItemCraftingNaming(Content)
{
  Content := RegExReplace(Content,"\<br\/?\>"," | ")
  Content := RegExReplace(Content,"\<.*?\>","")
  Content := RegExReplace(Content,"&ndash;","-")
  Return Content
}
