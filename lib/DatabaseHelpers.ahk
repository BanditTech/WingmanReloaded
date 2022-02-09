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
                    If(index := CheckAffixWR(AffixWRLine,WR.ActualTier[vii],v["ModGenerationTypeID"]))
                    {
                        WR.ActualTier[vii][index]["AffixLine"].Push(v["Name"])
                        WR.ActualTier[vii][index]["ILvL"].Push(v["Level"])
                    }
                    Else
                    {
                        aux := {"ActualTierName":ActualTierName,"ModGenerationTypeID":v["ModGenerationTypeID"],"AffixWRLine":FirstLineToWRFormat(v["str"]),"AffixLine":[v["Name"]],"ILvL":[v["Level"]]}
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

CheckAffixWR(Line,Obj,ModGenerationTypeID){
    for k , v in Obj
    {
        If(v["AffixWRLine"] == Line && ModGenerationTypeID == v["ModGenerationTypeID"]){
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

CraftingBasesRequest(YesCraftingBaseAutoUpdateOnStart){
    If(!YesCraftingBaseAutoUpdateOnStart){
        Return
    }
    If (AccountNameSTR = ""){
        AccountNameSTR := POE_RequestAccount().accountName
    }
    Object := POE_RequestStash(StashTabCrafting,0)
    ClearQuantCraftingBase()
    For k, v in Object.items
    {
        item := new ItemBuild(v,Object.quadLayout)
        text := % "Item Base: "item["Prop"]["ItemBase"]" Item Name: "item["Prop"]["ItemName"]" Item Higher ILvL Found: "item["Prop"]["CraftingBaseHigherILvLFound"]" Item Quant Found: "item["Prop"]["CraftingBaseQuantFound"]
        Log("CraftingBasesRequest",text)
    }
    Return
}

ClearQuantCraftingBase(){
    for ki,vi in ["str_armour","dex_armour","int_armour","str_dex_armour","str_int_armour","dex_int_armour","amulet","ring","belt","weapon"]{
        for k,v in WR.CustomCraftingBases[vi]{
            v.Quant:=0
            v.ILvL:=0
        }
    }
    Return
}