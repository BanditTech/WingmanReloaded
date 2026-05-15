; Wingman Crafting Labels - By DanMarzola

RefreshBaseList(type){
  global CustomCraftingBaseGui, CraftingBaseTypeSelector
  CraftingBaseTypeSelector := type
  For k, v in Bases
  {
    If (k ~= "Royale[\d_]?$")
      Continue
    if(type == "str_armour"){
      If (IndexOf(type,v["tags"])){
        translateimplicit := (v["implicits"][1] != "" ? ModAlias.Translate(v["implicits"][1]) : 0)
        CustomCraftingBaseGui["listview1"].Add("",v["item_class"],v["name"],"0","0",RegexFixLeadingZeros(2,v["drop_level"]),RegexFixLeadingZeros(3,v["properties"]["armour"]["min"]),(translateimplicit ? translateimplicit : v["implicits"][1]))
      }
    }else if(type == "dex_armour"){
      If (IndexOf(type,v["tags"])){
        translateimplicit := (v["implicits"][1] != "" ? ModAlias.Translate(v["implicits"][1]) : 0)
        CustomCraftingBaseGui["listview1"].Add("",v["item_class"],v["name"],"0","0",RegexFixLeadingZeros(2,v["drop_level"]),RegexFixLeadingZeros(3,v["properties"]["evasion"]["min"]),(translateimplicit ? translateimplicit : v["implicits"][1]))
      }
    }else if(type == "int_armour"){
      If (IndexOf(type,v["tags"])){
        translateimplicit := (v["implicits"][1] != "" ? ModAlias.Translate(v["implicits"][1]) : 0)
        CustomCraftingBaseGui["listview1"].Add("",v["item_class"],v["name"],"0","0",RegexFixLeadingZeros(2,v["drop_level"]),RegexFixLeadingZeros(3,v["properties"]["energy_shield"]["min"]),(translateimplicit ? translateimplicit : v["implicits"][1]))
      }
    }else if(type == "str_dex_armour"){
      If (IndexOf(type,v["tags"])){
        translateimplicit := (v["implicits"][1] != "" ? ModAlias.Translate(v["implicits"][1]) : 0)
        CustomCraftingBaseGui["listview1"].Add("",v["item_class"],v["name"],"0","0",RegexFixLeadingZeros(2,v["drop_level"]),RegexFixLeadingZeros(3,v["properties"]["armour"]["min"]),RegexFixLeadingZeros(3,v["properties"]["evasion"]["min"]),(translateimplicit ? translateimplicit : v["implicits"][1]))
      }
    }else if(type == "str_int_armour"){
      If (IndexOf(type,v["tags"])){
        translateimplicit := (v["implicits"][1] != "" ? ModAlias.Translate(v["implicits"][1]) : 0)
        CustomCraftingBaseGui["listview1"].Add("",v["item_class"],v["name"],"0","0",RegexFixLeadingZeros(2,v["drop_level"]),RegexFixLeadingZeros(3,v["properties"]["armour"]["min"]),RegexFixLeadingZeros(3,v["properties"]["energy_shield"]["min"]),(translateimplicit ? translateimplicit : v["implicits"][1]))
      }
    }else if(type == "dex_int_armour"){
      If (IndexOf(type,v["tags"])){
        translateimplicit := (v["implicits"][1] != "" ? ModAlias.Translate(v["implicits"][1]) : 0)
        CustomCraftingBaseGui["listview1"].Add("",v["item_class"],v["name"],"0","0",RegexFixLeadingZeros(2,v["drop_level"]),RegexFixLeadingZeros(3,v["properties"]["evasion"]["min"]),RegexFixLeadingZeros(3,v["properties"]["energy_shield"]["min"]),(translateimplicit ? translateimplicit : v["implicits"][1]))
      }
    }else if(type == "amulet"){
      If (IndexOf(type,v["tags"]) && !IndexOf("talisman",v["tags"])){
        translateimplicit := (v["implicits"][1] != "" ? ModAlias.Translate(v["implicits"][1]) : 0)
        CustomCraftingBaseGui["listview1"].Add("",v["item_class"],v["name"],"0","0",RegexFixLeadingZeros(2,v["drop_level"]),(translateimplicit ? translateimplicit : v["implicits"][1]))
      }
    }else if(type == "belt"){
      If (IndexOf(type,v["tags"])){
        translateimplicit := (v["implicits"][1] != "" ? ModAlias.Translate(v["implicits"][1]) : 0)
        CustomCraftingBaseGui["listview1"].Add("",v["item_class"],v["name"],"0","0",RegexFixLeadingZeros(2,v["drop_level"]),(translateimplicit ? translateimplicit : v["implicits"][1]))
      }
    }else if(type == "ring"){
      If (IndexOf(type,v["tags"])){
        translateimplicit := (v["implicits"][1] != "" ? ModAlias.Translate(v["implicits"][1]) : 0)
        CustomCraftingBaseGui["listview1"].Add("",v["item_class"],v["name"],"0","0",RegexFixLeadingZeros(2,v["drop_level"]),(translateimplicit ? translateimplicit : v["implicits"][1]))
      }
    }else if(type == "weapon"){
      If (IndexOf(type,v["tags"])){
        translateimplicit := (v["implicits"][1] != "" ? ModAlias.Translate(v["implicits"][1]) : 0)
        CustomCraftingBaseGui["listview1"].Add("",v["item_class"],v["name"],"0","0",RegexFixLeadingZeros(2,v["drop_level"]),(translateimplicit ? translateimplicit : v["implicits"][1]))
      }
    }else if(type == "quiver"){
      If (IndexOf(type,v["tags"])){
        translateimplicit := (v["implicits"][1] != "" ? ModAlias.Translate(v["implicits"][1]) : 0)
        CustomCraftingBaseGui["listview1"].Add("",v["item_class"],v["name"],"0","0",RegexFixLeadingZeros(2,v["drop_level"]),(translateimplicit ? translateimplicit : v["implicits"][1]))
      }
    }
  }

  ;; Retrive bases from custom crafting bases json to check box
  Loop CustomCraftingBaseGui["listview1"].GetCount()
  {
    Index := A_Index
    OutputVar := CustomCraftingBaseGui["listview1"].GetText(A_Index, 2)
    For k, v in WR.CustomCraftingBases.%type%{
      if (v.BaseName == OutputVar){
        CustomCraftingBaseGui["listview1"].Modify(Index,"Check",,,v.ILvL,v.Quant)
        Break
      }
    }
  }

  ;; Style
  Loop CustomCraftingBaseGui["listview1"].GetCount("Column")
  {
    CustomCraftingBaseGui["listview1"].ModifyCol(A_Index,"AutoHdr")
  }
  CustomCraftingBaseGui["listview1"].ModifyCol(1, 120)
  CustomCraftingBaseGui["listview1"].ModifyCol(2, 140)
  CustomCraftingBaseGui["listview1"].ModifyCol(5,"SortDesc")
  CustomCraftingBaseGui["listview1"].ModifyCol(1,"Sort")
}

