RefreshModList(type){
  LoadOnDemand(type)
  For ki ,vi in ["normal","elder","shaper","crusader","redeemer","hunter","warlord"]
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
  FreeOnDemand(type)
  ;;Check Box
  Gui, ListView, LVP
  Loop % LV_GetCount()
  {
    Index := A_Index
    LV_GetText(OutputVar, A_Index , 4)
    For k, v in WR.ItemCrafting.Active{
      if (v.Mod == OutputVar){
        LV_Modify(Index,"Check")
      }
    }
  }
  Gui, ListView, LVS
  Loop % LV_GetCount()
  {
    Index := A_Index
    LV_GetText(OutputVar, A_Index , 4)
    For k, v in WR.ItemCrafting.Active{
      if (v.Mod == OutputVar){
        LV_Modify(Index,"Check")
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
    Gui, ModsUI1: Add, Button, gSaveItemCrafting x+5 w120 h30 center, Save
    Gui, ModsUI1: Add, Button, gResetItemCrafting w120 h30 center, Reset
    Gui, ModsUI1: Show, , Mod List
  Return

  ResetItemCrafting:
    Gui, ListView, LVP
    Loop % LV_GetCount()
    {
      LV_Modify(A_Index,"-Check")
    }
    Gui, ListView, LVS
    Loop % LV_GetCount()
    {
      LV_Modify(A_Index,"-Check")
    }
  Return

  SaveItemCrafting:
    WR.ItemCrafting.Active := []
    RowNumber := 0
    Gui, ListView, LVP
    Loop
    {
      RowNumber := LV_GetNext(RowNumber,"C")
      if not RowNumber
        break
      LV_GetText(ModLine, RowNumber,4)
      ;Parse ModLine Missing
      aux := {"Mod":ModLine,"Value":"0"}
      WR.ItemCrafting.Active.push(aux)
    }
    RowNumber := 0
    Gui, ListView, LVS
    Loop
    {
      RowNumber := LV_GetNext(RowNumber,"C")
      if not RowNumber
        break
      LV_GetText(ModLine, RowNumber,4)
      ;Parse ModLine Missing
      aux := {"Mod":ModLine,"Value":"0"}
      WR.ItemCrafting.Active.push(aux)
    }
    Settings("ItemCrafting","Save")
  Return

LoadOnDemand(content){
  FileRead, JSONtext, %A_ScriptDir%\data\Mods%content%.json
	Mods%content% := JSON.Load(JSONtext)
	JSONtext := ""
}

FreeOnDemand(content){
	Mods%content% := []
}