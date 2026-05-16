; UpdateLeagues - Grab the League info from GGG API
UpdateLeagues(*) {
  global selectedLeague, MainGui
  MainGui.Submit(0)
  Download("http://api.pathofexile.com/leagues", A_ScriptDir "\data\leagues.json")
  LeagueIndex := JSON.LoadFile(A_ScriptDir "\data\leagues.json")
  leagueList := []
  For K, V in LeagueIndex
    leagueList.Push(V["id"])
  ctrl := MainGui["selectedLeague"]
  ctrl.Delete()
  ctrl.Add(leagueList)
  ctrl.Choose(selectedLeague)
}
