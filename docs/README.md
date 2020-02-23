# WingmanReloaded
<p align="center">
  <img width="100%" src="https://bandittech.github.io/WingmanReloaded/images/logo.png">
</p>

<p align="center">
<a href="https://github.com/BanditTech/WingmanReloaded/releases/latest" alt="Latest Base Version">
  <img src="https://img.shields.io/github/v/release/BanditTech/WingmanReloaded?label=Latest%20Base%20Version&style=for-the-badge" /></a>
<a href="https://github.com/BanditTech/WingmanReloaded/pulse" alt="Commit activity">
  <img src="https://img.shields.io/github/commits-since/BanditTech/WingmanReloaded/latest/master?label=Master%20Commits%20Since%20Release&style=for-the-badge" /></a>
<a href="https://github.com/BanditTech/WingmanReloaded/commits/master" alt="Latest Master Commit">
  <img src="https://img.shields.io/github/last-commit/BanditTech/WingmanReloaded/master?label=Last%20Master%20Commit&style=for-the-badge" /></a>
<a href="https://github.com/BanditTech/WingmanReloaded/commits/Alpha" alt="Latest Master Commit">
  <img src="https://img.shields.io/github/last-commit/BanditTech/WingmanReloaded/Alpha?label=Last%20Alpha%20Commit&style=for-the-badge" /></a>
</p>

This is the continuation of the PoE-Wingman script, my personally modified version released to the public. I have always found several game systems of Path of Exile to be rather tedious, and this is my attempt to relieve my stressed wrists and fingers. My main goal is to improve the enjoyment of my time playing the game, and it has definitely suceeded in that goal!

One great aspect of the script is how customizable it has become. There are options for nearly every type of playstyle, including support for Eldridch Battery and Mines. And this does much, much more than simply use your flasks. It is an entire suite of tools designed to make playing Path of Exile more enjoyable by reducing the amount of clicking required to do simple repetitious tasks. The best part is that you can customize nearly all the options of the script, including the samples, so you can get it working for your situation.

As of now, the script is in active development, and setup is not as easy as the original. Find more information in the [**Installation Section**](?id=installation).

### Origins of the script

