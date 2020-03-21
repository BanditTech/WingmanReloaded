#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
    ; #Warn  ; The rest of this area is for global settings
    SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
    SaveDir := RTrim(A_ScriptDir, "\data") "\save"
    SetWorkingDir %SaveDir%

    Global xpos, ypos, Maxed
    OnMessage(0x115, "OnScroll") ; WM_VSCROLL	;necessary for scrollable gui windows (must be added before gui lines)
    OnMessage(0x114, "OnScroll") ; WM_HSCROLL	;necessary for scrollable gui windows (must be added before gui lines)
    Global scriptPOEWingman := "PoE-Wingman.ahk ahk_exe AutoHotkey.exe"
    Global scriptPOEWingmanSecondary := "WingmanReloaded ahk_exe AutoHotkey.exe"
    global POEGameArr := ["PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe", "PathOfExile_KG.exe", "PathOfExile_x64_KG.exe"]
    for n, exe in POEGameArr
        GroupAdd, POEGameGroup, ahk_exe %exe%
    Global CLFStashTabDefault := 1
    IniRead, CLFStashTabDefault, LootFilter.ini, LootFilter, CLFStashTabDefault , 1
    Global LootFilter := {}
    Global LootFilterTabs := {}

    Prop := OrderedArray()
      Prop.ItemName := ""
      Prop.ItemBase := ""
      Prop.ItemClass := ""
      Prop.Influence := ""
      Prop.SpecialType := ""
      Prop.CLF_MatchGroup := ""
      Prop.CLF_SendTab := 0
      Prop.Ring := False
      Prop.Amulet := False
      Prop.Belt := False
      Prop.Chromatic := False
      Prop.Jewel := False
      Prop.ClusterJewel := False
      Prop.AbyssJewel := False
      Prop.Essence := False
      Prop.Incubator := False
      Prop.Fossil := False
      Prop.Resonator := False
      Prop.IsOrgan := ""
      Prop.IsBeast := False
      Prop.Jeweler := False
      Prop.TimelessSplinter := False
      Prop.BreachSplinter := False
      Prop.SacrificeFragment := False
      Prop.MortalFragment := False
      Prop.GuardianFragment := False
      Prop.ProphecyFragment := False
      Prop.Scarab := False
      Prop.Offering := False
      Prop.Vessel := False
      Prop.Incubator := False
      Prop.Flask := False
      Prop.Veiled := False
      Prop.Prophecy := False
      Prop.Oil := False
      Prop.ItemLevel := 0
      Prop.DropLevel := 0
      Prop.PredictPrice := 0
      Prop.PredictPriceInfo := ""
      Prop.ChaosValue := 0
      Prop.ExaltValue := 0
      Prop.Rarity := ""
      Prop.RarityCurrency := False
      Prop.RarityDivination := False
      Prop.RarityGem := False
      Prop.RarityNormal := False
      Prop.RarityMagic := False
      Prop.RarityRare := False
      Prop.RarityUnique := False
      Prop.Rarity_Digit := 0
      Prop.QualityAugmented := False
      Prop.Gem_Sockets := 0
      Prop.Gem_RawSockets := ""
      Prop.Gem_Links := 0
      Prop.IsItem := False
      Prop.Item_Width := 1
      Prop.Item_Height := 1
      Prop.IsWeapon := False
      Prop.IsMap := False
      Prop.IsBlightedMap := False
      Prop.MapTier := 0
      Prop.Support := False
      Prop.VaalGem := False
      Prop.AffixCount := 0
      Prop.Identified := True
      Prop.Corrupted := False
      Prop.DoubleCorrupted := False
      Prop.Variant := 0
      Prop.CraftingBase := 0
    textListProp= 
    For k, v in Prop
        textListProp .= (!textListProp ? "" : "|") "" k ""

    Stats := OrderedArray()
      Stats.MapTier := 0
      Stats.MapItemQuantity := 0
      Stats.MapItemRarity := 0
      Stats.MapMonsterPackSize := 0
      Stats.Dps := 0
      Stats.Dps_Q20 := 0
      Stats.Dps_Phys := 0
      Stats.Dps_Ele := 0
      Stats.Dps_Chaos := 0
      Stats.AttackSpeed := 0
      Stats.WeaponRange := 0
      Stats.PhysAvg := 0
      Stats.ChaosAvg := 0
      Stats.EleAvg := 0
      Stats.PhysLo := 0
      Stats.PhysHi := 0
      Stats.ChaosLo := 0
      Stats.ChaosHi := 0
      Stats.EleLo := 0
      Stats.EleHi := 0
      Stats.Quality := 0
      Stats.GemLevel := 0
      Stats.Stack := 0
      Stats.StackMax := 0
      Stats.RequiredLevel := 0
      Stats.RequiredStr := 0
      Stats.RequiredInt := 0
      Stats.RequiredDex := 0
      Stats.RatingArmour := 0
      Stats.RatingEnergyShield := 0
      Stats.RatingEvasion := 0
      Stats.RatingBlock := 0

    textListStats= 
    For k, v in Stats
        textListStats .= (!textListStats ? "" : "|") "" k ""

    Affix := OrderedArray() 
      Affix.Implicit := ""
      Affix.Corruption := ""
      Affix.Corruption2 := ""
      Affix.Corruption3 := ""
      Affix.Corruption4 := ""
      Affix.Corruption5 := ""
      Affix.LabEnchant := ""
      Affix.Annointment := ""
      Affix.MaximumLife := 0
      Affix.IncreasedMaximumLife := 0
      Affix.MaximumEnergyShield := 0
      Affix.IncreasedEnergyShield := 0
      Affix.IncreasedMaximumEnergyShield := 0
      Affix.MaximumMana := 0
      Affix.IncreasedMaximumMana := 0
      Affix.IncreasedMovementSpeed := 0
      Affix.WeaponRange := 0
      Affix.PseudoTotalResist := 0
      Affix.PseudoTotalEleResist := 0
      Affix.PseudoFireResist := 0
      Affix.PseudoColdResist := 0
      Affix.PseudoLightningResist := 0
      Affix.PseudoChaosResist := 0
      Affix.PseudoTotalAddedStats := 0
      Affix.PseudoAddedStrength := 0
      Affix.PseudoAddedDexterity := 0
      Affix.PseudoAddedIntelligence := 0
      Affix.PseudoIncreasedArmour := 0
      Affix.PseudoIncreasedEvasion := 0
      Affix.PseudoIncreasedEnergyShield := 0
      Affix.PseudoTotalAddedAvgAttack := 0
      Affix.PseudoTotalAddedEleAvgAttack := 0
      Affix.PseudoTotalAddedEleAvgSpell := 0
      Affix.PseudoIncreasedColdDamage := 0
      Affix.PseudoIncreasedFireDamage := 0
      Affix.PseudoIncreasedLightningDamage := 0
      Affix.AllElementalResistances := 0
      Affix.ColdLightningResistance := 0
      Affix.FireColdResistance := 0
      Affix.FireLightningResistance := 0
      Affix.ColdResistance := 0
      Affix.FireResistance := 0
      Affix.LightningResistance := 0
      Affix.ChaosResistance := 0
      Affix.AddedLevelGems := 0
      Affix.AddedLevelMinionGems := 0
      Affix.AddedLevelMeleeGems := 0
      Affix.AddedLevelBowGems := 0
      Affix.AddedLevelFireGems := 0
      Affix.AddedLevelColdGems := 0
      Affix.AddedLevelLightningGems := 0
      Affix.AddedLevelChaosGems := 0
      Affix.AddedLevelAllPhysicalSpellGems := 0
      Affix.AddedLevelAllColdSpellGems := 0
      Affix.AddedLevelAllFireSpellGems := 0
      Affix.AddedLevelAllLightningSpellGems := 0
      Affix.AddedLevelAllChaosSpellGems := 0
      Affix.ChaosDOTMult := 0
      Affix.ColdDOTMult := 0
      Affix.SupportGem := ""
      Affix.SupportGemLevel := 0
      Affix.SupportGem2 := ""
      Affix.SupportGem2Level := 0
      Affix.CountSupportGem := 0
      Affix.GrantedSkill := 0
      Affix.GrantedSkillLevel := 0
      Affix.GainFireToExtraChaos := 0
      Affix.GainColdToExtraChaos := 0
      Affix.GainLightningToExtraChaos := 0
      Affix.GainPhysicalToExtraChaos := 0
      Affix.GlobalCriticalChance := 0
      Affix.GlobalCriticalMultiplier := 0
      Affix.IncreasedAttackSpeed := 0
      Affix.IncreasedAttackSpeedWithMoveSkill := 0
      Affix.IncreasedAttackCastSpeed := 0
      Affix.AddedAccuracy := 0
      Affix.LifeGainOnAttack := 0
      Affix.PhysicalLeechLife := 0
      Affix.PhysicalLeechMana := 0
      Affix.EnergyShieldRegen := 0
      Affix.LifeRegeneration := 0
      Affix.PhysicalDamageReduction := 0
      Affix.ChanceDoubleDamage := 0
      Affix.ChanceDodgeAttack := 0
      Affix.ChanceDodgeSpell := 0
      Affix.ChanceBlock := 0
      Affix.ChanceBlockSpell := 0
      Affix.ChanceFreeze := 0
      Affix.ChanceShock := 0
      Affix.ChanceIgnite := 0
      Affix.ChanceBleed := 0
      Affix.ChancePoison := 0
      Affix.ChanceAvoidElementalAilment := 0
      Affix.IncreasedColdDamage := 0
      Affix.IncreasedFireDamage := 0
      Affix.IncreasedLightningDamage := 0
      Affix.IncreasedPhysicalDamage := 0
      Affix.IncreasedSpellDamage := 0
      Affix.IncreasedChaosDamage := 0
      Affix.IncreasedMinionDamage := 0
      Affix.IncreasedDamageWithMoveSkill := 0
      Affix.IncreasedRarity := 0
      Affix.IncreasedArmour := 0
      Affix.IncreasedEvasion := 0
      Affix.IncreasedArmourEnergyShield := 0
      Affix.IncreasedArmourEvasion := 0
      Affix.IncreasedEvasionEnergyShield := 0
      Affix.IncreasedElementalAttack := 0
      Affix.IncreasedGlobalAccuracy := 0
      Affix.IncreasedBurningDamage := 0
      Affix.IncreasedPoisonDamage := 0
      Affix.IncreasedBleedDamage := 0
      Affix.IncreasedCritChance := 0
      Affix.IncreasedSpellCritChance := 0
      Affix.IncreasedCastSpeed := 0
      Affix.IncreasedProjectileSpeed := 0
      Affix.IncreasedCritChanceOnKill := 0
      Affix.IncreasedPoisonDuration := 0
      Affix.IncreasedBleedDuration := 0
      Affix.IncreasedManaRegeneration := 0
      Affix.IncreasedLightRadius := 0
      Affix.IncreasedStunDuration := 0
      Affix.IncreasedStunBlockRecovery := 0
      Affix.IncreasedFlaskLifeRecovery := 0
      Affix.IncreasedFlaskManaRecovery := 0
      Affix.IncreasedFlaskDuration := 0
      Affix.IncreasedFlaskChargesGained := 0
      Affix.AddedArmour := 0
      Affix.AddedEvasion := 0
      Affix.AddedAllStats := 0
      Affix.AddedStrength := 0
      Affix.AddedDexterity := 0
      Affix.AddedIntelligence := 0
      Affix.AddedStrengthDexterity := 0
      Affix.AddedStrengthIntelligence := 0
      Affix.AddedDexterityIntelligence := 0
      Affix.ReflectPhysical := 0
      Affix.BlockManaGain := 0
      Affix.OnKillLife := 0
      Affix.OnKillMana := 0
      Affix.ReducedFlaskChargesUsed := 0
      Affix.ReducedEnemyStunThreshold := 0
      Affix.ReducedAttributeRequirement := 0

    textListAffix= 
    For k, v in Affix
        textListAffix .= (!textListAffix ? "" : "|") "" k ""

    Eval := [ "<","<=","=","!=",">=",">","~" ]
    textListEval= 
    For k, v in Eval
        textListEval .= (!textListEval ? "" : "|") v

    StashTabs := [ "1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"]
    textListStashTabs= 
    For k, v in StashTabs
        textListStashTabs .= (!textListStashTabs ? "" : "|") v

