#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
if not A_IsAdmin
{
     Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
     ExitApp
}

#Include %A_ScriptDir%\JSON.ahk



OnMessage(0x115, "OnScroll") ; WM_VSCROLL	;necessary for scrollable gui windows (must be added before gui lines)
OnMessage(0x114, "OnScroll") ; WM_HSCROLL	;necessary for scrollable gui windows (must be added before gui lines)
Global scriptPOEWingman := "PoE-Wingman.ahk ahk_exe AutoHotkey.exe"
Global scriptPOEWingmanSecondary := "WingmanReloaded ahk_exe AutoHotkey.exe"
global POEGameArr := ["PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe", "PathOfExile_KG.exe", "PathOfExile_x64_KG.exe"]
for n, exe in POEGameArr {
     GroupAdd, POEGameGroup, ahk_exe %exe%
}

Global CLFStashTabDefault := 1
IniRead, CLFStashTabDefault, LootFilter.ini, LootFilter, CLFStashTabDefault , 1
Global LootFilter := {}
Global LootFilterTabs := {}

Prop := {ItemName: ""
    , IsItem : False
    , IsWeapon : False
    , IsMap : False
    , ShowAffix : False
    , Rarity : ""
    , SpecialType : ""
    , RarityCurrency : False
    , RarityDivination : False
    , RarityGem : False
    , RarityNormal : False
    , RarityMagic : False
    , RarityRare : False
    , RarityUnique : False
    , Identified : True
    , Ring : False
    , Amulet : False
    , Belt : False
    , Chromatic : False
    , Jewel : False
    , AbyssJewel : False
    , Essence : False
    , Incubator : False
    , Fossil : False
    , Resonator : False
    , Sockets : 0
    , RawSockets : ""
    , LinkCount : 0
    , 2Link : False
    , 3Link : False
    , 4Link : False
    , 5Link : False
    , 6Link : False
    , Jeweler : False
    , TimelessSplinter : False
    , BreachSplinter : False
    , SacrificeFragment : False
    , MortalFragment : False
    , GuardianFragment : False
    , ProphecyFragment : False
    , Scarab : False
    , Offering : False
    , Vessel : False
    , Incubator : False
    , Flask : False
    , Veiled : False
    , Prophecy : False
    , Oil : False
    , DoubleCorrupted : False
    , Width : 1
    , Height : 1
    , ItemLevel : 0}

textListProp= 
For k, v in Prop
    textListProp .= (!textListProp ? "" : "|") "" k ""

Stats := { PhysLo : False
    , PhysHi : False
    , AttackSpeed : False
    , PhysMult : False
    , PhysDps : False
    , EleDps : False
    , TotalDps : False
    , ChaosLo : False
    , ChaosHi : False
    , EleLo : False
    , EleHi : False
    , TotalPhysMult : False
    , BasePhysDps : False
    , Q20Dps : False
	, ItemClass : ""
    , Quality : 0
    , Stack : 0
    , StackMax : 0
    , RequiredLevel : 0
    , RequiredStr : 0
    , RequiredInt : 0
    , RequiredDex : 0
    , RatingArmour : 0
    , RatingEnergyShield : 0
    , RatingEvasion : 0
    , RatingBlock : 0
    , MapTier : 0
    , MapItemQuantity : 0
    , MapItemRarity : 0
    , MapMonsterPackSize : 0 }

textListStats= 
For k, v in Stats
    textListStats .= (!textListStats ? "" : "|") "" k ""

