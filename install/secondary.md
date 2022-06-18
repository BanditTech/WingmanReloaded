## Flasks
> The core of the script is the flask routine. You are given several options in how you would like each flask slot triggered. Depending on the Character Type you have selected, different options of the interface will become available. Life type will have only life triggers active, ES will have only ES triggers active, and Hybrid will have both. 
* The 5 Flasks are given their own menus
  * Click the button to open the configuration
  * The settings will save when you close the menu
* Assign the duration the individual flask will go on cooldown
* Assign the Cooldown group name
 * This will make all other slots in the same group go on cooldown
 * The label names are irrelevant to the function of each flask
* Assign the duration the group will go on cooldown
* Assign key(s) to press when the flask slot triggers
  * space seperate list of keys
  * Delayed actions can be assigned with `[MS](KEY)` example: `[200](RButton)` will press Right mouse after 200ms
* Select the trigger types which will be active on this flask slot
  * Trigger on Move and On CD are special triggers, and will take priority over others
* Choose whether each flask slot will be included in the Pop Flasks hotkey
* Select a debuff type you want to trigger the flask with
* Use the resource trigger sliders to select an amount of that resource
 * The Resource triggers can be optionally bound to each other
 * This will mean that all the resource triggers must match before it fires

## Understanding Group Cooldowns
> When Configuring Flask and Utility settings, you will discover a new feature of the script, which is group cooldowns. These allow us to optionaly disable other flasks/utilities while the group cooldown is activated by another.

* When setting up multiple flasks to use in a group, take note of the individual duration of all flasks you want to toggle between.
 * Add the duration of all the flasks together and remember the value
 * Take this value, and assign it to the cooldown of all flasks that are being rotated
 * In the Group Cooldown field, enter the true duration of each flask.

### Life Flasks

> These flasks are best used with a Life Resource trigger. Drag the slider to around 70% and check the box to reset cooldown, and put 96% for reset point. Now you have a life flask which will fire when you take damage, and when you fill back up, its ready to fire again.

### Mana Flasks

> These work best with a Mana Resource Trigger. Set the threshold to as low as possible, 3% is usually best to work for all levels, even on new characters. If you are not using an enduring mana flask, then set to reset at whatever percentage mana you are full.

### Buff Flasks

> These work well when assigned with an attack key as trigger. Another option is using a Life/ES Resource trigger, or saving these for the Pop Flasks hotkey. Some builds such as Rightous Fire or Death's Oath simply run to attack, so Trigger on Move works well there to pop your buff flasks.

### Quicksilver Flasks

