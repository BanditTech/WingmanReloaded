#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
  SaveDir := RegExReplace(A_ScriptDir, "data$", "save")
  SetWorkingDir %SaveDir%

  FileRead, JSONtext, LootFilter.json
  LootFilter := JSON.Load(JSONtext)
  If !LootFilter
    LootFilter:= {}
  ReLootFilter := {} 
  For GKey, Gval in LootFilter
  {
    TempProp := []
    TempAffix := []
    If !(Gval.HasKey("OrCount"))
      Gval["OrCount"] := 1
    For SKey, Sval in Gval
    {
      If (SKey = "OrCount" || SKey = "StashTab" || SKey = "Data")
        Continue
      
      For AKey, Aval in Sval
      {
        If (InStr(AKey, "Eval") || InStr(AKey, "Min") || InStr(AKey, "OrFlag"))
          Continue
        If ( SKey = "Stats" || SKey = "Prop" )
        {
          TempProp.Push({"#Key":(SwapKeyName(Sval[AKey])),"Eval":Sval[AKey . "Eval"], "Min":Sval[AKey "Min"], "OrFlag":Sval[AKey "OrFlag"]})
        }
        Else If ( SKey = "Affix" )
        {
          TempAffix.Push({"#Key":(SwapKeyName(Sval[AKey])),"Eval":Sval[AKey . "Eval"], "Min":Sval[AKey "Min"], "OrFlag":Sval[AKey "OrFlag"]})
        }
      }
    }
    nKey := ReplaceDigit000(GKey)
    ReLootFilter[nKey] := {}
    ReLootFilter[nKey].Prop := TempProp
    ReLootFilter[nKey].Affix := TempAffix
    ReLootFilter[nKey].Data := {"StashTab":Gval["StashTab"],"OrCount":Gval["OrCount"]}
  }

  ; FileAppend, JSONtext, LootFilter.Backup.json
  FileCopy, LootFilter.json, LootFilter.%A_Now%.json, 0
  FileDelete, LootFilter.json
  FileAppend,% JSON.Dump(ReLootFilter,,1) , LootFilter.json
ExitApp 

#Include, %A_ScriptDir%/Library.ahk

ReplaceDigit000(Name:="Group1"){
  Return "Group" . Format("{1:03i}",StrSplit(Name,," ",6)[6])
}

SwapKeyName(KeyName:=""){
  If (KeyName = "IncreasedEnergyShield")
    Return "# increased Energy Shield"
  If (KeyName = "MaximumEnergyShield")
    Return "# to maximum Energy Shield"
  If (KeyName = "MaximumLife")
    Return "# increased maximum Life"
  If (KeyName = "IncreasedMovementSpeed")
    Return "# increased Movement Speed"
  If (KeyName = "PseudoColdResist")
    Return "(Pseudo) Total to Cold Resistance"
  If (KeyName = "PseudoFireResist")
    Return "(Pseudo) Total to Fire Resistance"
  If (KeyName = "PseudoLightningResist")
    Return "(Pseudo) Total to Lightning Resistance"
  If (KeyName = "PseudoChaosResist")
    Return "(Pseudo) Total to Chaos Resistance"
  If (KeyName = "ColdResist")
    Return "# to Cold Resistance"
  If (KeyName = "FireResist")
    Return "# to Fire Resistance"
  If (KeyName = "LightningResist")
    Return "# to Lightning Resistance"
  If (KeyName = "ChaosResist")
    Return "# to Chaos Resistance"

  If (KeyName = "AddedAccuracy")
    Return "# to Accuracy Rating"
  If (KeyName = "ChanceBlock")
    Return "# Chance to Block Attack Damage"
  If (KeyName = "ChanceBlockSpell")
    Return "# Chance to Block Spell Damage"

  If (KeyName = "IncreasedAttackSpeed")
    Return "# increased Attack Speed"
  If (KeyName = "IncreasedCritChance")
    Return "# increased Critical Strike Chance"
  If (KeyName = "GlobalCriticalMultiplier")
    Return "# to Global Critical Strike Multiplier"
  If (KeyName = "AddedArmour")
    Return "# to Armour"
  If (KeyName = "AddedEvasion")
    Return "# to Evasion Rating"

  If (KeyName = "PseudoIncreasedColdDamage")
    Return "(Pseudo) Increased Cold Damage"
  If (KeyName = "PseudoIncreasedFireDamage")
    Return "(Pseudo) Increased Fire Damage"
  If (KeyName = "PseudoIncreasedLightningDamage")
    Return "(Pseudo) Increased Lightning Damage"
  If (KeyName = "IncreasedSpellDamage")
    Return "# increased Spell Damage"
  If (KeyName = "IncreasedSpellCritChance")
    Return "# increased Critical Strike Chance for Spells"
  If (KeyName = "ChaosDOTMult")
    Return "# to Chaos Damage over Time Multiplier"
  If (KeyName = "ReducedFlaskChargesUsed")
    Return "# reduced Flask Charges used"
  If (KeyName = "PhysicalDamageAttackAvg")
    Return "Adds # to # Physical Damage to Attacks_Avg"
  If (KeyName = "IncreasedElementalAttack")
    Return "# increased Elemental Damage with Attack Skills"

  If (KeyName = "IncreasedCastSpeed")
    Return "# increased Cast Speed"
  If (KeyName = "IncreasedMaximumEnergyShield")
    Return "# increased maximum Energy Shield"
  ; If (KeyName = "PseudoTotalAddedEleAvgSpell")
  ;   Return ""
  If (KeyName = "IncreasedPhysicalDamage")
    Return "# increased Physical Damage"

  If (KeyName = "AddedLevelGems")
    Return "# to Level of Socketed Gems"
  If (KeyName = "AddedLevelMinionGems")
    Return "# to Level of Socketed Minion Gems"
  If (KeyName = "AddedLevelMeleeGems")
    Return "# to Level of Socketed Melee Gems"
  If (KeyName = "AddedLevelBowGems")
    Return "# to Level of Socketed Bow Gems"
  If (KeyName = "AddedLevelFireGems")
    Return "# to Level of Socketed Fire Gems"
  If (KeyName = "AddedLevelColdGems")
    Return "# to Level of Socketed Cold Gems"
  If (KeyName = "AddedLevelLightningGems")
    Return "# to Level of Socketed Lightning Gems"
  If (KeyName = "AddedLevelChaosGems")
    Return "# to Level of Socketed Chaos Gems"
  
  Return KeyName
}