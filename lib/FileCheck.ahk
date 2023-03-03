#Include, %A_ScriptDir%\lib\GLOBALS.ahk

directories := [ "\data"
	,"\save"
	,"\save\profiles"
	,"\save\profiles\Flask"
	,"\save\profiles\perChar"
	,"\save\profiles\Utility"
	,"\temp"
	,"\logs"
	,"\backup"
	,"\lib" ]
for k, v in directories {
	if !FileExist(A_ScriptDir v) {
		FileCreateDir, % A_ScriptDir v
	}
}
directories := ""

IfNotExist, %A_ScriptDir%\save\MyCustomAutoRun.ahk
	FileAppend,% "; This file will be included at the end of the Auto Execute section`n"
		. "; Code must not include any return until in hotkey labels`n"
		. "; Arrange any hotkeys to end of this file`n"
		, %A_ScriptDir%\save\MyCustomAutoRun.ahk
IfNotExist, %A_ScriptDir%\save\MyCustomRoutine.ahk
	FileAppend,% "; This file will be included at the end of the Logic Loop`n"
		. "; Code must not include any return`n"
		, %A_ScriptDir%\save\MyCustomRoutine.ahk
IfNotExist, %A_ScriptDir%\save\MyCustomLib.ahk
	FileAppend,% "; This file will be included at the end of the Script`n"
		. "; Include any Functions or Labels here`n"
		, %A_ScriptDir%\save\MyCustomLib.ahk
IfNotExist, %A_ScriptDir%\save\MyCustomZoneChange.ahk
	FileAppend,% "; This file will be included at the end of the Zone Change function`n"
		. "; Include executed code, any return must be true`n"
		, %A_ScriptDir%\save\MyCustomZoneChange.ahk

IfNotExist, %A_ScriptDir%\data\WR.ico
{
	UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/WR.ico, %A_ScriptDir%\data\WR.ico
	if ErrorLevel
	{
		Log("Error","Data download error", "WR.ico")
		MsgBox, Error ED02 : There was a problem downloading WR.ico
	} Else if (ErrorLevel=0) {
		Log("Verbose","Data downloaded Correctly", "WR.ico")
		needReload := True
	}
}
; Verify we have essential files, and redownload if required
For k, str in ["7za.exe","mtee.exe","LootFilter.ahk","WR_Prop.json","WR_Pseudo.json","WR_Affix.json","Controller.png","InventorySlots.png"] {
	IfNotExist, %A_ScriptDir%\data\%str%
	{
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/%str%, %A_ScriptDir%\data\%str%
		if ErrorLevel {
			Log("Error","Data download error", str)
			MsgBox, Error ED02 : There was a problem downloading %str%
		} Else if (ErrorLevel=0) {
			Log("Verbose","Data downloaded Correctly", str)
		}
	}
}

IfNotExist, %A_ScriptDir%\data\Bases.json
{
	UrlDownloadToFile, https://raw.githubusercontent.com/brather1ng/RePoE/master/RePoE/data/base_items.json, %A_ScriptDir%\data\Bases.json
	if ErrorLevel {
		Log("Error","Data download error", "Bases.json")
		MsgBox, Error ED02 : There was a problem downloading Bases.json from RePoE
	} Else if (ErrorLevel=0){
		Log("Verbose","Data downloaded Correctly", "Downloading Bases.json was a success")
	}
}
Bases := JSON.Load(FileOpen(A_ScriptDir "\data\Bases.json","r").Read())

ForceUpdatePOEDB(){
	UpdatePOEDB(True)
}

