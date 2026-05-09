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
      Output .= v . (k==Content.Length?"" : " | ")
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
    CustomMapModsGui["listview1"].Add("",v["generation_type"],v["name"],ItemCraftingNamingMaping(v["text"]),v["weight"],"Good","1")
  }
  Mods := []
  ;;Check Box
  Loop CustomMapModsGui["listview1"].GetCount()
  {
    Index := A_Index
    OutputVar := CustomMapModsGui["listview1"].GetText(A_Index, 2)
    For k, v in WR.CustomMapMods.MapMods
    {
      If (v["Map Affix"] == OutputVar)
        CustomMapModsGui["listview1"].Modify(Index,"Check",,,,,v["Mod Type"],v["Weight"])
    }
  }
  ;; Style
  Loop CustomMapModsGui["listview1"].GetCount("Column")
    CustomMapModsGui["listview1"].ModifyCol(A_Index,"AutoHdr")
  CustomMapModsGui["listview1"].ModifyCol(1, "Sort")
  Return
}

RefreshHeistList()
{
  AffixName:= ""
  Mods := LoadOnDemand("Contracts","Contracts")
  For k, v in Mods
  {
    CustomMapModsGui["listview1"].Add("","Contracts",v["generation_type"],v["name"],ItemCraftingNamingMaping(v["text"]),v["weight"],"Good","1")
  }
  Mods := LoadOnDemand("Blueprints","Blueprints")
  For k, v in Mods
  {
    CustomMapModsGui["listview1"].Add("","Blueprints",v["generation_type"],v["name"],ItemCraftingNamingMaping(v["text"]),v["weight"],"Good","1")
  }
  Mods := []
  ;;Check Box
  Loop CustomMapModsGui["listview1"].GetCount()
  {
    Index := A_Index
    OutputVar := CustomMapModsGui["listview1"].GetText(A_Index, 2)
    For k, v in WR.CustomMapMods.HeistMods
    {
      If (v["Map Affix"] == OutputVar)
        CustomMapModsGui["listview1"].Modify(Index,"Check",,,,,,v["Mod Type"],v["Weight"])
    }
  }
  ;; Style
  Loop CustomMapModsGui["listview1"].GetCount("Column")
    CustomMapModsGui["listview1"].ModifyCol(A_Index,"AutoHdr")
  CustomMapModsGui["listview1"].ModifyCol(1, "Sort")
  Return
}

CustomMapModsUI()
{
  global CustomMapModsGui
  CustomMapModsGui := Gui()
  CustomMapModsGui.Opt("+AlwaysOnTop -MinimizeBox")
  lv := CustomMapModsGui.Add("ListView", "w1200 h350 -wrap -Multi Grid Checked vlistview1", ["Affix Type","Affix Name","Detail","Mod Weight","Mod Type","Weight"])
  lv.OnEvent("Click", MyListViewMap)
  lv.OnEvent("DoubleClick", MyListViewMap)
  RefreshMapList()
  btn1 := CustomMapModsGui.Add("Button", "x+5 w120 h30 center", "Save Map Modifiers")
  btn1.OnEvent("Click", SaveMapData)
  btn2 := CustomMapModsGui.Add("Button", "w120 h30 center", "Reset Map Modifiers")
  btn2.OnEvent("Click", ResetMapData)
  CustomMapModsGui.Show("", "Custom Map Mods")
}

CustomHeistModsUI()
{
  global CustomMapModsGui
  CustomMapModsGui := Gui()
  CustomMapModsGui.Opt("+AlwaysOnTop -MinimizeBox")
  lv := CustomMapModsGui.Add("ListView", "w1200 h350 -wrap -Multi Grid Checked vlistview1", ["Affix Type","Affix Name","Detail","Mod Weight","Mod Type","Weight"])
  lv.OnEvent("Click", MyListViewHeist)
  lv.OnEvent("DoubleClick", MyListViewHeist)
  RefreshHeistList()
  btn1 := CustomMapModsGui.Add("Button", "x+5 w120 h30 center", "Save Heist Modifiers")
  btn1.OnEvent("Click", SaveHeistData)
  btn2 := CustomMapModsGui.Add("Button", "w120 h30 center", "Reset Heist Modifiers")
  btn2.OnEvent("Click", ResetHeistData)
  CustomMapModsGui.Show("", "Custom Heist")
}

