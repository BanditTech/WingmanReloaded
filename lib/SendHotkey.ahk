SendHotkey(keyStr:="",hold:=0){
  For i, keys in StrSplit(keyStr," "){
    If RegExMatch(keys, "\[(\d+)\]\(([\d\w]+)\)", &DelayKey)
    {
      DelayAction.Push({TriggerAt:A_TickCount+DelayKey[1], Key:DelayKey[2]})
      Continue
    }
    Obj := SplitModsFromKey(keys)
    If (GameActive := WinActive(GameStr))
      Send(Obj.Mods "{" Obj.Key ( hold ? " " hold : "" ) "}")
    Else
      ControlSend(Obj.Mods "{" Obj.Key ( hold ? " " hold : "" ) "}", , GameStr)
  }
}
SendDelayAction(){
  k := 1
  While (k <= DelayAction.Length)
  {
    keys := DelayAction[k]
    If (keys.TriggerAt <= A_TickCount)
    {
      SendHotkey(keys.Key)
      DelayAction.RemoveAt(k)
      ; do not advance k - the next item shifted into this slot
    }
    Else
      k++
  }
}
IsModifier(Character) {
  static Modifiers := Map("!",1,"#",1,"~",1,"^",1,"*",1,"+",1)
  return Modifiers.Has(Character)
}
SplitModsFromKey(key){
  Mods := String := ""
  for k, Letter in StrSplit(key) {
    if (IsModifier(Letter)) {
      Mods .= Letter
    }
    else {
      String .= Letter
    }
  }
  Return {Mods:Mods, Key:String}
}
