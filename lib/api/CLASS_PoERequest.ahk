; Efficient HTTP requests for POE resources
Class PoERequest {
  Stash(TabDigit) {
    Static Url := "https://www.pathofexile.com/character-window/get-stash-items"
    Static Headers := { "connection":"keep-alive", "cache-control":"max-age=0" }
    Headers["cookie"] := PoECookie
    postdata := {}
    postdata.league := UriEncode(selectedLeague)
    postdata.accountName := AccountNameSTR
    postdata.tabs := 0
    postdata.tabIndex := TabDigit - 1
    response := Util.HttpGet(Url,Headers,postdata)
    Return This.HandleResponse(response)
  }
  Account() {
    Static Url := "https://www.pathofexile.com/character-window/get-account-name"
    Static Headers := { "cache-control":"max-age=0", "accept-encoding":"gzip, deflate, br" }
    Headers["cookie"] := PoECookie
    response := Util.HttpGet(Url,Headers)
    ; Log("Account Response ","Request for account information returned:",response)
    obj := This.HandleResponse(response)
    Return ( obj ? obj.accountName : False )
  }
  Leagues(){
    Static Url := "http://api.pathofexile.com/leagues"
    response := Util.HttpGet(Url)
    Return This.HandleResponse(response)
  }
  HandleResponse(response){
    ; response := RegexReplace(response,"[]","")
    response := RegexReplace(response,"^[^\]\[\{\}""]*","")
    response := RegexReplace(response,"[^\]\[\{\}""]*$","")
    Try {
      obj := JSON.Load(response)
      If obj.error {
        Log("POERequest Error ", "API endpoint returned an error code",obj)
        Return False
      }
    } Catch e {
      Log("POERequest Error ","Invalid JSON error",response)
      Return False
    }
    Return obj
  }
}