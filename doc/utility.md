## Utility Management

#### ON column
> This setting will enable the utility slot, uncheck to disable

#### CD column
> This setting assigns the duration it will go on cooldown
This is in Milliseconds 1000 is 1 second

#### Key column
> Assign one or more keys to press when the utility is fired  

Place the first key then a space and all following keys
  * 1
  * 1 2345

#### Icon column
> This edit field allows a FindText string to search for a buff icon
If the buff icon is not found, it will trigger the utility

#### Show column
> This setting modifies the Icon behavior
When checked, this will instead trigger when the buff icon is present

#### QS column
> This setting will trigger the utility when firing Quicksilver flask

#### Pri column
> This setting will trigger the utility when pressing Primary Attack

#### Sec column
> This setting will trigger the utility when pressing Secondary Attack

#### Life column
> Trigger the utility based on a Life percentage

#### ES column
> Trigger the utility based on an Energy Shield percentage

#### Mana column
> Trigger the utility based on a Mana percentage

#### Notes About Trigger Types
> Generally you should not use multiple trigger types with a single utility

## Stack Release Tool
> This tool is designed to release a key once it detects a buff, along with a certain number of stacks. Check the box to Enable.
* Icon to Find is a string input field that accepts a valid FindText string
  * This should be the capture of the actual buff icon image itself
* Stack Capture is another input field for FindText string
  * This capture is the buff stacks when at maximum
  * Only capture the stack number itself
* Key to Release is the key that the ability is bound to in the game
* Stack Search Offset is the area it will look for the Stack Count
  * By default it searches the area below the found buff icon
    * if all values are 0 it would be a line from the bottom left of the buff icon to bottom right
    * Positive values for X1 will trim into the buff area, the opposite for X2
    * Positive values for Y1 and Y2 will go below the buff icon, negative values offset from the bottom edge up
  * Adjust the x1,y1 x2,y2 to search a different area
  * This is in case the buff stack is not below

## Auto-Detonate Mines
> This function will search for the Detonate Mines ability showing up on the interface. When found it will press the bound Detonate Mines hotkey.
* Delay after Detonate allows more time between each activation of the detonate trigger
  * The first mine will always detonate nearly instantly, this delay will allow for more time between following activation
* Pause Mines section allows for custom binding to pause the detonate mines
  * Delay is the amount of time to register a "Double Tap" of the hotkey
    * Set to 0 to turn the hotkey into a straight toggle
  * Key is the hotkey bound to pause detonate mines