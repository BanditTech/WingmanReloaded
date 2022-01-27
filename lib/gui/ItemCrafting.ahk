RefreshModList(type){
  auxlist:= ["normal","elder","shaper","crusader","redeemer","hunter","warlord"]

  For ki ,vi in auxlist
  {
    For k, v in Mods%type%[vi]
    {
      If (v["ModGenerationTypeID"] == 1)
      {
        Gui, ListView, LVP
        LV_Add("",vi,v["Name"],v["Level"],FixName(v["str"]),v["Code"])
      }
      Else
      {
        Gui, ListView, LVS
        LV_Add("",vi,v["Name"],v["Level"],FixName(v["str"]),v["Code"])
      }
  }
  }
  ;; Style
  Gui, ListView, LVP
  Loop % LV_GetCount("Column")
  {
    LV_ModifyCol(A_Index,"AutoHdr")
  }
  Gui, ListView, LVS
  Loop % LV_GetCount("Column")
  {
    LV_ModifyCol(A_Index,"AutoHdr")
  }
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
  Gui, ModsUI1: Add, Text,, Prefix
  Gui, ModsUI1: Add, ListView , w1200 h350 -wrap -Multi Grid Checked vLVP, Type|Affix Name|ILvL|Detail|Code
  Gui, ModsUI1: Add, Text,, Suffix
  Gui, ModsUI1: Add, ListView , w1200 h350 -wrap -Multi Grid Checked vLVS, Type|Affix Name|ILvL|Detail|Code
  RefreshModList("Claw")
  Gui, ModsUI1: Show, , Mod List
Return