UpdatePOEDB(forced:=False){
	For k, v in PoeDBAPI {
		content := RegExReplace(v," ","")
		contentdownload := v
		; Replace cluster jewel text
		contentdownload := RegExReplace(contentdownload,"LCJ","Large Cluster Jewel")
		contentdownload := RegExReplace(contentdownload,"MCJ","Medium Cluster Jewel")
		contentdownload := RegExReplace(contentdownload,"SCJ","Small Cluster Jewel")
		; Large clusters
		contentdownload := RegExReplace(contentdownload,"\(axe and sword damage\)","&tags=affliction_axe_and_sword_damage")
		contentdownload := RegExReplace(contentdownload,"\(mace and staff damage\)","&tags=affliction_mace_and_staff_damage")
		contentdownload := RegExReplace(contentdownload,"\(dagger and claw damage\)","&tags=affliction_dagger_and_claw_damage")
		contentdownload := RegExReplace(contentdownload,"\(bow damage\)","&tags=affliction_bow_damage")
		contentdownload := RegExReplace(contentdownload,"\(wand damage\)","&tags=affliction_wand_damage")
		contentdownload := RegExReplace(contentdownload,"\(damage with two handed melee weapons\)","&tags=affliction_damage_with_two_handed_melee_weapons")
		contentdownload := RegExReplace(contentdownload,"\(attack damage while dual wielding\)","&tags=affliction_attack_damage_while_dual_wielding_")
		contentdownload := RegExReplace(contentdownload,"\(atack damage while holding a shield\)","&tags=affliction_attack_damage_while_holding_a_shield")
		contentdownload := RegExReplace(contentdownload,"\(attack damage\)","&tags=affliction_attack_damage_")
		contentdownload := RegExReplace(contentdownload,"\(spell damage\)","&tags=affliction_spell_damage")
		contentdownload := RegExReplace(contentdownload,"\(elemental damage\)","&tags=affliction_elemental_damage")
		contentdownload := RegExReplace(contentdownload,"\(physical damage\)","&tags=affliction_physical_damage")
		contentdownload := RegExReplace(contentdownload,"\(fire damage\)","&tags=affliction_fire_damage")
		contentdownload := RegExReplace(contentdownload,"\(lightning damage\)","&tags=affliction_lightning_damage")
		contentdownload := RegExReplace(contentdownload,"\(cold damage\)","&tags=affliction_cold_damage")
		contentdownload := RegExReplace(contentdownload,"\(chaos damage\)","&tags=affliction_chaos_damage")
		contentdownload := RegExReplace(contentdownload,"\(minion damage\)","&tags=affliction_minion_damage")
		; Medium clusters
		contentdownload := RegExReplace(contentdownload,"\(fire damage over time multiplier\)","&tags=affliction_fire_damage_over_time_multiplier")
		contentdownload := RegExReplace(contentdownload,"\(chaos damage over time multiplier\)","&tags=affliction_chaos_damage_over_time_multiplier")
		contentdownload := RegExReplace(contentdownload,"\(physical damage over time multiplier\)","&tags=affliction_physical_damage_over_time_multiplier")
		contentdownload := RegExReplace(contentdownload,"\(cold damage over time multiplier\)","&tags=affliction_cold_damage_over_time_multiplier")
		contentdownload := RegExReplace(contentdownload,"\(damage over time multiplier\)","&tags=affliction_damage_over_time_multiplier")
		contentdownload := RegExReplace(contentdownload,"\(effect of non-damaging ailments\)","&tags=affliction_effect_of_non-damaging_ailments")
		contentdownload := RegExReplace(contentdownload,"\(legacy aura effect\)","&tags=old_do_not_use_affliction_aura_effect")
		contentdownload := RegExReplace(contentdownload,"\(legacy curse effect\)","&tags=old_do_not_use_affliction_curse_effect")
		contentdownload := RegExReplace(contentdownload,"\(damage while you have a herald\)","&tags=affliction_damage_while_you_have_a_herald")
		contentdownload := RegExReplace(contentdownload,"\(minion damage while you have a herald\)","&tags=affliction_minion_damage_while_you_have_a_herald")
		contentdownload := RegExReplace(contentdownload,"\(warcry buff effect\)","&tags=affliction_warcry_buff_effect")
		contentdownload := RegExReplace(contentdownload,"\(critical chance\)","&tags=affliction_critical_chance")
		contentdownload := RegExReplace(contentdownload,"\(minion life\)","&tags=affliction_minion_life")
		contentdownload := RegExReplace(contentdownload,"\(area damage\)","&tags=affliction_area_damage")
		contentdownload := RegExReplace(contentdownload,"\(projectile damage\)","&tags=affliction_projectile_damage")
		contentdownload := RegExReplace(contentdownload,"\(trap and mine damage\)","&tags=affliction_trap_and_mine_damage")
		contentdownload := RegExReplace(contentdownload,"\(totem damage\)","&tags=affliction_totem_damage")
		contentdownload := RegExReplace(contentdownload,"\(brand damage\)","&tags=affliction_brand_damage")
		contentdownload := RegExReplace(contentdownload,"\(channelling skill damage\)","&tags=affliction_channelling_skill_damage")
		contentdownload := RegExReplace(contentdownload,"\(flask duration\)","&tags=affliction_flask_duration")
		contentdownload := RegExReplace(contentdownload,"\(life and mana recovery from flasks\)","&tags=affliction_life_and_mana_recovery_from_flasks")
		; Small clusters
		contentdownload := RegExReplace(contentdownload,"\(maximum life\)","&tags=affliction_maximum_life")
		contentdownload := RegExReplace(contentdownload,"\(maximum energy shield\)","&tags=affliction_maximum_energy_shield")
		contentdownload := RegExReplace(contentdownload,"\(maximum mana\)","&tags=affliction_maximum_mana")
		contentdownload := RegExReplace(contentdownload,"\(armour\)","&tags=affliction_armour")
		contentdownload := RegExReplace(contentdownload,"\(evasion\)","&tags=affliction_evasion")
		contentdownload := RegExReplace(contentdownload,"\(chance to block\)","&tags=affliction_chance_to_block")
		contentdownload := RegExReplace(contentdownload,"\(fire resistance\)","&tags=affliction_fire_resistance")
		contentdownload := RegExReplace(contentdownload,"\(cold resistance\)","&tags=affliction_cold_resistance")
		contentdownload := RegExReplace(contentdownload,"\(lightning resistance\)","&tags=affliction_lightning_resistance")
		contentdownload := RegExReplace(contentdownload,"\(chaos resistance\)","&tags=affliction_chaos_resistance")
		contentdownload := RegExReplace(contentdownload,"\(chance to dodge attacks\)","&tags=affliction_chance_to_dodge_attacks")
		contentdownload := RegExReplace(contentdownload,"\(reservation efficiency\)","&tags=affliction_reservation_efficiency_small")
		contentdownload := RegExReplace(contentdownload,"\(curse effect\)","&tags=affliction_curse_effect_small")
		; replace space with URI code
		contentdownload := RegExReplace(contentdownload," ","%20")
		; Armour subtypes
		contentdownload := RegExReplace(contentdownload,"\(STR\)","&tags=str_armour")
		contentdownload := RegExReplace(contentdownload,"\(DEX\)","&tags=dex_armour")
		if (contentdownload ~= "Shield") {
			contentdownload := RegExReplace(contentdownload,"\(INT\)","&tags=int_armour,focus")
		} else {
			contentdownload := RegExReplace(contentdownload,"\(INT\)","&tags=int_armour")
		}
		contentdownload := RegExReplace(contentdownload,"\(STR-DEX\)","&tags=str_dex_armour")
		contentdownload := RegExReplace(contentdownload,"\(STR-INT\)","&tags=str_int_armour")
		contentdownload := RegExReplace(contentdownload,"\(DEX-INT\)","&tags=dex_int_armour")
		; Map subtypes
		contentdownload := RegExReplace(contentdownload,"\(LOW\)","&tags=low_tier_map")
		contentdownload := RegExReplace(contentdownload,"\(MID\)","&tags=mid_tier_map")
		contentdownload := RegExReplace(contentdownload,"\(TOP\)","&tags=top_tier_map")
		if (contentdownload ~= "Jewel") {
			contentdownload := "BaseItemTypes&an=" . contentdownload
		}

		if (!FileExist(A_ScriptDir "\data\Mods" content ".json") or forced)	{
			UrlDownloadToFile, https://poedb.tw/us/jsonAPI/Mods/Gen?cn=%contentdownload%, %A_ScriptDir%\data\Mods%content%.json
			if ErrorLevel {
				Log("Error","Data download error", "Mods.json")
				MsgBox, Error ED02 : There was a problem downloading Mods%content%.json from poedb
			} Else if (ErrorLevel=0) {
				Log("Verbose","Data downloaded Correctly", "Downloading Mods.json was a success")
			}
		}
	}
}

UpdatePOEDB()

IfNotExist, %A_ScriptDir%\data\Quest.json
{
	UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/Quest.json, %A_ScriptDir%\data\Quest.json
	if ErrorLevel {
		Log("Error","Data download error", "Quest.json")
		MsgBox, Error ED02 : There was a problem downloading Quest.json from Wingman Reloaded GitHub
	} Else if (ErrorLevel=0){
		Log("Verbose","Data downloaded Correctly", "Downloading Quest.json was a success")
	}
}
QuestItems := JSON.Load(FileOpen(A_ScriptDir "\data\Quest.json","r").Read())

IfNotExist, %A_ScriptDir%\data\PoE.Watch_PerfectUnique.json
{
	RefreshPoeWatchPerfect()
}
WR.Data.Perfect := JSON.Load(FileOpen(A_ScriptDir "\data\PoE.Watch_PerfectUnique.json","r").Read(),,1)

IfNotExist, %A_ScriptDir%\data\Affix_Lines.json
{
	UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/Affix_Lines.json, %A_ScriptDir%\data\Affix_Lines.json
}
WR.Data.Affix := JSON.Load(FileOpen(A_ScriptDir "\data\Affix_Lines.json","r").Read(),,1)

If needReload
	Reload