LoadArray()

Redraw:
    Gui, +Resize -MinimizeBox +0x300000  ; WS_VSCROLL | WS_HSCROLL	;necessary for scrollable gui windows 
                            ;+Resize (allows resize of windows)
    Gui, Add, Text, Section y+-5 w1 h1
    Tooltip, Building menu... 
    IniRead, Maxed, LootFilter.ini, Settings, Maxed, 0
    IniRead, xpos, LootFilter.ini, Settings, xpos, first
    IniRead, ypos, LootFilter.ini, Settings, ypos, first

    Gui, add, button, gAddGroup xs y+20, Add new Group
    Gui, add, DropDownList, gUpdateStashDefault vCLFStashTabDefault x+10 yp+1 w40, %CLFStashTabDefault%||%textListStashTabs%
    ; Gui, add, button, gPrintout x+10 yp, Print Array
    ;Gui, add, button, gPrintJSON x+10 yp, JSON string
    Gui, add, button, gLoadArray x+10 yp-1, Load Loot Filter
    Gui, add, button, gSaveArray x+10 yp, Save Loot Filter
    Gui, add, button, gImportGroup x+10 yp, Import Loot Filter
    ;Gui, add, button, gRefreshGUI x+10 yp, Refresh Menu
    ;Gui, add, button, gTestEval x+10 yp, Test Eval vs 5

    Gui, Add, Text, Section xm ym+52 w1 h1

    For GKey, Groups in LootFilter
    {
        gkeyarr := StrSplit(GKey, , , 6)
        
        if (gkeyarr[6] > 9 && gkeyarr[6] < 20) 
            activeGKeys10 := True
        else if (gkeyarr[6] > 19 && gkeyarr[6] < 30) 
            activeGKeys20 := True
        else if (gkeyarr[6] > 29 && gkeyarr[6] < 40) 
            activeGKeys30 := True
        else if (gkeyarr[6] > 39 && gkeyarr[6] < 50) 
            activeGKeys40 := True
        else if (gkeyarr[6] > 49 && gkeyarr[6] < 60) 
            activeGKeys50 := True
        else if (gkeyarr[6] > 59 && gkeyarr[6] < 70) 
            activeGKeys60 := True
        else if (gkeyarr[6] > 69 && gkeyarr[6] < 80) 
            activeGKeys70 := True
        else if (gkeyarr[6] > 79 && gkeyarr[6] < 90) 
            activeGKeys80 := True
        else if (gkeyarr[6] > 89) 
            activeGKeys90 := True
    }

    BuildMenu(1,9)
    if activeGKeys10 
    {
    Gui, Add, Text, Section x+45 ym+52 w1 h1
    BuildMenu(10,19)
    }
    if activeGKeys20 
    {
    Gui, Add, Text, Section x+45 ym+52 w1 h1
    BuildMenu(20,29)
    }
    if activeGKeys30 
    {
    Gui, Add, Text, Section x+45 ym+52 w1 h1
    BuildMenu(30,39)
    }
    if activeGKeys40 
    {
    Gui, Add, Text, Section x+45 ym+52 w1 h1
    BuildMenu(40,49)
    }
    if activeGKeys50 
    {
    Gui, Add, Text, Section x+45 ym+52 w1 h1
    BuildMenu(50,59)
    }
    if activeGKeys60 
    {
    Gui, Add, Text, Section x+45 ym+52 w1 h1
    BuildMenu(60,69)
    }
    if activeGKeys70 
    {
    Gui, Add, Text, Section x+45 ym+52 w1 h1
    BuildMenu(70,79)
    }
    if activeGKeys80 
    {
    Gui, Add, Text, Section x+45 ym+52 w1 h1
    BuildMenu(80,89)
    }
    if activeGKeys90 
    {
    Gui, Add, Text, Section x+45 ym+52 w1 h1
    BuildMenu(90,999)
    }
    tooltip
    Gui, +AlwaysOnTop
    if ((xpos="first") || !(xpos && ypos))
        Gui, show, w740 h575 ; if first run, show gui at default positon
    else
        Gui, show, w740 h575 x%xpos% y%ypos%
    If (Maxed)
        WinMaximize, LootFilter
    Gui,  +LastFound				;necessary for scrollable gui windows (allow scrolling with mouse wheel - must be added after gui lines)
    GroupAdd, MyGui, % "ahk_id " . WinExist()		;necessary for scrollable gui windows (allow scrolling with mouse wheel - must be added after gui lines)
