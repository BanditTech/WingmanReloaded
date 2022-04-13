; ScrapeNinjaData - Parse raw data from PoE-Ninja API and standardize Chaos Value || Chaos Equivalent
ScrapeNinjaData(apiString)
{
  If(RegExMatch(selectedLeague, "SSF",RxMatch))
  {
    selectedLeagueSC := RegExReplace(selectedLeague, "SSF ", "")
  }
  Else
  {
    selectedLeagueSC :=selectedLeague
  }

  If InStr(apiString, "Fragment")
  {
    UrlDownloadToFile, https://poe.ninja/api/Data/CurrencyOverview?type=%apiString%&league=%selectedLeagueSC%, %A_ScriptDir%\temp\data_%apiString%.txt
    If ErrorLevel{
      MsgBox, Error : There was a problem downloading data_%apiString%.txt `r`nLikely because of %selectedLeagueSC% not being valid or an API change
    }
    Else If (ErrorLevel=0){
      FileRead, JSONtext, %A_ScriptDir%\temp\data_%apiString%.txt
      Try {
        holder := JSON.Load(JSONtext)
      } Catch e {
        Log("Error","Something has gone wrong downloading " apiString " Ninja API data",e)
        RetryDL := True
      }
      If RetryDL
      {
        Sleep, 1000
        UrlDownloadToFile, https://poe.ninja/api/Data/CurrencyOverview?type=%apiString%&league=%selectedLeagueSC%, %A_ScriptDir%\temp\data_%apiString%.txt
        FileRead, JSONtext, %A_ScriptDir%\temp\data_%apiString%.txt
        Try {
          holder := JSON.Load(JSONtext)
        } Catch e {
          Log("Error","Something has gone all wrong downloading " apiString ,e)
          Return
        }
      }
      for index, indexArr in holder.lines
      { ; This will extract the information and standardize the chaos value to one variable.
        grabName := (indexArr["currencyTypeName"] ? indexArr["currencyTypeName"] : False)
        grabChaosVal := (indexArr["chaosEquivalent"] ? indexArr["chaosEquivalent"] : False)
        grabPayVal := (indexArr["pay"] ? indexArr["pay"] : False)
        grabRecVal := (indexArr["receive"] ? indexArr["receive"] : False)
        grabPaySparklineVal := (indexArr["paySparkLine"] ? indexArr["paySparkLine"] : False)
        grabRecSparklineVal := (indexArr["receiveSparkLine"] ? indexArr["receiveSparkLine"] : False)
        holder.lines[index] := {"name":grabName
          ,"chaosValue":grabChaosVal
          ,"pay":grabPayVal
          ,"receive":grabRecVal
          ,"paySparkLine":grabPaySparklineVal
          ,"receiveSparkLine":grabRecSparklineVal}
      }
      Ninja[apiString] := holder.lines
      FileDelete, %A_ScriptDir%\temp\data_%apiString%.txt
    }
    Return
  }
  Else If InStr(apiString, "Currency")
  {
    UrlDownloadToFile, https://poe.ninja/api/Data/CurrencyOverview?Type=%apiString%&league=%selectedLeagueSC%, %A_ScriptDir%\temp\data_%apiString%.txt
    if ErrorLevel{
      MsgBox, Error : There was a problem downloading data_%apiString%.txt `r`nLikely because of %selectedLeagueSC% not being valid
    }
    Else if (ErrorLevel=0){
      FileRead, JSONtext, %A_ScriptDir%\temp\data_%apiString%.txt
      Try {
        holder := JSON.Load(JSONtext)
      } Catch e {
        Log("Error","Something has gone wrong downloading " apiString " Ninja API data",e)
        RetryDL := True
      }
      If RetryDL
      {
        Sleep, 1000
        UrlDownloadToFile, https://poe.ninja/api/Data/CurrencyOverview?Type=%apiString%&league=%selectedLeagueSC%, %A_ScriptDir%\temp\data_%apiString%.txt
        FileRead, JSONtext, %A_ScriptDir%\temp\data_%apiString%.txt
        Try {
          holder := JSON.Load(JSONtext)
        } Catch e {
          Log("Error","Something has gone all wrong downloading " apiString ,e)
          Return
        }
      }
      for index, indexArr in holder.lines
      {
        grabName := (indexArr["currencyTypeName"] ? indexArr["currencyTypeName"] : False)
        grabChaosVal := (indexArr["chaosEquivalent"] ? indexArr["chaosEquivalent"] : False)
        grabPayVal := (indexArr["pay"] ? indexArr["pay"] : False)
        grabRecVal := (indexArr["receive"] ? indexArr["receive"] : False)
        grabPaySparklineVal := (indexArr["paySparkLine"] ? indexArr["paySparkLine"] : False)
        grabRecSparklineVal := (indexArr["receiveSparkLine"] ? indexArr["receiveSparkLine"] : False)
        holder.lines[index] := {"name":grabName
          ,"chaosValue":grabChaosVal
          ,"pay":grabPayVal
          ,"receive":grabRecVal
          ,"paySparkLine":grabPaySparklineVal
          ,"receiveSparkLine":grabRecSparklineVal}
      }
      Ninja[apiString] := holder.lines
      for index, indexArr in holder.currencyDetails
      {
        grabName := (indexArr["name"] ? indexArr["name"] : False)
        grabPoeTrdId := (indexArr["poeTradeId"] ? indexArr["poeTradeId"] : False)
        grabId := (indexArr["id"] ? indexArr["id"] : False)
        grabTradeId := (indexArr["tradeId"] ? indexArr["tradeId"] : False)
        holder.currencyDetails[index] := {"currencyName":grabName
          ,"poeTradeId":grabPoeTrdId
          ,"id":grabId
          ,"tradeId":grabTradeId}
      }
      Ninja["currencyDetails"] := holder.currencyDetails
      FileDelete, %A_ScriptDir%\temp\data_%apiString%.txt
    }
    Return
  }
  Else
  {
    UrlDownloadToFile, https://poe.ninja/api/Data/ItemOverview?Type=%apiString%&league=%selectedLeagueSC%, %A_ScriptDir%\temp\data_%apiString%.txt
    if ErrorLevel{
      MsgBox, Error : There was a problem downloading data_%apiString%.txt `r`nLikely because of %selectedLeagueSC% not being valid
    }
    Else if (ErrorLevel=0){
      RetryDL := False
      FileRead, JSONtext, %A_ScriptDir%\temp\data_%apiString%.txt
      Try {
        holder := JSON.Load(JSONtext)
      } Catch e {
        Log("Something has gone wrong downloading " apiString " Ninja API data",e)
        RetryDL := True
      }
      If RetryDL
      {
        Sleep, 1000
        UrlDownloadToFile, https://poe.ninja/api/Data/ItemOverview?Type=%apiString%&league=%selectedLeagueSC%, %A_ScriptDir%\temp\data_%apiString%.txt
        FileRead, JSONtext, %A_ScriptDir%\temp\data_%apiString%.txt
        Try {
          holder := JSON.Load(JSONtext)
        } Catch e {
          Log("Error","Error","Something has gone all wrong downloading " apiString ,e)
          Return
        }
      }
      for index, indexArr in holder.lines
      {
        grabSparklineVal := (indexArr["sparkline"] ? indexArr["sparkline"] : False)
        grabExaltVal := (indexArr["exaltedValue"] ? indexArr["exaltedValue"] : False)
        grabChaosVal := (indexArr["chaosValue"] ? indexArr["chaosValue"] : False)
        grabName := (indexArr["name"] ? indexArr["name"] : False)
        grabLinks := (indexArr["links"] ? indexArr["links"] : False)
        grabVariant := (indexArr["variant"] ? indexArr["variant"] : False)
        grabMapTier := (indexArr["mapTier"] ? indexArr["mapTier"] : False)
        grabLevelRequired := (indexArr["levelRequired"] ? indexArr["levelRequired"] : False)
        grabGemLevel := (indexArr["gemLevel"] ? indexArr["gemLevel"] : False)
        grabGemQuality := (indexArr["gemQuality"] ? indexArr["gemQuality"] : False)
        grabBaseType := (indexArr["baseType"] ? indexArr["baseType"] : False)
        
        holder.lines[index] := {"name":grabName
          ,"chaosValue":grabChaosVal
          ,"sparkline":grabSparklineVal}

        If grabExaltVal
          holder.lines[index]["exaltedValue"] := grabExaltVal
        If grabVariant
          holder.lines[index]["variant"] := grabVariant
        If grabLinks
          holder.lines[index]["links"] := grabLinks
        If grabMapTier
          holder.lines[index]["mapTier"] := grabMapTier
        If grabLevelRequired
          holder.lines[index]["levelRequired"] := grabLevelRequired
        If grabGemLevel
          holder.lines[index]["gemLevel"] := grabGemLevel
        If grabGemQuality
          holder.lines[index]["gemQuality"] := grabGemQuality
        If (grabBaseType && apiString = "UniqueMap")
          holder.lines[index]["baseType"] := grabBaseType
      }
      Ninja[apiString] := holder.lines
    }
    FileDelete, %A_ScriptDir%\temp\data_%apiString%.txt
  }
    ;MsgBox % "Download worked for Ninja Database  -  There are " Ninja.Count() " Entries in the array
  Return
}

