; Make a MsgBox Printout of an array
MsgBoxVals(obj,indent:=0){
  txt := ""
  Loop % indent
    spacing .= " "
  If IsObject(obj)
  {
    For k, v in obj
    {
      txt .= (k==1&&!indent?"":"`n") spacing
      txt .= "Key:`t"k "`t"
          . "Val:`t" (IsObject(v)?"OBJECT":v)
      If IsObject(v)
      txt .= MsgBoxVals(v,indent+1)
    }
  } Else {
    txt := obj
  }
  If indent
    Return txt
  Else
    MsgBox % txt
}
; ArrayToString - Make a string from array using specified delimiter
ArrayToString(Array,delim:="|"){
  text := ""
  for index, element in Array
    text .= (!text?"":delim) element
  return text
}
; StringToArray - Make a array from a string using specified delimiter
StringToArray(text,delim:="|"){
  return StrSplit(text,delim)
}
; Check if a specific value is part of an array and return the index
indexOf(var, Arr, fromIndex:=1){
  for index, value in Arr {
    if (index < fromIndex){
      Continue
    }else if (value = var){
      return index
    }
  }
}
; Check if a specific value is part of an array's array and return the parent index
indexOfArr(var, Arr, fromIndex:=1){
  for index, a in Arr 
  {
    if (index < fromIndex)
      Continue
    for k, value in a
      if (value = var)
        return index
  }
  Return False
}
; find a value in object - redundant function
HasVal(haystack, needle){
  for index, value in haystack
  {
    if (value = needle)
      return true
  }
  return false
}
; Transform an array to a comma separated string
arrToStr(array){
  Str := ""
  For Index, Value In array
    Str .= "," . Value
  Str := LTrim(Str, ",")
  return Str
}
; Transform an array to a comma separated string
hexArrToStr(array){
  Str := ""
  For Index, Value In array
    {
    value := Format("0x{1:06X}", value)
    Str .= "," . Value
    }
  Str := LTrim(Str, ",")
  return Str
}
; Function to Replace Nth instance of Needle in Haystack
StringReplaceN( Haystack, Needle, Replacement="", Instance=1 ){ 
  If !( Instance := 0 | Instance )
  {
    StringReplace, Haystack, Haystack, %Needle%, %Replacement%, A
    Return Haystack
  }
  Else Instance := "L" Instance
  StringReplace, Instance, Instance, L-, R
  StringGetPos, Instance, Haystack, %Needle%, %Instance%
  If ( ErrorLevel )
    Return Haystack
  StringTrimLeft, Needle, HayStack, Instance+ StrLen( Needle )
  StringLeft, HayStack, HayStack, Instance
  Return HayStack Replacement Needle
} 
; Clamp Value function
Clamp( Val, Min, Max){
  If Val < Min
    Val := Min
  If Val > Max
    Val := Max
  Return
}
; ClampGameScreen - Ensure points do not go outside Game Window
ClampGameScreen(ByRef ValX, ByRef ValY){
  Global GameWindow
  If (ValY < GameWindow.BBarY)
    ValY := GameWindow.BBarY
  If (ValX < GameWindow.X)
    ValX := GameWindow.X
  If (ValY > GameWindow.Y + GameWindow.H)
    ValT := GameWindow.Y + GameWindow.H
  If (ValX > GameWindow.X + GameWindow.W)
    ValX := GameWindow.X + GameWindow.W
  Return
}
; Provides a call for simpler random sleep timers
RandomSleep(min,max){
    Random, r, min, max
    r:=floor(r/Speed)
    Sleep, r*Latency
  return
}
; GetProcessTimes - Show CPU usage as precentage
GetProcessTimes(PID){
  static aPIDs := []
  ; If called too frequently, will get mostly 0%, so it's better to just return the previous usage 
  if aPIDs.HasKey(PID) && A_TickCount - aPIDs[PID, "tickPrior"] < 250
    return aPIDs[PID, "usagePrior"] 

  DllCall("GetSystemTimes", "Int64*", lpIdleTimeSystem, "Int64*", lpKernelTimeSystem, "Int64*", lpUserTimeSystem)
  if !hProc := DllCall("OpenProcess", "UInt", 0x1000, "Int", 0, "Ptr", pid)
    return -2, aPIDs.HasKey(PID) ? aPIDs.Remove(PID, "") : "" ; Process doesn't exist anymore or don't have access to it.
  DllCall("GetProcessTimes", "Ptr", hProc, "Int64*", lpCreationTime, "Int64*", lpExitTime, "Int64*", lpKernelTimeProcess, "Int64*", lpUserTimeProcess)
  DllCall("CloseHandle", "Ptr", hProc)
  
  if aPIDs.HasKey(PID) ; check if previously run
  {
    ; find the total system run time delta between the two calls
    systemKernelDelta := lpKernelTimeSystem - aPIDs[PID, "lpKernelTimeSystem"] ;lpKernelTimeSystemOld
    systemUserDelta := lpUserTimeSystem - aPIDs[PID, "lpUserTimeSystem"] ; lpUserTimeSystemOld
    ; get the total process run time delta between the two calls 
    procKernalDelta := lpKernelTimeProcess - aPIDs[PID, "lpKernelTimeProcess"] ; lpKernelTimeProcessOld
    procUserDelta := lpUserTimeProcess - aPIDs[PID, "lpUserTimeProcess"] ;lpUserTimeProcessOld
    ; sum the kernal + user time
    totalSystem :=  systemKernelDelta + systemUserDelta
    totalProcess := procKernalDelta + procUserDelta
    ; The result is simply the process delta run time as a percent of system delta run time
    result := 100 * totalProcess / totalSystem
  }
  else result := -1

  aPIDs[PID, "lpKernelTimeSystem"] := lpKernelTimeSystem
  aPIDs[PID, "lpUserTimeSystem"] := lpUserTimeSystem
  aPIDs[PID, "lpKernelTimeProcess"] := lpKernelTimeProcess
  aPIDs[PID, "lpUserTimeProcess"] := lpUserTimeProcess
  aPIDs[PID, "tickPrior"] := A_TickCount
  return aPIDs[PID, "usagePrior"] := result 
}
; check time
CheckTime(Type:="hours",Interval:=2,key:="temp",Time:=""){
  Static Keys := {}
  ; Available time types are: years, months, days, hours, minutes, seconds
  If (!Keys[key] || Time != "")
  {
    Keys[key] := (Time = "" ? A_Now : Time)
  }
  TimeVal := Keys[key]
  EnvSub, TimeVal, %A_now%, %Type%
  If (TimeVal <= 0)
  {
    TimeVal := Abs(TimeVal)
    If (TimeVal >= Interval)
    {
      Keys[key] := A_Now
      Return TimeVal
    }
    Else
      Return False
  }
  Else
    Return False
}
; return the greatest of all values
max(Max, n*){
  For each, Value in n
    If (Value > Max)
      Max := Value
  Return Max
}
; Create a text from an error object
ErrorText(e){
  msg := ""
  For k, type in ["what","file","line","message","extra"] {
    value := e[type]
    msg .= (msg ? "`n" : "") type " : " e[type]
  }
  return msg
}
