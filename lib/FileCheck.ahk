#Include, %A_ScriptDir%\lib\GLOBALS.ahk

IfNotExist, %A_ScriptDir%\data
	FileCreateDir, %A_ScriptDir%\data
IfNotExist, %A_ScriptDir%\save
	FileCreateDir, %A_ScriptDir%\save
IfNotExist, %A_ScriptDir%\save\profiles
	FileCreateDir, %A_ScriptDir%\save\profiles
IfNotExist, %A_ScriptDir%\save\profiles\Flask
	FileCreateDir, %A_ScriptDir%\save\profiles\Flask
IfNotExist, %A_ScriptDir%\save\profiles\perChar
	FileCreateDir, %A_ScriptDir%\save\profiles\perChar
IfNotExist, %A_ScriptDir%\save\profiles\Utility
	FileCreateDir, %A_ScriptDir%\save\profiles\Utility
IfNotExist, %A_ScriptDir%\temp
	FileCreateDir, %A_ScriptDir%\temp
IfNotExist, %A_ScriptDir%\logs
	FileCreateDir, %A_ScriptDir%\logs
IfNotExist, %A_ScriptDir%\backup
	FileCreateDir, %A_ScriptDir%\backup
IfNotExist, %A_ScriptDir%\lib
	FileCreateDir, %A_ScriptDir%\lib
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
	if ErrorLevel{
		Log("Error","Data download error", "WR.ico")
		MsgBox, Error ED02 : There was a problem downloading WR.ico
	}
	Else if (ErrorLevel=0){
		Log("Verbose","Data downloaded Correctly", "WR.ico")
		needReload := True
	}
}
; Verify we have essential files, and redownload if required
For k, str in ["7za.exe","mtee.exe","LootFilter.ahk","WR_Prop.json","WR_Pseudo.json","WR_Affix.json","Controller.png","InventorySlots.png"] {
	IfNotExist, %A_ScriptDir%\data\%str%
	{
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/%str%, %A_ScriptDir%\data\%str%
		if ErrorLevel{
			Log("Error","Data download error", str)
			MsgBox, Error ED02 : There was a problem downloading %str%
		}
		Else if (ErrorLevel=0){
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
	}
	Else if (ErrorLevel=0){
		Log("Verbose","Data downloaded Correctly", "Downloading Bases.json was a success")
		FileRead, JSONtext, %A_ScriptDir%\data\Bases.json
		Bases := JSON.Load(JSONtext)
		JSONtext := ""
	}
} Else {
	FileRead, JSONtext, %A_ScriptDir%\data\Bases.json
	Bases := JSON.Load(JSONtext)
	JSONtext := ""
}

For k, v in PoeDBAPI
{
	content := RegExReplace(v," ","")
	contentdownload := RegExReplace(v," ","%20")
	contentdownload := RegExReplace(contentdownload,"\(STR\)","&tags=str_armour")
    contentdownload := RegExReplace(contentdownload,"\(DEX\)","&tags=dex_armour")
    contentdownload := RegExReplace(contentdownload,"\(INT\)","&tags=int_armour")
    contentdownload := RegExReplace(contentdownload,"\(STR-DEX\)","&tags=str_dex_armour")
    contentdownload := RegExReplace(contentdownload,"\(STR-INT\)","&tags=str_int_armour")
    contentdownload := RegExReplace(contentdownload,"\(DEX-INT\)","&tags=dex_int_armour")
	contentdownload := RegExReplace(contentdownload,"\(LOW\)","&tags=low_tier_map")
	contentdownload := RegExReplace(contentdownload,"\(MID\)","&tags=mid_tier_map")
	contentdownload := RegExReplace(contentdownload,"\(TOP\)","&tags=top_tier_map")
	if(contentdownload ~= "Jewel"){
		contentdownload := "BaseItemTypes&an=" . contentdownload
	}
	
	IfNotExist, %A_ScriptDir%\data\Mods%content%.json
	{
		UrlDownloadToFile, https://poedb.tw/us/json.php/Mods/Gen?cn=%contentdownload%, %A_ScriptDir%\data\Mods%content%.json
		if ErrorLevel {
			Log("Error","Data download error", "Mods.json")
			MsgBox, Error ED02 : There was a problem downloading Mods%content%.json from poedb
		}
		Else if (ErrorLevel=0){
			Log("Verbose","Data downloaded Correctly", "Downloading Mods.json was a success")
			
		}
	}
}

IfNotExist, %A_ScriptDir%\data\Quest.json
{
	UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/Quest.json, %A_ScriptDir%\data\Quest.json
	if ErrorLevel {
		Log("Error","Data download error", "Quest.json")
		MsgBox, Error ED02 : There was a problem downloading Quest.json from Wingman Reloaded GitHub
	}
	Else if (ErrorLevel=0){
		Log("Verbose","Data downloaded Correctly", "Downloading Quest.json was a success")
		FileRead, JSONtext, %A_ScriptDir%\data\Quest.json
		QuestItems := JSON.Load(JSONtext)
		JSONtext := ""
	}
}
Else
{
	FileRead, JSONtext, %A_ScriptDir%\data\Quest.json
	QuestItems := JSON.Load(JSONtext)
	JSONtext := ""
}
IfNotExist, %A_ScriptDir%\data\PoE.Watch_PerfectUnique.json
{
	RefreshPoeWatchPerfect()
}
Else
{
	FileRead, JSONtext, %A_ScriptDir%\data\PoE.Watch_PerfectUnique.json
	WR.Data.Perfect := JSON.Load(JSONtext,,1)
	JSONtext := ""
}
IfNotExist, %A_ScriptDir%\data\Affix_Lines.json
{
	UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/Affix_Lines.json, %A_ScriptDir%\data\Affix_Lines.json
	FileRead, JSONtext, %A_ScriptDir%\data\Affix_Lines.json
	WR.Data.Affix := JSON.Load(JSONtext,,1)
	JSONtext := "" 
} Else {
	FileRead, JSONtext, %A_ScriptDir%\data\Affix_Lines.json
	WR.Data.Affix := JSON.Load(JSONtext,,1)
	JSONtext := ""
}
If needReload
	Reload