return

RedrawNewGroup:
    Gui,2: -Resize +AlwaysOnTop -MinimizeBox -MaximizeBox  +0x200000  ; WS_VSCROLL | WS_HSCROLL	;necessary for scrollable gui windows 
                            ;+Resize (allows resize of windows)
    Gui,2: Add, Text, Section y+-5 w1 h1
    Gui,2: add, button, gFinishAddGroup xs y+20 HwndFinishButton, Click here to Finish and Return to CLF
    Gui,2: add, button, gRemNewGroup vgroupKey x+150 yp HwndDeleteButton, Delete Group
    Tooltip, Building menu... 
    BuildNewGroupMenu(groupKey)
    tooltip
    Gui,2: show, w600 h475 , Add or Edit a Group
    DisableCloseButton()
    Gui,2:  +LastFound				;necessary for scrollable gui windows (allow scrolling with mouse wheel - must be added after gui lines)
    GroupAdd, MyGui, % "ahk_id " . WinExist()		;necessary for scrollable gui windows (allow scrolling with mouse wheel - must be added after gui lines)
return

DisableCloseButton(hWnd="") 
{
    If hWnd=
        hWnd:=WinExist("A")
    hSysMenu:=DllCall("GetSystemMenu","Int",hWnd,"Int",FALSE)
    nCnt:=DllCall("GetMenuItemCount","Int",hSysMenu)
    DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-1,"Uint","0x400")
    DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-2,"Uint","0x400")
    DllCall("DrawMenuBar","Int",hWnd)
