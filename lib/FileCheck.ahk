#Include %A_ScriptDir%\lib\GLOBALS.ahk

directories := [ "\data"
	,"\data\Bases Data"
	,"\data\PoE Data"
	,"\save"
	,"\save\profiles"
	,"\save\profiles\Flask"
	,"\save\profiles\perChar"
	,"\save\profiles\Utility"
	,"\temp"
	,"\logs"
	,"\backup"
	,"\lib" ]
for _k, _dir in directories {
	if !FileExist(A_ScriptDir _dir) {
		DirCreate(A_ScriptDir _dir)
	}
}
directories := ""

if !FileExist(A_ScriptDir "\save\MyCustomAutoRun.ahk")
	FileAppend("; This file will be included at the end of the Auto Execute section`n"
		. "; Code must not include any return until in hotkey labels`n"
		. "; Arrange any hotkeys to end of this file`n"
		, A_ScriptDir "\save\MyCustomAutoRun.ahk")
if !FileExist(A_ScriptDir "\save\MyCustomRoutine.ahk")
	FileAppend("; This file will be included at the end of the Logic Loop`n"
		. "; Code must not include any return`n"
		, A_ScriptDir "\save\MyCustomRoutine.ahk")
if !FileExist(A_ScriptDir "\save\MyCustomLib.ahk")
	FileAppend("; This file will be included at the end of the Script`n"
		. "; Include any Functions or Labels here`n"
		, A_ScriptDir "\save\MyCustomLib.ahk")
if !FileExist(A_ScriptDir "\save\MyCustomZoneChange.ahk")
	FileAppend("; This file will be included at the end of the Zone Change function`n"
		. "; Include executed code, any return must be true`n"
		, A_ScriptDir "\save\MyCustomZoneChange.ahk")

