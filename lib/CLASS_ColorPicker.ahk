; ColorPicker - Create a color Picker into any GUI window or stand alone
class ColorPicker {
  __New(pGroup_GUI_NAME:="ColorPicker", pGroup_ID:="ColorPicker" , pGroup_X:=10 , pGroup_Y:=30 , pGroup_W:=90 , pGroup_H:=280, pGroup_SideBar:=110, pGroup_Start_Color:="000000"){
    This.GUI_NAME := pGroup_GUI_NAME
    This.ID := pGroup_ID
    This.X := pGroup_X
    This.Y := pGroup_Y
    This.W := pGroup_W
    This.H := pGroup_H
    This.SideBar := pGroup_SideBar
    This.Spacing := This.W // 2.5
    This.W_Bar := This.W // 4
    This.Start_Color := pGroup_Start_Color
    This.Start_Red := (0xff0000 & pGroup_Start_Color) >> 16
    This.Start_Green := (0x00ff00 & pGroup_Start_Color) >> 8
    This.Start_Blue := 0x0000ff & pGroup_Start_Color

    ; Gui,% This.GUI_NAME ":Destroy"
    Gui,% This.GUI_NAME ":+AlwaysOnTop +ToolWindow"
    Gui,% This.GUI_NAME ":Color",000000
    Gui,% This.GUI_NAME ":Font",s10 w600

    Edit_Trigger := This.UpdateColor.BIND( THIS ) 

    Gui,% This.GUI_NAME ":Add",Edit,% "x" This.X - 9 " y" This.Y - 18 " w40 h17 -E0x200 Center Disabled v" This.ID "_Red_Edit_Hex" ,% Format("{1:02X}",This.Start_Red)
    This.Slider_Red := New Progress_Slider(This.GUI_NAME,This.ID "_Red",This.X ,This.Y,This.W_Bar,This.H,0,255,This.Start_Red,"550000","BB0000",2,This.ID "_Red_Edit",0,1)
    Gui,% This.GUI_NAME ":Add",Edit,% "x" This.X - 10 " y" This.Y + This.H + 2 " w40 h17 -E0x200 Center Disabled v" This.ID "_Red_Edit hwndRedTriggerhwnd",% This.Start_Red
    GUICONTROL +G , %RedTriggerhwnd% , % Edit_Trigger

    Gui,% This.GUI_NAME ":Add",Edit,% "x" This.X - 9 + This.Spacing " y" This.Y - 18 " w40 h17 -E0x200 Center Disabled v" This.ID "_Green_Edit_Hex" ,% Format("{1:02X}",This.Start_Green)
    This.Slider_Green := New Progress_Slider(This.GUI_NAME,This.ID "_Green",This.X + This.Spacing,This.Y,This.W_Bar,This.H,0,255,This.Start_Green,"005500","00BB00",2,This.ID "_Green_Edit",0,1)
    Gui,% This.GUI_NAME ":Add",Edit,% "x" This.X - 10 + This.Spacing " y" This.Y + This.H + 2 " w40 h17 -E0x200 Center Disabled v" This.ID "_Green_Edit hwndGreenTriggerhwnd" ,% This.Start_Green
    GUICONTROL +G , %GreenTriggerhwnd% , % Edit_Trigger


    Gui,% This.GUI_NAME ":Add",Edit,% "x" This.X - 9 + This.Spacing * 2 " y" This.Y - 18 " w40 h17 -E0x200 Center Disabled v" This.ID "_Blue_Edit_Hex" ,% Format("{1:02X}",This.Start_Blue)
    This.Slider_Blue := New Progress_Slider(This.GUI_NAME,This.ID "_Blue",This.X + This.Spacing*2,This.Y,This.W_Bar,This.H,0,255,This.Start_Blue,"000055","0000BB",2,This.ID "_Blue_Edit",0,1)
    Gui,% This.GUI_NAME ":Add",Edit,% "x" This.X - 10 + This.Spacing * 2 " y" This.Y + This.H + 2 " w40 h17 -E0x200 Center Disabled v" This.ID "_Blue_Edit hwndBlueTriggerhwnd" ,% This.Start_Blue
    GUICONTROL +G , %BlueTriggerhwnd% , % Edit_Trigger


    Gui,% This.GUI_NAME ":Font",s15 w600
    Gui,% This.GUI_NAME ":Add",Edit,% "x" This.X + This.Spacing * 3 " y" This.Y - 22 " w" This.SideBar "h17 -E0x200 Center Disabled v" This.ID "_Group_Color_Hex" ,% Format("0x{1:06X}",This.Start_Color)
  
    Copy_Trigger := This.CopyColor.BIND( THIS )

    Gui,% This.GUI_NAME ":Add",Text,% "x" This.X + This.Spacing * 3 " y" This.Y " w" This.SideBar " h" This.H // 2 + 40 " hwndCopyTriggerhwnd center",
    GUICONTROL +G , %CopyTriggerhwnd% , % Copy_Trigger
    
    Gui,% This.GUI_NAME ":Add",Progress,% "x" This.X + This.Spacing * 3 " y" This.Y " w" This.SideBar " h" This.H // 2 + 20 " Background000000 c" Format("{1:06X}",This.Start_Color) " v" This.ID "_Group_Color", 100

    Gui,% This.GUI_NAME ":Font",s25 w600 c77BB77
    Gui,% This.GUI_NAME ":Add",Text,% "x" This.X + This.Spacing * 3 " y" This.Y + This.H // 2 + 30 " w" This.SideBar " h" (This.H // 2 - 40) // 2 + 10 " hwndCopyTriggerhwnd center", Copy
    GUICONTROL +G , %CopyTriggerhwnd% , % Copy_Trigger
    Gui,% This.GUI_NAME ":Font",s25 w600 cBB7777
    Gui,% This.GUI_NAME ":Add",Text,% "x" This.X + This.Spacing * 3 " y" This.Y + This.H // 2 + 40 + 10 + (This.H // 2 - 40) // 2 " w" This.SideBar " h" (This.H // 2 - 40) // 2 + 10 " gCoordCommand center", Coord


    ; Gui,% This.GUI_NAME ":Show", AutoSize, Color Picker
  }
  UpdateColor(){
    GuiControl, % This.GUI_NAME ": +c" Format("{1:02X}",This.Slider_Red.Slider_Value) Format("{1:02X}",This.Slider_Green.Slider_Value) Format("{1:02X}",This.Slider_Blue.Slider_Value), % This.ID "_Group_Color",
    GuiControl, % This.GUI_NAME ":", % This.ID "_Group_Color_Hex", % "0x" Format("{1:02X}",This.Slider_Red.Slider_Value) Format("{1:02X}",This.Slider_Green.Slider_Value) Format("{1:02X}",This.Slider_Blue.Slider_Value)
  }
  SetColor(newColor){
      This.Start_Color := Format("0x{1:06X}",newColor)
      This.Start_Red := (0xff0000 & newColor) >> 16
      This.Start_Green := (0x00ff00 & newColor) >> 8
      This.Start_Blue := 0x0000ff & newColor
      This.Slider_Red.SET_pSlider(This.Start_Red)
      This.Slider_Green.SET_pSlider(This.Start_Green)
      This.Slider_Blue.SET_pSlider(This.Start_Blue)
  }
  CopyColor(){
    Clipboard := "0x" Format("{1:02X}",This.Slider_Red.Slider_Value) Format("{1:02X}",This.Slider_Green.Slider_Value) Format("{1:02X}",This.Slider_Blue.Slider_Value)
    ; MsgBox, 262144, Color Copied, The Hex color code has been copied to the Clipboard `n`n %Clipboard%
    Notify("Copied To Clipboard`n`n" Clipboard,"",3)
  }
}