Affix := { SupportGem : ""
    , SupportGemLevel : 0
    , CountSupportGem : 0
    , AllElementalResistances : 0
    , ColdLightningResistance : 0
    , FireColdResistance : 0
    , FireLightningResistance : 0
    , ColdResistance : 0
    , FireResistance : 0
    , LightningResistance : 0
    , ChaosResistance : 0
    , MaximumLife : 0
    , IncreasedMaximumLife : 0
    , MaximumEnergyShield : 0
    , IncreasedEnergyShield : 0
    , MaximumMana : 0
    , IncreasedMaximumMana : 0
    , IncreasedAttackSpeed : 0
    , IncreasedColdDamage : 0
    , IncreasedFireDamage : 0
    , IncreasedLightningDamage : 0
    , IncreasedPhysicalDamage : 0
    , IncreasedSpellDamage : 0
    , PseudoColdResist : 0
    , PseudoFireResist : 0
    , PseudoLightningResist : 0
    , PseudoChaosResist : 0
    , PseudoTotalResist : 0
    , PseudoTotalEleResist : 0
    , LifeRegeneration : 0
    , ChanceDoubleDamage : 0
    , IncreasedRarity : 0
    , IncreasedEvasion : 0
    , IncreasedArmour : 0
    , IncreasedAttackSpeed : 0
    , IncreasedAttackCastSpeed : 0
    , IncreasedMovementSpeed : 0
    , ReducedEnemyStunThreshold : 0
    , IncreasedStunBlockRecovery : 0
    , LifeGainOnAttack : 0
    , WeaponRange : 0
    , AddedIntelligence : 0
    , AddedStrength : 0
    , AddedDexterity : 0
    , AddedStrengthDexterity : 0
    , AddedStrengthIntelligence : 0
    , AddedDexterityIntelligence : 0
    , AddedArmour : 0
    , AddedEvasion : 0
	, AddedAccuracy : 0
    , AddedAllStats : 0
    , PseudoAddedStrength : 0
    , PseudoAddedDexterity : 0
    , PseudoAddedIntelligence : 0
    , IncreasedArmourEnergyShield : 0
    , IncreasedArmourEvasion : 0
    , IncreasedEvasionEnergyShield : 0
    , PseudoIncreasedArmour : 0
    , PseudoIncreasedEvasion : 0
    , PseudoIncreasedEnergyShield : 0
    , ChanceDodgeAttack : 0
    , ChanceDodgeSpell : 0
    , ChanceBlockSpell : 0
    , BlockManaGain : 0
    , PhysicalDamageReduction : 0
    , ReducedAttributeRequirement : 0
    , ReflectPhysical : 0
    , EnergyShieldRegen : 0
    , PhysicalLeechLife : 0
    , PhysicalLeechMana : 0
    , OnKillLife : 0
    , OnKillMana : 0
    , IncreasedElementalAttack : 0
    , IncreasedFlaskLifeRecovery : 0
    , IncreasedFlaskManaRecovery : 0
    , IncreasedStunDuration : 0
    , IncreasedFlaskDuration : 0
    , IncreasedFlaskChargesGained : 0
    , ReducedFlaskChargesUsed : 0
    , GlobalCriticalChance : 0
    , GlobalCriticalMultiplier : 0
    , IncreasedProjectileSpeed : 0
    , AddedLevelGems : 0
    , AddedLevelMinionGems : 0
    , AddedLevelMeleeGems : 0
    , AddedLevelBowGems : 0
    , AddedLevelFireGems : 0
    , AddedLevelColdGems : 0
    , AddedLevelLightningGems : 0
    , AddedLevelChaosGems : 0
    , ChaosDOTMult : 0
    , ColdDOTMult : 0
    , ChanceFreeze : 0
    , ChanceShock : 0
    , ChanceIgnite : 0
    , ChanceAvoidElementalAilment : 0
    , ChanceIgnite : 0
    , ChanceIgnite : 0
    , ChanceIgnite : 0
    , IncreasedBurningDamage : 0
    , IncreasedSpellCritChance : 0
    , IncreasedCritChance : 0
    , IncreasedManaRegeneration : 0
    , IncreasedCastSpeed : 0
    , IncreasedPoisonDuration : 0
    , ChancePoison : 0
    , IncreasedPoisonDamage : 0
    , IncreasedBleedDuration : 0
    , ChanceBleed : 0
    , IncreasedBleedDamage : 0
    , IncreasedLightRadius : 0
    , IncreasedGlobalAccuracy : 0
    , ChanceBlock : 0
    , GainFireToExtraChaos : 0
    , GainColdToExtraChaos : 0
    , GainLightningToExtraChaos : 0
    , GainPhysicalToExtraChaos : 0
    , Implicit : ""}

textListAffix= 
For k, v in Affix
    textListAffix .= (!textListAffix ? "" : "|") "" k ""

Eval := [ ">","=","<","!=","~" ]

textListEval= 
For k, v in Eval
    textListEval .= (!textListEval ? "" : "|") v

StashTabs := [ "1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25"]

textListStashTabs= 
For k, v in StashTabs
    textListStashTabs .= (!textListStashTabs ? "" : "|") v


LoadArray()

Redraw:
Gui, +Resize -MinimizeBox +0x300000  ; WS_VSCROLL | WS_HSCROLL	;necessary for scrollable gui windows 
						;+Resize (allows resize of windows)
Gui, Add, Text, Section y+-5 w1 h1

