/*** PoEPrices.info functions from PoE-TradeMacro v2.15.7
*  Contains all the assorted functions needed to launch TradeFunc_DoPoePricesRequest
*/
TradeFunc_DoPoePricesRequest(RawItemData, ByRef retCurl) {
  RawItemData := RegExReplace(RawItemData, "<<.*?>>|<.*?>")
  encodingError := ""
  EncodedItemData := StringToBase64UriEncoded(RawItemData, true, encodingError)
  
  postData   := "l=" UriEncode(selectedLeague) "&i=" EncodedItemData
  payLength  := StrLen(postData)
  url     := "https://www.poeprices.info/api"
  
  reqTimeout := 25
  options  := "RequestType: GET"
  ;options  .= "`n" "ReturnHeaders: skip"
  options  .= "`n" "ReturnHeaders: append"
  options  .= "`n" "TimeOut: " reqTimeout
  reqHeaders := []

  reqHeaders.push("Connection: keep-alive")
  reqHeaders.push("Cache-Control: max-age=0")
  reqHeaders.push("Origin: https://poeprices.info")
  reqHeaders.push("Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8")
  
  ; ShowToolTip("Getting price prediction... ")
  retCurl := true
  response := Curl_Download(url, postData, reqHeaders, options, false, false, false, "", "", true, retCurl)
  
  ; debugout := RegExReplace("""" A_ScriptDir "\lib\" retCurl, "curl", "curl.exe""")
  FileDelete, %A_ScriptDir%\temp\poeprices_request.txt
  FileAppend, %retCurl%, %A_ScriptDir%\temp\poeprices_request.txt
  
  
  ; If (TradeOpts.Debug) {
    ; FileDelete, %A_ScriptDir%\temp\DebugSearchOutput.html
    ; FileAppend, % response "<br />", %A_ScriptDir%\temp\DebugSearchOutput.html
  ; }

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

  If (1) {
    arr := {}
    arr.aReturn := responseObj
    arr.RawItemData := RawItemData
    arr.EncodedItemata := EncodedItemData
    arr.League := selectedLeague
    FileDelete, %A_ScriptDir%\temp\poeprices_return.json
    FileAppend,% json_fromObj(arr), %A_ScriptDir%\temp\poeprices_return.json

    ; TradeFunc_LogPoePricesRequest(arr, request, "poe_prices_debug_log.txt")
  }

  ; responseObj.added := {}
  ; responseObj.added.encodedData := EncodedItemData
  ; responseObj.added.league := TradeGlobals.Get("LeagueName")
  ; responseObj.added.requestUrl := url "?" postData
  ; responseObj.added.browserUrl := url "?" postData "&w=1"
  ; responseObj.added.encodingError := encodingError
  ; responseObj.added.retHeader := responseHeader
  ; responseObj.added.timeoutParam := reqTimeout
  
  Return responseObj
}

StringToBase64UriEncoded(stringIn, noUriEncode = false, ByRef errorMessage = "") {
  FileDelete, %A_ScriptDir%\temp\itemText.txt
  FileDelete, %A_ScriptDir%\temp\base64Itemtext.txt
  FileDelete, %A_ScriptDir%\temp\encodeToBase64.txt
  
  encodeError1 := ""
  encodeError2 := ""
  stringBase64 := b64Encode(stringIn, encodeError1)
  
  If (not StrLen(stringBase64)) {
    FileAppend, %stringIn%, %A_ScriptDir%\temp\itemText.txt, utf-8
    command    := "certutil -encode -f ""%cd%\temp\itemText.txt"" ""%cd%\temp\base64ItemText.txt"" & type ""%cd%\temp\base64ItemText.txt"""
    stringBase64  := ReadConsoleOutputFromFile(command, "encodeToBase64.txt", encodeError2)
    stringBase64  := Trim(RegExReplace(stringBase64, "i)-----BEGIN CERTIFICATE-----|-----END CERTIFICATE-----|77u/", ""))
  }

  If (not StrLen(stringBase64)) {
    errorMessage := ""
    If (StrLen(encodeError1)) {
      errorMessage .= encodeError1 " "
    }
    If (StrLen(encodeError2)) {
      errorMessage .= "Encoding via certutil returned: " encodeError2
    }
  }
  
  If (not noUriEncode) {
    stringBase64  := UriEncode(stringBase64)
    stringBase64  := RegExReplace(stringBase64, "i)^(%0D)?(%0A)?|((%0D)?(%0A)?)+$", "")
  } Else {
    stringBase64 := RegExReplace(stringBase64, "i)\r|\n", "")
  }
  
  Return stringBase64
}

