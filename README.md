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
  - Auto Detonate Mines
  - Hotkey to logout instantly
  - Loot Vacuum while you hold Item Pickup (requires major lootfilter editing)
  - Automatic Wisdom/Portal scroll restock from currency tab
  - Button to hit all your flasks at once.
  - Passthrough keys for the script to recognize when you manually activate flasks.
  - Pauses flasks while you are chatting, at inventory or stash.
  - Smart inventory hotkey

* One button Inventory managment:
  - Clipboard Parsing system - Knows what type of items under cursor!
  - Identifies all items when appropriate (Doesnt waste scrolls on chromes and jewelers that are magic, etc)
  - Stashes items when you are at stash, and will move to whichever stash necessary.
  - Vendors the junk and leaves behind anything valuable! 5link and 6link items will not autovendor, or unique rings etc
  - Customizable Stash tab locations
  - Enable or disable any portion of the inventory management. Can only ID, only SELL, only Stash etc
  - Option to keep maps Unidentified

* Assorted Additions
  - Debug Mode with aditional tools when enabled.
  - Hotkeys to Reload (Alt-Esc) or Exit (Win-Esc)
  - Now runs in background on start unless you open settings.
  - Continued Fine-Tuning the logic of the script

* Feature in testing:
  - UltraWide Scaling

[Support the Project with a donation](http://www.paypal.me/banditmedia)
