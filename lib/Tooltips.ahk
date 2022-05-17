; Debug messages within script
Ding(Timeout:=500, MultiTooltip:=0 , Message*)
{
  If (!DebugMessages && MultiTooltip >= 0)
    Return
  Else
  {
    If MultiTooltip < 0
      MultiTooltip := Abs(MultiTooltip)
    debugStr := ""
    If Message.Count()
    {
      For mkey, mval in Message
      {
        If mval=
          Continue
        If A_Index = 1
        {
          If MultiTooltip
            ToolTip, %mval%, 20, % 40 + MultiTooltip* 23, %MultiTooltip% 
          Else
            debugStr .= Message.A_Index
        }
        Else if A_Index <= 20
        {
          If MultiTooltip
            ToolTip, %mval%, 20, % 40 + A_Index* 23, %A_Index% 
          Else
            debugStr .= "`n" . Message.A_Index
        }
      }
      If !MultiTooltip
        Tooltip, %debugStr%
    }
    Else
    {
      If MultiTooltip
        ToolTip, Ding, 20, % 40 + MultiTooltip* 23, %MultiTooltip% 
      Else
        Tooltip, Ding
    }
  }
  If Timeout
  {
    If MultiTooltip
      SetTimer, RemoveTT%MultiTooltip%, %Timeout%
    Else
      SetTimer, RemoveToolTip, %Timeout%
  }
  Return
}
; tooltip management
RemoveToolTip()
{
  SetTimer, , Off
  Loop, 20
  {
    SetTimer, RemoveTT%A_Index%, Off
    ToolTip,,,,%A_Index%
  }
  PauseTooltips := 0
  return

  RemoveTT1:
    SetTimer, , Off
    ToolTip,,,,1
  Return

  RemoveTT2:
    SetTimer, , Off
    ToolTip,,,,2
  Return

  RemoveTT3:
    SetTimer, , Off
    ToolTip,,,,3
  Return

  RemoveTT4:
    SetTimer, , Off
    ToolTip,,,,4
  Return

  RemoveTT5:
    SetTimer, , Off
    ToolTip,,,,5
  Return

  RemoveTT6:
    SetTimer, , Off
    ToolTip,,,,6
  Return

  RemoveTT7:
    SetTimer, , Off
    ToolTip,,,,7
  Return

  RemoveTT8:
    SetTimer, , Off
    ToolTip,,,,8
  Return

  RemoveTT9:
    SetTimer, , Off
    ToolTip,,,,9
  Return

  RemoveTT10:
    SetTimer, , Off
    ToolTip,,,,10
  Return

  RemoveTT11:
    SetTimer, , Off
    ToolTip,,,,11
  Return

  RemoveTT12:
    SetTimer, , Off
    ToolTip,,,,12
  Return

  RemoveTT13:
    SetTimer, , Off
    ToolTip,,,,13
  Return

  RemoveTT14:
    SetTimer, , Off
    ToolTip,,,,14
  Return

  RemoveTT15:
    SetTimer, , Off
    ToolTip,,,,15
  Return

  RemoveTT16:
    SetTimer, , Off
    ToolTip,,,,16
  Return

  RemoveTT17:
    SetTimer, , Off
    ToolTip,,,,17
  Return

  RemoveTT18:
    SetTimer, , Off
    ToolTip,,,,18
  Return

  RemoveTT19:
    SetTimer, , Off
    ToolTip,,,,19
  Return

  RemoveTT20:
    SetTimer, , Off
    ToolTip,,,,20
  Return
}
ShowToolTip()
{
  global ft_ToolTip_Text
  If (PauseTooltips || GameActive)
    Return
  ListLines, Off
  static CurrControl, PrevControl, _TT
  CurrControl := A_GuiControl
  if (CurrControl != PrevControl) {
    PrevControl := CurrControl
    ToolTip
    if (CurrControl != "")
      SetTimer, ft_DisplayToolTip, -500
  }
  return

  ft_DisplayToolTip:
    If PauseTooltips
      Return
    ListLines, Off
    MouseGetPos,,, _TT
    WinGetClass, _TT, ahk_id %_TT%
    if (_TT = "AutoHotkeyGUI") {
      stripCtrl := StrReplace(CurrControl,"ft_")
      stripCtrl := RegExReplace(stripCtrl,"^Utility\d*","")
      stripCtrl := RegExReplace(stripCtrl,"^Flask\d*","")
      ToolTip, % RegExMatch(ft_ToolTip_Text, "m`n)^" stripCtrl "\K\s*=.*", _TT)
        ? StrReplace(Trim(_TT,"`t ="),"\n","`n") : ""
      SetTimer, ft_RemoveToolTip, -10000
    }
  return

  ft_RemoveToolTip:
    ToolTip
  return
}