Return ""
}

ImportGroup:
    
    Gui, Submit, NoHide
    LootFilterEmpty:=0
    Loop, % LootFilter.Count() + 1
    {
        ++LootFilterEmpty
        groupstr := "Group" LootFilterEmpty
        if LootFilter.HasKey(groupstr)
            continue
        Else
            break
    }
    LootFilter[groupstr] := JSON.Load(Clipboard)
    LootFilterTabs[groupstr]:=CLFStashTabDefault
    Gui, Destroy
    GoSub, Redraw
Return

ChangeButtonNamesVar: 
    IfWinNotExist, Export String
        Return ; Keep waiting.
    SetTimer, ChangeButtonNamesVar, off 
    WinActivate 
    ControlSetText, Button1, Continue, Export String
    ControlSetText, Button2, Duplicate, Export String
Return

ExportGroup:
    Gui, Submit, NoHide
    StringSplit, buttonstr, A_GuiControl, _
    GKey := buttonstr2
    exportArr := LootFilter[GKey]
    Clipboard := JSON.Dump(exportArr)
    SetTimer, ChangeButtonNamesVar, 10
    MsgBox 262147, Export String,% Clipboard "`n`n Copied to the clipboard`n`nPress duplicate button to Add a copy"
    IfMsgBox, Yes
        Return
    IfMsgBox, No
        GoSub, ImportGroup
Return

EditGroup:
    Gui, Submit
    StringSplit, buttonstr, A_GuiControl, _
    Global groupKey := buttonstr2
    Gui, 2: Destroy
    GoSub, RedrawNewGroup
Return

AddGroup:
    Gui, Submit
    LootFilterEmpty:=0
    Loop, % (LootFilter.Count() + 1)
    {
        ++LootFilterEmpty
        groupstr := "Group" LootFilterEmpty
        if LootFilter.HasKey(groupstr)
            continue
        Else
            break
    }
    LootFilter[groupstr] := {Prop: {}, Stats: {}, Affix: {}}
    LootFilterTabs[groupstr] := CLFStashTabDefault
    Global groupKey := groupstr
    Gui, 2: Destroy
    GoSub, RedrawNewGroup
Return

FinishAddGroup:
    Gui, Submit
    Gui,2: Destroy
    Gui, 1: Default
    SaveWinPos()
    Gui, Destroy
    GoSub, Redraw
Return

