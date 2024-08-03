; Global Script Object
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Global WR := {"loc":{},"Flask":{},"Utility":{},"perChar":{},"Debug":{}
	,"cdExpires":{},"func":{},"data":{},"String":{},"Restock":{}
	,"CustomCraftingBases":{},"CustomMapMods":{},"ItemCrafting":{},"ActualTier":{}}
WR.loc.pixel := {}, WR.loc.area := {}
WR.data.Counts := {}
for k, v in ["DetonateDelve", "Detonate", "Gui", "GuiChaos", "VendorAccept", "DivTrade", "DivItem"
	,"CurrencyGeneral","CurrencyInfluence"
	, "Wisdom", "Portal", "Blacksmith", "Armourer", "Glassblower", "Gemcutter", "Chisel"
	,"Transmutation","Alteration","Annulment","Chance","Regal","Alchemy","Chaos","Veiled"
	,"Augmentation","Divine"
	,"Jeweller","Fusing","Chromatic","Harbinger","Horizon"
	,"Enkindling","Ancient","Binding","Engineer","Regret","Unmaking"
	,"Instilling","Scouring","Sacred","Blessed","Vaal"
	, "OnMenu", "OnChar", "OnChat", "OnInventory", "OnStash", "OnVendor", "OnVendorHeist"
	, "OnDiv", "OnLeft", "OnDelveChart"]
	WR.loc.pixel[v] := {"X":0,"Y":0}

for k, v in []
	WR.loc.area[v] := {"X1":0,"Y1":0,"X2":0,"Y2":0}
WR.cdExpires.Group := {}, WR.cdExpires.Flask := {}, WR.cdExpires.Utility := {}, WR.cdExpires.Binding := {}
WR.cdExpires.Binding.Move := ""
WR.func.Toggle := {"Flask":"1","Move":"1","Quit":"0","Utility":"1","PopAll":"0"}
WR.func.failsafe := {"OHB":"1"}
WR.perChar.Setting := {"typeLife":"1", "typeHybrid":"0", "typeES":"0", "typeEldritch":"0"
	, "quitDC":"1", "quitPortal":"0", "quitExit":"0", "quitBelow":"20", "quitLogBackIn":"1"
	, "movementDelay":".5", "movementMainAttack":"0", "movementSecondaryAttack":"0"
	, "channelrepressEnable":"0" , "channelrepressKey":"RButton", "channelrepressOffsetX1":"0", "channelrepressOffsetY1":"0", "channelrepressOffsetX2":"0", "channelrepressOffsetY2":"20"
	, "channelrepressIcon":"|<Scourge Arrow>0xFDF100@0.60$40"
	. ".108104040k60E0k30M303UQ1UA0C1kC0s0s70w7U3US3kC040k70k0E30M1011hzw4049zwQE0F3zVt01SLwDw0DsjUzk0zmS7zkDz9QTk1Xw3lk001sD60oQ3UwED1w23k1w7s0DUDkTk3B1z1zUBo5y7z26U0sTk0H00lw0A0017U2k000w0053w/c00kDwj3k01zMMzU0Dptrz01wFgzzU7U2rzzwQ0Tzzzllz7zzzzz03zzzzU003zz008"
	, "channelrepressStack":"|<5 stacks>*52$8.zsC3bsS3wz7nwsSTzs"
	, "autominesEnable":"0", "autominesBoomDelay":"500", "autominesPauseDoubleTapSpeed":"300", "autominesPauseSingleTap":"2", "autominesSmokeDashEnable":"0", "autominesSmokeDashKey":"q"
	, "autolevelgemsEnable":"0", "autolevelgemsWait":"0"
	, "swap1AltWeapon":"0", "swap1Item":"0", "swap1Xa":"0", "swap1Ya":"0", "swap1Xb":"0", "swap1Yb":"0"
	, "swap2AltWeapon":"0", "swap2Item":"0", "swap2Xa":"0", "swap2Ya":"0", "swap2Xb":"0", "swap2Yb":"0"
	, "profilesYesFlask":"0", "profilesFlask":"", "profilesYesUtility":"0", "profilesUtility":""}
