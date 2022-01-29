; Main UI

ModsUI:
    Gui, ModsUI1: New
    Gui, ModsUI1: Default
    Gui, ModsUI1: +AlwaysOnTop -MinimizeBox
    Gui, ModsUI1: Add, Text,, Prefix List
    Gui, ModsUI1: Add, ListView , w1200 h350 -wrap -Multi Grid Checked vLVP, Influence|Affix Name|ILvL|Detail|Code
    Gui, ModsUI1: Add, Text,, Suffix List
    Gui, ModsUI1: Add, ListView , w1200 h350 -wrap -Multi Grid Checked vLVS, Influence|Affix Name|ILvL|Detail|Code
    RefreshModList(ItemClassSelector)
    Gui, ModsUI1: Add, Button, gSaveItemCrafting x+5 w120 h30 center, Save
    Gui, ModsUI1: Add, Button, gResetItemCrafting w120 h30 center, Reset
    Gui, ModsUI1: Show, , %ItemClassSelector% Affix List 
Return

ResetItemCrafting:
    Gui, ListView, LVP
    Loop % LV_GetCount()
        LV_Modify(A_Index,"-Check")
    Gui, ListView, LVS
    Loop % LV_GetCount()
        LV_Modify(A_Index,"-Check")
Return

SaveItemCrafting:
    WR.ItemCrafting.Active := []
    RowNumber := 0
    Gui, ListView, LVP
    Loop
    {
        RowNumber := LV_GetNext(RowNumber,"C")
        If not RowNumber
            break
        LV_GetText(ModLine, RowNumber,4)
        ;Parse ModLine Missing
        aux := {"Mod":ModLine,"Value":"0","ModGenerationTypeID":"1"}
        WR.ItemCrafting.Active.push(aux)
    }
    RowNumber := 0
    Gui, ListView, LVS
    Loop
    {
        RowNumber := LV_GetNext(RowNumber,"C")
        If not RowNumber
            break
        LV_GetText(ModLine, RowNumber,4)
        ;Parse ModLine Missing
        aux := {"Mod":ModLine,"Value":"0","ModGenerationTypeID":"2"}
        WR.ItemCrafting.Active.push(aux)
    }
    Settings("ItemCrafting","Save")
Return

ChooseMenuTest:
    Gui,Submit, Nohide
Return

;; Functions
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
            ModLine := RegExReplace(v["str"],"\<br\>"," \n ")
            ModLine := RegExReplace(content,"\<.*?\>","")
            ModLine := RegExReplace(content,"–","-")
            If (v["ModGenerationTypeID"] == 1)
            {
                Gui, ListView, LVP
                StringUpper, vi, vi, T
                LV_Add("",vi,v["Name"],v["Level"],ModLine,v["Code"])
            }else {
                Gui, ListView, LVS
                StringUpper, vi, vi, T
                LV_Add("",vi,v["Name"],v["Level"],ModLine,v["Code"])
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
        For k, v in WR.ItemCrafting.Active
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
        For k, v in WR.ItemCrafting.Active
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