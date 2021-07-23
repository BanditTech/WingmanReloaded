; Requests GGG stash API, requires SessionID and Account Name
POE_RequestStash(FetchTab,tabs:=0) {
  FetchTab:=FetchTab-1
  encodingError := ""

  postData   := "league=" . UriEncode(selectedLeague)
  . "&realm=pc"
  . "&accountName=" AccountNameSTR
  . "&tabs=" . tabs
  . "&tabIndex=" FetchTab
  payLength  := StrLen(postData)
  url     := "https://www.pathofexile.com/character-window/get-stash-items"
  
  reqTimeout := 25
  options  := "RequestType: GET"
  ;options  .= "`n" "ReturnHeaders: skip"
  options  .= "`n" "ReturnHeaders: append"
  options  .= "`n" "TimeOut: " reqTimeout
  reqHeaders := []

  reqHeaders.push("connection: keep-alive")
  reqHeaders.push("cache-Control: max-age=0")
  reqHeaders.push("accept: */*")
  reqHeaders.push("cookie: "PoECookie)
  
  ; ShowToolTip("Getting price prediction... ")
  retCurl := true
  response := Curl_Download(url, postData, reqHeaders, options, false, false, false, "", "", true, retCurl)
  
  responseObj := {}
  responseHeader := ""
  
  RegExMatch(response, "is)(.*?({.*}))?.*?'(.*?)'.*", responseMatch)
  response := responseMatch1
  responseHeader := responseMatch3

  Try {
    responseObj := JSON.Load(response)
  } Catch e {
    responseObj.failed := "ERROR: Parsing response failed, invalid JSON! "
  }
  If (not isObject(responseObj)) {    
    responseObj := {}
  }

  If (true) { ; Debug messages for the content response
    debugout := RegExReplace("""" A_ScriptDir "\data\" retCurl, "curl", "curl.exe""")
    FileDelete, %A_ScriptDir%\temp\Stash_request.txt
    FileAppend, %debugout%, %A_ScriptDir%\temp\Stash_request.txt
    FileDelete, %A_ScriptDir%\temp\DebugStashOutput.html
    FileAppend, % response "<br />", %A_ScriptDir%\temp\DebugStashOutput.html
    FileDelete, %A_ScriptDir%\temp\DebugStashJSON.json
    FileAppend, % JSON.Dump(responseObj,,2), %A_ScriptDir%\temp\DebugStashJSON.json
  }

  Return responseObj
}
