; Wingman Crafting Labels - By DanMarzola
CustomUndesirableMods:
  Global CustomUndesirableModsBase
  Gui, CustomUndesirableMods: New
  Gui, CustomUndesirableMods: +AlwaysOnTop -MinimizeBox
  Gui, CustomUndesirableMods: Add, ListView , r10 w600 gMyListView, Index|Map Modifier
  LV_Add("",LV_GetCount(), "Area is inhabited by Skeletons")
  LV_Add("",LV_GetCount(), "Monsters fire # additional Projectiles")
  LV_Add("",LV_GetCount(), "Unique Boss has #% increased Life")
  LV_Add("",LV_GetCount(), "Monsters have a #% chance to avoid Poison, Blind, and Bleeding")
  LV_Add("",LV_GetCount(), "Monsters are Hexproof")
  LV_Add("",LV_GetCount(), "#% less effect of Curses on Monsters")
  LV_Add("",LV_GetCount(), "Players have Elemental Equilibrium")
  LV_Add("",LV_GetCount(), "Monsters gain a Power Charge on Hit")

  Gui, CustomUndesirableMods: Show, , Custom Undesirable Mods Base
Return


MyListView:
if (A_GuiEvent = "DoubleClick")
{
  Gui, CustomUndesirableMods2: New
  Gui, CustomUndesirableMods2: +AlwaysOnTop -MinimizeBox
  Gui, CustomUndesirableMods2: Add, Button,  y+8 w60 r2 center, Edit Row
  Gui, CustomUndesirableMods2: Add, Button,  x+5 w60 r2 center, Remove Row
  LV_GetText(RowText, A_EventInfo)  ; Get the text from the row's first field.
  ToolTip You double-clicked row number %A_EventInfo%. Text: "%RowText%"
  Gui, CustomUndesirableMods2: Show, , Edit Box
}
return