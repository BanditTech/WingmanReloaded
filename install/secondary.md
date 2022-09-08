## Flasks
> The core of the script is the flask routine. You are given several options in how you would like each flask slot triggered. Depending on the Character Type you have selected, different options of the interface will become available. Life type will have only life triggers active, ES will have only ES triggers active, and Hybrid will have both. 
* The 5 Flasks are arranged in columns 
  * Flask slot 1 is on the left and slot 5 on the right
* Assign the duration the flask lasts (Cooldown)
* Assign key(s) to press when the flask slot triggers
* Check options in the column to enable a trigger type
  * Choose between Life/ES, Mana, Quicksilver, or Attack keys
* Choose whether each flask slot will be included in the Pop Flasks hotkey

### Life Flasks

> These flasks are best used with a Life trigger. Select the row matching the percentage to trigger. For example, to trigger when below 90% select the radio box at the top row.

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
  * Trigger with Life, ES, or Mana percentage

> The utility section is tied to the Auto-Flasks toggle. If the flask routine is ON then utilities will also fire.


## Loot Vacuum

The "Loot Vacuum" is a color searching tool, which finds colors in the area surrounding your mouse. When it gets a match, it clicks it! :)

It does this by creating small squares of the color as FindText strings, and appends them all together. Since they are squares, it requires that it finds a solid area of the color.

### Setting up the colors
> Modify your in-game loot filter to remove any transparency from the background colors for items you want to pick up.

You will need to match with small squares of that color, and in order for that to happen, there can be NO TRANSPARENCY in the background color. Thats why it's important to use SOLID backgrounds and not transparent when making your loot filter. 

You can quickly convert a basic [FilterBlade](filterblade.xyz) filter by using the style editors. To find this, you go to the `STYLE` tab and select `Background colors`. Any color which shows a slight checker pattern behind the color is transparent.

You choose the transparent colors you find, click the color, and then drag the horizontal slider to the right. This will change the textbox from saying `rgba(#, #, #, #)` to `rgb(#, #, #)`

> Avoid using colors such as pure black, and pure white! They will match with the environment!

### Setting up the key

> This function operates with your loot pickup hotkey that is bound In-Game. 

You need to ensure that the loot pickup hotkey is matching in both the game and the script.

> To properly use the Vacuum you will need to enable the In-Game setting to only highlight loot while the key is pressed.  

Once you have configured your colors, you may return the option back to default if you wish. This is so that we can sample both the unhighlighted color AND the highlighted color. If we do not enable this option, the loot will always highlight when you mouse over the item.

> If you sample only the highlighted color, then the tool will only work when you have your mouse hovering over the item. This is a common mistake.

Once you have the In-Game filter configured with Items that have NO TRANSPARENCY, you can begin to make your color samples. Consider which items you want to be picked up before others, and place them in a higher position on the list of color samples.

> Colors for currency items are good candidates to be at the top of the list, as well as colors for specialty items that do not appear often or take up small amount of space.

Once you determine your order, begin to sample the items while they lay on the floor. Press the sample button for the color set you want to update, and then mouse over the background of the item. Press the "A" key to grab the sample.  
The color of the background should change, and you should show one color slightly lighter than the other.

### Testing your setup!

Once you have gotten your background colors matching with the samples on the list, your ready to start looting items on the floor. Hold down the item highlight hotkey, and move the mouse cursor within the configured pixel range of the item you want to loot. The mouse will snap towards the item nameplate, and click to loot it.

> If you are having issues with the vacuum not working, make sure that your script is not paused for calibration reasons. Messages in the script status saying anything other than wingman Active, will also pause this function.

### Search Strings

You are also given the ability to search for specific sample strings, in addition to the color squares. These take second precedence, and will occur if no color match is found.

These two search boxes are active at different times, so they are exclusive, only one will be searched at any time. One is anytime OUTSIDE of delving, the other is only in the mines.

The strings in these boxes are all appended together, so in order to modify these you will need to open a text editor to see it all at once. 

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