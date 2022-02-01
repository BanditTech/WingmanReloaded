; Main UI

ModsUI:
  Gui, ModsUI1: New
  Gui, ModsUI1: Default
  Gui, ModsUI1: +AlwaysOnTop -MinimizeBox
  Gui, ModsUI1: Add, Text,, Prefix List
  Gui, ModsUI1: Add, ListView , w1200 h350 -wrap -Multi Grid Checked vLVP, Influence|Affix Name|ILvL|Detail|Code
  Gui, ModsUI1: Add, Text,, Suffix List
  Gui, ModsUI1: Add, ListView , w1200 h350 -wrap -Multi Grid Checked vLVS, Influence|Affix Name|ILvL|Detail|Code
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
    TrueIndex++
    RowNumber := LV_GetNext(RowNumber,"C")
    If not RowNumber
      break
    LV_GetText(ModLine, RowNumber,4)
    MatchLineForItemCraft(ModLine,1,WR.ItemCrafting[ItemCraftingBaseSelector],TrueIndex)
  }

  RowNumber := 0
  Gui, ListView, LVS
  Loop
  {
    TrueIndex++
    RowNumber := LV_GetNext(RowNumber,"C")
    If not RowNumber
      break
    LV_GetText(ModLine, RowNumber,4)
    MatchLineForItemCraft(ModLine,2,WR.ItemCrafting[ItemCraftingBaseSelector],TrueIndex)
  }

  Settings("ItemCrafting","Save")
Return

SaveItemCraftingMenu:
Return

ItemCraftingSubmit:
  Gui,Submit, Nohide
Return

;; Functions

MatchLineForItemCraft(FullLine,ModGenerationTypeID,ObjectToPush,MyID)
{
  Repeat := 1
  Item := New Itemscan()
  IsHybridMod := False
  OriginalFullLine:=FullLine
  if(RxMatch := StrSplit(FullLine, " | ", RxMatch))
  {
    Repeat := RxMatch.Count()
  }
  Loop, %Repeat%
  {
    If(Repeat > 1)
      FullLine := RxMatch[A_Index]
    Line := RegExReplace(FullLine,"\(" rxNum "-" rxNum "\)", "$1")
    Line := RegExReplace(Line,"\(-" rxNum "--" rxNum "\)", "$1")
    Mod := Item.Standardize(Line)
    If(!IsHybridMod && Item.CheckIfActualHybridMod(Mod))
      IsHybridMod := True
    If (vals := Item.MatchLine(Line))
    {
      If (vals.Count() >= 2)
      {
        If (Line ~= rxNum " to " rxNum || Line ~= rxNum "-" rxNum)
          FinalValue := (Format("{1:0.3g}",(vals[1] + vals[2]) / 2))
        Else
          FinalValue := vals[1]
      }
      Else
        FinalValue := vals[1]
    }
    Else
      FinalValue := True
    If(IsHybridMod){
      Mod := "(Hybrid) " . Mod
    }
    aux := {"Mod":OriginalFullLine,"ModGenerationTypeID":ModGenerationTypeID,"ModWRFormat":Mod,"ValueWRFormat":FinalValue,"RNMod":Repeat,"ID":MyID}
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
      If (v["ModGenerationTypeID"] == 1)
      {
        Gui, ListView, LVP
        StringUpper, vi, vi, T
        LV_Add("",vi,v["Name"],v["Level"],ItemCraftingNaming(v["str"]),v["Code"])
      }else {
        Gui, ListView, LVS
        StringUpper, vi, vi, T
        LV_Add("",vi,v["Name"],v["Level"],ItemCraftingNaming(v["str"]),v["Code"])
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

ItemCraftingNaming(Content) {
  Content := RegExReplace(Content,"\<br\/?\>"," | ")
  Content := RegExReplace(Content,"\<.*?\>","")
  Content := RegExReplace(Content,"&ndash;","-")
    Return Content
  }