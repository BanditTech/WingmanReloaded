; StackRelease
StackRelease()
{
  if (buff:=FindText(GameX, GameY, GameX + (GameW//(6/5)),GameY + (GameH//(1080/75)), 0, 0, WR.perChar.Setting.channelrepressIcon,0))
  {
    If FindText(buff.1.1 + WR.perChar.Setting.channelrepressOffsetX1,buff.1.2 + buff.1.4 + WR.perChar.Setting.channelrepressOffsetY1,buff.1.1 + buff.1.3 + WR.perChar.Setting.channelrepressOffsetX2,buff.1.2 + buff.1.4 + WR.perChar.Setting.channelrepressOffsetY2, 0, 0, WR.perChar.Setting.channelrepressStack,0)
    {
      If GetKeyState(WR.perChar.Setting.channelrepressKey,"P")
      {
        SendHotkey(WR.perChar.Setting.channelrepressKey,"up")
        Sleep, 10
        SendHotkey(WR.perChar.Setting.channelrepressKey,"down")
      }
    }
  }
}
