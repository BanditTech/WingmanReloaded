SendHotkey(keyStr:="",hold:=0){
  For i, keys in StrSplit(keyStr," "){
    If RegExMatch(keys, "O)\[(\d+)\]\(([\d\w]+)\)", DelayKey)
    {
      DelayAction.Push({"TriggerAt":A_TickCount+DelayKey[1],"Key":DelayKey[2]})
      Continue
    }
    Obj := SplitModsFromKey(keys)
    If (GameActive := WinActive(GameStr))
      Send, % Obj.Mods "{" Obj.Key ( hold ? " " hold : "" ) "}"
    Else
      controlsend, , % Obj.Mods "{" Obj.Key ( hold ? " " hold : "" ) "}", %GameStr%
  }
}
SendDelayAction(){
  For k, keys in DelayAction
  {
    If (keys.TriggerAt <= A_TickCount)
    {
      SendHotkey(keys.Key)
      DelayAction.Delete(k)
    }
  }
}
IsModifier(Character) {
  static Modifiers := {"!": 1, "#": 1, "~": 1, "^": 1, "*": 1, "+": 1}
  return Modifiers.HasKey(Character)
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
  Return {"Mods":Mods, "Key":String }
}
