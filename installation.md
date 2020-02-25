# Installation

## Install Information
> This script is more complex to set up than the original. Try to follow along with the different portions of the setup process to ensure you have done it correctly. Use the readout in the statusbar of the scripts GUI to see whats going on with the script. Enable debug messages with Logic or Location to see the information as a tooltip in the top left corner.

> This script is written in [**AutoHotKey**](https://www.autohotkey.com/), and will require the [**latest version of AHK**](https://www.autohotkey.com/download/ahk-install.exe) installed to use the script. Because it is written in AutoHotKey it is also portable, so it can be run from mostly any folder. 

> It is highly recommended from a safety standpoint that you follow the instructions [**here for basic info**](https://www.ownedcore.com/forums/mmo/path-of-exile/poe-bots-programs/676345-run-poe-limited-user.html) and [**here for steam and additional info**](https://www.ownedcore.com/forums/mmo/path-of-exile/poe-bots-programs/676345-run-poe-limited-user-13.html#post4065928) to set up the game to run as a limited user, then block the limited user from acessing the folder this script is located in.

> If you have not already, here is a link to download the [**Latest Base Release**](https://github.com/BanditTech/WingmanReloaded/releases/latest)

### In-Game Requirements

> The script requires a few things set up In-Game to work.
* Local chat MUST be enabled.
* Display must be set to Windowed Fullscreen
* For most things related to item parsing you must use english client.
  * The location system should work for any language client though
* Enable the Overhead Health Bar in game, so the script knows when to pause.
* Make sure the chat window text does not overlap inventory while stash is open

   

### Choose Aspect Ratio

> Determine the aspect ratio of your game resolution. Use [**Aspect Ratio Calulator**](https://andrew.hedges.name/experiments/aspect_ratio/) to determine which aspect ratio to choose.
* Standard is 16:9 aspect ratio, and is default
* Classic is 4:3 ( 12:9 )
* Cinematic is 21:9
  * Also a submitted 43:18 aspect ( 21.5:9 )
* UltraWide is 32:9

   

### Client.txt file location

> You must locate the Client.txt file that will be used for the script
* This file is required in order to determine the current location
* Default file location is configured as C:\ drive in a steam library
* If not found you will see a warning message, Simply locate your file in your PoE install folder
* Double check that you have local chat enabled In-Game, and it should now update when you zone change

   

### Configure Hotkeys

> Mandatory In-Game hotkeys are required for the script to function properly:
* Close-UI
* Inventory
* Weapon-Swap
* Item Pickup

> Optional hotkeys enable or disable script functions: (To disable leave blank)
* Open the Main Menu (defaults to Alt-F10 if blank)
* Auto-Flask toggle
* Auto-Quit toggle
* Logout
* Auto-Quicksilver toggle
* Coord/Pixel
* Quick-Portal
* Gem-Swap
* Pop Flasks
* ID/Vend/Stash
* Item Info

> Find more information about these hotkey functions in the [**GUI Documentation**](documentation)

### Calibrate Gamestates

> Several bits of information that the script is gathering are based on single pixel locations. When the pixel matches the previously sampled color, it will determine that the specific gamestate is active. This is important for knowing when your on your character and ready to play, or have panels open, are at the stash, etc... 
* There are two primary methods of performing the calibrations.
* The simplest for newer players is probably the Wizard.
  * It allows you to select several samples to do at once.
  * It will prompt you with what to do for each step.
* Individual Sample is the other method, and its easier when you only want to recalibrate one or two gamestates.
  * Mouse over each button to see a discription.
  * Click the appropriate sample button while the gamestate is active, read the popup and continue.

> Once you have done your calibrations, click Show Gamestates button to confirm everything is working. When changing game panels the corresponding gamestate should light up. If everything has lit up green the script is ready to work.

   

### Adjust Globes

> Use the Adjust Globes GUI to change where the script scans the screen for determining the Life, Energy Shield and Mana percentages.
* Adjust the area to change where it will scan the screenshot
* Change the "Base Color" to match against
* Change the variance from the base color it will consider matching

   

### Assign Scroll Locations

> In order to properly use the inventory functions, you need to have portal and Identify scrolls in fixed position of your inventory.
* Go to Configuration Tab > Inventory > Scroll and Gem Locations
* Click Locate button for Portal then Wisdom scrolls
  * Press the Control button when you are directly in the center of each scroll.

   

### Assign Gem Locations

> In order to properly use the Gem-Swap function, you need to have two locations set to swap
* Go to Configuration Tab > Inventory > Scroll and Gem Locations
* Click Locate button for Current and Alternate Gem
  * Press the Control button when you are directly in the center of each Gem.

   

### Assign Stash Tabs

> In order to properly use the Inventory function to sort to stash tabs, you need to assign the number for each tab that matches the ingame list. From the top of the dropdown list for your stash tabs is position 1 going down to position 32.
* Go to Configuration Tab > Inventory > Stash Tabs > Stash Management
* Select the assigned tab from the dropdown list
  * You can assign multiple types to the same stash tab
* Check the box to enable or disable stashing that type of item

> While you are in Inventory Settings, go to Stash Hotkeys tab to configure that as well, or disable it.
* With default settings, Press Numpad0+Numpad1 to go to the first tab.
* Press Numpad0+NumpadDot to reset the "Current Tab" internal index
  * This makes the next hotkey open the dropdown list instead of using arrows
  * This is useful when you have moved the tab from the scripts "Current Tab"