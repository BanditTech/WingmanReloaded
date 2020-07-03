#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
SaveDir := RegExReplace(A_ScriptDir, "data$", "save")
; SetWorkingDir %SaveDir%

Global PoESessionID := ""
, AccountNameSTR := ""
, selectedLeague := "Harvest"

IniRead, PoESessionID, %SaveDir%\Account.ini, GGG, PoESessionID, %A_Space%
IniRead, AccountNameSTR, %SaveDir%\Account.ini, GGG, AccountNameSTR, %A_Space%

curlReturn := ""
Object := POE_StashRequest(11,1)
Array_Gui(Object)
ExitApp


POE_StashRequest(FetchTab,tabs:=0) {
  encodingError := ""

  postData   := "league=" selectedLeague
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

  reqHeaders.push("Connection: keep-alive")
  reqHeaders.push("Cache-Control: max-age=0")
  reqHeaders.push("Accept: */*")
  reqHeaders.push("Cookie: POESESSID=" . PoESessionID)
  
  ; ShowToolTip("Getting price prediction... ")
  retCurl := true
  response := Curl_Download(url, postData, reqHeaders, options, false, false, false, "", "", true, retCurl)
  
  debugout := RegExReplace("""" A_ScriptDir "\" retCurl, "curl", "curl.exe""")
  FileDelete, %A_ScriptDir%\temp\poeprices_request.txt
  FileAppend, %debugout%, %A_ScriptDir%\temp\poeprices_request.txt
  
  If (True) {
    FileDelete, %A_ScriptDir%\temp\DebugSearchOutput.html
    FileAppend, % response "<br />", %A_ScriptDir%\temp\DebugSearchOutput.html
  }

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

  Return responseObj
}

#Include %A_ScriptDir%/Library.ahk
