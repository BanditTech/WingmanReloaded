## Flask Settings

> The options for Flasks are arranged in 5 collumns. Assign flask duration in MS, Keys to press, Character Type, and Trigger Types.

Choose between different Triggers: 
* Health Trigger - Either Life or ES
* Quicksilver Group - Trigger with LButton or Attack Keys
* Mana Group - Trigger Group with adjustable threshold on the left.
* Pop Flsk - Triggers all enabled flasks when the hotkey is pressed
  * Options allow this to respect cooldowns of active flasks
  * Options also allow for additional keys of any of the flask slots to also be pressed
* Attack Keys group - Primary and Secondary Attack
  * Assign the keys used as primary and secondary attack on the left

Choose Quicksilver options to adjust delay (in seconds) and associate the Quicksilver group with either of the Attack Keys.

### Character Type
> This option determines how flasks can trigger, this effects health trigger and Auto-Quit.
* Life uses only Life Triggers, and Auto-Quit is based on Life. 
* Hybrid uses both Life and ES Triggers, and Auto-Quit is based on life. 
* ES only uses ES Triggers, and Auto-Quit is based on ES.

> There is an option on the right for Eldritch Battery for any characters with ES on the mana globe.

### Flask Duration
> Assign the duration in MilliSeconds (Time in seconds * 1000)
* This behaves as a cooldown

### Flask Ingame Key
> Assign the key associated with this flask slot. The very first key is considered the flask slots primary key. You can proceed with a space then any number of additional keys to press when triggering that slot. Some possible keybindings:
* 1
* 1 {RButton} s a d
* {Space} 2345asdf

### Life and ES Triggers

> This section contains two collumns of radio buttons in each flask collumn. The left side is the Life radio buttons, and the right side is the ES radio buttons. 
* When switching between character types these will become active or inactive.
* To disable a health trigger, select the lowest option "Disable".
* The percentages on the left signify what value is represented in that row.
* Trigger below 90 at the top row, going down to 20 and disabled.
* Selecting a Quicksilver box, or mana box will disable any selected health triggers for that flask collumn.

### Quicksilver Trigger Group

> This row of check boxes allows to add the flask slot to the Quicksilver Flask group.
* They wait to fire sequentially, and will not overlap cooldowns.
* Selecting this group will remove active health triggers.
* A delay is default to not use one when your only doing single clicks.
  * This is adjusted in Seconds
  * This can be adjusted or removed entirely.
* By default the script will use the left mouse button as the trigger for this group.
  * Optionally trigger Quicksilvers with the Primary or Secondary Attack Keys.

### Mana Trigger Group

> This row of check boxes allows to add the flask slot to the Mana Flask group.
* They wait to fire sequentially, and will not overlap cooldowns.
* Selecting this group will remove active health triggers.
* All mana flasks use the same threshold which is set on the left hand side.
  * Use the Up-Down buttons to adjust the percentage of mana to trigger the group.

### Pop Flasks Group

> This row of checkboxes will enable that flask slot to fire when pressing the Pop Flasks hotkey.
* Optionally this can respect the cooldown of flasks that are currently active.
* Optionally allow the Pop Flasks hotkey to fire any extra buttons from the flask bindings.
  * This means if your bindings have more than one key, you can choose not to fire the extra ones

### Attack Key Triggers

> These rows of check boxes allow flask slots to be tied to two Attack Keys.
* Choose which keys are considered the Primary and Secondary Attack Keys.
  * Primary Attack Row is the First and Secondary Attack below it.
* Select the flask slots you want associated with the chosen keys row.

## Auto-Quit Settings
> This group of settings determine how and when you will Auto-Quit
* Use the dropdown list to choose the Health Percentage Threshold
  * Life and Hybrid triggers from life percentage, ES uses ES instead.
* Choose your quit method with the radio buttons
  * D/C is default and uses the LutBot logout method to disconnect TCP ports
  * Portal will open a portal and click it, is useful for leveling
  * /exit is simply sending the exit command to chat, slower than dc but you return to character screen instead of logged out
* The last option allows the script to press Enter to log back in after D/C or /exit

```autohotkey
Blah blah code blah blah
```