needReload := False
if !FileExist(A_ScriptDir "\data\WR.ico")
{
	Try {
		Download("https://raw.githubusercontent.com/BanditTech/WingmanReloaded/" BranchName "/data/WR.ico", A_ScriptDir "\data\WR.ico")
		Log("Verbose","Data downloaded Correctly", "WR.ico")
		needReload := True
	} Catch {
		Log("Error","Data download error", "WR.ico")
		MsgBox("Error ED02 : There was a problem downloading WR.ico")
	}
}
; Verify we have essential files, and redownload if required
For k, str in ["7za.exe","mtee.exe","LootFilter.ahk","WR_Prop.json","WR_Pseudo.json","WR_Affix.json","Controller.png","InventorySlots.png"] {
	if !FileExist(A_ScriptDir "\data\" str)
	{
		Try {
			Download("https://raw.githubusercontent.com/BanditTech/WingmanReloaded/" BranchName "/data/" str, A_ScriptDir "\data\" str)
			Log("Verbose","Data downloaded Correctly", str)
		} Catch {
			Log("Error","Data download error", str)
			MsgBox("Error ED02 : There was a problem downloading " str)
		}
	}
}

if !FileExist(A_ScriptDir "\data\Bases.json")
{
	Try {
		Download("https://repoe-fork.github.io/base_items.json", A_ScriptDir "\data\Bases.json")
		Log("Verbose","Data downloaded Correctly", "Downloading Bases.json was a success")
	} Catch {
		Log("Error","Data download error", "Bases.json")
		MsgBox("Error ED02 : There was a problem downloading Bases.json from RePoE")
	}
}
Bases := JSON.LoadFile(A_ScriptDir "\data\Bases.json")

UpdatePOEData(){
	Global POEData, BranchName
	if !FileExist(A_ScriptDir "\data\PoE Data\Category.json")
	{
		Try {
			Download("https://raw.githubusercontent.com/BanditTech/WingmanReloaded/" BranchName "/data/PoE Data/Category.json", A_ScriptDir "\data\PoE Data\Category.json")
			Log("Verbose","Data downloaded Correctly", "Downloading POEData was a success")
		} Catch {
			Log("Error","Data download error", "Category.json")
			MsgBox("Error ED02 : There was a problem downloading Category.json from Wingman Reloaded GitHub")
		}
	}
	POEData := JSON.LoadFile(A_ScriptDir "\data\PoE Data\Category.json")
	For fk, fv in POEData {
		for fki, fvi in fv {
			faux := fk . "(" . fvi . ").json"
			if !FileExist(A_ScriptDir "\data\PoE Data\" faux)
			{
				Try {
					Download("https://raw.githubusercontent.com/BanditTech/WingmanReloaded/" BranchName "/data/PoE Data/" faux, A_ScriptDir "\data\PoE Data\" faux)
					Log("Verbose","Data downloaded Correctly", "Downloading POEData was a success")
				} Catch {
					Log("Error","Data download error", faux)
					MsgBox("Error ED02 : There was a problem downloading Quest.json from Wingman Reloaded GitHub")
				}
			}
		}
	}
}
UpdatePOEData()

UpdateBasesData(){
	Global BasesData, BasesWR, QuestItems, BranchName
	if !FileExist(A_ScriptDir "\data\Bases Data\Category.json")
	{
		Try {
			Download("https://raw.githubusercontent.com/BanditTech/WingmanReloaded/" BranchName "/data/Bases Data/Category.json", A_ScriptDir "\data\Bases Data\Category.json")
			Log("Verbose","Data downloaded Correctly", "Downloading Category for Bases was a success")
		} Catch {
			Log("Error","Data download error", "Category.json")
			MsgBox("Error ED02 : There was a problem downloading Category.json from Wingman Reloaded GitHub")
		}
	}
	BasesData := JSON.LoadFile(A_ScriptDir "\data\Bases Data\Category.json")
	if !FileExist(A_ScriptDir "\data\Bases Data\BasesWR.json")
	{
		Try {
			Download("https://raw.githubusercontent.com/BanditTech/WingmanReloaded/" BranchName "/data/Bases Data/BasesWR.json", A_ScriptDir "\data\Bases Data\BasesWR.json")
			Log("Verbose","Data downloaded Correctly", "Downloading BasesWR was a success")
		} Catch {
			Log("Error","Data download error", "BasesWR.json")
			MsgBox("Error ED02 : There was a problem downloading Category.json from Wingman Reloaded GitHub")
		}
	}
	BasesWR := JSON.LoadFile(A_ScriptDir "\data\Bases Data\BasesWR.json")
	For fk, fv in BasesData {
			faux := fk . ".json"
			if !FileExist(A_ScriptDir "\data\Bases Data\" faux)
			{
				Try {
					Download("https://raw.githubusercontent.com/BanditTech/WingmanReloaded/" BranchName "/data/Bases Data/" faux, A_ScriptDir "\data\Bases Data\" faux)
					Log("Verbose","Data downloaded Correctly", "Downloading BasesData was a success")
				} Catch {
					Log("Error","Data download error", faux)
					MsgBox("Error ED02 : There was a problem downloading Quest.json from Wingman Reloaded GitHub")
				}
			}
	}
	QuestItems := JSON.LoadFile(A_ScriptDir "\data\Bases Data\QuestItem.json")
}
UpdateBasesData()

; WR.Data.Perfect and WR.Data.Affix are hydrated from ScriptObject.ahk after
; WR has been initialized — both used to live here but referenced WR before
; it existed, which v2 won't tolerate.

if !FileExist(A_ScriptDir "\data\Affix_Lines.json")
{
	Download("https://raw.githubusercontent.com/BanditTech/WingmanReloaded/" BranchName "/data/Affix_Lines.json", A_ScriptDir "\data\Affix_Lines.json")
}

; ActualTier creation is run from ScriptObject.ahk after WR is initialized
; (ActualTierCreator writes to WR.ActualTier[...]).
If needReload
	Reload()
