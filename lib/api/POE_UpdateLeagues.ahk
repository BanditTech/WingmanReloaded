; UpdateLeagues - Grab the League info from GGG API
UpdateLeagues:
  Gui, Submit, nohide
  UrlDownloadToFile, http://api.pathofexile.com/leagues, %A_ScriptDir%\data\leagues.json
  FileRead, JSONtext, %A_ScriptDir%\data\leagues.json
  LeagueIndex := JSON.Load(JSONtext)
  textList= 
  For K, V in LeagueIndex
    textList .= "|" LeagueIndex[K]["id"]
  GuiControl, , selectedLeague, % "|" selectedLeague "|" textList
  GuiControl, ChooseString, selectedLeague, %selectedLeague%
Return