RegexFixLeadingZeros(digits,content){
  if(content==""){
    content := ""
  }
  else if(digits==2){
    Loop 2
    {
      content := RegExReplace(content, "(?<!\d)\d(?!\d)", "0$0")
    }
  }else if(digits==3){
    Loop 2
    {
      content := RegExReplace(content, "(?<!\d)\d(?!\d)", "00$0")
      content := RegExReplace(content, "(?<!\d)\d{2}(?!\d)", "0$0")
    }
  }
  return content
}

CraftingBaseUI(title, type, columns)
{
  global CustomCraftingBaseGui, CraftingBaseTypeSelector
  CraftingBaseTypeSelector := type
  CustomCraftingBaseGui := Gui()
  CustomCraftingBaseGui.Opt("+AlwaysOnTop -MinimizeBox")
  CustomCraftingBaseGui.Add("ListView", "w900 h400 -wrap -Multi Grid Checked vlistview1", columns)
  RefreshBaseList(type)
  btn1 := CustomCraftingBaseGui.Add("Button", "x+5 w120 h30 center", "Save")
  btn1.OnEvent("Click", SaveCraftingBase)
  btn2 := CustomCraftingBaseGui.Add("Button", "w120 h30 center", "Reset")
  btn2.OnEvent("Click", ResetCraftingBase)
  CustomCraftingBaseGui.Show("", title)
}

