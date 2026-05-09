; UpdateLeagues - Grab the League info from GGG API
UpdateLeagues() {
  LootFilterGui.Submit(0)
  Download("http://api.pathofexile.com/leagues", A_ScriptDir "\data\leagues.json")
  LeagueIndex := JSON.Load(FileOpen(A_ScriptDir "\data\leagues.json","r").Read())
  textList := ""
  For K, V in LeagueIndex
    textList .= "|" LeagueIndex[K]["id"]
  WR_selectedLeague.Value := "|" selectedLeague "|" textList
  WR_selectedLeague.Choose(selectedLeague)
}