/*  Base64 Encode / Decode a string (binary-to-text encoding)
  https://github.com/jNizM/AHK_Scripts/blob/master/src/encoding_decoding/base64.ahk
  
  Alternative: https://github.com/cocobelgica/AutoHotkey-Util/blob/master/Base64.ahk
  */
b64Encode(string, ByRef error = "") {  
  VarSetCapacity(bin, StrPut(string, "UTF-8")) && len := StrPut(string, &bin, "UTF-8") - 1 
  If !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", 0, "uint*", size)) {
    ;throw Exception("CryptBinaryToString failed", -1)
    error := "Exception (1) while encoding string to base64."
  }  
  VarSetCapacity(buf, size << 1, 0)
  If !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", &buf, "uint*", size)) {
    ;throw Exception("CryptBinaryToString failed", -1)
    error := "Exception (2) while encoding string to base64."
  }
  
  If (not StrLen(Error)) {
    Return StrGet(&buf)
  } Else {
    Return ""
  }
}
b64Decode(string) {
  If !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", 0, "uint*", size, "ptr", 0, "ptr", 0))
    throw Exception("CryptStringToBinary failed", -1)
  VarSetCapacity(buf, size, 0)
  If !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", &buf, "uint*", size, "ptr", 0, "ptr", 0))
    throw Exception("CryptStringToBinary failed", -1)
  return StrGet(&buf, size, "UTF-8")
}

UriEncode(Uri, Enc = "UTF-8")  {
  StrPutVar(Uri, Var, Enc)
  f := A_FormatInteger
  SetFormat, IntegerFast, H
  Loop
  {
    Code := NumGet(Var, A_Index - 1, "UChar")
    If (!Code)
      Break
    If (Code >= 0x30 && Code <= 0x39 ; 0-9
      || Code >= 0x41 && Code <= 0x5A ; A-Z
      || Code >= 0x61 && Code <= 0x7A) ; a-z
      Res .= Chr(Code)
    Else
      Res .= "%" . SubStr(Code + 0x100, -1)
  }
  SetFormat, IntegerFast, %f%
  Return, Res
}

StrPutVar(Str, ByRef Var, Enc = "") {
  Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
  VarSetCapacity(Var, Len, 0)
  Return, StrPut(Str, &Var, Enc)
}

