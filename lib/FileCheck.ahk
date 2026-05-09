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
for k, v in directories {
	if !FileExist(A_ScriptDir v) {
		DirCreate(A_ScriptDir v)
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
		Download("https://raw.githubusercontent.com/lvlvllvlvllvlvl/RePoE/master/RePoE/data/base_items.json", A_ScriptDir "\data\Bases.json")
		Log("Verbose","Data downloaded Correctly", "Downloading Bases.json was a success")
	} Catch {
		Log("Error","Data download error", "Bases.json")
		MsgBox("Error ED02 : There was a problem downloading Bases.json from RePoE")
	}
}
;Bases := JSON.Load(FileOpen(A_ScriptDir "\data\Bases.json","r").Read())

UpdatePOEData(){
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
	POEData := JSON.Load(FileOpen(A_ScriptDir "\data\PoE Data\Category.json","r").Read())
	For k, v in POEData {
		for ki, vi in v {
			aux := k . "(" . vi . ").json"
			if !FileExist(A_ScriptDir "\data\PoE Data\" aux)
			{
				Try {
					Download("https://raw.githubusercontent.com/BanditTech/WingmanReloaded/" BranchName "/data/PoE Data/" aux, A_ScriptDir "\data\PoE Data\" aux)
					Log("Verbose","Data downloaded Correctly", "Downloading POEData was a success")
				} Catch {
					Log("Error","Data download error", aux)
					MsgBox("Error ED02 : There was a problem downloading Quest.json from Wingman Reloaded GitHub")
				}
			}
		}
	}
}
UpdatePOEData()

UpdateBasesData(){
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
	BasesData := JSON.Load(FileOpen(A_ScriptDir "\data\Bases Data\Category.json","r").Read())
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
	BasesWR := JSON.Load(FileOpen(A_ScriptDir "\data\Bases Data\BasesWR.json","r").Read())
	For k, v in BasesData {
			aux := k . ".json"
			if !FileExist(A_ScriptDir "\data\Bases Data\" aux)
			{
				Try {
					Download("https://raw.githubusercontent.com/BanditTech/WingmanReloaded/" BranchName "/data/Bases Data/" aux, A_ScriptDir "\data\Bases Data\" aux)
					Log("Verbose","Data downloaded Correctly", "Downloading BasesData was a success")
				} Catch {
					Log("Error","Data download error", aux)
					MsgBox("Error ED02 : There was a problem downloading Quest.json from Wingman Reloaded GitHub")
				}
			}
	}
	QuestItems := JSON.Load(FileOpen(A_ScriptDir "\data\Bases Data\QuestItem.json","r").Read())
}
UpdateBasesData()

if !FileExist(A_ScriptDir "\data\PoE.Watch_PerfectUnique.json")
{
	RefreshPoeWatchPerfect()
}
WR.Data.Perfect := JSON.Load(FileOpen(A_ScriptDir "\data\PoE.Watch_PerfectUnique.json","r").Read(),,1)

if !FileExist(A_ScriptDir "\data\Affix_Lines.json")
{
	Download("https://raw.githubusercontent.com/BanditTech/WingmanReloaded/" BranchName "/data/Affix_Lines.json", A_ScriptDir "\data\Affix_Lines.json")
}
WR.Data.Affix := JSON.Load(FileOpen(A_ScriptDir "\data\Affix_Lines.json","r").Read(),,1)

;Create ActualTier
if !FileExist(A_ScriptDir "\save\ActualTier.json")
{
	ActualTierCreator()
}
If needReload
	Reload()
