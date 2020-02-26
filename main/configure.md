## Flasks
> The core of the script is the flask routine. You are given several options in how you would like each flask slot triggered. Depending on the Character Type you have selected, different options of the interface will become available. Life type will have only life triggers active, ES will have only ES triggers active, and Hybrid will have both. 
* The 5 Flasks are arranged in collumns 
  * Flask slot 1 is on the left and slot 5 on the right
* Assign the duration the flask lasts (Cooldown)
* Assign key(s) to press when the flask slot triggers
* Check options in the collumn to enable a trigger type
  * Choose between Life/ES, Mana, Quicksilver, or Attack keys
* Choose whether each flask slot will be included in the Pop Flasks hotkey

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