RandomStr(l = 24, i = 48, x = 122) { ; length, lowest and highest Asc value
  Loop, %l% {
    Random, r, i, x
    s .= Chr(r)
  }
  s := RegExReplace(s, "\W", "i") ; only alphanum.
  
  Return, s
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
  If FileExist(A_ScriptDir . "\data\curl.exe")
    curl    := """" A_ScriptDir "\data\curl.exe"" "  
  Else If FileExist(A_ScriptDir . "\curl.exe")
    curl    := """" A_ScriptDir "\curl.exe"" "  
  Else
    {
      MsgBox, Curl exe not found
      return {}
    }
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

ReadConsoleOutputFromFile(command, fileName, ByRef error = "") {
  file := "temp\" fileName
  RunWait %comspec% /c "chcp 1251 /f >nul 2>&1 & %command% > %file%", , Hide
  FileRead, io, %file%
  
  If (FileExist(file) and not StrLen(io)) {
    error := "Output file is empty."
  }
  Else If (not FileExist(file)) {
    error := "Output file does not exist."
  }
  
  Return io
}

StdOutStream(sCmd, Callback = "") {
  /*
    Runs commands in a hidden cmdlet window and returns the output.
  */
              ; Modified  :  Eruyome 18-June-2017
  Static StrGet := "StrGet"  ; Modified  :  SKAN 31-Aug-2013 http://goo.gl/j8XJXY
              ; Thanks to :  HotKeyIt     http://goo.gl/IsH1zs
              ; Original  :  Sean 20-Feb-2007 http://goo.gl/mxCdn
  64Bit := A_PtrSize=8

  DllCall( "CreatePipe", UIntP,hPipeRead, UIntP,hPipeWrite, UInt,0, UInt,0 )
  DllCall( "SetHandleInformation", UInt,hPipeWrite, UInt,1, UInt,1 )

  If 64Bit {
    VarSetCapacity( STARTUPINFO, 104, 0 )    ; STARTUPINFO      ;  http://goo.gl/fZf24
    NumPut( 68,     STARTUPINFO,  0 )    ; cbSize
    NumPut( 0x100,    STARTUPINFO, 60 )    ; dwFlags  =>  STARTF_USESTDHANDLES = 0x100
    NumPut( hPipeWrite, STARTUPINFO, 88 )    ; hStdOutput
    NumPut( hPipeWrite, STARTUPINFO, 96 )    ; hStdError

    VarSetCapacity( PROCESS_INFORMATION, 32 )  ; PROCESS_INFORMATION  ;  http://goo.gl/b9BaI
  } Else {
    VarSetCapacity( STARTUPINFO, 68,  0 )    ; STARTUPINFO      ;  http://goo.gl/fZf24
    NumPut( 68,     STARTUPINFO,  0 )    ; cbSize
    NumPut( 0x100,    STARTUPINFO, 44 )    ; dwFlags  =>  STARTF_USESTDHANDLES = 0x100
    NumPut( hPipeWrite, STARTUPINFO, 60 )    ; hStdOutput
    NumPut( hPipeWrite, STARTUPINFO, 64 )    ; hStdError

    VarSetCapacity( PROCESS_INFORMATION, 32 )  ; PROCESS_INFORMATION  ;  http://goo.gl/b9BaI
  }

  If ! DllCall( "CreateProcess", UInt,0, UInt,&sCmd, UInt,0, UInt,0 ;  http://goo.gl/USC5a
        , UInt,1, UInt,0x08000000, UInt,0, UInt,0
        , UInt,&STARTUPINFO, UInt,&PROCESS_INFORMATION )
  Return ""
  , DllCall( "CloseHandle", UInt,hPipeWrite )
  , DllCall( "CloseHandle", UInt,hPipeRead )
  , DllCall( "SetLastError", Int,-1 )

  hProcess := NumGet( PROCESS_INFORMATION, 0 )
  If 64Bit {
    hThread  := NumGet( PROCESS_INFORMATION, 8 )
  } Else {
    hThread  := NumGet( PROCESS_INFORMATION, 4 )
  }

  DllCall( "CloseHandle", UInt,hPipeWrite )

  AIC := ( SubStr( A_AhkVersion, 1, 3 ) = "1.0" )           ;  A_IsClassic
  VarSetCapacity( Buffer, 4096, 0 ), nSz := 0

  While DllCall( "ReadFile", UInt,hPipeRead, UInt,&Buffer, UInt,4094, UIntP,nSz, Int,0 ) {
    tOutput := ( AIC && NumPut( 0, Buffer, nSz, "Char" ) && VarSetCapacity( Buffer,-1 ) )
        ? Buffer : %StrGet%( &Buffer, nSz, "CP850" )

    Isfunc( Callback ) ? %Callback%( tOutput, A_Index ) : sOutput .= tOutput
  }

  DllCall( "GetExitCodeProcess", UInt,hProcess, UIntP,ExitCode )
  DllCall( "CloseHandle",  UInt,hProcess  )
  DllCall( "CloseHandle",  UInt,hThread   )
  DllCall( "CloseHandle",  UInt,hPipeRead )
  DllCall( "SetLastError", UInt,ExitCode  )

  Return Isfunc( Callback ) ? %Callback%( "", 0 ) : sOutput
}

; PoePrices server status - PPServerStatus
PPServerStatus()
{
  Global PPServerStatus
  RTT := Ping4("www.poeprices.info", Result)
  If (ErrorLevel){
    Log("Error","PoePrice Error: " ErrorLevel)
    PPServerStatus := False
  } Else {
    PPServerStatus := True
  }
  Return PPServerStatus
}
