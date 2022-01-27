RefreshModList(type){
  For k, v in ModsBeta
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

RefreshModList2(type){
  For k, v in ModsClaw["normal"]
  {
    LV_Add("",v["Name"],v["Code"],v["Level"],FixName(v["str"]))
  }
  ;; Style
  Loop % LV_GetCount("Column")
  {
    LV_ModifyCol(A_Index,"AutoHdr")
  }
}
Return

FixName(content){
  ; content := RegExReplace(content, "^Adds <.+>", "Adds #")
  ; content := RegExReplace(content, "^<.+>", "#")
  content := RegExReplace(content,"\<.*?\>","")
  content := RegExReplace(content,"&ndash;","-")
  return content
}




ModsUI:
  Gui, ModsUI1: New
  Gui, ModsUI1: Default
  Gui, ModsUI1: +AlwaysOnTop -MinimizeBox +LabelCustomUndesirable
  Gui, ModsUI1: Add, ListView , w1200 h800 -wrap -Multi Grid Checked vlistview1, PreSu|Name|LvL|statsid|statsmin|statsmax
  RefreshModList("str_armour")
  Gui, ModsUI1: Show, , Str Armour Bases
Return

ModsUI2:
  Gui, ModsUI1: New
  Gui, ModsUI1: Default
  Gui, ModsUI1: +AlwaysOnTop -MinimizeBox +LabelCustomUndesirable
  Gui, ModsUI1: Add, ListView , w1200 h800 -wrap -Multi Grid Checked vlistview1, Name|Code|Level|ModString
  RefreshModList2("str_armour")
  Gui, ModsUI1: Show, , Str Armour Bases
Return