MyListViewMap(ctrl, rowNum, *)
{
  global RowNumber, CustomMapModsGui
  if (ctrl.Event != "DoubleClick" && A_GuiEvent != "DoubleClick")
    return
  RowNumber := rowNum ? rowNum : A_EventInfo
  OutputVar1 := CustomMapModsGui["listview1"].GetText(RowNumber, 5)
  OutputVar2 := CustomMapModsGui["listview1"].GetText(RowNumber, 6)
  CustomUI := Gui()
  CustomUI.Opt("+AlwaysOnTop -MinimizeBox")
  CustomUI.Add("Text",, "Mod Type:")
  ddl := CustomUI.Add("DropDownList", "vCMP_ModType", ["Good","Bad","Impossible"])
  ddl.Choose(OutputVar1)
  CustomUI.Add("Text",, "Weight:")
  CustomUI.Add("Edit", "Number w40", OutputVar2)
  ud := CustomUI.Add("UpDown", "Range1-100 vCMP_Weight", OutputVar2)
  btn := CustomUI.Add("Button", "y+8 w120 h30 center", "Save")
  btn.OnEvent("Click", (*) => SaveRowLVM(CustomUI))
  CustomUI.Show("", "Edit Map Mod")
}

MyListViewHeist(ctrl, rowNum, *)
{
  global RowNumber, CustomMapModsGui
  if (ctrl.Event != "DoubleClick" && A_GuiEvent != "DoubleClick")
    return
  RowNumber := rowNum ? rowNum : A_EventInfo
  OutputVar1 := CustomMapModsGui["listview1"].GetText(RowNumber, 5)
  OutputVar2 := CustomMapModsGui["listview1"].GetText(RowNumber, 6)
  CustomUI := Gui()
  CustomUI.Opt("+AlwaysOnTop -MinimizeBox")
  CustomUI.Add("Text",, "Mod Type:")
  ddl := CustomUI.Add("DropDownList", "vCMP_ModType", ["Good","Bad","Impossible"])
  ddl.Choose(OutputVar1)
  CustomUI.Add("Text",, "Weight:")
  CustomUI.Add("Edit", "Number w40", OutputVar2)
  ud := CustomUI.Add("UpDown", "Range1-100 vCMP_Weight", OutputVar2)
  btn := CustomUI.Add("Button", "y+8 w120 h30 center", "Save")
  btn.OnEvent("Click", (*) => SaveRowLVM(CustomUI))
  CustomUI.Show("", "Edit Map Mod")
}

SaveRowLVM(CustomUI)
{
  global RowNumber, CustomMapModsGui
  saved := CustomUI.Submit(0)
  CustomMapModsGui["listview1"].Modify(RowNumber,,,,,,saved.CMP_ModType,saved.CMP_Weight)
  CustomUI.Hide()
}

SaveMapData(*)
{
  global CustomMapModsGui
  TrueIndex := 0
  WR.CustomMapMods.MapMods := []
  RowNumber := 0
  Loop
  {
    RowNumber := CustomMapModsGui["listview1"].GetNext(RowNumber,"C")
    If not RowNumber
      Break
    TrueIndex++
    MapAffix := CustomMapModsGui["listview1"].GetText(RowNumber, 2)
    Detail   := CustomMapModsGui["listview1"].GetText(RowNumber, 3)
    ModType  := CustomMapModsGui["listview1"].GetText(RowNumber, 5)
    Weight   := CustomMapModsGui["listview1"].GetText(RowNumber, 6)
    aux := {"ID":TrueIndex,"Map Affix":MapAffix,"Map Detail":Detail,"Mod Type":ModType,"Weight":Weight}
    WR.CustomMapMods.MapMods.Push(aux)
  }
  Settings("CustomMapMods","Save")
}

ResetMapData(*)
{
  global CustomMapModsGui
  Loop CustomMapModsGui["listview1"].GetCount()
    CustomMapModsGui["listview1"].Modify(A_Index,"-Check")
  WR.CustomMapMods.MapMods := []
  Settings("CustomMapMods","Save")
}

SaveHeistData(*)
{
  global CustomMapModsGui
  TrueIndex := 0
  WR.CustomMapMods.HeistMods := []
  RowNumber := 0
  Loop
  {
    RowNumber := CustomMapModsGui["listview1"].GetNext(RowNumber,"C")
    If not RowNumber
      Break
    TrueIndex++
    MapAffix := CustomMapModsGui["listview1"].GetText(RowNumber, 2)
    Detail   := CustomMapModsGui["listview1"].GetText(RowNumber, 3)
    ModType  := CustomMapModsGui["listview1"].GetText(RowNumber, 5)
    Weight   := CustomMapModsGui["listview1"].GetText(RowNumber, 6)
    aux := {"ID":TrueIndex,"Map Affix":MapAffix,"Map Detail":Detail,"Mod Type":ModType,"Weight":Weight}
    WR.CustomMapMods.HeistMods.Push(aux)
  }
  Settings("CustomMapMods","Save")
}

ResetHeistData(*)
{
  global CustomMapModsGui
  Loop CustomMapModsGui["listview1"].GetCount()
    CustomMapModsGui["listview1"].Modify(A_Index,"-Check")
  WR.CustomMapMods.HeistMods := []
  Settings("CustomMapMods","Save")
}