This code is derived from [**Andoesk's PoE-Wingman v1.1**](https://www.ownedcore.com/forums/mmo/path-of-exile/poe-bots-programs/783680-poe-wingman-auto-flask-auto-quit-more-ahk-pixel.html), which was originally derived from [**Nidark's PoE-Companion**](https://github.com/nidark/Poe-Companion) and inspired by [**Gurud's Beta-Autopot**](https://github.com/badplayerr/beta-autopot/releases/).

Large portions of the code have been rewritten or refactored. There are countless new functions added, and many more adjustable options. Major improvements include the ability for the script to properly detect health while in delve darkness, and all inventory management and item parsing                                                                           functions.

### Documentation

See [**GUI Documentation**](/doc_documentation) for details about each of the GUI panels and their settings.

See [**Script Functions**](/doc_functions) for developer information regarding script functions.

# What can it do?

> This multi functional script can perform several actions based on states of the game:
* Auto-Flasks with custom triggers or hotkey to use all at once
* Abilities fired on cooldown or with triggers
* Auto-Quit on health threshold
* Auto-Detonate Mines
* Loot Vacuum for picking up items
* Manage Inventory (ID,Vendor,Stash,Divination)
* Custom Loot Filter for sorting items to stash tabs
* Automate going to stash, and then from Stash to vendor
* Skill-up Gems when they level
* Cast Portal-Scroll from inventory
* Swap Gems between two positions
* Price information for Currency, Uniques, Maps, Rare Items, and More!
* Pixel Information and Zoom tool with Coord hotkey
* Game Controller support to remote stream the game
* Chat Hotkeys for responding to whispers or sending chat commands
* Auto-Fill Metamorph panel when opened in field

   

> **Some functions may not work if you are using a non 1080 height resolution monitor, then you will need to input your own captures to get them working.** I have made it so that anyone can add their own custom strings in to replace the default ones, so all hope is not lost if you really want to get those functions working. Find more information on the Strings tab docs, and I am always happy to add any submitted samples to the default dropdown lists.

   

## Auto-Flasks
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

   

## Auto-Quit
> Quit automatically when your health reaches a threshold. Select from 10 to 90% health to quit, so even lowlife characters are supported. The script allows for three quit methods:
* D/C method is nearly instant and is default
* Portal exit can be somewhat slow, but works great for leveling
* /exit is an alternative to D/C which is slightly slower

   

## Utility spells
> Utilities allow for several triggers for abilities as well:
* On Cooldown
* Buff Icon showing/not
* With Quicksilver
* With Primary or Secondary attack keys
* Life percentage
* ES Percentage
* Mana Percentage

> These utilities can trigger keys for abilities or as more advanced flask setup. They support multiple keys in the same ways the flask slots do, so one utility can trigger multiple keys like 1234 with "1 234".

## Inventory Management
> One button can do so many things! The script detects which panels are active, so it knows what inventory routine to run when pressing the hotkey. 
* It can be pressed while you are elsewhere and no panels are open, then it will quickly open the inventory.
* If in a location with a stash, it can optionally search for a stash to open if no panels are open.
* If Inventory alone is open, it can go through your items and identify any needed.
* If Stash and Inventory is open, then it can send items to assigned stash tabs
  * Supports Custom Loot Filter, currency, crafting, special item types, gems, maps, uniques + rings, and much more
  * It can be configured to automatically walk to vendor and sell left over items after stashing
* If Vendor Sell and Inventory is open, then it can sell items to vendor
* If Divination and Inventory is open then it will trade full stacks of div cards in inventory

> The stash function can happen in two ways. The default way is sorting items into groups first, based on the tab the item will end up. This speeds up the time it takes to manage a full inventory of various items.

![WingmanReloaded](/images/item-management.gif)

> When the option to sort into groups is disabled, it stashes each item as it is scanned. It is much slower, as you can see it does not deal with a varied inventory in the same amount of time. This option is best used with only essential tabs like currency and the dump tab enabled. This reduces the need to switch stash tabs.

![WingmanReloaded](/images/item-management-nogrouping.gif)

## Loot Vacuum

> This function will click on loot near your mouse cursor. Hold down the ingame item pickup key, and it will begin to search for loot and openables.
* Customize the colors of your loot background you want to pick up
* Change the area it will search
* Change the delay after each click
* Optionally open containers and openables
  * There are findtext strings for both normal and delve

![WingmanReloaded](/images/loot-vacuum.gif)


## Other Functions

### Release Key on Stack Count
> Stack Release tool for abilities like Blade Flurry

Assign a buff icon to look for, and a capture of the stack count

Then assign the key you want it to release when it detects full stacks!

When configured correctly, it will provide maximum stack release the moment it reaches it.

![WingmanReloaded](/images/stack-release.gif)

### Auto-Detonate Mines
> Instantly detonate mines when cast, works for both normal and delve

Detonate mines with adjustable delay for stacking up mines between detonates. This detects when you have the Detonate Mines ability active on your in-game GUI. When found, it will press D.

Also allows for pausing detonate so you can stack up for a boss by double tapping detonate key (D).

### Loot Vacuum
   

# Installation

> This script is more complex to set up than the original. Try to follow along with the different portions of the setup process to ensure you have done it correctly. Use the readout in the statusbar of the scripts GUI to see whats going on with the script. Enable debug messages with Logic or Location to see the information as a tooltip in the top left corner.

> This script is written in [**AutoHotKey**](https://www.autohotkey.com/), and will require the [**latest version of AHK**](https://www.autohotkey.com/download/ahk-install.exe) installed to use the script.

## Basic Setup

> Setup sections:
>
> Interface with Game | | | |
> -|-|-|-|
> [**In-Game Requirements**](?id=in-game-requirements) | [**Choose Aspect Ratio**](?id=choose-aspect-ratio) | [**Client.txt file location**](?id=client.txt-file-location) | [**Configure Hotkeys**](?id=configure-hotkeys)
> 
> Configure Script | | | |
> -|-|-|-|
> [**Calibrate Gamestates**](?id=calibrate-gamestates) | [**Adjust Globes**](?id=Adjust-globes) | Assign [**Scroll**](?id=assign-scroll-locations) / [**Gem**](?id=assign-gem-locations) Locations | [**Assign Stash Tabs**](?id=assign-stash-tabs)


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

> Find more information about these hotkey functions in the [**GUI Documentation**](/doc_documentation)

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

   

## Flasks

> The core of the script is the flask routine. You are given several options in how you would like each flask slot triggered. Depending on the Character Type you have selected, different options of the interface will become available. Life type will have only life triggers active, ES will have only ES triggers active, and Hybrid will have both. 
* The 5 Flasks are arranged in collumns 
  * Flask slot 1 is on the left and slot 5 on the right
* Assign the duration the flask lasts (Cooldown)
* Assign key(s) to press when the flask slot triggers
* Check options in the collumn to enable a trigger type
  * Choose between Life/ES, Mana, Quicksilver, or Attack keys

### Life Flasks

> These flasks are best used with a Life trigger. Select the row matching the percentage to trigger. For example, to trigger when below 90% select the radiobox at the top row.

### Mana Flasks

> These work best when assigned to the mana group. Select the threshold the mana will be considered triggered on the left. An alternative configuration is to use an attack key as the trigger. The Mana flask group will wait on cooldown together when any flask is active, and always cycles through each flask one at a time.

### Buff Flasks

> These work well when assigned with an attack key as trigger. Another option is using a health trigger, or saving these for the Pop Flasks hotkey.

### Quicksilver Flasks

> Assign to the quicksilver group to use these when holding Left mouse button. These will always wait for the previous flask to finish before using the next. The Quicksilver flask group will wait on cooldown together when any flask is active, and always cycles through each flask one at a time.
   

## Utility

> This tab of the GUI allows for very flexible configurations of any ability or flask slot. It provides the triggers available to flasks as well as allowing the slot to be cast on cooldown, or associate with a buff icon.

* This section is instead arranged in Rows, so each utility slot goes from left to right.
  * Utility slot 1 at the top and slot 10 at the bottom
* Start by assigning a CD (in Milliseconds) and Key
  * These allow for pressing several keys when triggered
  * put the initial key first then space then the rest of the keys
    * to trigger 1 then 3rt we can put "1 3rt" or "1 3 r t"
* Check options in the row to enable a trigger type
  * Assign a buff icon to trigger when showing or not showing
  * Trigger alongside the Quicksilver flask group
  * Trigger with attack keys
  * Trigger with Life, ES, or Mana percantage

> The utility section is tied to the Auto-Flasks toggle. If the flask routine is ON then utilities will also fire.

## CLF Examples

> Import these examples to the CLF to use or edit them for yourself. I would suggest using the Item Info hotkey to learn which stats to look for. The filters will always return the first result, so order can be important. (Currently requires manually re-ordering in the file, not recommended)

> In the following example we filter any items with PoE.Ninja price above 4 chaos to stash tab excluding currency

```JSON
{"Affix":{},"Prop":{"Prop1":"ChaosValue","Prop1Eval":">=","Prop1Min":"4","Prop2":"RarityCurrency","Prop2Eval":"!=","Prop2Min":"1"},"Stats":{}}
```

> In the next example, we filter non-unique one hand or claw weapons, with potential q20 dps above 300

```JSON
{"Affix":{},"Prop":{"Prop1":"RarityUnique","Prop1Eval":"!=","Prop1Min":"1","Prop2":"ItemClass","Prop2Eval":"~","Prop2Min":"One Hand | Claw"},"Stats":{"Stats2":"Dps_Q20","Stats2Eval":">","Stats2Min":"300"}}
```

> In the next example, we filter by both ItemBase and ItemClass, and then a required affix

```JSON
{"Affix":{"Affix1":"ChaosDOTMult","Affix1Eval":">","Affix1Min":"10"},"Prop":{"Prop1":"ItemBase","Prop1Eval":"~","Prop1Min":"fingerless","Prop2":"ItemClass","Prop2Eval":"~","Prop2Min":"glove"},"Stats":{}}
```

> In the next example, we filter for high Energy shield boots with movement speed

```JSON
{"Affix":{"Affix1":"IncreasedMovementSpeed","Affix1Eval":">","Affix1Min":"24"},"Prop":{},"Stats":{"Stats1":"RatingEnergyShield","Stats1Eval":">","Stats1Min":"145"}}
```

> In the next example, we filter for life amulets and rings

```JSON
{"Affix":{"Affix1":"MaximumLife","Affix1Eval":">","Affix1Min":"85"},"Prop":{"Prop1":"ItemClass","Prop1Eval":"~","Prop1Min":"amulet | ring"},"Stats":{}}
```

> For the last example, we filter non-quality Vaal Gems to their own tab

```JSON
{"Affix":{},"Prop":{"Prop1":"VaalGem","Prop1Eval":">","Prop1Min":0},"Stats":{"Stats1":"Quality","Stats1Eval":"<","Stats1Min":"1"}}
```

   
