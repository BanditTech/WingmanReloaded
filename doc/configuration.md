## Information

> This setting panel contains the bulk of the options for the script, as well as buttons to open additional portions of the settings menu. 

## Gamestate Calibration
> This contains buttons for launching additional GUI related to calibration.

### Run Wizard
> This will allow you to sample multiple locations while following onscreen tooltip prompts. Select the type of calibrations you will be doing during the Wizard, all the options are default selected which can be performed upon reaching the very first town. To capture the samples, follow the prompts and press the A button at each step. To cancel the Wizard, hold down Escape then press A.

### Individual Sample
> This panel is for quickly sampling colors for a specific location. It provides the same options for calibration that are provided by the wizard.

### Show Gamestates
> This is a debug tool which shows the current logic states of the script. When the script shows all clear, it will be all green. If anything that will pause the script is active, it will show in red. You can also use this to get a readout of the inventory system for debugging purposes.

### Adjust Globes
> This panel allows for adjustment of the screen locations used to search for Life, Mana or Energy Shield percentages.

The areas are split into Life, Mana, Energy Shield, and Eldritch Battery

Click the color to load it into the color picker on the right. Click Show Area to see a box around the search area in-game.

If you want to make adjustments, there are three adjustable fields. First is the area to search, second is the Color to match against, third is the variance from the matching color.

To get averages of areas of the globe, use the Coord tool to select a rectangle of the area. It will calculate all the unique pixel colors and create an average. This may take some time to process large areas.

Press the Copy button to put the current color of the color picker into the Clipboard. Paste a Hex color into any of the color edit boxes to update it.

> The percentages in the bottom of the panel will update in real time as you make adjustments to any of the settings.

## Interface Options
> These settings are primarily how the script interacts with the game. 

#### Pause script when OHB missing?
> This setting allows the script to pause when the Overhead Health Bar is obscured by an In-Game panel. This is very important for anyone using Utilities set to trigger on cooldown, or bound to the mouse buttons. This option will only work properly when the In-game Overhead Health Bar is enabled.

#### Use Globe Scanner?
> This setting enables the usage of the Health Globe and Mana Globe as the source of information for percentages of Life, Mana and Energy Shield. If disabled, it will use the old style of sampling static locations. The Globe Scanner allows for entering Delve Darkness without triggering a false alarm for being low health.

#### Show GUI on startup?
> This will let you chose whether the interface will always appear when you start the script. Disable this option to send the script to the tray on start instead.

#### Persistent Auto-Toggles?
> This setting allows for the script to remember the toggle state of Auto-Flasks, Auto-Quit and Auto-Quicksilver on script load.

#### Turn off Auto-Update?
> This setting allows the script to Automatically prompt when there is a new update.

#### Update Branch
> Choose the source of the updates, either Alpha branch for changes as they happen or Master branch for stable releases after they have been tested.

#### Auto-check Update
> This setting will let the script search for updates in the background while the game is closed. Choose the time scale and value, so hours and 1 would check every hour. 

#### Aspect Ratio
> This setting allows the script to scale its sample locations based on the width and height of your screen. These aspect ratios allow the script to support several types of screens.

Standard is 16:9  
Classic is 12:9 (4:3)  
Cinematic is 21:9  
Cinematic(43:18) is 21.5:9  
UltraWide is 32:9  

#### Latency Clicks and Clip
> These three dropdowns allow for adjustment of the speed of the script

Latency is a general adjustment that will slow down the actions of most functions, and can be used as a way to provide relief to players with extreme ping.

Clicks is the speed the script does any Click action, and can be modified -2 to +2. The value is multiplied by 15 then added to a base delay. Negative values will subtract from the base delay, while positive values will increase the base delay.

Clip is very similar to Clicks in the way that it behaves, it can also be modified from -2 to +2. This setting will adjust any item clipping action, namely the speed between moving the mouse and performing a Ctrl+C. 

#### Locate Logfile
> This setting is critical to the function of the script, the Logfile must point to the current Client.txt file in the log folder of your currently used Path of Exile installation.

This setting defaults to the Steam installation folder on a C: drive, if this is not your install location then use Locate Logfile button to search for the proper file path.

for the standalone client the file path will look like:

```
C:\Program Files (x86)\Grinding Gear Games\Path of Exile\logs\Client.txt
```

## Additional Settings
> PLACEHOLDER

### Add Info
> PLACEHOLDER

### just blah

PLACEHOLDER

### Example

```autohotkey
Blah blah code blah blah
```