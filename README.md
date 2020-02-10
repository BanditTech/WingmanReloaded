# WingmanReloaded

PoE-Wingman was originally derived from [Nidark's PoE-Companion](https://github.com/nidark/Poe-Companion) and inspired by [Gurud's Beta-Autopot](https://github.com/badplayerr/beta-autopot/releases/)

This code is derived from [Andoesk's PoE-Wingman v1.1](https://www.ownedcore.com/forums/mmo/path-of-exile/poe-bots-programs/783680-poe-wingman-auto-flask-auto-quit-more-ahk-pixel.html)
* Andoesk provided this project with:
  - GUI based flask management
  - Auto-Quit
  - Auto-Flask
  - Auto-Quicksilver
  - Gem-Swap
  - Quick-Portal
  - Support for any 16:10/9 aspect ratios

In the same spirit as Andoesk I have been searching for a simple program that has optional keybindings and non intrusive interface. I saw that I might be keen to pick up where he left off and improve upon some of the simple functions that this provides. 

* New key features:
  - Profile Management for flasks and utility buttons
    - Save your settings for up to 10 character slots
  - Configure 5 utility keys
     - press on CD
     - or on QS and/or Life/ES percent
     - or when missing buff icon
  - Auto Detonate Mines
  - Hotkey to logout instantly
    - Choose from different types of "logout"
    - Can D/C, type /exit or open portal and click it
  - Loot Vacuum while you hold Item Pickup
    - Use the included filter or set up your own
    - Assign any number of colors to the Loot Vacuum
  - Automatic Wisdom/Portal scroll restock from currency tab
  - Button to hit all your flasks at once.
    - Can choose which flasks are fired when you press the hotkey
  - Passthrough keys for the script to recognize when you manually activate flasks.
    - Can set up any ingame key as your flask slot bindings
  - Pauses flasks while you are chatting, at inventory or stash.
    - Inteligent detection of your gamestate, and tries to stop from interfering you
  - Smart inventory hotkey
    - One button to do everything related to inventory management
    - Identifies, Vendors, Stashes and trades Div Cards!
    - Even systems in place for bulk selling Quality flasks and gems
  - Resolution Scaling
    - Several aspect ratios have been added to the script 4:3, 16:9, 21:9, 32:9
  - Customizable mana threshold
  - Eldritch Battery support
  - Price information from PoE.Ninja database
  - Price information from PoEPrices.info
  - Client.txt log parser that allows the script to know exactly where we are
    - Changes the logic of the script depending on location
    - Support for every single client language when file is encoded properly
  - Hotkeys for Moving between specific stash tabs
  - Hotkeys for Replying to whispers or sending Chat commands
  - Automatic detection of skill gems leveling, and click to level up
  - Open containers and doors when searching for loot with Loot Vacuum
  - Fully customizable search strings for adjusting to your own resolution
  - Calibration wizard to help guide through the setup process
  - Gamestate GUI to show what the script is detecting
  - Globe scan method of always getting the health even while in delve
  - Automatically fill Metamorph panel with best organs

* One button Inventory managment:
  - Clipboard Parsing system - Knows what type of items under cursor!
  - Identifies all items when appropriate (Doesnt waste scrolls on chromes and jewelers that are magic, etc)
  - Stashes items when you are at stash, and will move to whichever stash necessary.
    - Customizable Stash tab locations
      - Chooose which crafting bases to stash
      - Sort gems by Quality or Support
  - Vendors the junk and leaves behind anything valuable! 5link and 6link items will not autovendor, or unique rings etc
  - Custom loot filter for even further filtering items
  - Enable or disable any portion of the inventory management. Can only ID, only SELL, only Stash etc
  - Option to keep maps Unidentified
  - Search for Stash if all panels are closed and in Town/Hideout/Mines
  - Automatically go vendor after Stashing items if there is left overs

* Assorted Additions
  - Debug Messages to display issues
  - Log output for further finding any problems
  - Hotkeys to Reload (Alt-Esc) or Exit (Win-Esc)
  - Now runs in background on start unless you open settings.
     - Detects when game opens or closes and shows overlay
  - Continued Fine-Tuning the logic of the script


[Grab the latest release of the project](https://github.com/BanditTech/WingmanReloaded/releases/latest)

[For install instructions](https://github.com/BanditTech/WingmanReloaded/wiki)

[Keep the project alive with a donation!](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=ESDL6W59QR63A&item_name=Open+Source+Script+Building&currency_code=USD&source=url)

* Quick Setup Guide:
  - Extract the contents of the Zip into a folder somewhere
  - Ensure you current version of AHK is up to date > (1.1.32)
  - Make sure your game is set to Windowed Fullscreen (Borderless)
  - Make sure you have Local Chat enabled in-game
  - Open PoE-Wingman.ahk
  - If you get a message that your Client.txt file was not found
    - Open Configuration Tab and click Locate Logfile
    - Find and select your POE logfile
  - Now assign your ingame Keybindings for Close UI, Inventory, W-Swap, Item Pickup
  - Assign bindings to any features you want to use in the Script's Keybinds section
    - Blank editbox will disable the keybinding for that feature of the script
  - Locate your Scrolls of Wisdom and Portal Scroll in your inventory
    - Use the locate button to set coordinates, or edit x and y positions
  - Make sure the Current league is selected in Item Parse Settings for proper price data
  - Select your Aspect ratio from the dropdown list if you are not using standard 16:9
  - Select if you are using Steam and/or 64 bit
  - Now lets calibrate the game windows
    - Click Run Wizard in the Gamestate Calibration section
    - Select all available calibrations, make sure your inventory is completely empty
    - Run all the calibrations, making sure to follow the tooltip instructions
    - Once finished, Click Show Gamestates to confirm your samples are working
  - If you will be using the inventory features
    - Go to Inventory Tab and either diable unwanted categories or assign stash tabs
    - Click assign Ignored Slots and choose which slots will not get touched
  - Configure your globe sample positions, and make sure they are in the correct location
    - use the Adjust Globes button to change the Area, color or variance to match your screen
  - All the basic stuff is set up, make sure your on your character then Save Configuration
    - If you are using globe scan, resampling colors is no longer needed when saving
      - Otherwise it will resample your Health, ES, and Mana for comparing against while the script runs
    - If the script instantly triggers when you exit town or hideout, you need to resample or adjust globe settings