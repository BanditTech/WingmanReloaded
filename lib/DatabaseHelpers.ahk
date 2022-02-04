

ActualTierCreator()
{
    For kii , vii in PoeDBAPI
    {
        Mods := LoadOnDemand(vii)
        WR.ActualTier[vii] := []
        For ki ,vi in ["normal"]
        {
            For k, v in Mods[vi]
            {
                AffixWRLine := FirstLineToWRFormat(v["str"])
                If(index := CheckAffixWR(AffixWRLine,WR.ActualTier[vii]))
                {
                    WR.ActualTier[vii][index]["AffixLine"].Push(v["Name"])
                    WR.ActualTier[vii][index]["ILvL"].Push(v["Level"])
                }
                Else
                {
                    aux := {"AffixWRLine":FirstLineToWRFormat(v["str"]),"AffixLine":[v["Name"]],"ILvL":[v["Level"]]}
                    WR.ActualTier[vii].Push(aux)
                }
            }
        }
    }
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

trimArray(arr) { ; Hash O(n) 

    hash := {}, newArr := []

    for e, v in arr
        if (!hash[v])
        hash[(v)] := 1, newArr.push(v)

    return newArr
}

FirstLineToWRFormat(FullLine)
{
    FullLine := ItemCraftingNaming(FullLine)
    ;SplittedModLine := StrSplit(FullLine, " | ")
    ; Start Aux
    StartingPos := 1
    ;FullLine := SplittedModLine[1]

    ; Create WR Mod Line
    Line := RegExReplace(FullLine,"\(" rxNum "-" rxNum "\)", "$1")
    Line := RegExReplace(Line,"\(-" rxNum "--" rxNum "\)", "$1")
    Mod := RegExReplace(Line, "\+?"rxNum , "#")
    Return Mod
}