Gui, add, button, gAddGroup xs y+20, Add new Group
Gui, add, DropDownList, gUpdateStashDefault vCLFStashTabDefault x+10 yp+1 w40, %CLFStashTabDefault%||%textListStashTabs%
;Gui, add, button, gPrintout x+10 yp, Print Array
;Gui, add, button, gPrintJSON x+10 yp, JSON string
Gui, add, button, gLoadArray x+10 yp-1, Load Loot Filter
Gui, add, button, gSaveArray x+10 yp, Save Loot Filter
Gui, add, button, gImportGroup x+10 yp, Import Loot Filter
;Gui, add, button, gRefreshGUI x+10 yp, Refresh Menu
;Gui, add, button, gTestEval x+10 yp, Test Eval vs 5

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
Gui, Add, Text, Section x+45 ym+32 w1 h1
BuildMenu(10,19)
}
if activeGKeys20 
{
Gui, Add, Text, Section x+45 ym+32 w1 h1
BuildMenu(20,29)
}
if activeGKeys30 
{
Gui, Add, Text, Section x+45 ym+32 w1 h1
BuildMenu(30,39)
}
if activeGKeys40 
{
Gui, Add, Text, Section x+45 ym+32 w1 h1
BuildMenu(40,49)
}
if activeGKeys50 
{
Gui, Add, Text, Section x+45 ym+32 w1 h1
BuildMenu(50,59)
}
if activeGKeys60 
{
Gui, Add, Text, Section x+45 ym+32 w1 h1
BuildMenu(60,69)
}
if activeGKeys70 
{
Gui, Add, Text, Section x+45 ym+32 w1 h1
BuildMenu(70,79)
}
if activeGKeys80 
{
Gui, Add, Text, Section x+45 ym+32 w1 h1
BuildMenu(80,89)
}
if activeGKeys90 
{
Gui, Add, Text, Section x+45 ym+32 w1 h1
BuildMenu(90,999)
}

Gui, show, w640 h475 
Gui,  +LastFound				;necessary for scrollable gui windows (allow scrolling with mouse wheel - must be added after gui lines)
GroupAdd, MyGui, % "ahk_id " . WinExist()		;necessary for scrollable gui windows (allow scrolling with mouse wheel - must be added after gui lines)
return


ImportGroup:
    
    Gui, Submit, NoHide
    LootFilterActive := LootFilter.Count()
    ++LootFilterActive
    ;msgbox %LootFilterActive%
    LootFilterEmpty:=0
    Loop, %LootFilterActive%
    {
        ++LootFilterEmpty
        groupstr := "Group" LootFilterEmpty
        if LootFilter.HasKey(groupstr)
            {
            continue
            }
        Else
            break
    }
    ; msgbox %groupstr%
    importJSON := JSON.Load(Clipboard)
    %groupstr% := importJSON

    LootFilter[groupstr]:=%groupstr%
    LootFilterTabs[groupstr]:=CLFStashTabDefault
    ; MsgBox % LootFilterTabs 
    ; for k, v in LootFilterTabs
    ;     MsgBox % "Key:  " k "  Val:  " v 
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
MsgBox 3, Export String,% Clipboard "`n`n Copied to the clipboard`n`nPress duplicate button to Add a copy"
IfMsgBox, Yes
{
    Return
}
IfMsgBox, No
{
    GoSub, ImportGroup
}

Return



AddGroup:
    
    Gui, Submit, NoHide
    LootFilterActive := LootFilter.Count()
    ++LootFilterActive
    ;msgbox %LootFilterActive%
    LootFilterEmpty:=0
    Loop, %LootFilterActive%
    {
        ++LootFilterEmpty
        groupstr := "Group" LootFilterEmpty
        if LootFilter.HasKey(groupstr)
            {
            continue
            }
        Else
            break
    }
    ; msgbox %groupstr%

    %groupstr% := {Prop: {}, Stats: {}, Affix: {}}

    LootFilter[groupstr]:=%groupstr%
    LootFilterTabs[groupstr]:=CLFStashTabDefault
    ; MsgBox % LootFilterTabs 
    ; for k, v in LootFilterTabs
    ;     MsgBox % "Key:  " k "  Val:  " v 
    Gui, Destroy
    GoSub, Redraw
Return

