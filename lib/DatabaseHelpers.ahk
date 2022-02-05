LoadActualTierName()
{
    FileRead, JSONtext, %A_ScriptDir%\data\ActualTierName.json
    Return JSON.Load(JSONtext)
}

ActualTierCreator()
{
    ActualTierNameJSON := LoadActualTierName()
    For kii , vii in PoeDBAPI
    {
        Mods := LoadOnDemand(vii)
        WR.ActualTier[vii] := []
        For ki ,vi in ["normal"]
        {
            For k, v in Mods[vi]
            {
                AffixWRLine := FirstLineToWRFormat(v["str"])
                If(ActualTierName:=CheckAffixWRFromJson(AffixWRLine,ActualTierNameJSON))
                {
                    If(index := CheckAffixWR(AffixWRLine,WR.ActualTier[vii]))
                    {
                        WR.ActualTier[vii][index]["AffixLine"].Push(v["Name"])
                        WR.ActualTier[vii][index]["ILvL"].Push(v["Level"])
                    }
                    Else
                    {
                        aux := {"ActualTierName":ActualTierName,"AffixWRLine":FirstLineToWRFormat(v["str"]),"AffixLine":[v["Name"]],"ILvL":[v["Level"]]}
                        WR.ActualTier[vii].Push(aux)
                    }
                }

            }
        }
    }
    ;Free at End
    Mods := []
    ;Save Json
    Settings("ActualTier","Save")
    Return
}

CheckAffixWR(Line,Obj){
    for k , v in Obj
    {
        If(v["AffixWRLine"] == Line){
            Return k
        }
    }
}

CheckAffixWRFromJson(Line,Obj){
    for k , v in Obj
    {
        If(v["AffixWRLine"] == Line){
            aux:= "ActualTier" . v["ActualTierName"]
            Return aux
        }
    }
}

FirstLineToWRFormat(FullLine)
{
    FullLine := ItemCraftingNaming(FullLine)
    ; Create WR Mod Line
    Line := RegExReplace(FullLine,"\(" rxNum "-" rxNum "\)", "$1")
    Line := RegExReplace(Line,"\(-" rxNum "--" rxNum "\)", "$1")
    Mod := RegExReplace(Line, "\+?"rxNum , "#")
    Return Mod
}
