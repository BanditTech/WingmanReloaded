LoadActualTierName() {
    Return JSON.Load(FileOpen(A_ScriptDir "\data\ActualTierName.json","r").Read())
}

ActualTierCreator() {
    ActualTierNameJSON := LoadActualTierName()
    For kii , vii in PoeDBAPI {
        Mods := LoadOnDemand(vii)
        WR.ActualTier[vii] := []
        For ki ,vi in ["normal"] {
            For k, v in Mods[vi] {
                AffixWRLine := FirstLineToWRFormat(v["str"])
                If(ActualTierName:=CheckAffixWRFromJson(AffixWRLine,ActualTierNameJSON)) {
                    If(index := CheckAffixWR(AffixWRLine,WR.ActualTier[vii],v["ModGenerationTypeID"])) {
                        WR.ActualTier[vii][index]["AffixLine"].Push(v["Name"])
                        WR.ActualTier[vii][index]["ILvL"].Push(v["Level"])
                    } Else {
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

CheckAffixWR(Line,Obj,ModGenerationTypeID) {
    for k , v in Obj {
        If (v["AffixWRLine"] == Line && ModGenerationTypeID == v["ModGenerationTypeID"]) {
            Return k
        }
    }
}

CheckAffixWRFromJson(Line,Obj) {
    for k , v in Obj {
        If(v["AffixWRLine"] == Line) {
            aux:= "ActualTier" . v["ActualTierName"]
            Return aux
        }
    }
}

FirstLineToWRFormat(FullLine) {
    FullLine := ItemCraftingNaming(FullLine)
    ; Create WR Mod Line
    Line := RegExReplace(FullLine,"\(" rxNum "-" rxNum "\)", "$1")
    Line := RegExReplace(Line,"\(-" rxNum "--" rxNum "\)", "$1")
    Mod := RegExReplace(Line, "\+?"rxNum , "#")
    Return Mod
}

CraftingBasesRequest(ShouldRun) {
    If (!ShouldRun || PoECookie == "") {
        Return
    }
    If (!AccountNameSTR) {
        Log("Crafting Bases Request","You need def your account name in save/Account.ini",Strings*)
        Return
    }
    Object := PoERequest.Stash(StashTabCrafting)
    ClearQuantCraftingBase()
    Strings := []
    For k, v in Object.items {
        item := new ItemBuild(v,Object.quadLayout)
        Strings.Push("Item Base: " item["Prop"]["ItemBase"] 
        . ", Name: " item["Prop"]["ItemName"] 
        . ", ILVL: " item["Prop"]["CraftingBaseHigherILvLFound"] 
        . ", Quantity: " item["Prop"]["CraftingBaseQuantFound"])
    }
    Log("Crafting Bases ","Refreshing quantity and minimum ilvl from stash items",Strings*)
    Return
}

ClearQuantCraftingBase() {
    for ki,vi in ["str_armour","dex_armour","int_armour","str_dex_armour","str_int_armour","dex_int_armour","amulet","ring","belt","weapon","quiver"]{
        for k,v in WR.CustomCraftingBases[vi] {
            v.Quant:=0
            v.ILvL:=0
        }
    }
    Return
}