AddNewDDL:
    Gui, Submit, NoHide
    StringSplit, buttonstr, A_GuiControl, %A_Space%
    SKey := buttonstr3
    GKey := buttonstr5
    skeyItemsActive := Round(LootFilter[GKey][SKey].Count() / 3)
    ++skeyItemsActive
    ;msgbox, %skeyItemsActive% %GKey% %SKey%

    AKey := SKey . skeyItemsActive
    ;msgbox %AKey%
    LootFilter[GKey][SKey][AKey] := "Blank"
    LootFilter[GKey][SKey][AKey . "Eval"] := ">"
    LootFilter[GKey][SKey][AKey . "Min"] := 0
    SaveWinPos()
    Gui, Destroy
    GoSub, Redraw
Return

AddNewGroupDDL:
    Gui, Submit, NoHide
    StringSplit, buttonstr, A_GuiControl, %A_Space%
    SKey := buttonstr3
    GKey := buttonstr5
    AKey := SKey . (Round(LootFilter[GKey][SKey].Count() / 3) + 1)
    LootFilter[GKey][SKey][AKey] := "Blank"
    LootFilter[GKey][SKey][AKey . "Eval"] := ">"
    LootFilter[GKey][SKey][AKey . "Min"] := 0
    SaveWinPos()
    Gui,2: Destroy
    GoSub, RedrawNewGroup
Return

BuildMenu(Min,Max,AllEdit:=0)
{
    Global
    For GKey, Groups in LootFilter
    {
        totalHeight := 0
        gkeyarr := StrSplit(GKey, , , 6)[6]
        if (gkeyarr < Min) || (gkeyarr > Max)
            Continue
        For SKey, selectedItems in Groups
        {
            totalHeight += (((LootFilter[GKey][SKey].Count() / 3) + 1) * 25) + 30
            Gui, Add, GroupBox,% " section xs y+15 w325 h" ((LootFilter[GKey][SKey].Count() / 3) + 1) * 25 ,%SKey%
            For AKey, Val in selectedItems
                {
                    Gui, Font, Bold s10 cBlack
                    If !InStr(AKey, "Eval") && !InStr(AKey, "Min")
                        Gui, Add,  Text, w318 xs+5 yp+25 h19, % LootFilter[GKey][SKey][AKey] "  " LootFilter[GKey][SKey][AKey . "Eval"] "  " LootFilter[GKey][SKey][AKey . "Min"]
                    Gui, Font,
                }
            Gui, add, button, xs yp+25 w1 h1,
        }
        Gui, Add, Text, y+15 ,______%GKey% Stash Tab:
        strLootFilterGroupStash := "LootFilter_" . GKey . "_Stash"
        %strLootFilterGroupStash% := LootFilterTabs[GKey]
        Gui, Add,  Text,  w30 x+5, % LootFilterTabs[GKey]
        strLootFilterEdit := "LootFilter_" . GKey . "_Edit"
        Gui, Add, Button, v%strLootFilterEdit% gEditGroup w60 h21 x+0 yp-3, Edit
        strLootFilterExport := "LootFilter_" . GKey . "_Export"
        Gui, Add, Button, v%strLootFilterExport% gExportGroup w40 h21 x+5, Export
        if (gkeyarr < 10 ) 
            gkeyarr := 0 . gkeyarr
        Gui, Add, Button,gRemGroup x+5 yp-1 ,% "Rem: " gkeyarr
        Gui, Font, Bold s10 cBlack
        Gui, Add, GroupBox, % "w335 h" . totalHeight - 15 . " xs-3 yp-" . totalHeight - 45, %GKey%
        Gui, add, button, x+0 y+20 w1 h1,
        Gui, Font
    }
Return
}

BuildNewGroupMenu(GKey)
{
    Global
    For SKey, selectedItems in LootFilter[GKey]
    {
        Gui,2: Add, GroupBox,% " section xs y+18 w247 h" ((LootFilter[GKey][SKey].Count() / 3) + 1) * 25 ,%SKey%
        Gui,2: Add, GroupBox,% " x+2 yp w54 h" ((LootFilter[GKey][SKey].Count() / 3) + 1) * 25 ,Eval:
        Gui,2: Add, GroupBox,% " x+2 yp w254 h" ((LootFilter[GKey][SKey].Count() / 3) + 1) * 25 ,Min:
        For AKey, Val in selectedItems
        {
            strLootFilterGSA := "LootFilter_" . GKey . "_" . SKey . "_" . AKey
            %strLootFilterGSA% := LootFilter[GKey][SKey][AKey]
            ;MsgBox % AKey
            If InStr(AKey, "Min"){
                Gui,2: Add, Edit, v%strLootFilterGSA% gUpdateLootFilterDDL x+6 w250 h21, % LootFilter[GKey][SKey][AKey]
                %strLootFilterGSA%_Remove := False
                Gui,2: Add, Button, v%strLootFilterGSA%_Remove gRemoveNewMenuItem x+6 w21 h21, X
            }
            else If InStr(AKey, "Eval")
                Gui,2: Add, DropDownList, v%strLootFilterGSA% gUpdateLootFilterDDL x+6 w50, % LootFilter[GKey][SKey][AKey] "||" textListEval
            Else
                Gui,2: Add,  DropDownList, v%strLootFilterGSA% gUpdateLootFilterDDL xs+5 yp+25 w240, % LootFilter[GKey][SKey][AKey] "||" textList%SKey%
        }
        Gui,2: add, button, gAddNewGroupDDL xs yp+25, Add new %SKey% to %GKey%
    }
    Gui,2: Add, Text, ,_________%GKey% Stash Tab:
    strLootFilterGroupStash := "LootFilter_" . GKey . "_Stash"
    %strLootFilterGroupStash% := LootFilterTabs[GKey]
    Gui,2: Add,  DropDownList, v%strLootFilterGroupStash% gUpdateGroupStash w40 x+5 yp-6, % LootFilterTabs[GKey] "||" textListStashTabs
    strLootFilterExport := "LootFilter_" . GKey . "_Export"
    Gui,2: Add, Button, v%strLootFilterExport% gExportGroup w60 h21 x+5, Export
Return
}

