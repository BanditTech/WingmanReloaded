; Make a MsgBox Printout of an array
; HotIf context predicate used for every POE-gated hotkey registration.
; Must be the SAME function object across Off / On calls or v2 treats
; the contexts as distinct.
GameWindowActive(*) {
  return WinActive("ahk_group POEGameGroup")
}
MsgBoxVals(obj,indent:=0){
  txt := ""
  Loop indent
    spacing .= " "
  If IsObject(obj)
  {
    For k, v in obj
    {
      txt .= (k==1&&!indent?"":"`n") spacing
      txt .= "Key:`t" k "`t"
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
    MsgBox(txt)
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
  if !IsObject(Arr)
    return False
  for index, value in Arr {
    if (index < fromIndex){
      Continue
    }else if (value == var){
      return index
    }
  }
}
; Check if a specific value is part of an array's array and return the parent index
indexOfArr(var, Arr, fromIndex:=1){
  if !IsObject(Arr)
    return False
  pos := 0
  for index, a in Arr
  {
    pos++
    if (pos < fromIndex)
      Continue
    for k, value in a
      if (value == var)
        return index
  }
  Return False
}
; find a value in object - redundant function
HasVal(haystack, needle){
  for index, value in haystack
  {
    if (value == needle)
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
; Function to Replace Nth instance of Needle (regex) in Haystack
; Instance=0: replace all; negative Instance counts from the end
StringReplaceN( Haystack, Needle, Replacement:="", Instance:=1 ){
  If !( Instance := 0 | Instance )
    Return StrReplace(Haystack, Needle, Replacement)
  ; Collect all match positions
  Positions := [], pos := 1, _m := ""
  While RegExMatch(Haystack, Needle, &_m, pos) {
    Positions.Push({Pos: _m.Pos, Len: _m.Len})
    pos := _m.Pos + Max(_m.Len, 1)
  }
  ; Resolve negative index (from end)
  idx := (Instance < 0) ? Positions.Length + Instance + 1 : Instance
  If (idx < 1 || idx > Positions.Length)
    Return Haystack
  m := Positions[idx]
  Return SubStr(Haystack, 1, m.Pos - 1) Replacement SubStr(Haystack, m.Pos + m.Len)
}
; Clamp Value function
Clamp( Val, Min, Max){
  If Val < Min
    Val := Min
  If Val > Max
    Val := Max
  Return
}
; GameWindow / Speed / Latency are normally populated by the main
; script (Rescale.ahk + GLOBALS.ahk). Initialize them at script scope
; so any analyser or embedded-include context (e.g. data/LootFilter.ahk
; pulling Helpers in standalone) sees defined values.
Global GameWindow := {X:0, Y:0, W:0, H:0, BBarY:0}
Global Speed := 1
Global Latency := 1
; ClampGameScreen - Ensure points do not go outside Game Window
ClampGameScreen(&ValX, &ValY){
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
    r := Random(min, max)
    r:=floor(r/Speed)
    Sleep(r*Latency)
  return
}
; GetProcessTimes - Show CPU usage as precentage
GetProcessTimes(PID){
  static aPIDs := Map()
  ; If called too frequently, will get mostly 0%, so it's better to just return the previous usage
  if aPIDs.Has(PID) && A_TickCount - aPIDs[PID]["tickPrior"] < 250
    return aPIDs[PID]["usagePrior"]

  lpIdleTimeSystem := 0, lpKernelTimeSystem := 0, lpUserTimeSystem := 0
  DllCall("GetSystemTimes", "Int64*", &lpIdleTimeSystem, "Int64*", &lpKernelTimeSystem, "Int64*", &lpUserTimeSystem)
  if !hProc := DllCall("OpenProcess", "UInt", 0x1000, "Int", 0, "Ptr", pid) {
    if aPIDs.Has(PID)
      aPIDs.Delete(PID) ; Process doesn't exist anymore or don't have access to it.
    return -2
  }
  lpCreationTime := 0, lpExitTime := 0, lpKernelTimeProcess := 0, lpUserTimeProcess := 0
  DllCall("GetProcessTimes", "Ptr", hProc, "Int64*", &lpCreationTime, "Int64*", &lpExitTime, "Int64*", &lpKernelTimeProcess, "Int64*", &lpUserTimeProcess)
  DllCall("CloseHandle", "Ptr", hProc)

  if aPIDs.Has(PID) ; check if previously run
  {
    ; find the total system run time delta between the two calls
    systemKernelDelta := lpKernelTimeSystem - aPIDs[PID]["lpKernelTimeSystem"] ;lpKernelTimeSystemOld
    systemUserDelta := lpUserTimeSystem - aPIDs[PID]["lpUserTimeSystem"] ; lpUserTimeSystemOld
    ; get the total process run time delta between the two calls
    procKernalDelta := lpKernelTimeProcess - aPIDs[PID]["lpKernelTimeProcess"] ; lpKernelTimeProcessOld
    procUserDelta := lpUserTimeProcess - aPIDs[PID]["lpUserTimeProcess"] ;lpUserTimeProcessOld
    ; sum the kernal + user time
    totalSystem :=  systemKernelDelta + systemUserDelta
    totalProcess := procKernalDelta + procUserDelta
    ; The result is simply the process delta run time as a percent of system delta run time
    result := 100 * totalProcess / totalSystem
  }
  else result := -1

  if !aPIDs.Has(PID)
    aPIDs[PID] := Map()
  aPIDs[PID]["lpKernelTimeSystem"] := lpKernelTimeSystem
  aPIDs[PID]["lpUserTimeSystem"] := lpUserTimeSystem
  aPIDs[PID]["lpKernelTimeProcess"] := lpKernelTimeProcess
  aPIDs[PID]["lpUserTimeProcess"] := lpUserTimeProcess
  aPIDs[PID]["tickPrior"] := A_TickCount
  aPIDs[PID]["usagePrior"] := result
  return result
}
; check time
CheckTime(Type:="hours",Interval:=2,key:="temp",Time:=""){
  Static Keys := Map()
  ; v2 DateDiff accepts only Seconds/Minutes/Hours/Days. Reject anything else
  ; (callers may pass "Off" etc. to mean "disabled") so we don't throw.
  If !(Type ~= "i)^(s(econds)?|m(inutes)?|h(ours)?|d(ays)?)$")
    Return False
  ; Available time types are: hours, minutes, seconds, days
  If (!Keys.Has(key) || Time != "")
  {
    Keys[key] := (Time == "" ? A_Now : Time)
  }
  TimeVal := Keys[key]
  TimeVal := DateDiff(A_Now, TimeVal, Type)
  TimeVal := -TimeVal
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
; ObjCount - Count own properties on a plain Object. Replaces v1's catch-all
; .Count() method on Objects/Maps. Use Array.Length for Arrays and Map.Count
; (no parens) for Maps — this helper is only for plain Objects used as maps.
ObjCount(obj){
  n := 0
  For _, _ in obj.OwnProps()
    n++
  Return n
}
; MapToObj - Recursively convert a Map (and nested Maps/Arrays) into a plain
; Object so dot-access works. JSON.LoadFile returns Maps for JSON objects in
; cJson v2, but the codebase uses dot-access on shapes like Globe.Life.X1.
MapToObj(input){
  If (input is Map) {
    obj := {}
    For k, v in input
      obj.%k% := MapToObj(v)
    Return obj
  }
  If (input is Array) {
    arr := []
    For v in input
      arr.Push(MapToObj(v))
    Return arr
  }
  Return input
}
; SemverCompare - Compare two dotted version strings numerically component-by-component.
; Returns -1 if a < b, 0 if equal, 1 if a > b. Missing trailing components are treated
; as 0 ("3.0" == "3.0.0").
SemverCompare(a, b){
  pa := StrSplit(a, "."), pb := StrSplit(b, ".")
  n := Max(pa.Length, pb.Length)
  Loop n {
    va := (A_Index <= pa.Length && pa[A_Index] != "") ? Integer(pa[A_Index]) : 0
    vb := (A_Index <= pb.Length && pb[A_Index] != "") ? Integer(pb[A_Index]) : 0
    If (va < vb)
      Return -1
    If (va > vb)
      Return 1
  }
  Return 0
}
; UriEncode - Percent-encode a string per RFC 3986 (unreserved chars left intact)
UriEncode(str){
  static safe := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
  out := ""
  size := StrPut(str, "UTF-8")
  buf := Buffer(size)
  StrPut(str, buf, "UTF-8")
  Loop size - 1 {
    b := NumGet(buf, A_Index - 1, "UChar")
    c := Chr(b)
    out .= InStr(safe, c, true) ? c : Format("%{:02X}", b)
  }
  Return out
}
; Create a text from an error object
ErrorText(e){
  msg := ""
  For k, type in ["what","file","line","message","extra"] {
    value := e.%type%
    msg .= (msg ? "`n" : "") type " : " value
  }
  return msg
}