; DBUpdateCheck - Check if the database should be updated 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DBUpdateCheck()
{
	Global LastDatabaseParseDate
  IfWinExist, ahk_group POEGameGroup 
  {
    Return
  } 
  Else If (YesNinjaDatabase && DaysSince())
  {
    DBUpdate()
  }
	Return
}

DBUpdate(){
  FormatTime, Date_now, A_Now, yyyyMMdd
  Try {
			For k, apiKey in apiList
				ScrapeNinjaData(apiKey)
			JSONtext := JSON.Dump(Ninja,,2)
			FileDelete, %A_ScriptDir%\data\Ninja.json
			FileAppend, %JSONtext%, %A_ScriptDir%\data\Ninja.json
			IniWrite, %Date_now%, %A_ScriptDir%\save\Settings.ini, Database, LastDatabaseParseDate
			LastDatabaseParseDate := Date_now
  } catch e {
		Log("Error","DBUpdate Error: " ErrorText(e))
	}
}

DBUpdateNinja(){
  ;Update ninja Database
  FormatTime, Date_now, A_Now, yyyyMMdd
  l := apiList.MaxIndex()
  Load_BarControl(0,"Initializing",1)
  For k, apiKey in apiList
  {
    Load_BarControl(k/l*90,"Downloading " k " of " l " (" apiKey ")")
    Sleep, -1
    ScrapeNinjaData(apiKey)
  }
  sleep, -1
  Load_BarControl(92,"Saving Ninja JSON")
  sleep, -1
  JSONtext := JSON.Dump(Ninja,,2)
  FileDelete, %A_ScriptDir%\data\Ninja.json
  FileAppend, %JSONtext%, %A_ScriptDir%\data\Ninja.json
  sleep, -1
  Load_BarControl(95,"Downloading Perfect Prices")
  sleep, -1
  RefreshPoeWatchPerfect()
  IniWrite, %Date_now%, %A_ScriptDir%\save\Settings.ini, Database, LastDatabaseParseDate
  LastDatabaseParseDate := Date_now
  sleep, -1
  Load_BarControl(100,"Database Updated",-1)
}