CraftingBaseSTRUI(*)
{
  CraftingBaseUI("Str Armour Bases", "str_armour", ["Item Class","Base Name","Max ILvL Found","Stashed","Drop Level","Base Armour","Implicit"])
}

CraftingBaseDEXUI(*)
{
  CraftingBaseUI("Dex Armour Bases", "dex_armour", ["Item Class","Base Name","Max ILvL Found","Stashed","Drop Level","Base Evasion","Implicit"])
}

CraftingBaseINTUI(*)
{
  CraftingBaseUI("Int Armour Bases", "int_armour", ["Item Class","Base Name","Max ILvL Found","Stashed","Drop Level","Base Energy Shield","Implicit"])
}

CraftingBaseSTRDEXUI(*)
{
  CraftingBaseUI("StrDex Armour Bases", "str_dex_armour", ["Item Class","Base Name","Max ILvL Found","Stashed","Drop Level","Base Armour","Base Evasion","Implicit"])
}

CraftingBaseSTRINTUI(*)
{
  CraftingBaseUI("StrInt Armour Bases", "str_int_armour", ["Item Class","Base Name","Max ILvL Found","Stashed","Drop Level","Base Armour","Base Energy Shield","Implicit"])
}

CraftingBaseDEXINTUI(*)
{
  CraftingBaseUI("DexInt Armour Bases", "dex_int_armour", ["Item Class","Base Name","Max ILvL Found","Stashed","Drop Level","Base Evasion","Base Energy Shield","Implicit"])
}

CraftingBaseAMULETUI(*)
{
  CraftingBaseUI("Amulet Bases", "amulet", ["Item Class","Base Name","Max ILvL Found","Stashed","Drop Level","Implicit"])
}

CraftingBaseRINGUI(*)
{
  CraftingBaseUI("Ring Bases", "ring", ["Item Class","Base Name","Max ILvL Found","Stashed","Drop Level","Implicit"])
}

CraftingBaseBELTUI(*)
{
  CraftingBaseUI("Belt Bases", "belt", ["Item Class","Base Name","Max ILvL Found","Stashed","Drop Level","Implicit"])
}

CraftingBaseWEAPONUI(*)
{
  CraftingBaseUI("Belt Bases", "weapon", ["Item Class","Base Name","Max ILvL Found","Stashed","Drop Level","Implicit"])
}

CraftingBaseQUIVERUI(*)
{
  CraftingBaseUI("Quiver Bases", "quiver", ["Item Class","Base Name","Max ILvL Found","Stashed","Drop Level","Implicit"])
}

ResetCraftingBase(*)
{
  global CustomCraftingBaseGui, CraftingBaseTypeSelector
  Loop CustomCraftingBaseGui["listview1"].GetCount()
  {
    CustomCraftingBaseGui["listview1"].Modify(A_Index,"-Check")
  }
  WR.CustomCraftingBases.%CraftingBaseTypeSelector% := []
  Settings("CustomCraftingBases","Save")
}

SaveCraftingBase(*)
{
  global CustomCraftingBaseGui, CraftingBaseTypeSelector
  RowNumber := 0
  WR.CustomCraftingBases.%CraftingBaseTypeSelector% := []
  Loop
  {
    RowNumber := CustomCraftingBaseGui["listview1"].GetNext(RowNumber,"C")
    if not RowNumber
      break
    BaseName := CustomCraftingBaseGui["listview1"].GetText(RowNumber, 2)
    aux := {BaseName:BaseName, ILvL:"0", Quant:"0"}
    WR.CustomCraftingBases.%CraftingBaseTypeSelector%.Push(aux)
  }
  Settings("CustomCraftingBases","Save")
}
