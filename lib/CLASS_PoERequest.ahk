; Efficient HTTP requests for POE resources
Class PoERequest {
  Stash(TabDigit) {
    Static Url := "https://www.pathofexile.com/character-window/get-stash-items"
    Static Headers := { "connection":"keep-alive", "cache-control":"max-age=0", "accept":"*/*" }
    Headers["cookie"] := PoECookie
    postdata := {}
    postdata.league := UriEncode(selectedLeague)
    postdata.accountName := AccountNameSTR
    postdata.tabs := 0
    postdata.tabIndex := TabDigit - 1
    
    response := Util.HttpGet(Url,Headers,postdata)
    If WR.Debug.LogRequest {
      Log("POERequest","Stash Response",response)
    }
    Try {
      obj := JSON.Load(response)
    } Catch e {
      Log("POERequest Error ","Invalid JSON error",response)
      Return False
    }
    Return obj
  }
  Account() {
    Static Url := "https://www.pathofexile.com/character-window/get-account-name"
    Static Headers := { "cache-control":"max-age=0", "accept":"*/*", "accept-encoding":"gzip, deflate, br" }
    Headers["cookie"] := PoECookie
    response := Util.HttpGet(Url,Headers)
    If WR.Debug.LogRequest {
      Log("POERequest","Account Response",response)
    }
    Try {
      obj := JSON.Load(response)
    } Catch e {
      Log("POERequest Error ","Invalid JSON error",response)
      Return False
    }
    Return obj.accountName
  }
}