for k, v in ["1","2","3","4","5"]
{
	WR.Flask[v] := {"Key":v, "GroupCD":"150", "Condition":"1", "CD":"4000"
		, "Group":"f"A_Index, "Slot":A_Index, "Type":"Flask"
		, "MainAttack":"0", "SecondaryAttack":"0", "MainAttackRelease":"0", "SecondaryAttackRelease":"0", "Move":"0", "PopAll":"1", "Life":0, "ES":0, "Mana":0
		, "Curse":"0", "Shock":"0", "Bleed":"0", "Freeze":"0", "Ignite":"0", "Poison":"0", "ResetCooldownAtHealthPercentage":"0", "ResetCooldownAtHealthPercentageInput":"0", "ResetCooldownAtEnergyShieldPercentage":"0", "ResetCooldownAtEnergyShieldPercentageInput":"0", "ResetCooldownAtManaPercentage":"0", "ResetCooldownAtManaPercentageInput":"0"}
	WR.cdExpires.Flask[v] := A_TickCount
}
for k, v in ["1","2","3","4","5","6","7","8","9","10"]
{
	WR.Utility[v] := {"Enable":"0", "OnCD":"0", "Condition":"1", "Key":v, "GroupCD":"5000", "CD":"5000"
		, "Group":"u"A_Index, "Slot":A_Index, "QS":"0", "Type":"Utility"
		, "MainAttackOnly":"0", "MainAttack":"0", "SecondaryAttack":"0", "MainAttackRelease":"0", "SecondaryAttackRelease":"0", "Move":"0", "PopAll":"0", "Life":0, "ES":0, "Mana":0
		, "Icon":"", "IconShown":"0", "IconSearch":"1", "IconArea":{}, "IconVar0":"0", "IconVar1":"0"
		, "Curse":"0", "Shock":"0", "Bleed":"0", "Freeze":"0", "Ignite":"0", "Poison":"0"}
	WR.cdExpires.Utility[v] := A_TickCount
}
for k, v in ["f1","f2","f3","f4","f5","u1","u2","u3","u4","u5","u6","u7","u8","u9","u10","Mana","Life","ES","QuickSilver","Defense"]
	WR.cdExpires.Group[v] := A_TickCount

for k, v in ["h768","h1050","h1080","h1440","h2160"]
	WR.String[v] := {}

WR.String.h1080.Debuff :={"EleW":"|<1080 Ele Weakness>0xF6E9FE@0.75$22.01s000s401k005W14vo2LZE3PO05ZykDHblYi/rOMpoVVFH44mYEncH0NE8U11V04A209U40w067005U2i"
	,"Vuln":"|<1080 Vulnerability>0xAF1015@0.90$34.0kE7000DAC013xwQ84Drsk0YzzV02xzs0U3rzY60CkSEA1k0s0k4E1k1WV03XX0U03wAC0UDsm000Tl0001zaE007yM000TsU001sU0007kA000zk003bz0020zsQ0k0zXUADvwA11zzVk0Dys0007llU00D0807000U1YM0M00HsME00Dzk003zy0003rEE2"
	,"Enfeeble":"|<1080 Enfeeble>0x6A7E25@0.75$24.Ms30BntUDjyk5TzM1Tzc3zzc2zzU2zza2zza2Tza3Tva3zfj7jcT7rYT7sETryFTzzOjzvOjzrCyzbjTzjjSTDzyTTzwDTztKTzmMzz6gDwTjU1xU"
	,"TempChains":"|<1080 Temp Chains>0x7442D7@0.75$29.03kA00ttq03vzq0Tnzi1zrzi3zbzA7z7zQzy3yzjs7wzTkjxyzZTnxz0zbvz1yTrznszbzbbzjzgDjDz1zT7w7yTU0Dxzk07vzzV7rzz9VzzwPsTztrwxznbzlzjjVVzTQ01wyc8"
	,"Conductivity":"|<1080 Conductivity>0x91CCFE@0.79$23.3z00S7k1k1s203w81ww0DD87ntswSQPjvsFs6wTTyuXXQxy7XP03A7044T0M8j1c37Y0A3k3k0zy2"
	,"Flammability":"|<1080 Flammability>0xFDCF61@0.79$18.0zU3UkC0AM0SM1qk7BUDlUP1Xg0iE1vU1aG1sV5kUdkUzMmLAITU"
	,"Frostbite":"|<1080 Frostbite>0xE2F6FC@0.79$21.4Tk1C7k70n4U7As1wq0/nU3/A0QdU3kY0q2U7M00xUU7q41AFUMU+203EE0F2044k1US0MU"
	,"WMark":""
	,"Poison":"|<1080 Poison>0xDFF381@0.86$16.wM3V01404E3i07s0S0fU3Y07U0C00M00U02"
	,"Shock":"|<1080 Shock>0xD3F9F0@0.79$21.1qTU9ts7Tb0k2s6073k0ww03bk0Ry07zs0zz07zw0zzU7zw0zz07zk0Dw01w"
	,"Bleed":"|<1080 Bleed>0xE41B27@0.79$27.01s000DU0074000zk00430012M008G0010E00040000Y001AU011U00AA001V000A8U03V007s0Q1w03szU07rD00DvwLxzzyzbtbbqTCAXXsvYsP0wS3s51kA|<Corrupting Blood>*39$11.sV+2K6yHC7wDgDQSs9WO02U"
	,"Freeze":"|<1080 Frozen>0xCBEEF6@0.93$14.EXo0Q01U0M0a81U0c0/b3M0y0C"
	,"Ignite":"|<1080 Ignite>0xFFEC00@0.70$23.0F003y4060M03lk1jXU20L040C0M0A3k0M7U0kD03wD07sy0Dlw0TXw0z7s1zDU1wS03ys03z000Q000A"}