BuildMenu(Min,Max)
{
Global
    For GKey, Groups in LootFilter
    {
        gkeyarr := StrSplit(GKey, , , 6)
        if (gkeyarr[6] < Min) || (gkeyarr[6] > Max)
            Continue
        For SKey, selectedItems in Groups
        {
            ;MsgBox % selectedItems
            Gui, Add, GroupBox,% " section xs y+18 w127 h" ((LootFilter[GKey][SKey].Count() / 3) + 1) * 25 ,%SKey%
            Gui, Add, GroupBox,% " x+2 yp w54 h" ((LootFilter[GKey][SKey].Count() / 3) + 1) * 25 ,Eval:
            Gui, Add, GroupBox,% " x+2 yp w94 h" ((LootFilter[GKey][SKey].Count() / 3) + 1) * 25 ,Min:
            For AKey, Val in selectedItems
                {
                    strLootFilterGSA := "LootFilter_" . GKey . "_" . SKey . "_" . AKey
                    %strLootFilterGSA% := LootFilter[GKey][SKey][AKey]
                    ;MsgBox % AKey
                    If InStr(AKey, "Min"){
                        Gui, Add, Edit, v%strLootFilterGSA% gUpdateLootFilterDDL x+6 w90 h21, % LootFilter[GKey][SKey][AKey]
                        %strLootFilterGSA%_Remove := False
                        Gui, Add, Button, v%strLootFilterGSA%_Remove gRemoveMenuItem x+6 w21 h21, X
                    }
                    else If InStr(AKey, "Eval")
                        Gui, Add, DropDownList, v%strLootFilterGSA% gUpdateLootFilterDDL x+6 w50, % LootFilter[GKey][SKey][AKey] "||" textListEval
                    Else
                    {
                        Gui, Add,  DropDownList, v%strLootFilterGSA% gUpdateLootFilterDDL xs+5 yp+25, % LootFilter[GKey][SKey][AKey] "||" textList%SKey%
                        ;MsgBox % LootFilter[GKey][SKey][AKey] "  GKey: " GKey "  SKey: " SKey "  AKey: " AKey
                        ;GuiControl, ,% vLootFilter[GKey][SKey][AKey], % LootFilter[GKey][SKey][AKey]
                    }
                }
            Gui, add, button, gAddNewDDL xs yp+25, Add new %SKey% to %GKey%
        }
        Gui, Add, Text, ,_________%GKey% Stash Tab:
        strLootFilterGroupStash := "LootFilter_" . GKey . "_Stash"
        %strLootFilterGroupStash% := LootFilterTabs[GKey]
        Gui, Add,  DropDownList, v%strLootFilterGroupStash% gUpdateGroupStash w40 x+5 yp-6, % LootFilterTabs[GKey] "||" textListStashTabs
        strLootFilterExport := "LootFilter_" . GKey . "_Export"
        Gui, Add, Button, v%strLootFilterExport% gExportGroup w60 h21 x+5, Export
        if (gkeyarr[6] < 10 ) 
            gkeyarr[6] := 0 . gkeyarr[6]
        ;MsgBox % gkeyarr[6]
        Gui, Add, Button,gRemGroup x+5 yp-1 ,% "Rem: " gkeyarr[6]
    }
Return
}
LoadArray:
LoadArray()
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
;MsgBox % A_GuiControl
;MsgBox % %A_GuiControl%
StringSplit, buttonstr, A_GuiControl, _
GKey := buttonstr2
SKey := buttonstr3
AKey := buttonstr4
LootFilter[GKey][SKey][AKey] := %A_GuiControl%
;MsgBox % LootFilter[GKey][SKey][AKey]
Return

UpdateGroupStash:
Gui, Submit, NoHide
;MsgBox % A_GuiControl
;MsgBox % %A_GuiControl%
StringSplit, buttonstr, A_GuiControl, _
GKey := buttonstr2
LootFilterTabs[GKey] := %A_GuiControl%
;MsgBox % LootFilterTabs[GKey]
Return

UpdateStashDefault:
Gui, Submit, NoHide
IniWrite, %CLFStashTabDefault%, LootFilter.ini, LootFilter, CLFStashTabDefault
Return

RemoveMenuItem:
Gui, Submit, NoHide
;MsgBox % A_GuiControl
;MsgBox % %A_GuiControl%
StringSplit, buttonstr, A_GuiControl, _
GKey := buttonstr2
SKey := buttonstr3
buttonstr4 := RegExReplace(buttonstr4, "Min$", "")
AKey := buttonstr4
;MsgBox % GKey "  -  " SKey "  -  " AKey
;LootFilter[GKey][SKey][AKey] := %A_GuiControl%

LootFilter[GKey][SKey].Delete(AKey . "Min")
LootFilter[GKey][SKey].Delete(AKey . "Eval")
LootFilter[GKey][SKey].Delete(AKey)

;MsgBox % LootFilter[GKey][SKey][AKey]
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

RemGroup:
Gui, Submit, NoHide
StringSplit, buttonstr, A_GuiControl, %A_Space%
if (buttonstr2 < 10)
    StringTrimLeft, buttonstr2, buttonstr2, 1
gnumber := buttonstr2
GKey := "Group" gnumber
LootFilter.Delete(GKey)
LootFilterTabs.Delete(GKey)
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
Gui, Destroy
GoSub, Redraw
Return

Printout:
PrintArray(LootFilter)
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

#IfWinActive ahk_group MyGui
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
;     NumPut(SIF_RANGE | SIF_PAGE | SIF_DISABLENOSCROLL, si, 4) ; fMask
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
     {
        PostMessage, 0x5555, wParam, lParam  ; The message is sent  to the "last found window" due to WinExist() above.
     }
     else if WinExist(scriptPOEWingmanSecondary)
     {
        PostMessage, 0x5555, wParam, lParam  ; The message is sent  to the "last found window" due to WinExist() above.
     }
     else
     MsgBox, Either Script Window Not Found
     DetectHiddenWindows Off  ; Must not be turned off until after PostMessage.
     Return
}

GuiEscape:
GuiClose:
    SendMSG( 7, 0)
ExitApp