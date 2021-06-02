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
Chaos recipe requires the configuration of your POE session ID, this can be retrieved by looking for the cookie within the developer console of your browser. You will need to paste this string into PoESessionID editbox found on the Configuration tab. 

### Getting your POESESSID
In order to see this value, you need to [log into your account](https://www.pathofexile.com/)

Once you have logged in, there are a few ways to look at the value:

#### Chrome

* Press the F12 key.  
* Select the "Application".  
* Expand the "Cookies", select the https://www.pathofexile.com.  
* Copy the value of the "POESESSID".

#### Firefox

* Press the F12 key.  
* Select the "Storage".  
* Expand the "Cookies", select the https://www.pathofexile.com.  
* Copy the value of the "POESESSID".  

#### IE11

* Press the F12 key.  
* Select the "Network".  
* Enables the capture of network traffic.  
* Reloads the page.  
* Select [DETAILS]-[Cookies].  
* Copy the value of the "POESESSID".  


**Once you have the copy of your session ID, paste that into the Configuration > PoESessionID editfield.** 

> The ID will remain obscured, and shown as a password field. This is also saved to a separate Account.ini file to remain independent of the general settings.
### Enable the Chaos Recipe settings

Once the ID is configured, we can enable the settings.  
Open the Inventory Settings, then open Stash Tabs > Dump Tab  
There is a checkbox to Enable the Dump Tab for chaos recipe  
On the right is the option for how many sets it will attempt to build

This allows the dump tab to remain disabled, and junk items that are not needed for sets will be vendored. Otherwise, it will stash the items that are needed for chaos recipe sets until you have reached the # of items needed for your sets.

> Configure the hotkey you wish to operate the Chaos Recipe, this is above the ID in the Keybinds section.

Once your ready to vendor for some chaos orbs, press the Chaos Recipe hotkey. It will request the contents of your dump tab, and make recipe sets which it will start to withdrawal. If your automation options are configured properly, it will also find the vendor and sell the set.

If you see a message saying there are more sets to vendor, further presses of the hotkey will get the next set to sell. Each time you should see notifications showing your totals for each slot type.

Once you have sold all sets, pressing the hotkey again will re-fetch your stash API. So you may want to re-zone to refresh the contents of your stash for the request. To do this easily, zone into the Garden or the Mines and Zone back in.

> If you get stuck with a stale list, restart the script with Alt+Escape to force a fresh request.