WR.String.h1080.Vendor:={"Hideout":"|<1080 Lilly Roth>*93$29.bDtll4TnX79zbCT7z0wyDy1twTwlnsztlX|<1080 Einhar>*93$28.0TznYNzzCFXzw36Dzk4NzzC07zws0zznkFzzC1XDwt74zkC"
	,"Mines":"|<1080 niko>*104$121.7yTzzzzzzzzzzzzzzzzzXyDzzzzzzzzzzzzzzzzzlz7xzDzzzzzzbzzzzrxzsT3wz1043UDz0w3w0Nws4DVwDAgPBlbzCDBylgySO3oy7byDbslz7bbzsyTDD1mSFlz7nwMzblnzwTDbbYtDAwDXsCAznssDyDU3kG9bUT3lwD0ztwQDz7k1sNYnU7lsyTUTwyCTzXtwwwktnnwQTDl7yDDDzlwySSMQHtiSDbslzX7bzsyTDDCS9wET7kAQTsDnzwTDbUTjzzyzzzzzzzTzzzzzzzs"
	,"Lioneye":"|<1080 Nessa>*100$48.TtzzzzzzDtzzzzzz7tzzbtzj3tkD1kTD1ttiNaS70ttyTby78NtyDXwXANsD3kwnC9sTVsQ3D1tzlwM1DVtzsy9tDltytiHtDts63UnszzzzjvzzU|<1080 Bestel>*100$54.zzzzzzzzzUzzzzzzzzUTzzzzzzzbDzwzzzyzbC1s80UQTbDBn/6nSTUTDnz7nyTUDDlz7nyTb71sT7kSTb73wD7kyTbbDyD7nyTbbDz77nyTbDDrD7nyRUT0kT7kC1zzzxzzzzzzzzzzzzzzU"
	,"Forest":"|<1080 Greust>*87$59.s7zzzzzzzzU7zzzzzzzyDDzzzTjbzsys3UASA201zlbaMyNZX7zX7Dlwnz7Dz6CTXtXyCDaAw7bn1wQSA1sDDbVssyM7nyTDXlkwl7bwyzXXktX7DstrD7k3761s7USDszzzzwznzy"
	,"Sarn":"|<1080 Clarissa>*100$73.zzzzzzzzzzzzz3zzzzzzzzzzy0TzzzzzzzzzyDCzxzzvwzDxyDiDwy0sw71wz7zbwD6SQnAwDbzny7X7CTby7nztyFlXb7lyFszwzAsnnkwDAwTyTUQ3twD3USDzDU61wz7lU73vbnn4STlwHnklnXtX7CtiHtw1s1wFlb1kNwTrzzzzzzvyzzzzzzzzzzzzzzy"
	,"Highgate":"|<1080 Petarus>*100$69.zzzzzzzzzzzw7zzzzzzzzzzUDzzzzzzzzzwtzzzzTzyzTDb61U3ns3XlkQsthXQD6QTAnb7DwTVslXtbwttzXt76ATATUT1wTAsnntkwDsTXs70yTD3bzDwS0M7ntwQztzXnn4STTlbzDwQyMllniQzs7Xbl770w7zzzzzzzzyTvzzzzzzzzzzzzU"
	,"Overseer":"|<1080 Lani>*100$36.zzzzzzbzzzzzbzzzzzbzjrxvbzDXslby7lttby7kttbwXkNtbwnm9tbw3n9tbs1n1tbttnVtb3tnltU3snttzzzzzzU"
	,"Bridge":"|<1080 Helena>*100$62.DlzzzzzzzznwTzzzzzzzwz7zxzzvyzjDlkCDUQT7nnwSPnwrXnsQz7bwzDsQy701tzDny3D8k0S3nw7YHnAz7Vwz3tYw3DltzDnyMC0HwSTnwzb3bYz7bwvDtsntDls70kCTAy8"
	,"Docks":"|<1080 Lani>*100$36.zzzzzzbzzzzzbzzzzzbzjrxvbzDXslby7lttby7kttbwXkNtbwnm9tbw3n9tbs1n1tbttnVtb3tnltU3snttzzzzzzU"
	,"Oriath":"|<1080 Lani>*100$36.zzzzzzbzzzzzbzzzzzbzjrxvbzDXslby7lttby7kttbwXkNtbwnm9tbw3n9tbs1n1tbttnVtb3tnltU3snttzzzzzzU"}
