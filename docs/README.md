# WingmanReloaded

![WingmanReloaded](/images/logo.png)

This is the continuation of the PoE-Wingman script, my personally modified version released to the public. I have always found several game systems of Path of Exile to be rather tedious, and this is my attempt to relieve my stressed wrists and fingers. My main goal is to improve the enjoyment of my time playing the game, and it has definitely suceeded in that goal!

One great aspect of the script is how customizable it has become. There are options for nearly every type of playstyle, including support for Eldridch Battery and Mines. And this does much, much more than simply use your flasks. It is an entire suite of tools designed to make playing Path of Exile more enjoyable by reducing the amount of clicking required to do simple repetitious tasks. The best part is that you can customize nearly all the options of the script, including the samples, so you can get it working for your situation.

As of now, the script is in active development, and setup is not as easy as the original. Find more information in the [**Installation Section**](?id=installation).

 

## Origins of the script

This code is derived from [Andoesk's PoE-Wingman v1.1](https://www.ownedcore.com/forums/mmo/path-of-exile/poe-bots-programs/783680-poe-wingman-auto-flask-auto-quit-more-ahk-pixel.html), which was originally derived from [Nidark's PoE-Companion](https://github.com/nidark/Poe-Companion) and inspired by [Gurud's Beta-Autopot](https://github.com/badplayerr/beta-autopot/releases/).

Large portions of the code have been rewritten or refactored. There are countless new functions added, and many more adjustable options. 


## What is it?

> This multi functional script can perform several actions based on states of the game:
* Potions
* Abilities
* Auto-Quit
* Mines
* Loot Vacuum
* Custom Loot Filter
* Manage Inventory (ID,Vendor,Stash,Divination)
* Automate going from Stash to vendor
* Skill-up Gems
* Cast Portal-Scroll
* Swap Gems
* Price information
* Pixel Information
* Game Controller support
* Chat Hotkeys
* Auto-Fill Metamorph panel

 

> **Some functions may not work if you are using a non 1080 height resolution monitor, then you will need to input your own captures to get them working.** I have made it so that anyone can add their own custom strings in to replace the default ones, so all hope is not lost if you really want to get those functions working. Find more information on the Strings tab docs, and I am always happy to add any submitted samples to the default dropdown lists.

 

## Flasks
> The script can automatically cast Flasks based on several triggers: 
* Life percentage
* ES Percentage
* Mana Percentage
* As Quicksilver
* With Primary or Secondary attack keys
* All flasks as one Hotkey

> Mana and Quicksilver flasks will wait on cooldown as a group

> Quicksilver Flasks trigger with an optional delay
* Quicksilver uses LButton as default trigger
* Optionaly trigger with primary or secondary attack

 

## Utility spells
> Utilities allow for several triggers for abilities as well:
* On Cooldown
* Buff Icon showing/not
* With Quicksilver
* With Primary or Secondary attack keys
* Life percentage
* ES Percentage
* Mana Percentage

 

## Inventory Management
> One button can do so many things! The script detects which panels are active, so it knows what inventory routine to run when pressing the hotkey. 
* It can be pressed while you are elsewhere and no panels are open, then it will quickly open the inventory.
* If in a location with a stash, it can optionally search for a stash to open if no panels are open.
* If Inventory alone is open, it can go through your items and identify any needed.
* If Stash and Inventory is open, then it can send items to assigned stash tabs
  * Supports Custom Loot Filter, currency, crafting, special item types, gems, maps, uniques + rings, and much more
* If Vendor Sell and Inventory is open, then it can sell items to vendor
* If Divination and Inventory is open then it will trade full stacks of div cards in inventory

 

## Release Key on Stack Count
> Stack Release tool for abilities like Blade Flurry

Assign a buff icon to look for, and a capture of the stack count

Then assign the key you want it to release when it detects full stacks!

 

## Auto-Detonate Mines
> Instantly detonate mines when cast, works for both normal and delve

Detonate mines with adjustable delay for stacking up mines between detonates. 

Also allows for pausing detonate so you can stack up for a boss by double tapping detonate key.

 

# Installation

> This script is a much more complex to set up than the original.
>
> I will try and explain each process with detail to provide a clearer instruction to follow.


> The script requires a few things set up In-Game to work.
* Local chat MUST be enabled.
* Display must be set to Windowed Fullscreen
* For most things related to item parsing you must use english client.
  * The location system should work for any language client though
* Enable the Overhead Health Bar in game, so the script knows when to pause.
* Make sure the chat window text does not overlap inventory while stash is open

 

### Choose Aspect Ratio

> Determine the aspect ratio of your game resolution. Use [Aspect Ratio Calulator](https://andrew.hedges.name/experiments/aspect_ratio/) to determine which aspect ratio to choose.
* Standard is 16:9 aspect ratio, and is default
* Classic is 4:3 ( 12:9 )
* Cinematic is 21:9
  * Also a submitted 43:18 aspect ( 21.5:9 )
* UltraWide is 32:9

 

### Client.txt file location

> You must locate the Client.txt file that will be used for the script
* Default location is configured as C:\ drive in a steam library
* If not found you will see a warning message, Simply locate your file and your finished with this part

 

### Configure Hotkeys

> Mandatory In-Game hotkeys are required for the script to function properly:
* Close-UI
* Inventory
* Weapon-Swap
* Item Pickup

> Optional hotkeys enable or disable script functions: (To disable leave blank)
* Open the Main Menu (defaults to Alt-F10 if blank)
* Auto-Flask
* Auto-Quit
* Logout
* Auto-Quicksilver
* Coord/Pixel
* Quick-Portal
* Gem-Swap
* Pop Flasks
* ID/Vend/Stash
* Item Info

 

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
* Check the box to enable or disable that type of stash type

> While you are in Inventory Settings, go to Stash Hotkeys tab to configure that as well, or disable it.
* With default settings, Press Numpad0+Numpad1 to go to the first tab.
* Press Numpad0+NumpadDot to reset the "Current Tab" internal index
  * This makes the next hotkey open the dropdown list instead of using arrows
  * This is useful when you have moved the tab from the scripts "Current Tab"

 

## Flasks

> The core of the script is the flask routine. You are given several options in how you would like each flask slot triggered. Depending on the Character Type you have selected, different options of the interface will become available. Life type will have only life triggers active, ES will have only ES triggers active, and Hybrid will have both. 
* Flasks are arranged in collumns
* Check options in the collumn to enable a trigger type
  * 
    Options are Durations, The In-Game Key (can assign ), 

 

> Lets go over some different types of flasks and how they can be used.

### Life Flasks

> To select a health threshold for these types of flasks, select one of the radiobutton in that flasks column
 

## Utility
Lorem ipsum dolor sit amet, ex vix autem movet dictas. Lobortis mandamus dissentias sed et. Pro ut odio quodsi, at vim meis singulis voluptatibus. Cu ius nostrum electram delicatissimi. Veritus vocibus quo no. Audire nostrud praesent cu qui. Tation saperet principes vix cu, sumo praesent moderatius at eos, cum epicuri scaevola an.

His alii modo assum cu. Vis an partem doming vivendo, id sit sanctus invidunt recteque. Vel no inani interesset, ad qui deleniti cotidieque. Nam id graece possit, adhuc percipit id mel.

 

Lorem ipsum dolor sit amet, ex vix autem movet dictas. Lobortis mandamus dissentias sed et. Pro ut odio quodsi, at vim meis singulis voluptatibus. Cu ius nostrum electram delicatissimi. Veritus vocibus quo no. Audire nostrud praesent cu qui. Tation saperet principes vix cu, sumo praesent moderatius at eos, cum epicuri scaevola an.

His alii modo assum cu. Vis an partem doming vivendo, id sit sanctus invidunt recteque. Vel no inani interesset, ad qui deleniti cotidieque. Nam id graece possit, adhuc percipit id mel.

 

## CLF Examples

> In the following example

```
Lorem ipsum dolor sit amet, ex vix autem movet dictas. Lobortis mandamus dissentias sed et. Pro ut odio quodsi, at vim meis singulis voluptatibus. Cu ius nostrum electram delicatissimi. Veritus vocibus quo no. Audire nostrud praesent cu qui. Tation saperet principes vix cu, sumo praesent moderatius at eos, cum epicuri scaevola an.

His alii modo assum cu. Vis an partem doming vivendo, id sit sanctus invidunt recteque. Vel no inani interesset, ad qui deleniti cotidieque. Nam id graece possit, adhuc percipit id mel.
```

> In the next example, 

```
Lorem ipsum dolor sit amet, ex vix autem movet dictas. Lobortis mandamus dissentias sed et. Pro ut odio quodsi, at vim meis singulis voluptatibus. Cu ius nostrum electram delicatissimi. Veritus vocibus quo no. Audire nostrud praesent cu qui. Tation saperet principes vix cu, sumo praesent moderatius at eos, cum epicuri scaevola an.

His alii modo assum cu. Vis an partem doming vivendo, id sit sanctus invidunt recteque. Vel no inani interesset, ad qui deleniti cotidieque. Nam id graece possit, adhuc percipit id mel.
```

> For the last example, 

```
Lorem ipsum dolor sit amet, ex vix autem movet dictas. Lobortis mandamus dissentias sed et. Pro ut odio quodsi, at vim meis singulis voluptatibus. Cu ius nostrum electram delicatissimi. Veritus vocibus quo no. Audire nostrud praesent cu qui. Tation saperet principes vix cu, sumo praesent moderatius at eos, cum epicuri scaevola an.

His alii modo assum cu. Vis an partem doming vivendo, id sit sanctus invidunt recteque. Vel no inani interesset, ad qui deleniti cotidieque. Nam id graece possit, adhuc percipit id mel.
```

 

# Documentation

See [**Documentation**](/doc_documentation) for details about each of the settings panels.

See [**PLACEHOLDER**](/doc_functions) PLACEHOLDER.
