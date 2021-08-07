; Take input values which are compared to current resources
CompareToResource(SlotES,SlotLife,SlotMana,AllFlag:=False){
  Matched := True
  For k, Name in ["ES","Life","Mana"] {
    If (Slot%Name% && Slot%Name% > Player.Percent[Name] ) {
      If !AllFlag
        Return True
    } Else
      Matched := False
  }
  Return Matched
}
