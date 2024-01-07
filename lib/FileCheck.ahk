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
	UrlDownloadToFile, https://raw.githubusercontent.com/brather1ng/lvlvllvlvllvlvl/master/RePoE/data/base_items.json, %A_ScriptDir%\data\Bases.json
	if ErrorLevel {
		Log("Error","Data download error", "Bases.json")
		MsgBox, Error ED02 : There was a problem downloading Bases.json from RePoE
	} Else if (ErrorLevel=0){
		Log("Verbose","Data downloaded Correctly", "Downloading Bases.json was a success")
	}
}
Bases := JSON.Load(FileOpen(A_ScriptDir "\data\Bases.json","r").Read())

UpdatePOEData(){
	IfNotExist, %A_ScriptDir%\data\PoE Data\Category.json
	{
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/PoE Data/Category.json, %A_ScriptDir%\data\PoE Data\Category.json
		if ErrorLevel {
			Log("Error","Data download error", "Category.json")
			MsgBox, Error ED02 : There was a problem downloading Category.json from Wingman Reloaded GitHub
		} Else if (ErrorLevel=0){
			Log("Verbose","Data downloaded Correctly", "Downloading POEData was a success")
		}
	}
	POEData := JSON.Load(FileOpen(A_ScriptDir "\data\PoE Data\Category.json","r").Read())
	For k, v in POEData {
		for ki, vi in v {
			aux := k . "(" . vi . ").json"
			IfNotExist, %A_ScriptDir%\data\PoE Data\%aux%
			{
				UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/PoE Data/%aux%, %A_ScriptDir%\data\PoE Data\%aux%
				if ErrorLevel {
					Log("Error","Data download error", aux)
					MsgBox, Error ED02 : There was a problem downloading Quest.json from Wingman Reloaded GitHub
				} Else if (ErrorLevel=0){
					Log("Verbose","Data downloaded Correctly", "Downloading POEData was a success")
				}
			}
		}
	}
}
UpdatePOEData()

UpdateBasesData(){
	IfNotExist, %A_ScriptDir%\data\Bases Data\BasesCategory.json
	{
		UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/Bases Data/BasesCategory.json, %A_ScriptDir%\data\Bases Data\BasesCategory.json
		if ErrorLevel {
			Log("Error","Data download error", "Category.json")
			MsgBox, Error ED02 : There was a problem downloading Category.json from Wingman Reloaded GitHub
		} Else if (ErrorLevel=0){
			Log("Verbose","Data downloaded Correctly", "Downloading POEData was a success")
		}
	}
	BasesData := JSON.Load(FileOpen(A_ScriptDir "\data\Bases Data\BasesCategory","r").Read())
	For k, v in BasesData {
			aux := k . ".json"
			IfNotExist, %A_ScriptDir%\data\Bases Data\%aux%
			{
				UrlDownloadToFile, https://raw.githubusercontent.com/BanditTech/WingmanReloaded/%BranchName%/data/Bases Data/%aux%, %A_ScriptDir%\data\Bases Data\%aux%
				if ErrorLevel {
					Log("Error","Data download error", aux)
					MsgBox, Error ED02 : There was a problem downloading Quest.json from Wingman Reloaded GitHub
				} Else if (ErrorLevel=0){
					Log("Verbose","Data downloaded Correctly", "Downloading BasesData was a success")
				}
			}
	}
}
UpdateBasesData()

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

;Create ActualTier
IfNotExist, %A_ScriptDir%\save\ActualTier.json
{
	ActualTierCreator()
}
s
If needReload
	Reload