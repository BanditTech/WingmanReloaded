; Requests GGG account API, requires SessionID
POE_RequestAccount() {
  encodingError := ""

  postData   := ""
  payLength  := StrLen(postData)
  url     := "https://www.pathofexile.com/character-window/get-account-name"
  
  reqTimeout := 25
  options  := "RequestType: GET"
  ;options  .= "`n" "ReturnHeaders: skip"
  options  .= "`n" "ReturnHeaders: append"
  options  .= "`n" "TimeOut: " reqTimeout
  reqHeaders := []

  ; reqHeaders.push("Connection: keep-alive")
  reqHeaders.push("cache-control: max-age=0")
  reqHeaders.push("accept: */*")
  reqHeaders.push("accept-encoding: gzip, deflate, br")
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
    FileDelete, %A_ScriptDir%\temp\account_request.txt
    FileAppend, %debugout%, %A_ScriptDir%\temp\account_request.txt
    FileDelete, %A_ScriptDir%\temp\DebugAccountOutput.html
    FileAppend, % response "<br />", %A_ScriptDir%\temp\DebugAccountOutput.html
    FileDelete, %A_ScriptDir%\temp\DebugAccountJSON.json
    FileAppend, % JSON.Dump(responseObj,,2), %A_ScriptDir%\temp\DebugAccountJSON.json
  }

  Return responseObj
}
