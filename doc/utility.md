## Utility Management

#### ON column
> PLACEHOLDER
PLACEHOLDER

#### CD column
> PLACEHOLDER
PLACEHOLDER

#### Key column
> PLACEHOLDER
PLACEHOLDER

#### Icon column
> PLACEHOLDER
PLACEHOLDER

#### Show column
> PLACEHOLDER
PLACEHOLDER

#### QS column
> PLACEHOLDER
PLACEHOLDER

#### Pri column
> PLACEHOLDER
PLACEHOLDER

#### Sec column
> PLACEHOLDER
PLACEHOLDER

#### Life column
> PLACEHOLDER
PLACEHOLDER

#### ES column
> PLACEHOLDER
PLACEHOLDER

#### Mana column
> PLACEHOLDER
PLACEHOLDER

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