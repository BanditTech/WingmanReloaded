; UpdateLeagues - Grab the League info from GGG API
UpdateLeagues() {
  global selectedLeague, MainGui
  MainGui.Submit(0)
  Download("http://api.pathofexile.com/leagues", A_ScriptDir "\data\leagues.json")
  LeagueIndex := JSON.LoadFile(A_ScriptDir "\data\leagues.json")
  textList := ""
  For K, V in LeagueIndex
    textList .= "|" LeagueIndex[K]["id"]
  MainGui["selectedLeague"].Value := "|" selectedLeague "|" textList
  MainGui["selectedLeague"].Choose(selectedLeague)
}