WR.String.h1080.General:={"OHB":"|<1080 Overhead Health Bar>0x201614@0.99$106.Tzzzzzzzzzzzzzzzzu"
	,"SkillUp":"|<1080 Skill Up>0xAA6204@0.80$9.sz7ss0000sz7sw"
	,"SellItems":"|<1080 Sell Items>*100$80.zzzjTzzzzzzzzzzzlXzzzzzzzzy3zwMzlzzzzzzz0TzbDyTzzzzzznbztnzbbzzzzzwzsSQztkC74AT37w3bDyQ30k03UESQtnzbbbAAANa3b6Qztttlb76TsM1bDySS0NllVz6Ttnzb7byQQQ7sbyQztltzb77lyMxbDyQSDFlly360NnzbUU4QQPY3kCQztsA37761nzDzzzzDnzzzts"
	,"Stash":"|<1080 Stash>0xC8C8DC@0.78$57.00Q000000006s00000001V00000000A3zVUT6301k3UC48kM070A2kk6300S1UK70kM01sA4MQ7z0031UX1skM00MADs3630031V1UMkM08MA8AX6300y1X0rkkQ"
	,"Xbutton":"|<1080 X Button>*43$12.0307sDwSDwDs7k7sDwSSwTsDk7U"}

WR.CustomMapMods.MapMods := []
WR.CustomMapMods.HeistMods := []

for k,v in POEData
{
	WR.ItemCrafting[k] := {}
	WR.ActualTier[k] := {}
	WR.CustomCraftingBases[k] := {}
	for ki,vi in v{
		WR.ItemCrafting[k][vi] := {}
	}
}

for k,v in BasesData
{
	WR.CustomCraftingBases[k] := {}
}

; Only Enable to Reclear ActualTier every Reload/Start
;ActualTierCreator()

WR.Data.Map_Affixes := RegexReplace(ArrayToString(Util.Load("Affix_List_Map")),"\%","`%")
WR.Data.Map_Affixes := RegexReplace(WR.Data.Map_Affixes,",","`,")

; Make Default profiles if they do not exist
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
For k, name in ["perChar","Flask","Utility"]{
	If !FileExist( A_ScriptDir "\save\profiles\" name "\Default.json")
		Profile(name,"Save","Default")
}

