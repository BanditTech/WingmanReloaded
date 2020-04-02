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

Using the CLF has become much easier, press the TAB key to search for keys

Use the OR condition to match for mutliple types in one filter

These examples show a few demonstrations using the breakpoints from the community thread [You can find HERE](https://docs.google.com/spreadsheets/d/1cH1Kd5nQnXSjY6SFQ_bPVei8n_Hy6fje5OWdG7s48UI/edit#gid=262670440)

> Import these examples to the CLF to use or edit them for yourself. I would suggest using the Item Info hotkey to learn which stats to look for. The filters will always return the first result, so order can be important. (Currently requires manually re-ordering in the file, not recommended)

> In the following example we filter any items with PoE.Ninja price above 4 chaos to stash tab excluding currency

```JSON
{
 "Affix": {},
 "Prop": {
  "Prop1": "ChaosValue",
  "Prop1Eval": ">=",
  "Prop1Min": "4",
  "Prop2": "RarityCurrency",
  "Prop2Eval": "!=",
  "Prop2Min": "1",
  "Prop1OrFlag": 0,
  "Prop2OrFlag": 0
 },
 "Stats": {},
 "OrCount": 1,
 "StashTab": "2"
}
```

> In the next example, we filter for tier one boots

```JSON
{
 "Affix": {
  "Affix1": "MaximumLife",
  "Affix1Eval": ">=",
  "Affix1Min": "70",
  "Affix1OrFlag": "1",
  "Affix2": "MaximumEnergyShield",
  "Affix2Eval": ">=",
  "Affix2Min": "39",
  "Affix2OrFlag": "1",
  "Affix3": "IncreasedEnergyShield",
  "Affix3Eval": ">=",
  "Affix3Min": "80",
  "Affix3OrFlag": "1",
  "Affix4": "IncreasedMovementSpeed",
  "Affix4Eval": ">=",
  "Affix4Min": "30",
  "Affix4OrFlag": "1",
  "Affix5": "PseudoColdResist",
  "Affix5Eval": ">=",
  "Affix5Min": "42",
  "Affix5OrFlag": "1",
  "Affix6": "PseudoFireResist",
  "Affix6Eval": ">=",
  "Affix6Min": "42",
  "Affix6OrFlag": "1",
  "Affix7": "PseudoLightningResist",
  "Affix7Eval": ">=",
  "Affix7Min": "42",
  "Affix7OrFlag": "1"
 },
 "OrCount": "2",
 "Prop": {
  "Prop1": "ItemClass",
  "Prop1Eval": "~",
  "Prop1Min": "boot",
  "Prop1OrFlag": "0"
 },
 "StashTab": "2",
 "Stats": {}
}
```

> In the next example, we filter for tier one helm

```JSON
{
 "Affix": {
  "Affix1": "MaximumLife",
  "Affix1Eval": ">=",
  "Affix1Min": "80",
  "Affix1OrFlag": "1",
  "Affix2": "MaximumEnergyShield",
  "Affix2Eval": ">=",
  "Affix2Min": "39",
  "Affix2OrFlag": "1",
  "Affix3": "IncreasedEnergyShield",
  "Affix3Eval": ">=",
  "Affix3Min": "80",
  "Affix3OrFlag": "1",
  "Affix4": "AddedLevelMinionGems",
  "Affix4Eval": ">=",
  "Affix4Min": "3",
  "Affix4OrFlag": "1",
  "Affix5": "PseudoColdResist",
  "Affix5Eval": ">=",
  "Affix5Min": "42",
  "Affix5OrFlag": "1",
  "Affix6": "PseudoFireResist",
  "Affix6Eval": ">=",
  "Affix6Min": "42",
  "Affix6OrFlag": "1",
  "Affix7": "PseudoLightningResist",
  "Affix7Eval": ">=",
  "Affix7Min": "42",
  "Affix7OrFlag": "1",
  "Affix8": "AddedAccuracy",
  "Affix8Eval": ">=",
  "Affix8Min": "351",
  "Affix8OrFlag": "1"
 },
 "OrCount": "2",
 "Prop": {
  "Prop1": "ItemClass",
  "Prop1Eval": "~",
  "Prop1Min": "helm",
  "Prop1OrFlag": 0
 },
 "StashTab": "2",
 "Stats": {}
}
```

> In the next example, we filter for tier one body armour

```JSON
{
 "Affix": {
  "Affix1": "MaximumLife",
  "Affix1Eval": ">=",
  "Affix1Min": "80",
  "Affix1OrFlag": "1",
  "Affix2": "MaximumEnergyShield",
  "Affix2Eval": ">=",
  "Affix2Min": "77",
  "Affix2OrFlag": "1",
  "Affix3": "IncreasedEnergyShield",
  "Affix3Eval": ">=",
  "Affix3Min": "92",
  "Affix3OrFlag": "1",
  "Affix4": "PseudoColdResist",
  "Affix4Eval": ">=",
  "Affix4Min": "42",
  "Affix4OrFlag": "1",
  "Affix5": "PseudoFireResist",
  "Affix5Eval": ">=",
  "Affix5Min": "42",
  "Affix5OrFlag": "1",
  "Affix6": "PseudoLightningResist",
  "Affix6Eval": ">=",
  "Affix6Min": "42",
  "Affix6OrFlag": "1"
 },
 "OrCount": "2",
 "Prop": {
  "Prop1": "ItemClass",
  "Prop1Eval": "~",
  "Prop1Min": "body arm",
  "Prop1OrFlag": "0"
 },
 "StashTab": "2",
 "Stats": {}
}
```

> In the next example, we filter for tier one shields

```JSON
{
 "Affix": {
  "Affix1": "AddedLevelGems",
  "Affix1Eval": ">=",
  "Affix1Min": "1",
  "Affix1OrFlag": "1",
  "Affix2": "MaximumLife",
  "Affix2Eval": ">=",
  "Affix2Min": "90",
  "Affix2OrFlag": "1",
  "Affix3": "MaximumEnergyShield",
  "Affix3Eval": ">=",
  "Affix3Min": "62",
  "Affix3OrFlag": "1",
  "Affix4": "IncreasedEnergyShield",
  "Affix4Eval": ">=",
  "Affix4Min": "92",
  "Affix4OrFlag": "1",
  "Affix5": "PseudoFireResist",
  "Affix5Eval": ">=",
  "Affix5Min": "42",
  "Affix5OrFlag": "1",
  "Affix6": "PseudoColdResist",
  "Affix6Eval": ">=",
  "Affix6Min": "42",
  "Affix6OrFlag": "1",
  "Affix7": "PseudoLightningResist",
  "Affix7Eval": ">=",
  "Affix7Min": "42",
  "Affix7OrFlag": "1",
  "Affix8": "ChanceBlockSpell",
  "Affix8Eval": ">=",
  "Affix8Min": "10",
  "Affix8OrFlag": "1",
  "Affix9": "PseudoIncreasedColdDamage",
  "Affix9Eval": ">=",
  "Affix9Min": "100",
  "Affix9OrFlag": "1",
  "Affix10": "PseudoIncreasedFireDamage",
  "Affix10Eval": ">=",
  "Affix10Min": "100",
  "Affix10OrFlag": "1",
  "Affix11": "PseudoIncreasedLightningDamage",
  "Affix11Eval": ">=",
  "Affix11Min": "100",
  "Affix11OrFlag": "1",
  "Affix12": "IncreasedSpellDamage",
  "Affix12Eval": ">=",
  "Affix12Min": "100",
  "Affix12OrFlag": "1",
  "Affix13": "IncreasedSpellCritChance",
  "Affix13Eval": ">=",
  "Affix13Min": "100",
  "Affix13OrFlag": "1"
 },
 "OrCount": 2,
 "Prop": {
  "Prop1": "ItemClass",
  "Prop1Eval": "~",
  "Prop1Min": "shield",
  "Prop1OrFlag": 0
 },
 "StashTab": "2",
 "Stats": {}
}
```

> In the next example, we filter for tier one Phys 2H

```JSON
{
 "Affix": {
  "Affix1": "IncreasedPhysicalDamage",
  "Affix1Eval": ">=",
  "Affix1Min": "170",
  "Affix1OrFlag": "1",
  "Affix2": "PseudoTotalAddedAvgAttack",
  "Affix2Eval": ">=",
  "Affix2Min": "52",
  "Affix2OrFlag": "1",
  "Affix3": "IncreasedCritChance",
  "Affix3Eval": ">=",
  "Affix3Min": "35",
  "Affix3OrFlag": "1",
  "Affix4": "GlobalCriticalMultiplier",
  "Affix4Eval": ">=",
  "Affix4Min": "35",
  "Affix4OrFlag": "1",
  "Affix5": "IncreasedAttackSpeed",
  "Affix5Eval": ">=",
  "Affix5Min": "26",
  "Affix5OrFlag": "1",
  "Affix6": "AddedLevelGems",
  "Affix6Eval": ">=",
  "Affix6Min": "3",
  "Affix6OrFlag": "1"
 },
 "OrCount": "2",
 "Prop": {
  "Prop1": "ItemClass",
  "Prop1Eval": "~",
  "Prop1Min": "Two Hand Axe | Two Hand Sword | Two Hand Mace | Warsta",
  "Prop1OrFlag": 0
 },
 "StashTab": "2",
 "Stats": {}
}
```

> For the last example, we filter for tier one Elemental 2H

```JSON
{
 "Affix": {
  "Affix1": "IncreasedElementalAttack",
  "Affix1Eval": ">=",
  "Affix1Min": "87",
  "Affix1OrFlag": "1",
  "Affix2": "IncreasedCritChance",
  "Affix2Eval": ">=",
  "Affix2Min": "35",
  "Affix2OrFlag": "1",
  "Affix3": "GlobalCriticalMultiplier",
  "Affix3Eval": ">=",
  "Affix3Min": "35",
  "Affix3OrFlag": "1",
  "Affix4": "IncreasedAttackSpeed",
  "Affix4Eval": ">=",
  "Affix4Min": "26",
  "Affix4OrFlag": "1",
  "Affix5": "AddedLevelGems",
  "Affix5Eval": ">=",
  "Affix5Min": "3",
  "Affix5OrFlag": "1"
 },
 "OrCount": "2",
 "Prop": {
  "Prop1": "ItemClass",
  "Prop1Eval": "~",
  "Prop1Min": "Two Hand Axe | Two Hand Sword | Two Hand Mace | Warsta",
  "Prop1OrFlag": 0
 },
 "StashTab": "2",
 "Stats": {}
}
```

> For the last example, we filter non-quality Vaal Gems to their own tab

```JSON
{
 "Affix": {},
 "Prop": {
  "Prop1": "VaalGem",
  "Prop1Eval": ">",
  "Prop1Min": 0,
  "Prop1OrFlag": 0
 },
 "Stats": {
  "Stats1": "Quality",
  "Stats1Eval": "<",
  "Stats1Min": "1",
  "Stats1OrFlag": 0
 },
 "OrCount": 1,
 "StashTab": "2"
}
```

