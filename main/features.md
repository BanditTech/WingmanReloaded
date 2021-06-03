## Feature List

> This multi functional script can perform several actions based on states of the game:
* Auto-Flasks with custom triggers
* Customizable pop flasks hotkey to use some or all flasks at once
* Abilities fired on cooldown or with custom triggers
* Auto-Quit on health threshold
* Auto-Detonate Mines
* Loot Vacuum for picking up items
* Manage Inventory (ID,Vendor,Stash,Divination)
* Custom Loot Filter for sorting items to stash tabs
* Automate going to vendor/stash, then follow up with the second choice
* Automate sending harvest items to Seed Stockpile
* Skill-up Gems when they level
* Cast Portal-Scroll from inventory
* Quickly grab currency from your inventory to apply onto chests
* Swap up to two Gems or items between another position
* Price information for Currency, Uniques, Maps, Rare Items, and More!
* Pixel Information and Zoom tool with Coord hotkey
* Game Controller support to remote stream the game
* Chat Hotkeys for responding to whispers or sending chat commands
* Auto-Fill Metamorph panel when opened in field
* Auto-Stash Chaos/Regal recipe items, and hotkey to auto-vendor sets of items
* Customizable list of Crafting items to stash
* Bulk Craft the map items in your inventory
* Auto-Open Stacked Decks
* Basic crafting of Colors, Sockets, Links and Chancing

   

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
* Optionally trigger with primary or secondary attack

   

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

![WingmanReloaded](images/item-management.gif)

> When the option to sort into groups is disabled, it stashes each item as it is scanned. It is much slower, as you can see it does not deal with a varied inventory in the same amount of time. This option is best used with only essential tabs like currency and the dump tab enabled. This reduces the need to switch stash tabs.

![WingmanReloaded](images/item-management-nogrouping.gif)

## Loot Vacuum

> This function will click on loot near your mouse cursor. Hold down the ingame item pickup key, and it will begin to search for loot and openables.
* Customize the colors of your loot background you want to pick up
* Change the area it will search
* Change the delay after each click
* Optionally open containers and openables
  * There are findtext strings for both normal and delve

![WingmanReloaded](/images/loot-vacuum.gif)

## Auto-Detonate Mines
> Instantly detonate mines when cast, works for both normal and delve

Detonate mines with adjustable delay for stacking up mines between detonates. This detects when you have the Detonate Mines ability active on your in-game GUI. When found, it will press D.

Also allows for pausing detonate so you can stack up for a boss by double tapping detonate key (D).

## Release Key on Stack Count
> Stack Release tool for abilities like Blade Flurry

Assign a buff icon to look for, and a capture of the stack count

Then assign the key you want it to release and repress when it detects full stacks!

When configured correctly, it will provide maximum stack release the moment it reaches it.

![WingmanReloaded](/images/stack-release.gif)

## Autofill Metamorph Panel

> When interacting with the Metamorph Tank inside a map, easily fill the organ selections.

When properly configured and calibrated, it will select the leftmost organs and then place the cursor over the confirm button. Metamorphs become a breeze, instantly fill and go!