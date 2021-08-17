; LogoutCommand - Logout Function
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LogoutCommand(){
  LogoutCommand:
    Critical
    Static LastLogout := 0
    if (WR.perChar.Setting.quitDC || (WR.perChar.Setting.quitPortal && (OnMines || OnTown || OnHideout))) {
      global POEGameArr
      dc := False
      succ := logout(Active_executable)
      if !(succ == 0)
      {
        dc := True
      }
      Else
      {
        tt=
        For k, executable in POEGameArr
        {
          tt.= (tt?",":"") executable
          succ := logout(executable)
          if !(succ == 0)
          {
            dc := True
            Break
          }
        }
      }
      If !dc
        Log("Error","Logout Failed","Could not find game EXE",tt)
      If WR.perChar.Setting.quitLogBackIn
      {
        RandomSleep(750,750)
        ControlSend,, {Enter}, %GameStr%
        RandomSleep(750,750)
        ControlSend,, {Enter}, %GameStr%
      }
    } 
    Else If WR.perChar.Setting.quitPortal
    {
      If ((A_TickCount - LastLogout) > 10000)
      {
        If !GameActive
          WinActivate, %GameStr%
        QuickPortal(True)
        LastLogout := A_TickCount
      }
    }
    Else If WR.perChar.Setting.quitExit
    {
      Send, {Enter}/exit{Enter}
      If WR.perChar.Setting.quitLogBackIn
      {
        RandomSleep(900,900)
        ControlSend,, {Enter}, %GameStr%
      }
    }
    If (!WR.perChar.Setting.typeES)
      Log("Logout","Exit with " . Player.Percent.Life . "`% Life", CurrentLocation)
    Else
      Log("Logout","Exit with " . Player.Percent.ES . "`% ES", CurrentLocation)
    Thread, NoTimers, False    ;End Critical
  return
}
