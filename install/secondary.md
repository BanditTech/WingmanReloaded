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

* When setting up multiple flasks to use in a group, take not of the individual duration of all flasks you want to toggle between.
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