> Assign to the movement trigger to use these when holding assigned Movement hotkey (Left mouse is default). To toggle between multiple flasks, reference the configuration tips from [Understanding Group Cooldowns](https://bandittech.github.io/WingmanReloaded/#/install/secondary?id=understanding-group-cooldowns) to have them all rotate individually.

## Utility

> This tab of the GUI allows for very flexible configurations of any ability or flask slot. It provides the triggers available to flasks as well as allowing the slot to be cast on cooldown, or associate with a buff icon.

* This section is instead arranged in Rows, so each utility slot goes from left to right.
  * Utility slot 1 at the top and slot 10 at the bottom
* Start by assigning a CD (in Milliseconds) and Key
  * These allow for pressing several keys when triggered
  * put the initial key first then space then the rest of the keys
   * to trigger 1 then 3rt we can put `1 3rt` or `1 3 r t`
* Check options in the row to enable a trigger type
  * Assign a buff icon to trigger when showing or not showing
  * Trigger alongside the Quicksilver flask group
  * Trigger with attack keys
  * Trigger with Life, ES, or Mana percentage

> The utility section is tied to the Auto-Flasks toggle. If the flask routine is ON then utilities will also fire.


## Detonate Mines

To have the script automatically detonate mines when available, you will require a few things to get setup.

* First ensure the detonate key in the Hotkeys section is matching your ingame key
* Second you will want to ensure you have your detonate shown calibrated correctly
  * Click the Detonate Shown label while you have a mine layed to calibrate the detonate icon
* Enable the option in the Per-Character settings menu
  * Save this setup to a new miner profile to make future configuration easier
* The script uses the same color for the Mines and Normal
  * Calibration of detonate can break for non standard Aspect ratios
  * When entering the mines, the position is offset
  * If you have an affected aspect ratio, please submit information to the github issue thread about this

## Loot Vacuum

The Loot Vacuum system is put in place to facilitate looting items that drop in the game.  

> This function operates with your loot pickup hotkey that is bound In-Game.  
> To properly use the Vacuum you will need to enable the In-Game setting to only highlight loot while the key is pressed.  Once you have configured your colors, you may return the option back to default if you wish.  

> To refer to default configuration, please find the files located in the "Files to Use" folder within your installation. There are default ZIP files which contain loot filters showing the style required to function.

> All items that you wish to sample will require a NON-TRANSPARENT background. This means ZERO alpha channel, any transparency will cause the item to change background colors.

Once you have the In-Game filter configured with Items that have NO TRANSPARENCY, you can begin to make your color samples. Consider which items you want to be picked up before others, and place them in a higher position on the list of color samples.

Colors for currency items are good candidates to be at the top of the list, as well as colors for specialty items that do not appear often or take up small amount of space.

Once you determine your order, begin to sample the items while they lay on the floor. Press the sample button for the color set you want to update, and then mouse over the background of the item. Press the "A" key to grab the sample.  
The color of the background should change, and you should show one color slightly lighter than the other.

Once you have gotten your background colors matching with the samples on the list, your ready to start looting items on the floor. Hold down the item highlight hotkey, and move the mouse near the item you want to loot. The mouse will snap towards the item nameplate, and click to loot it.

> If you are having issues with the vacuum not working, make sure that your script is not paused for calibration reasons. Messages in the script status saying anything other than wingman Active, will also pause this function.

> Keep in mind that bad colors to sample are pure white and pure black, they often get matched against the background and can cause issues during combat.

## Chaos Recipe Automation
Chaos recipe requires the configuration of your POE cookie. This includes the sessid as well as any cloudflare data, this can be retrieved by looking for the cookie within the developer console of your browser. You will need to paste this string into PoE Cookie editbox found on the Configuration tab. 

### Getting your POE Cookie
In order to see this value, you need to [log into your account](https://www.pathofexile.com/)

Once you have logged in, Here is how I get the cookie data from Chrome:

#### Chrome

* Press the F12 key to open the developer console.
* Press the F5 key to refresh the page.
* Select the `Network` option on the top row.  
* Select the `Doc` option two rows below, on the right.  
* Select the `https://www.pathofexile.com` entry. 
* It will expand to show several sections, colapse them until you find `Request Headers` 
* Copy the value of the `cookie:` entry
  * Make sure to copy everything that is there, starting with `_ga=GA12345` and end with `POESESSID=BLAH1234XYZ`

**Once you have the copy of your cookie, paste that into the Configuration > PoE Cookie editfield.** 

> The ID will remain obscured, and shown as a password field. This is also saved to a separate Account.ini file to remain independent of the general settings.
### Enable the Chaos Recipe settings

Once the Cookie is configured, we can enable the settings.  
* Open the `Inventory Sorting` options on the Main Menu's `Configuration` tab
* Open the `Chaos Recipe` tab to begin setting your options  
* Check to Enable the overall chaos recipe logic  
* Decide which type of stash method to use on the right, then set its associated options below.
* Other settings directly effect the recipe behavior
  * 2x jewelry and Belt options to allow for twice as many, for overflow to the next set
  * Skipping jeweler and chroma from being put into chaos recipe, and instead vendor for the orb
  * Set the max number of each part of the recipe, for weapons/rings this includes both slots
  * Only stash small weapons will prevent anything larger than 1x3 or 2x2 to be used for recipe
  * Recipe Rare UnId keeps rares unidentified within the level range `60-your choice`
  * Keeping a seperate count for both identified and Unidentified will fill UnId then Id
  * Only stash unid will not use Identified items for recipes in the level range
  * The last option is to Choose when the UnId recipe range ends, and items will resume identifying

> Configure the hotkey you wish to operate the Chaos Recipe, this is above the ID in the Keybinds section.

Once your ready to vendor for some chaos orbs, press the Chaos Recipe hotkey. It will request the contents of your dump tab, and make recipe sets which it will start to withdrawal. If your automation options are configured properly, it will also find the vendor and sell the set.

If you see a message saying there are more sets to vendor, further presses of the hotkey will get the next set to sell. Each time you should see notifications showing your totals for each slot type.

Once you have sold all sets, pressing the hotkey again will re-fetch your stash API. So you may want to re-zone to refresh the contents of your stash for the request. To do this easily, zone into the Garden or the Mines and Zone back in.

> If you get stuck with a stale list, restart the script with Alt+Escape to force a fresh request.

## Crafting Maps and Items

To get to the different crafting tools, you will want to go into `Configuration` tab, and click `Crafting`

You are not presented with three tabs of crafting tools, the first is `Map Crafting`, second is `Basic Crafting` and the third is `Item Craft Beta`. `Map crafting` is where you can configure how it will bulk craft your maps in your inventory. `Basic crafting` is where you set up options for Chancing, Linking, Coloring, and Socketing items. `Item Craft Beta` is where you are doing item affix crafts with specified currency. So lets get into what each section can do.

### Map Crafting

The map crafting tab is split into a few pieces. Tier ranges, Map mods, Minimum Map Qualities, and Other settings.

The first section is where you decide what currency you will be using to make your maps, and what tier maps belong in each range. The default ranges are 1-10, 11-13, 14-16. This means that any map which is within those tier ranges, will use the crafting method chosen to roll the map. This allows you to specify different methods for each of the 3 ranges, which means no reconfiguring as you go up in map tiers.

The second section is the Map Mods, which allows you to select from the available mod pool and the minimum weight required of all affixes added together. When browsing the Custom Map Mods you can set each option to `Good`, `Bad`, or `Impossible`. Remember that in order to save any of these changes, you must check the box to the left to activate that affix. Other than the mod type, you can also change its `Weight` which will affect how much value each mod is given. When matched, Good modifiers will add their weight value to the total. Inversely, Bad Modifiers will subtract their weight value from the total. Any matched modifier with Impossible will reroll the map, their weight is irrelevant. Minimum weight setting will allow you to change the minimum total value required for a map to be determined adequate. If set to 10, then there would need to be enough weight added to the total in order to reach 10. For example, if we had 4 Good affixes matched, with a weight of 2 given to each. In this situation of minimum 10, it would not be an adequate amount to prevent rerolling (total of 8). This is left up to your discretion in order to allow it to be flexible.

The third section is Minimum Map Qualities, which allows you to require more basic values than the actual affix rolls. This includes the `Item Quality`, `Item Rarity`, and `Monster Pack Size`. Be wary of setting these values too high if you do not intend to spend large amounts of currency rerolling your maps. This section is also disabled on magic maps, unless you check the box for `Enable on Magic Maps`. Lastly, the `Match MMQ or Weight` option allows you to match EITHER Map Mods section or Minimum Map Qualities section. This would allow you to Set extremely high values for the MMQ, while also having very specific Map mods selected. Then in that situation, when a map is rolled that does not meet the map mods, but has a high enough MMQ it would be determined adequate. Inversely, when the option is unchecked, you can ensure that not only do the map mods match, but that the map also passes the MMQ values.

The fourth section is the Other Settings, they are some general options in regard to the behavior of the function. First we have the option for alch and go with contracts and blueprints. Second option allows you to have the maps which are finished rolling to be moved to the left or right side, depending on how you set up your map skip area. The third option allows you to ensure that Maps are always chiseled to 20% quality, which will result in chisels being used for less than 5% quality. When disabled, maps will be chiseled to the closest to 20 without using chisels for anything less than 5%. (resulting maps are 16-20%)

### Basic Crafting

This is the basic section for Chancing, Linking, Coloring or Socketing an item. All of the sections are limited to crafting on the item under your cursor when you activate the crafting method. Currency Stash and Bulk Inventory options are disabled for now.

Chance section has a single option, to scour and retry. This will usually remain enabled for crafting on cursor, but when bulk crafting is enabled it will be there to give an option.

Link can be configured to set the desired links, or have on auto mode. Auto is recommended, and will use the highest number of links available on the item (linking all sockets).

Color can be configured to set the number of each color required on the item.

Socket can be configured to require a set number of Sockets. Auto is recommended, and will determine the maximum number of sockets automatically and use that as the required number to reach.

### Item Craft Beta

This is a more advanced feature for crafting items based on their affixes. It is recommended to do some research on [Craft of Exile](https://www.craftofexile.com/) before you start, in order to ensure you are not wasting your currency attempting to make something impossible.

First section is the `Item Type` which you select the `Category` of item, and the `Class` of item. For example, the Weapons category would have all the different types of weapon classes, then you would select one such as Claw to begin choosing affixes for that specific type of item.

Second section is the `Affix Rules` where you choose the specific affixes, and how many of them you will require. For sextants, this is also how you determine the match behavior. To select an affix to become part of the requirements, check the box on the left hand side. When selecting the specific affixes to require, be advised that it is range specific, so select all versions of the modifier which you would like to keep. Now choose how many of each type of affix you would like it to require. Specify values for either Prefix, Suffix, or Combination to change the match requirements.

Item Crafting method is where you set the style of craft which will be used to make the item. This will affect which currency is used.

Sextant Crafting Method is specific to the Sextant category. This allows you to select whether you will be crafting sextants in bulk, using compasses, or if you wish to craft a single sextant. Keep in mind that in order to do your sextant crafting, you need to have both the Stash and Atlas displayed at the same time. To do this, you click on the stash, at that same moment you press your atlas hotkey.
