; Debug messages within script
Ding(Timeout:=500, MultiTooltip:=0, Message*)
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
        If (mval = "")
          Continue
        If (A_Index = 1)
        {
          If MultiTooltip
            ToolTip(mval, 20, 40 + MultiTooltip * 23, MultiTooltip)
          Else
            debugStr .= Message.A_Index
        }
        Else if A_Index <= 20
        {
          If MultiTooltip
            ToolTip(mval, 20, 40 + A_Index * 23, A_Index)
          Else
            debugStr .= "`n" . Message.A_Index
        }
      }
      If !MultiTooltip
        ToolTip(debugStr)
    }
    Else
    {
      If MultiTooltip
        ToolTip("Ding", 20, 40 + MultiTooltip * 23, MultiTooltip)
      Else
        ToolTip("Ding")
    }
  }
  If Timeout
  {
    If MultiTooltip
    {
      static removers := Map()
      if !removers.Has(MultiTooltip) {
        n := MultiTooltip
        removers[MultiTooltip] := ClearTooltipSlot.Bind(n)
      }
      SetTimer(removers[MultiTooltip], -Timeout)
    }
    Else
      SetTimer(RemoveToolTip, -Timeout)
  }
}

ClearTooltipSlot(n) {
  ToolTip(,,, n)
}

; tooltip management
RemoveToolTip()
{
  Loop 20
    ToolTip(,,, A_Index)
  ToolTip()
  PauseTooltips := 0
}

ShowToolTip(wParam, lParam, msg, hwnd)
{
  global ft_ToolTip_Text
  If (PauseTooltips || GameActive)
    Return
  ListLines(0)
  static CurrControl := "", PrevControl := "", _TT := ""
  local ctrl := GuiCtrlFromHwnd(hwnd)
  CurrControl := ctrl ? ctrl.Name : ""
  if (CurrControl != PrevControl) {
    PrevControl := CurrControl
    ToolTip()
    if (CurrControl != "")
      SetTimer(ft_DisplayToolTip, -500)
  }

  ft_DisplayToolTip() {
    If PauseTooltips
      Return
    ListLines(0)
    MouseGetPos(,, &_TT)
    _TT := WinGetClass("ahk_id " _TT)
    if (_TT = "AutoHotkeyGUI") {
      stripCtrl := StrReplace(CurrControl, "ft_")
      stripCtrl := RegExReplace(stripCtrl, "^Utility\d*", "")
      stripCtrl := RegExReplace(stripCtrl, "^Flask\d*", "")
      ToolTip(RegExMatch(ft_ToolTip_Text, "m`n)^" stripCtrl "\K\s*=.*", &_TT)
        ? StrReplace(Trim(_TT, "`t ="), "\n", "`n") : "")
      SetTimer(ft_RemoveToolTip, -10000)
    }
  }

  ft_RemoveToolTip() {
    ToolTip()
  }
}
