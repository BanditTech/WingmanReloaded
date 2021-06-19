# WingmanReloaded
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-9-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

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
## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/BanditTech"><img src="https://avatars.githubusercontent.com/u/13251996?v=4?s=100" width="100px;" alt=""/><br /><sub><b>BanditTech</b></sub></a><br /><a href="https://github.com/BanditTech/WingmanReloaded/commits?author=BanditTech" title="Code">💻</a> <a href="https://github.com/BanditTech/WingmanReloaded/issues?q=author%3ABanditTech" title="Bug reports">🐛</a> <a href="#data-BanditTech" title="Data">🔣</a> <a href="https://github.com/BanditTech/WingmanReloaded/commits?author=BanditTech" title="Documentation">📖</a> <a href="#design-BanditTech" title="Design">🎨</a> <a href="#ideas-BanditTech" title="Ideas, Planning, & Feedback">🤔</a> <a href="#maintenance-BanditTech" title="Maintenance">🚧</a> <a href="#projectManagement-BanditTech" title="Project Management">📆</a> <a href="#question-BanditTech" title="Answering Questions">💬</a> <a href="#translation-BanditTech" title="Translation">🌍</a> <a href="https://github.com/BanditTech/WingmanReloaded/pulls?q=is%3Apr+reviewed-by%3ABanditTech" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://github.com/danmarzola"><img src="https://avatars.githubusercontent.com/u/20021542?v=4?s=100" width="100px;" alt=""/><br /><sub><b>danmarzola</b></sub></a><br /><a href="https://github.com/BanditTech/WingmanReloaded/commits?author=danmarzola" title="Code">💻</a> <a href="https://github.com/BanditTech/WingmanReloaded/issues?q=author%3Adanmarzola" title="Bug reports">🐛</a> <a href="#data-danmarzola" title="Data">🔣</a> <a href="https://github.com/BanditTech/WingmanReloaded/commits?author=danmarzola" title="Documentation">📖</a> <a href="#design-danmarzola" title="Design">🎨</a> <a href="#ideas-danmarzola" title="Ideas, Planning, & Feedback">🤔</a> <a href="#maintenance-danmarzola" title="Maintenance">🚧</a> <a href="#question-danmarzola" title="Answering Questions">💬</a></td>
    <td align="center"><a href="https://github.com/Barragek0"><img src="https://avatars.githubusercontent.com/u/24503018?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Barragek0</b></sub></a><br /><a href="https://github.com/BanditTech/WingmanReloaded/commits?author=Barragek0" title="Code">💻</a> <a href="https://github.com/BanditTech/WingmanReloaded/issues?q=author%3ABarragek0" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/Hx2600"><img src="https://avatars.githubusercontent.com/u/48565218?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Hx2600</b></sub></a><br /><a href="https://github.com/BanditTech/WingmanReloaded/commits?author=Hx2600" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/sebbi08"><img src="https://avatars.githubusercontent.com/u/9070136?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Sebastian Mahr</b></sub></a><br /><a href="https://github.com/BanditTech/WingmanReloaded/commits?author=sebbi08" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/Sauron-Dev"><img src="https://avatars.githubusercontent.com/u/8209987?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Sauron-Dev</b></sub></a><br /><a href="https://github.com/BanditTech/WingmanReloaded/commits?author=Sauron-Dev" title="Code">💻</a> <a href="https://github.com/BanditTech/WingmanReloaded/issues?q=author%3ASauron-Dev" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/norecha"><img src="https://avatars.githubusercontent.com/u/10354246?v=4?s=100" width="100px;" alt=""/><br /><sub><b>norecha</b></sub></a><br /><a href="https://github.com/BanditTech/WingmanReloaded/commits?author=norecha" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/Hillgrove"><img src="https://avatars.githubusercontent.com/u/20029330?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Hillgrove</b></sub></a><br /><a href="https://github.com/BanditTech/WingmanReloaded/commits?author=Hillgrove" title="Code">💻</a> <a href="#data-Hillgrove" title="Data">🔣</a></td>
    <td align="center"><a href="https://github.com/Violet-Vibes"><img src="https://avatars.githubusercontent.com/u/19490536?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Violet Vibes</b></sub></a><br /><a href="https://github.com/BanditTech/WingmanReloaded/commits?author=Violet-Vibes" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!