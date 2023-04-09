RefreshStatsList(){
	tooltip, refreshing stats
	UrlDownloadToFile, https://www.pathofexile.com/api/trade/data/stats, %A_ScriptDir%\temp\new_Stats.json
	result := JSON.Load(RegExReplace(FileOpen(A_ScriptDir "\temp\new_Stats.json","r").Read(), " \(\\u00d7#\)", ""),,1).result
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
				} Else If IsObject(v.option) {
					desc := StrSplit(v.text,"#").1
					For i, t in v.option.options
						for i, tx in StrSplit(RegExReplace(RegExReplace(t.text, "\+", ""), rxNum, "#"), "`n")
							If !indexOf(desc tx,EnchantKeyList)
								EnchantKeyList.Push(desc tx)
				} Else {
					If !indexOf(v.text,EnchantKeyList)
						EnchantKeyList.Push(v.text)
				}
			}
		}
	}
	; MsgBoxVals(AffixKeyList)
	
	tooltip,
	FileOpen(A_ScriptDir "\data\GGG_Stats.json","w").Write(JSON_Beautify(result," ",3))
	FileOpen(A_ScriptDir "\data\WR_Affix.json","w").Write(JSON_Beautify(AffixKeyList," ",3))
	FileOpen(A_ScriptDir "\data\WR_Enchant.json","w").Write(JSON_Beautify(EnchantKeyList," ",3))
}