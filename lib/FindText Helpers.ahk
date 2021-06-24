String2ASCII(String:="",One:="#",Zero:="."){
  local
  s := StrSplit(String, ".")
  w := StrSplit(s.1, "$").2
  s := StrSplit(StrReplace(StrReplace(FindText.base64tobit(s.2),"1",One),"0",Zero))
  v := ""
  For k, c in s
  {
    v .= c
    If !Mod(k,w)
      v .= "`n"
  }
  Return v
}

