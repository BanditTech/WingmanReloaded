## PoE-Click

I wrote these functions to provide a simple method of performing click actions since each click requires several commands. This also keeps the script uniform and adjustable in one place. These all require x and y coordinates as input.

#### SwiftClick(x, y)
> Left-Clicks the fastest of the group, but only by 15ms x 2 delays

#### LeftClick(x, y, Old:=0)
> Performs a mouse movement and Left Click action. Old flag is to switch between old method and new, code is intact to view in source.

#### RightClick(x, y, Old:=0)
> Performs a mouse movement and Right Click action. Old flag is to switch between old method and new, code is intact to view in source.

#### ShiftClick(x, y)
> Performs a mouse movement and Shift Click action.

#### CtrlClick(x, y)
> Performs a mouse movement and Ctrl Click action.

#### RandClick(x, y)
> Creates a random location up and to the right from the provided location. This function is to randomize the click patern in the inventory scan.

#### WisdomScroll(x, y)
> This function will use a Scroll of Wisdom on the provided coords from a set location for scrolls.


## WR_Menu

#### WR_Menu(Function:="",Var*)
> This function is inspired by the work of Feiyue on the [**AHK forum**](https://www.autohotkey.com/boards/viewtopic.php?f=6&t=17834), his design of the function that manages his interface was so clever I had to try my own implimentation. Essentially it works by using the name of the variable associated with the GUI element, and doing a string split to create three variables from the name. The first part of the name is used as a matching key, and in this case they are all "WR_". The script splits the string like so: WR_ (2) _ (1) _ (3_3_3_3_3) and sends it to this function to evaluate.

> This function will become more and more used as I add the scripts GUI menus to it. So far I have migrated a few to the new system, but will probably need to do this all over for the rewrite of the script.

* Function can equal:
  * Inventory
  * Strings
  * Chat
  * Controller
  * Globe
  * Locate
  * Area
  * Show
  * Color
  * FillMetamorph
  * JSON

```AutoHotkey
WR_Update:
If (A_GuiControl ~= "WR_\w{1,}_")
{
	BtnStr := StrSplit(StrSplit(A_GuiControl, "WR_", " ")[2], "_", " ",3)
	; Naming convention: WR_GuiElementType_FunctionName_ExtraStuff_AfterFunctionName
	; Function = FunctionName, Var[1] = GuiElementType, Var[2] = ExtraStuff_AfterFunctionName
	WR_Menu(BtnStr[2],BtnStr[1],BtnStr[3])
}	
Return
```

## Ding
#### Ding(Timeout:=500, MultiTooltip:=0 , Message*)
> This is a debug message system I wrote to try and make tooltips easier to use while I was doing debugging. I added some marginal improvements, like static tooltip locations and built in time-out control for each tooltip index. 
* Negative values in MultiTooltip will show no matter if debug messages is enabled.
* Timeout can be assigned to 0 for permanant tooltip
* Set MultiTooltip to 0 for tooltip on mouse cursor
  * Allows for multiple tooltips sent at once in the variable Message

## RemoveTooltip
#### RemoveToolTip()
> This contains several labels for each of the Tooltip indexes. The labels are RemoveTT#, where # can be between 1 and 20

## ShowToolTip
#### ShowToolTip()
> This function is called on mouse movement, and will return if the game is active. This updates the tooltips on mouseover, finding the matching variable in the tooltip index. This function was borrowed and modified from the FindText library.

## GuiStatus
#### GuiStatus(Fetch:="",SS:=1)
> This function determines all the pixel states for the script. During each cycle this function is called which takes a new screenshot and evaluates all the OnState variables.
* Pass a name of one of the OnState variables and it will return the state of that pixel location.
  * Set the SS flag to false to evaluate from the previous screenshot instead.

```AutoHotkey
If !(Fetch="")
{
    P%Fetch% := ScreenShot_GetColor(vX_%Fetch%,vY_%Fetch%)
    temp := %Fetch% := (P%Fetch%=var%Fetch%?True:False)
    Return temp
}
```

#### Return (OnChar && !(OnChat||OnMenu||OnInventory||OnStash||OnVendor||OnDiv||OnLeft||OnDelveChart||OnMetamorph))
> This will return true only when on character and no panels active

## PixelStatus / PanelManager 
> These classes were written to replace GuiStatus but there is no real beneifit to making the switch at this time.

#### Class PixelStatus
> Holds the variables locally within the class instead of using globals, checks pixel status and returns true or false

#### Class PanelManager
> This class manages several PixelStatus instances. It is not fully written, as I decided to shelf this code until later.

