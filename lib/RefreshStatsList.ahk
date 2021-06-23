RefreshStatsList(){
	tooltip, refreshing stats
	UrlDownloadToFile, https://www.pathofexile.com/api/trade/data/stats, %A_ScriptDir%\temp\new_Stats.json
	FileRead, JSONtext, %A_ScriptDir%\temp\GGG_Stats.json
	result := JSON.Load(JSONtext,,1).result
	AffixKeyList := []
	EnchantKeyList := []
	for Ck, Cv in result
	{
		For k, v in Cv.entries
		{
			v.text := RegExReplace(v.text, rxNum, "#")
			If InStr(v.text,"`n")
			{
				tlist := []
				For k, t in StrSplit(v.text,"`n")
					tlist.Push(t)
				v.text := tlist
			}
			If indexOf(Cv.label,["Explicit","Implicit"])
			{
				If IsObject(v.text)
				{
					for i, t in v.text
						If !indexOf(t,AffixKeyList)
							AffixKeyList.Push(t)
				} Else {
					If !indexOf(v.text,AffixKeyList)
						AffixKeyList.Push(v.text)
				}
			}
			If indexOf(Cv.label,["Enchant"])
			{
				If IsObject(v.text)
				{
					for i, t in v.text
						If !indexOf(t,EnchantKeyList)
							EnchantKeyList.Push(t)
				} Else {
					If !indexOf(v.text,EnchantKeyList)
						EnchantKeyList.Push(v.text)
				}
			}
		}
	}
	; MsgBoxVals(AffixKeyList)
	
	tooltip,
	JSONtext := JSON_Beautify(result," ",3)
	FileDelete, %A_ScriptDir%\data\GGG_Stats.json
	FileAppend, %JSONtext%, %A_ScriptDir%\data\GGG_Stats.json

	JSONtext := JSON_Beautify(AffixKeyList," ",3)
	FileDelete, %A_ScriptDir%\data\WR_Affix.json
	FileAppend, %JSONtext%, %A_ScriptDir%\data\WR_Affix.json

	JSONtext := JSON_Beautify(EnchantKeyList," ",3)
	FileDelete, %A_ScriptDir%\data\WR_Enchant.json
	FileAppend, %JSONtext%, %A_ScriptDir%\data\WR_Enchant.json
	JSONtext := ""
}