LoadArray:
    LoadArray()
    SaveWinPos()
    Gui, Destroy
    GoSub, Redraw
return

LoadArray()
{
    FileRead, JSONtext, LootFilter.json
    LootFilter := JSON.Load(JSONtext)
    If !LootFilter
        LootFilter:={}
    FileRead, JSONtexttabs, LootFilterTabs.json
    LootFilterTabs := JSON.Load(JSONtexttabs)
    If !LootFilterTabs
        LootFilterTabs:={}
Return
}

SaveArray()
{
    SaveArray:
    Gui, Submit, NoHide
    JSONtext := JSON.Dump(LootFilter)
    FileDelete, LootFilter.json
    FileAppend, %JSONtext%, LootFilter.json
    JSONtexttabs := JSON.Dump(LootFilterTabs)
    FileDelete, LootFilterTabs.json
    FileAppend, %JSONtexttabs%, LootFilterTabs.json
    Return
}

UpdateLootFilterDDL:
    Gui, Submit, NoHide
    StringSplit, buttonstr, A_GuiControl, _
    GKey := buttonstr2
    SKey := buttonstr3
    AKey := buttonstr4
    LootFilter[GKey][SKey][AKey] := %A_GuiControl%
Return

UpdateGroupStash:
    Gui, Submit, NoHide
    StringSplit, buttonstr, A_GuiControl, _
    GKey := buttonstr2
    LootFilterTabs[GKey] := %A_GuiControl%
Return

UpdateStashDefault:
    Gui, Submit, NoHide
    IniWrite, %CLFStashTabDefault%, LootFilter.ini, LootFilter, CLFStashTabDefault
Return

RemoveMenuItem:
    Gui, Submit, NoHide
    StringSplit, buttonstr, A_GuiControl, _
    GKey := buttonstr2
    SKey := buttonstr3
    buttonstr4 := RegExReplace(buttonstr4, "Min$", "")
    AKey := buttonstr4
    LootFilter[GKey][SKey].Delete(AKey . "Min")
    LootFilter[GKey][SKey].Delete(AKey . "Eval")
    LootFilter[GKey][SKey].Delete(AKey)
    SaveWinPos()
    Gui, Destroy
    GoSub, Redraw
Return

RemoveNewMenuItem:
    Gui, Submit, NoHide
    StringSplit, buttonstr, A_GuiControl, _
    GKey := buttonstr2
    SKey := buttonstr3
    buttonstr4 := RegExReplace(buttonstr4, "Min$", "")
    AKey := buttonstr4
    LootFilter[GKey][SKey].Delete(AKey . "Min")
    LootFilter[GKey][SKey].Delete(AKey . "Eval")
    LootFilter[GKey][SKey].Delete(AKey)
    SaveWinPos()
    Gui,2: Destroy
    GoSub, RedrawNewGroup
Return

RemoveNewGroupMenuItem:
    Gui, Submit, NoHide
    StringSplit, buttonstr, A_GuiControl, _
    GKey := buttonstr2
    SKey := buttonstr3
    buttonstr4 := RegExReplace(buttonstr4, "Min$", "")
    AKey := buttonstr4
    LootFilter[GKey][SKey].Delete(AKey . "Min")
    LootFilter[GKey][SKey].Delete(AKey . "Eval")
    LootFilter[GKey][SKey].Delete(AKey)
    SaveWinPos()
    Gui,2: Destroy
    GoSub, RedrawNewGroup
Return

RemGroup:
    Gui, Submit, NoHide
    StringSplit, buttonstr, A_GuiControl, %A_Space%
    if (buttonstr2 < 10)
        StringTrimLeft, buttonstr2, buttonstr2, 1
    gnumber := buttonstr2
    GKey := "Group" gnumber
    LootFilter.Delete(GKey)
    LootFilterTabs.Delete(GKey)
    SaveWinPos()
    Gui, Destroy
    GoSub, Redraw
Return

RemNewGroup:
    Gui, Submit, NoHide
    GKey := groupKey
    LootFilter.Delete(GKey)
    LootFilterTabs.Delete(GKey)
    Gui, 2: Destroy
    SaveWinPos()
    Gui, 1: Default
    Gui, Destroy
    GoSub, Redraw
Return

TestEval:
    Gui, Submit, NoHide
    eval := LootFilter.Group1.Affix.Affix1Eval
    if eval = >
        If (5 > LootFilter.Group1.Affix.Affix1Min)
        MsgBox, Yes
        Else
        MsgBox, No
    else if eval = =
        if (5 = LootFilter.Group1.Affix.Affix1Min)
        MsgBox, Yes
        Else
        MsgBox, No
    else if eval = <
        if (5 < LootFilter.Group1.Affix.Affix1Min)
        MsgBox, Yes
        Else
        MsgBox, No
    else if eval = !=
        if (5 != LootFilter.Group1.Affix.Affix1Min)
        MsgBox, Yes
        Else
        MsgBox, No
    else if eval = ~
        If InStr("365", LootFilter.Group1.Affix.Affix1Min)
        MsgBox, Yes
        Else
        MsgBox, No
