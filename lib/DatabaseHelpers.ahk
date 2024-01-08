LoadActualTierName() {
    Return JSON.Load(FileOpen(A_ScriptDir "\data\ActualTierName.json","r").Read())
}

ActualTierCreator() {
    ActualTierNameJSON := LoadActualTierName()
    For kii , vii in POEData{
        WR.ActualTier[kii] := []
        for kiii, viii in vii{
            Mods := LoadOnDemand(kii,viii)
            For k, v in Mods
            {
                if(v["influence"] == "Normal"){
                    AffixWRLine := FirstLineToWRFormat(v["text"])
                    ModGenerationType := v["generation_type"]
                    If(ActualTierName:=CheckAffixWRFromJson(AffixWRLine,ModGenerationType,ActualTierNameJSON)) {
                        If(index := CheckAffixWR(AffixWRLine,v["generation_type"],WR.ActualTier[kii])) {
                            aux := False
                            aux2 := 0
                            for a, b in WR.ActualTier[kii][index]["ILvL"]{
                                if (b == v["required_level"]){
                                    aux := true
                                    break
                                }
                                if(v["required_level"] > b){
                                    aux2 = %A_Index%
                                }
                            }
                            if(!aux){
                                WR.ActualTier[kii][index]["AffixLine"].InsertAt(aux2+1, v["name"])
                                WR.ActualTier[kii][index]["ILvL"].InsertAt(aux2+1, v["required_level"])
                            }
                        } Else {
                            aux := {"ActualTierName":ActualTierName,"ModGenerationType":v["generation_type"],"AffixWRLine":FirstLineToWRFormat(v["text"]),"AffixLine":[v["name"]],"ILvL":[v["required_level"]]}
                            WR.ActualTier[kii].Push(aux)
                        }
                    }
                }
            }
        }
    }
    ;Save Json
    Settings("ActualTier","Save")
    Return
}

CheckAffixWR(Line,ModGenerationType,Obj) {
    for k , v in Obj {
        If (v["AffixWRLine"] == Line && ModGenerationType == v["ModGenerationType"]) {
            Return k
        }
    }
}

CheckAffixWRFromJson(Line,ModGenerationType,Obj) {
    for k , v in Obj {
        If(v["AffixWRLine"] == Line and (v["ModGenerationType"] == ModGenerationType)) {
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
        Log("Crafting Bases Request","You need define your account name in save/Account.ini",Strings*)
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