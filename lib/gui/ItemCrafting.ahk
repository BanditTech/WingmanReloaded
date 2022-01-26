RefreshModList(type){
  For k, v in ModsTeste
  {
    if(v["generation_type"] == "suffix"||v["generation_type"] == "prefix"){
      LV_Add("",v["generation_type"],v["name"],v["required_level"],v["stats"][1]["id"],v["stats"][1]["min"],v["stats"][1]["max"])
    }
    
  }
  ;; Style
  Loop % LV_GetCount("Column")
  {
    LV_ModifyCol(A_Index,"AutoHdr")
  }
}
Return



ModsUI:
  Gui, ModsUI1: New
  Gui, ModsUI1: Default
  Gui, ModsUI1: +AlwaysOnTop -MinimizeBox +LabelCustomUndesirable
  Gui, ModsUI1: Add, ListView , w1200 h800 -wrap -Multi Grid Checked vlistview1, PreSu|Name|LvL|statsid|statsmin|statsmax
  RefreshModList("str_armour")
  Gui, ModsUI1: Show, , Str Armour Bases
Return