Return

Printout:
    Array_Gui(LootFilter)
return

PrintJSON:
    Gui, Submit, NoHide
    arrStr := JSON.Dump(LootFilter)
    MsgBox % arrStr
    arrStr := JSON.Dump(LootFilterTabs)
    MsgBox % arrStr
return

RefreshGUI:
    Gui, Submit, NoHide
    Gui, Destroy
    GoSub, Redraw
Return

GuiSize:
    UpdateScrollBars(A_Gui, A_GuiWidth, A_GuiHeight)

return

ScrollUpLeft:	;________Scroll Up / Left Edge (prevents blank spaces while adding new controls)_______

    SendMessage, 0x115, 6, 0, ,A 		;moves vertical scroll to windows top (to prevent "blank" areas in gui windows)
                    ;"1" means move down ("3" moves down higher)
                    ;"0" means move up ("2" moves up higher)
                    ;"6" moves top
                    ;"7" moves to bottom
                    ; "A" may mean for any active windows (yet to be confirmed)

    SendMessage, 0x114, 6, 0, , A		;moves horizontal scroll to windows left edge (to prevent "blank" areas in gui windows)
                    ;"1" means move right ("3" moves right higher)
                    ;"0" means move left ("2" moves left higher)
                    ;"6" moves left edge
                    ;"7" moves to right edge
                    ; "A" may mean for any active windows (yet to be confirmed)
    sleep 50
return

ScrollDownRight:	;________Scroll Down / Right Edge (prevents blank spaces while adding new controls)_______
    sleep 50

    SendMessage, 0x115, 7, 0, ,A 		;moves vertical scroll to windows bottom 
                    ;"1" means move down ("3" moves down higher)
                    ;"0" means move up ("2" moves up higher)
                    ;"6" moves top
                    ;"7" moves to bottom
                    ; "A" may mean for any active windows (yet to be confirmed)

    SendMessage, 0x114, 7, 0, , A		;moves horizontal scroll to windows left edge (to prevent "blank" areas in gui windows)
                    ;"1" means move right ("3" moves right higher)
                    ;"0" means move left ("2" moves left higher)
                    ;"6" moves left edge
                    ;"7" moves to right edge
                    ; "A" may mean for any active windows (yet to be confirmed)

return

#IfWinActive ahk_group MyGui ; Wheel up and down hook
    WheelUp::
    WheelDown::
    +WheelUp::
    +WheelDown::
        ; SB_LINEDOWN=1, SB_LINEUP=0, WM_HSCROLL=0x114, WM_VSCROLL=0x115
        OnScroll(InStr(A_ThisHotkey,"Down") ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, WinExist())
    return
#IfWinActive

