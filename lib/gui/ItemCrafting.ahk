RefreshModList(type){
  For k, v in Mods%type%["normal"]
  {
    If (v["ModGenerationTypeID"] == 1)
    {
      Affix :=  "Prefix"
    }
    Else
    {
      Affix := "Suffix"
    }
    LV_Add("",Affix,v["Name"],v["Code"],v["Level"],FixName(v["str"]))
  }
  ;; Style
  Loop % LV_GetCount("Column")
  {
    LV_ModifyCol(A_Index,"AutoHdr")
  }
  LV_ModifyCol(1,"Sort")
}
Return

FixName(content){
  content := RegExReplace(content,"\<br\>"," \n ")
  content := RegExReplace(content,"\<.*?\>","")
  content := RegExReplace(content,"&ndash;","-")
  return content
}


ModsUI:
  Gui, ModsUI1: New
  Gui, ModsUI1: Default
  Gui, ModsUI1: +AlwaysOnTop -MinimizeBox
  Gui, ModsUI1: Add, ListView , w1200 h800 -wrap -Multi Grid Checked vlistview1, Affix|Name|Code|ILvL|Full String
  RefreshModList("Claw")
  Gui, ModsUI1: Show, , Mod List %
Return