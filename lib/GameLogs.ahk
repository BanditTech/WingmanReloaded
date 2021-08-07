; Captures the current Location and determines if in Town, Hideout or Azurite Mines
CompareLocation(cStr:="")
{
  Static Lang := ""
  ;                                                     English / Thai                French                 German                  Russian                     Spanish                   Portuguese               Chinese             Korean
  Static ClientTowns :=  { "Lioneye's Watch" :    [ "Lioneye's Watch"       , "Le Guet d'Œil de Lion"  , "Löwenauges Wacht"    , "Застава Львиного глаза", "La Vigilancia de Lioneye", "Vigília de Lioneye"      , "獅眼守望"       , "라이온아이 초소에" ]
                      , "The Forest Encampment" : [ "The Forest Encampment" ,"Le Campement de la forêt", "Das Waldlager"       , "Лесной лагерь"         , "El Campamento Forestal"  , "Acampamento da Floresta" , "森林營地"       , "숲 야영지에" ]
                      , "The Sarn Encampment" :   [ "The Sarn Encampment"   , "Le Campement de Sarn"   , "Das Lager von Sarn"  , "Лагерь Сарна"          , "El Campamento de Sarn"   , "Acampamento de Sarn"     , "薩恩營地"       , "사안 야영지에" ]
                      , "Highgate" :              [ "Highgate"              , "Hautevoie"              , "Hohenpforte"         , "Македы"                , "Atalaya"                                             , "統治者之殿"     , "하이게이트에" ]
                      , "Overseer's Tower" :      [ "Overseer's Tower"      , "La Tour du Superviseur","Der Turm des Aufsehers", "Башня надзирателя"     , "La Torre del Capataz"    , "Torre do Capataz"        , "堅守高塔"       , "감시탑에" ]
                      , "The Bridge Encampment" : [ "The Bridge Encampment" , "Le Campement du pont"   , "Das Brückenlager"    , "Лагерь на мосту"       , "El Campamento del Puente", "Acampamento da Ponte"    , "橋墩營地"       , "다리 야영지에" ]
                      , "Oriath Docks" :          [ "Oriath Docks"          , "Les Docks d'Oriath"     , "Die Docks von Oriath", "Доки Ориата"           , "Las Dársenas de Oriath"  , "Docas de Oriath"         , "奧瑞亞港口"     , "오리아스 부두에" ]
                      , "Oriath" :                [ "Oriath"                                                                   , "Ориат"                                                                         , "奧瑞亞"         , "오리아스에" ]
                      , "Karui Shores" :          [ "Karui Shores" ]
                      , "The Rogue Harbour" :     [ "The Rogue Harbour","ท่าเรือโจร","Le Port des Malfaiteurs", "Der Hafen der Abtrünnigen", "Разбойничья гавань", "El Puerto de los renegados","O Porto dos Renegados","도둑 항구에"] }
  Static LangString :=  { "English" : ": You have entered"  , "Spanish" : " : Has entrado a "   , "Chinese" : " : 你已進入："   , "Korean" : "진입했습니다"   , "German" : " : Ihr habt '"
              , "Russian" : " : Вы вошли в область "  , "French" : " : Vous êtes à présent dans : "   , "Portuguese" : " : Você entrou em: "  , "Thai" : " : คุณเข้าสู่ " }
  Static MineStrings := ["Azurite Mine"]
  If (cStr="Town")
    Return indexOfArr(CurrentLocation,ClientTowns)
  If (Lang = "")
  {
    For k, v in LangString
    {
      If InStr(cStr, v)
      {
        Lang := k
        If (VersionNumber > 0)
        Log("Client.txt language has been detected as: " Lang)
        Break
      }
    }
  }
  If (Lang = "English") ; This is the default setting
  {
    ; first we confirm if this line contains our zone change phrase
    If InStr(cStr, ": You have entered")
    {
      ; We split away the rest of the sentence for only location
      CurrentLocation := StrSplit(cStr, " : You have entered "," .`r`n" )[2]
      ; We should now have our location name and can begin comparing
      ; This compares the captured string to a list of town names
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      ; Now we check if it's a hideout, make sure to whitelist Syndicate
      If (InStr(CurrentLocation, "Hideout") && !InStr(CurrentLocation, "Syndicate"))
        OnHideout := True
      Else
        OnHideout := False
      ; Now we check if we match mines
      If indexOf(CurrentLocation,MineStrings)
        OnMines := True
      Else
        OnMines := False
      Return True
    } Else If (cStr ~= ": \w+ \(\w+\) is now level \d") {
      RegExMatch(cStr, "O)is now level (\d*)", RxMatch)
      Player.Level := RxMatch[1]
    }
  }
  Else If (Lang = "Spanish") 
  {
    If InStr(cStr, " : Has entrado a ")
    {
      CurrentLocation := StrSplit(cStr, " : Has entrado a "," .`r`n")[2]
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      If (InStr(CurrentLocation, "Guarida") && !InStr(CurrentLocation, "Sindicato"))
        OnHideout := True
      Else
        OnHideout := False
      If (CurrentLocation = "Mina de Azurita")
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Else If (Lang = "Chinese") 
  {
    If InStr(cStr, " : 你已進入：")
    {
      CurrentLocation := StrSplit(cStr, " : 你已進入："," .。`r`n")[2]
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      If (InStr(CurrentLocation, "藏身處") && !InStr(CurrentLocation, "永生密教"))
        OnHideout := True
      Else
        OnHideout := False
      If (CurrentLocation = "碧藍礦坑")
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Else If (Lang = "Korean") 
  {
    If InStr(cStr, "진입했습니다")
    {
      CurrentLocation := StrSplit(StrSplit(cStr,"] : ")[2], "진입했습니다"," .`r`n")[1]
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      If (InStr(CurrentLocation, "은신처에") && !InStr(CurrentLocation, "신디케이트"))
        OnHideout := True
      Else
        OnHideout := False
      If (CurrentLocation = "남동석 광산에")
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Else If (Lang = "German") 
  {
    If InStr(cStr, " : Ihr habt '")
    {
      CurrentLocation := StrSplit(StrSplit(cStr," : Ihr habt '")[2], "' betreten"," .`r`n")[1]
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      If (InStr(CurrentLocation, "Versteckter") && !InStr(CurrentLocation, "Syndikat"))
        OnHideout := True
      Else
        OnHideout := False
      If (CurrentLocation = "Azuritmine")
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Else If (Lang = "Russian") 
  {
    If InStr(cStr, " : Вы вошли в область ")
    {
      CurrentLocation := StrSplit(cStr," : Вы вошли в область "," .`r`n")[2]
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      If (InStr(CurrentLocation, "убежище") && !InStr(CurrentLocation, "синдикат"))
        OnHideout := True
      Else
        OnHideout := False
      If (CurrentLocation = "Азуритовая шахта")
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Else If (Lang = "French") 
  {
    If InStr(cStr, " : Vous êtes à présent dans : ")
    {
      CurrentLocation := StrSplit(cStr," : Vous êtes à présent dans : "," .`r`n")[2]
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      If (InStr(CurrentLocation, "Repaire") && !InStr(CurrentLocation, "Syndicat"))
        OnHideout := True
      Else
        OnHideout := False
      If (CurrentLocation = "La Mine d'Azurite")
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Else If (Lang = "Portuguese") 
  {
    If InStr(cStr, " : Você entrou em: ")
    {
      CurrentLocation := StrSplit(cStr," : Você entrou em: "," .`r`n")[2]
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      If (InStr(CurrentLocation, "Refúgio") && !InStr(CurrentLocation, "Sindicato"))
        OnHideout := True
      Else
        OnHideout := False
      If (CurrentLocation = "Mina de Azurita")
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Else If (Lang = "Thai") 
  {
    If InStr(cStr, " : คุณเข้าสู่ ")
    {
      CurrentLocation := StrSplit(cStr," : คุณเข้าสู่ "," .`r`n")[2]
      If indexOfArr(CurrentLocation,ClientTowns)
        OnTown := True
      Else
        OnTown := False
      If (InStr(CurrentLocation, "Hideout") && !InStr(CurrentLocation, "Syndicate"))
        OnHideout := True
      Else
        OnHideout := False
      If (CurrentLocation = "Azurite Mine")
        OnMines := True
      Else
        OnMines := False
      Return True
    }
  }
  Return False
}
; Monitor for changes in log since initialized
Monitor_GameLogs(Initialize:=0) 
{
  global ClientLog, CLogFO, CurrentLocation
  OldTown := OnTown, OldHideout := OnHideout, OldMines := OnMines, OldLocation := CurrentLocation
  if (Initialize)
  {
    Try
    {
      CLogFO := FileOpen(ClientLog, "r")
      FileGetSize, errchk, %ClientLog%, M
      If (errchk >= 64)
      {
        CurrentLocation := "Log too large"
        CLogFO.Seek(0, 2)
        If (VersionNumber != "")
        {
          Log("Client.txt Log File is too large (" . errchk . "MB)")
          Notify("Client.txt file is too large (" . errchk . "MB)`nDelete contents of the log file and reload`nYou Must change zones to update Location","",0,,110)
        }
        Return
      }
      T1 := A_TickCount
      If (VersionNumber != "")
        Ding(0,-10,"Parsing Client.txt Logfile")
      latestFileContent := CLogFo.Read()
      latestFileContent := TF_ReverseLines(latestFileContent)
      Loop, Parse,% latestFileContent,`n,`r
      {
        If InStr(A_LoopField, "] :")
          If CompareLocation(A_LoopField)
            Break
        If (A_Index > 1000)
        {
          CurrentLocation := "1k Line Break"
          Log("1k Line Break reached, ensure the file is encoded with UTF-8-BOM")
          Break
        }
      }
      If (CurrentLocation = "")
        CurrentLocation := "Nothing Found"
      If (VersionNumber != "")
        Ding(500,-10,"Parsed Client.txt logs in " . A_TickCount - T1 . "MS`nSize: " . errchk . "MB")
      StatusText := (OnTown?"OnTown":(OnHideout?"OnHideout":(OnMines?"OnMines":"Elsewhere")))
      SB_SetText("Status:" StatusText " `(" CurrentLocation "`)",2)
      If (DebugMessages && YesLocation && WinActive(GameStr))
      {
        Ding(6000,4,"Status:   `t" (OnTown?"OnTown":(OnHideout?"OnHideout":(OnMines?"OnMines":"Elsewhere"))))
        Ding(6000,5,CurrentLocation)
      }
      If (VersionNumber != "")
        Log("Log File initialized","OnTown " OnTown, "OnHideout " OnHideout, "OnMines " OnMines, "Located:" CurrentLocation)
    }
    Catch, loaderror
    {
      Ding(5000,-10,"Client.txt Critical Load Error`nSize: " . errchk . "MB")
      CurrentLocation := "Client File Load Error"
      Log("Error loading File, Submit information about your client.txt",loaderror)
    }
    Return
  } Else {
    latestFileContent := CLogFo.Read()

    if (latestFileContent) 
    {
      Loop, Parse,% latestFileContent,`n,`r 
      {
        If InStr(A_LoopField, "] :")
          CompareLocation(A_LoopField)
      }
    }
    If (DebugMessages && YesLocation && GameActive)
    {
      Ding(2000,4,"Status:   `t" (OnTown?"OnTown":(OnHideout?"OnHideout":(OnMines?"OnMines":"Elsewhere"))))
      Ding(2000,5,CurrentLocation)
    }
    If (CurrentLocation != OldLocation || OldTown != OnTown || OldMines != OnMines || OldHideout != OnHideout)
    {
      StatusText := (OnTown?"OnTown":(OnHideout?"OnHideout":(OnMines?"OnMines":"Elsewhere")))
      If YesLocation
        Log("Zone Change Detected", StatusText , "Located:" CurrentLocation)
      SB_SetText("Status:" StatusText " (" CurrentLocation ")",2)
    }
    Return
  }
}
; Tail Function for files
LastLine(SomeFileObject) {
  static SEEK_CUR := 1
  static SEEK_END := 2
  loop {
    SomeFileObject.Seek(-1, SEEK_CUR)
    
    if (SomeFileObject.Read(1) = "`n") {
      StartPosition := SomeFileObject.Tell()
      
      Line := SomeFileObject.ReadLine()
      SomeFileObject.Seek(StartPosition - 1)
      return Line
    }
    else {
      SomeFileObject.Seek(-1, SEEK_CUR)
    }
  } until (A_Index >= 1000000)
  Return ; this should never happen
}
