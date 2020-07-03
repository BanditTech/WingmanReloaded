#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
; SaveDir := RegExReplace(A_ScriptDir, "data$", "save")
; SetWorkingDir %SaveDir%

Global PoESessionID := ""
, AccountNameSTR := ""
, selectedLeague := "Harvest"

curlReturn := ""
Object := POE_StashRequest(11)
Array_Gui(Object)
ExitApp


POE_StashRequest(FetchTab) {
  encodingError := ""

  postData   := "league=" selectedLeague
  . "&realm=pc"
  . "&accountName=" AccountNameSTR
  . "&tabs=0"
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


Curl_Download(url, ioData, ByRef ioHdr, options, useFallback = true, critical = false, binaryDL = false, errorMsg = "", ByRef reqHeadersCurl = "", handleAccessForbidden = true, ByRef returnCurl = false) {
  /*
    url    = download url
    ioData  = uri encoded postData 
    ioHdr  = array of request headers
    options  = multiple options separated by newline (currently only "SaveAs:",  "Redirect:true/false")
    
    useFallback = Use UrlDownloadToFile if curl fails, not possible for POST requests or when cookies are required 
    critical  = exit macro if download fails
    binaryDL  = file download (zip for example)
    errorMsg  = optional error message, will be added to default message
    reqHeadersCurl = returns the returned headers from the curl request 
    handleAccessForbidden = "true" throws an error message if "403 Forbidden" is returned, "false" prevents it, returning "403 Forbidden" to enable custom error handling
  */

  ; https://curl.haxx.se/download.html -> https://bintray.com/vszakats/generic/curl/
  /*
    parse options, create the cURL request and execute it
  */
  reqLoops++
  curl    := """" A_ScriptDir "\curl.exe"" "  
  headers  := ""
  cookies  := ""
  uAgent  := ""

  For key, val in ioHdr {    
    val := Trim(RegExReplace(val, "i)(.*?)\s*:\s*(.*)", "$1:$2"))

    If (RegExMatch(val, "i)^Cookie:(.*)", cookie)) {
      cookies .= cookie1 " "    
    }
    If (RegExMatch(val, "i)^User-Agent:(.*)", ua)) {
      uAgent := ua1 " "    
    }
  }
  cookies := StrLen(cookies) ? "-b """ Trim(cookies) """ " : ""
  uAgent := StrLen(uAgent) ? "-A """ Trim(uAgent) """ " : ""
  
  redirect := "L"
  PreventErrorMsg := false
  validateResponse := 1
  If (StrLen(options)) {
    Loop, Parse, options, `n 
    {
      If (RegExMatch(A_LoopField, "i)SaveAs:[ \t]*\K[^\r\n]+", SavePath)) {
        commandData  .= " " A_LoopField " "
        commandHdr  .= ""  
      }
      If (RegExMatch(A_LoopField, "i)Redirect:\sFalse")) {
        redirect := ""
      }
      If (RegExMatch(A_LoopField, "i)parseJSON:\sTrue")) {
        ignoreRetCodeForJSON := true
      }
      If (RegExMatch(A_LoopField, "i)PreventErrorMsg")) {
        PreventErrorMsg := true
      }
      If (RegExMatch(A_LoopField, "i)RequestType:(.*)", match)) {
        requestType := Trim(match1)
      }
      If (RegExMatch(A_LoopField, "i)ReturnHeaders:(.*skip.*)")) {
        skipRetHeaders := true
      }
      If (RegExMatch(A_LoopField, "i)ReturnHeaders:(.*append.*)")) {
        appendRetHeaders := true
      }
      If (RegExMatch(A_LoopField, "i)TimeOut:(.*)", match)) {
        timeout := Trim(match1)
      }
      If (RegExMatch(A_LoopField, "i)ValidateResponse:(.*)", match)) {
        If (Trim(match1) = "false") {
          validateResponse := 0
        }        
      }  
    }      
  }
  If (not timeout or timeout < 5) {
    timeout := 25
  }
  
  e := {}
  Try {    
    commandData  := ""    ; console curl command to return data/content 
    commandHdr  := ""    ; console curl command to return headers
    If (binaryDL) {
      commandData .= " -" redirect "Jkv "    ; save as file
      If (SavePath) {
        commandData .= "-o """ SavePath """ "  ; set target destination and name
      }
    } Else {
      commandData .= " -" redirect "ks --compressed "
      If (requestType = "GET") {        
        ;commandHdr  .= " -s" redirect " -D - -o /dev/null " ; unix
        commandHdr  .= " -s" redirect " -D - -o nul " ; windows
      } Else {
        commandHdr  .= " -I" redirect "ks "
      }
      
      If (appendRetHeaders) {
        commandData  .= " -w '%{http_code}' "
        commandHdr  .= " -w '%{http_code}' "
      }
    }      

    If (not requestType = "GET") {
      commandData .= headers
      commandHdr  .= headers
    }      
    If (StrLen(cookies)) {
      commandData .= cookies
      commandHdr  .= cookies
    }
    If (StrLen(uAgent)) {
      commandData .= uAgent
      commandHdr  .= uAgent
    }

    If (StrLen(ioData) and not requestType = "GET") {
      If (requestType = "POST") {
        commandData .= "-X POST "
      }
      commandData .= "--data """ ioData """ "
    } Else If (StrLen(ioData)) {
      url := url "?" ioData
    }
    
    If (binaryDL) {
      commandData  .= "--connect-timeout " timeout " "
      commandData  .= "--connect-timeout " timeout " "
    } Else {
      commandData  .= "--connect-timeout " timeout " --max-time " timeout + 15 " "
      commandHdr  .= "--connect-timeout " timeout " --max-time " timeout + 15 " "
    }
    ; get data
    html  := StdOutStream(curl """" url """" commandData)
    
    ;html := ReadConsoleOutputFromFile(curl """" url """" commandData, "commandData") ; alternative function
    
    If (returnCurl) {
      returnCurl := "curl " """" url """" commandData
    }

    ; get return headers in seperate request
    If (not binaryDL and not skipRetHeaders) {
      If (StrLen(ioData) and not requestType = "GET") {
        commandHdr := curl """" url "?" ioData """" commandHdr    ; add payload to url since you can't use the -I argument with POST requests          
      } Else {
        commandHdr := curl """" url """" commandHdr
      }
      ioHdr := StdOutStream(commandHdr)
      ;ioHrd := ReadConsoleOutputFromFile(commandHdr, "commandHdr") ; alternative function
    } Else If (skipRetHeaders) {
      commandHdr := curl """" url """" commandHdr
      ioHdr := html
    } Else {
      ioHdr := html
    }
    ;msgbox % curl """" url """" commandData "`n`n" commandHdr
    reqHeadersCurl := commandHdr
  } Catch e {

  }
  
  Return html
}


#Include %A_ScriptDir%/Library.ahk