UpdateScrollBars(GuiNum, GuiWidth, GuiHeight)
{
    static SIF_RANGE=0x1, SIF_PAGE=0x2, SIF_DISABLENOSCROLL=0x8, SB_HORZ=0, SB_VERT=1
    
    Gui, %GuiNum%:Default
    Gui, +LastFound
    
    ; Calculate scrolling area.
    Left := Top := 9999
    Right := Bottom := 0
    WinGet, ControlList, ControlList
    Loop, Parse, ControlList, `n
    {
        GuiControlGet, c, Pos, %A_LoopField%
        if (cX < Left)
            Left := cX
        if (cY < Top)
            Top := cY
        if (cX + cW > Right)
            Right := cX + cW
        if (cY + cH > Bottom)
            Bottom := cY + cH
    }
    Left -= 8
    Top -= 8
    Right += 8
    Bottom += 8
    ScrollWidth := Right-Left
    ScrollHeight := Bottom-Top
    
    ; Initialize SCROLLINFO.
    VarSetCapacity(si, 28, 0)
    NumPut(28, si) ; cbSize
    NumPut(SIF_RANGE | SIF_PAGE, si, 4) ; fMask
    
    ; Update horizontal scroll bar.
    NumPut(ScrollWidth, si, 12) ; nMax
    NumPut(GuiWidth, si, 16) ; nPage
    DllCall("SetScrollInfo", "uint", WinExist(), "uint", SB_HORZ, "uint", &si, "int", 1)
    
    ; Update vertical scroll bar.
    ; NumPut(SIF_RANGE | SIF_PAGE | SIF_DISABLENOSCROLL, si, 4) ; fMask
    NumPut(ScrollHeight, si, 12) ; nMax
    NumPut(GuiHeight, si, 16) ; nPage
    DllCall("SetScrollInfo", "uint", WinExist(), "uint", SB_VERT, "uint", &si, "int", 1)
    
    if (Left < 0 && Right < GuiWidth)
        x := Abs(Left) > GuiWidth-Right ? GuiWidth-Right : Abs(Left)
    if (Top < 0 && Bottom < GuiHeight)
        y := Abs(Top) > GuiHeight-Bottom ? GuiHeight-Bottom : Abs(Top)
    if (x || y)
        DllCall("ScrollWindow", "uint", WinExist(), "int", x, "int", y, "uint", 0, "uint", 0)
}

OnScroll(wParam, lParam, msg, hwnd)
{
    static SIF_ALL=0x17, SCROLL_STEP=10
    
    bar := msg=0x115 ; SB_HORZ=0, SB_VERT=1
    
    VarSetCapacity(si, 28, 0)
    NumPut(28, si) ; cbSize
    NumPut(SIF_ALL, si, 4) ; fMask
    if !DllCall("GetScrollInfo", "uint", hwnd, "int", bar, "uint", &si)
        return
    
    VarSetCapacity(rect, 16)
    DllCall("GetClientRect", "uint", hwnd, "uint", &rect)
    
    new_pos := NumGet(si, 20, "int") ; nPos
    
    action := wParam & 0xFFFF
    if action = 0 ; SB_LINEUP
        new_pos -= SCROLL_STEP
    else if action = 1 ; SB_LINEDOWN
        new_pos += SCROLL_STEP
    else if action = 2 ; SB_PAGEUP
        new_pos -= NumGet(rect, 12, "int") - SCROLL_STEP
    else if action = 3 ; SB_PAGEDOWN
        new_pos += NumGet(rect, 12, "int") - SCROLL_STEP
    else if (action = 5 || action = 4) ; SB_THUMBTRACK || SB_THUMBPOSITION
        new_pos := wParam>>16
    else if action = 6 ; SB_TOP
        new_pos := NumGet(si, 8, "int") ; nMin
    else if action = 7 ; SB_BOTTOM
        new_pos := NumGet(si, 12, "int") ; nMax
    else
        return
    
    min := NumGet(si, 8, "int") ; nMin
    max := NumGet(si, 12, "int") - NumGet(si, 16, "int") ; nMax-nPage
    new_pos := new_pos > max ? max : new_pos
    new_pos := new_pos < min ? min : new_pos
    
    old_pos := NumGet(si, 20, "int") ; nPos
    
    x := y := 0
    if bar = 0 ; SB_HORZ
        x := old_pos-new_pos
    else
        y := old_pos-new_pos
    ; Scroll contents of window and invalidate uncovered area.
    DllCall("ScrollWindow", "uint", hwnd, "int", x, "int", y, "uint", 0, "uint", 0)
    
    ; Update scroll bar.
    NumPut(new_pos, si, 20, "int") ; nPos
    DllCall("SetScrollInfo", "uint", hwnd, "int", bar, "uint", &si, "int", 1)
}

PrintArray(Array, Display:=1, Level:=0)
{
    Gui, Submit, NoHide
    Global PrintArray
    static trailingCharacter := "****"        
    Loop, % 4 + (Level*8)
    Tabs .= A_Space
    
    Output := "`r`n" . SubStr(Tabs, 5) . "{" . trailingCharacter
    
    For Key, Value in Array
    {
            If (IsObject(Value))
            {
                Level++
                Value := PrintArray(Value, 0, Level)
                Level--
            }
            
            Output .= "`r`n" . Tabs . "[" . Key . "] " . Value
    }
    Output .= "`r`n" . SubStr(Tabs, 5) . "}" . trailingCharacter
    
    If (!Display)
        Return Output
  
    Gui, PrintArray:+MaximizeBox +Resize
    Gui, PrintArray:Font, s9, Courier New
    Gui, PrintArray:Add, Edit, x12 y10 w450 h350 vPrintArray ReadOnly HScroll, %Output%
    Gui, PrintArray:Show, w476 h374, PrintArray
    Gui, PrintArray:+LastFound
    ControlSend, , {Right}
    WinWaitClose
    Return Output

    PrintArrayGuiSize:
        ;Anchor("PrintArray", "wh")
    Return

    PrintArrayGuiClose:
    Gui, PrintArray:Destroy
    Return
}
; Send one or two digits to a sub-script 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SendMSG(wParam:=0, lParam:=0){
    SetTitleMatchMode 3
    DetectHiddenWindows On
    if WinExist(scriptPOEWingman) 
        PostMessage, 0x5555, wParam, lParam  ; The message is sent  to the "last found window" due to WinExist() above.
    else if WinExist(scriptPOEWingmanSecondary)
        PostMessage, 0x5555, wParam, lParam  ; The message is sent  to the "last found window" due to WinExist() above.
    else
        MsgBox 262147, Either Script Window Not Found
    DetectHiddenWindows Off  ; Must not be turned off until after PostMessage.
    Return
}

SaveWinPos()
{
    WinGet, Maxed, MinMax, LootFilter.ahk
    WinGetPos, xpos, ypos
    IniWrite, %Maxed%, LootFilter.ini, Settings, Maxed
    If !Maxed
    {
        IniWrite, %xpos%, LootFilter.ini, Settings, xpos
        IniWrite, %ypos%, LootFilter.ini, Settings, ypos
    }
Return
}

GuiEscape:
GuiClose:
    WinGet, Maxed, MinMax, LootFilter.ahk
    WinGetPos, xpos, ypos
    IniWrite, %Maxed%, LootFilter.ini, Settings, Maxed
    If !Maxed
    {
        IniWrite, %xpos%, LootFilter.ini, Settings, xpos
        IniWrite, %ypos%, LootFilter.ini, Settings, ypos
    }
    SendMSG( 7, 0)
ExitApp

#Include %A_ScriptDir%\Library.ahk
