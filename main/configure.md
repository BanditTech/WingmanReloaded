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

## Using the Custom Loot Filter (CLF)

> Items are evaluated and given variables, which you can use to determine where they should end up in the stash  
> We will be referring to the selected affix or property as the "Selection Key" or "Key"  
> This is the Variable which you are evaluating against using the selected Evaluation type, and Minimum value

Using the CLF has become much easier to find the desired affix or property, press TAB while the Selected Key is active to search through the list.  
Press Enter to fill the Selected Key with the search result.

Assign the number of required OR matches, then check the OR box on all the affixes which you would like to become conditional on that count.

These examples will show both basic functionality as well as advanced usage of the CLF. Follow along with the descriptive text to learn more about how to use the CLF basic functionality.

> Import these examples to the CLF to use, and then edit them for your own personal taste.  
> I would suggest using the Item Info hotkey to learn which Properties and Affixes to look for.  
> The CLF will always match with the first filter that is considered true, so order can be important. (Currently requires manually re-ordering in the file, not recommended)

> Here we have a simple filter which is two conditions: ChaosValue is AT LEAST 4, and RarityCurrency is NOT true  
> Notice that we are checking for both conditions, and they both must match to return true  
> Basic evaluations include these: < , > , = , != , <= , >=

```JSON
{
 "Affix": {},
 "Data": { "OrCount": 1, "StashTab": "2" },
 "Prop": [
  { "#Key": "ChaosValue", "Eval": ">=", "Min": "4", "OrFlag": 0 },
  { "#Key": "RarityCurrency", "Eval": "!=", "Min": "1", "OrFlag": 0 }
 ]
}
```

> Now with a grasp of basic evaluations, we can begin to use the ~ evaluator to search for strings  
> The basic tools of this search mode are the | symbol (OR) and & symbol (AND)

> Let us create a hypothetical search, where we want to only get specific influenced items but also specific item types  
> This will match with Redeemer OR Hunter OR (Crusader AND Elder)  
> Notice that the third match condition will only be true when BOTH the strings "Crusader" AND "Elder" are contained in Influence  
> It also requires that the item Class to contain the strings: "Boot", "Glove", "Ring", "Belt", or "Amulet"  
> This allows for loose matching since some item classes are named in the plural like "Boots", "Gloves", etc..

```JSON
{
 "Affix": {},
 "Data": { "OrCount": 1, "StashTab": "2" },
 "Prop": [
  { "#Key": "Influence", "Eval": "~", "Min": "Redeemer | Hunter | Crusader & Elder", "OrFlag": 0 },
  { "#Key": "ItemClass", "Eval": "~", "Min": "Boot | Glove | Ring | Belt | Amulet", "OrFlag": 0 }
 ]
}
```
> Now that we covered the evaluation types, we can start to look at affixes.  
> The new item parser is capable of matching the affixes of nearly every item  
> When looking to create filters remember that most numbers will be replaced with a # symbol

> Lets begin this section by getting straight into the usage of the OR condition  
> We can assign any number of the Keys as being mutually conditional with any number of others  
> Assign a minimum number of matches that the OR group must contain in order to return true  
> Check the OR CheckBox next to any Key to add it to the OR group

> Let's contrive another hypothetical filter, where we want to use the OR condition  
> We can assign the Min OR # to 1 in order to match any of the three conditions  
> This filter will match any item that is Divination, Gem, or Currency

```JSON
{
 "Affix": {},
 "Data": { "OrCount": "1", "StashTab": "2" },
 "Prop": [
  { "#Key": "RarityDivination", "Eval": "=", "Min": "1", "OrFlag": "1" },
  { "#Key": "RarityGem", "Eval": "=", "Min": "1", "OrFlag": "1" },
  { "#Key": "RarityCurrency", "Eval": "=", "Min": "1", "OrFlag": "1" }
 ]
}
```


> The next examples will all take this idea to an extreme, using Affix Keys that are assigned to the OR group  
> These filters are loosely based on the [Community CutSheet](https://docs.google.com/spreadsheets/d/1cH1Kd5nQnXSjY6SFQ_bPVei8n_Hy6fje5OWdG7s48UI/edit#gid=262670440) and expanded to T2 affixes by DanMarzola

**Helmet Filter**

```JSON
{
 "Affix": [
  { "#Key": "# to maximum Mana", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Intelligence", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Strength", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Dexterity", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Life", "Eval": ">=", "Min": "70", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Energy Shield", "Eval": ">=", "Min": "31", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total Increased Energy Shield", "Eval": ">=", "Min": "68", "OrFlag": "1" },
  { "#Key": "# to Level of all Minion Skill Gems", "Eval": ">=", "Min": "2", "OrFlag": "1" },
  { "#Key": "# to Accuracy Rating", "Eval": ">=", "Min": "251", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Cold Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Fire Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Lightning Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Elemental Resistance", "Eval": ">=", "Min": "80", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 2, "StashTab": "2" },
 "Prop": [
  { "#Key": "RarityRare", "Eval": "=", "Min": "1", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" },
  { "#Key": "ItemClass", "Eval": "=", "Min": "Helmet", "OrFlag": "0" }
 ]
}
```

**Boots Filter**

```JSON
{
 "Affix": [
  { "#Key": "# to maximum Mana", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Life", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Intelligence", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Strength", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Dexterity", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Energy Shield", "Eval": ">=", "Min": "24", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total Increased Energy Shield", "Eval": ">=", "Min": "68", "OrFlag": "1" },
  { "#Key": "# increased Movement Speed", "Eval": ">=", "Min": "25", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Cold Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Fire Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Lightning Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Elemental Resistance", "Eval": ">=", "Min": "80", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 2, "StashTab": "2" },
 "Prop": [
  { "#Key": "RarityRare", "Eval": "=", "Min": "1", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" },
  { "#Key": "ItemClass", "Eval": "=", "Min": "Boots", "OrFlag": "0" }
 ]
}
```

**Body Armour Filter**

```JSON
{
 "Affix": [
  { "#Key": "# to maximum Mana", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Life", "Eval": ">=", "Min": "100", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Intelligence", "Eval": ">=", "Min": "43", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Energy Shield", "Eval": ">=", "Min": "62", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total Increased Energy Shield", "Eval": ">=", "Min": "80", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Cold Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Fire Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Lightning Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Elemental Resistance", "Eval": ">=", "Min": "80", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 2, "StashTab": "2" },
 "Prop": [
  { "#Key": "RarityRare", "Eval": "=", "Min": "1", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" },
  { "#Key": "ItemClass", "Eval": "=", "Min": "Body Armour", "OrFlag": "0" }
 ]
}
```

**Gloves Filter**

```JSON
{
 "Affix": [
  { "#Key": "# to maximum Mana", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Life", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Strength", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Dexterity", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Intelligence", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "# to Accuracy Rating", "Eval": ">=", "Min": "251", "OrFlag": "1" },
  { "#Key": "# increased Attack Speed", "Eval": ">=", "Min": "14", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Energy Shield", "Eval": ">=", "Min": "24", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total Increased Energy Shield", "Eval": ">=", "Min": "68", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Cold Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Fire Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Lightning Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Elemental Resistance", "Eval": ">=", "Min": "80", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 2, "StashTab": "2" },
 "Prop": [
  { "#Key": "RarityRare", "Eval": "=", "Min": "1", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" },
  { "#Key": "ItemClass", "Eval": "=", "Min": "Gloves", "OrFlag": "0" }
 ]
}
```

**Shield Filter**

```JSON
{
 "Affix": [
  { "#Key": "(Pseudo) Total to Maximum Life", "Eval": ">=", "Min": "80", "OrFlag": "1" },
  { "#Key": "# to maximum Mana", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Intelligence", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Strength", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Dexterity", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Energy Shield", "Eval": ">=", "Min": "50", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total Increased Energy Shield", "Eval": ">=", "Min": "80", "OrFlag": "1" },
  { "#Key": "(Pseudo) Increased Cold Damage", "Eval": ">=", "Min": "65", "OrFlag": "1" },
  { "#Key": "(Pseudo) Increased Fire Damage", "Eval": ">=", "Min": "65", "OrFlag": "1" },
  { "#Key": "(Pseudo) Increased Lightning Damage", "Eval": ">=", "Min": "65", "OrFlag": "1" },
  { "#Key": "# increased Spell Damage", "Eval": ">=", "Min": "65", "OrFlag": "1" },
  { "#Key": "# to Level of all Fire Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Cold Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Lightning Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Chaos Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# increased Critical Strike Chance for Spells", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "# Chance to Block Spell Damage", "Eval": ">=", "Min": "10", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Cold Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Fire Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Lightning Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Elemental Resistance", "Eval": ">=", "Min": "80", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 2, "StashTab": "2" },
 "Prop": [
  { "#Key": "RarityRare", "Eval": "=", "Min": "1", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" },
  { "#Key": "ItemClass", "Eval": "=", "Min": "Shield", "OrFlag": "0" }
 ]
}
```

**Belt Filter**

```JSON
{
 "Affix": [
  { "#Key": "(Pseudo) Total to Maximum Life", "Eval": ">=", "Min": "70", "OrFlag": "1" },
  { "#Key": "# to maximum Mana", "Eval": ">=", "Min": "55", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Strength", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Dexterity", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Intelligence", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Energy Shield", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "# increased Elemental Damage with Attack Skills", "Eval": ">=", "Min": "31", "OrFlag": "1" },
  { "#Key": "# to Armour", "Eval": ">=", "Min": "231", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Cold Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Fire Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Lightning Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Elemental Resistance", "Eval": ">=", "Min": "80", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 2, "StashTab": "2" },
 "Prop": [
  { "#Key": "RarityRare", "Eval": "=", "Min": "1", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" },
  { "#Key": "ItemClass", "Eval": "=", "Min": "Belt", "OrFlag": "0" }
 ]
}
```

**Amulet Filter**

```JSON
{
 "Affix": [
  { "#Key": "(Pseudo) Total to Maximum Life", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "# to maximum Mana", "Eval": ">=", "Min": "66", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Strength", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Dexterity", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Intelligence", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Energy Shield", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "# increased Elemental Damage with Attack Skills", "Eval": ">=", "Min": "31", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total Increased Energy Shield", "Eval": ">=", "Min": "14", "OrFlag": "1" },
  { "#Key": "(Pseudo) Add Physical Damage to Attacks_Avg", "Eval": ">=", "Min": "11", "OrFlag": "1" },
  { "#Key": "# to Global Critical Strike Multiplier", "Eval": ">=", "Min": "25", "OrFlag": "1" },
  { "#Key": "# to Accuracy Rating", "Eval": ">=", "Min": "166", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Cold Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Fire Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Lightning Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Elemental Resistance", "Eval": ">=", "Min": "80", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 2, "StashTab": "2" },
 "Prop": [
  { "#Key": "RarityRare", "Eval": "=", "Min": "1", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" },
  { "#Key": "ItemClass", "Eval": "=", "Min": "Amulet", "OrFlag": "0" }
 ]
}
```

**Ring Filter**

```JSON
{
 "Affix": [
  { "#Key": "(Pseudo) Total to Maximum Life", "Eval": ">=", "Min": "50", "OrFlag": "1" },
  { "#Key": "# to maximum Mana", "Eval": ">=", "Min": "65", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Strength", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Dexterity", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Intelligence", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Energy Shield", "Eval": ">=", "Min": "32", "OrFlag": "1" },
  { "#Key": "# increased Elemental Damage with Attack Skills", "Eval": ">=", "Min": "21", "OrFlag": "1" },
  { "#Key": "(Pseudo) Add Physical Damage to Attacks_Avg", "Eval": ">=", "Min": "6", "OrFlag": "1" },
  { "#Key": "# to Accuracy Rating", "Eval": ">=", "Min": "166", "OrFlag": "1" },
  { "#Key": "# increased Cast Speed", "Eval": ">=", "Min": "5", "OrFlag": "1" },
  { "#Key": "# increased Attack Speed", "Eval": ">=", "Min": "5", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Cold Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Fire Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Lightning Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Elemental Resistance", "Eval": ">=", "Min": "80", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 2, "StashTab": "2" },
 "Prop": [
  { "#Key": "RarityRare", "Eval": "=", "Min": "1", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" },
  { "#Key": "ItemClass", "Eval": "=", "Min": "Ring", "OrFlag": "0" }
 ]
}
```

**Quiver Filter**

```JSON
{
 "Affix": [
  { "#Key": "(Pseudo) Total to Maximum Life", "Eval": ">=", "Min": "70", "OrFlag": "1" },
  { "#Key": "# to maximum Mana", "Eval": ">=", "Min": "65", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Energy Shield", "Eval": ">=", "Min": "32", "OrFlag": "1" },
  { "#Key": "# increased Elemental Damage with Attack Skills", "Eval": ">=", "Min": "31", "OrFlag": "1" },
  { "#Key": "# increased Global Critical Strike Chance", "Eval": ">=", "Min": "30", "OrFlag": "1" },
  { "#Key": "# to Global Critical Strike Multiplier", "Eval": ">=", "Min": "25", "OrFlag": "1" },
  { "#Key": "(Pseudo) Add Physical Damage to Attacks_Avg", "Eval": ">=", "Min": "4", "OrFlag": "1" },
  { "#Key": "# to Accuracy Rating", "Eval": ">=", "Min": "166", "OrFlag": "1" },
  { "#Key": "# increased Attack Speed", "Eval": ">=", "Min": "8", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Cold Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Fire Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Lightning Resistance", "Eval": ">=", "Min": "36", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Elemental Resistance", "Eval": ">=", "Min": "80", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 2, "StashTab": "2" },
 "Prop": [
  { "#Key": "RarityRare", "Eval": "=", "Min": "1", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" },
  { "#Key": "ItemClass", "Eval": "=", "Min": "Quiver", "OrFlag": "0" }
 ]
}
```

**General Weapon Filter**

```JSON
{
 "Affix": [
  { "#Key": "(Pseudo) Increased Cold Damage", "Eval": ">=", "Min": "80", "OrFlag": "1" },
  { "#Key": "(Pseudo) Increased Fire Damage", "Eval": ">=", "Min": "80", "OrFlag": "1" },
  { "#Key": "(Pseudo) Increased Lightning Damage", "Eval": ">=", "Min": "80", "OrFlag": "1" },
  { "#Key": "# increased Spell Damage", "Eval": ">=", "Min": "65", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total Elemental Damage to Spells_Avg", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "# to maximum Mana", "Eval": ">=", "Min": "120", "OrFlag": "1" },
  { "#Key": "# to Level of all Physical Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Fire Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Cold Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Lightning Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Chaos Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "Gain # of Fire Damage as Extra Chaos Damage", "Eval": ">=", "Min": "11", "OrFlag": "1" },
  { "#Key": "Gain # of Cold Damage as Extra Chaos Damage", "Eval": ">=", "Min": "11", "OrFlag": "1" },
  { "#Key": "Gain # of Physical Damage as Extra Chaos Damage", "Eval": ">=", "Min": "11", "OrFlag": "1" },
  { "#Key": "Gain # of Lightning Damage as Extra Chaos Damage", "Eval": ">=", "Min": "11", "OrFlag": "1" },
  { "#Key": "# to Fire Damage over Time Multiplier", "Eval": ">=", "Min": "24", "OrFlag": "1" },
  { "#Key": "# to Chaos Damage over Time Multiplier", "Eval": ">=", "Min": "24", "OrFlag": "1" },
  { "#Key": "# to Cold Damage over Time Multiplier", "Eval": ">=", "Min": "24", "OrFlag": "1" },
  { "#Key": "# increased Critical Strike Chance for Spells", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "# to Global Critical Strike Multiplier", "Eval": ">=", "Min": "25", "OrFlag": "1" },
  { "#Key": "# increased Cast Speed", "Eval": ">=", "Min": "17", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 2, "StashTab": "2" },
 "Prop": [
  { "#Key": "RarityRare", "Eval": "=", "Min": "1", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" },
  { "#Key": "IsWeapon", "Eval": "=", "Min": "1", "OrFlag": "0" }
 ]
}
```

**Physical Weapon Filter**

```JSON
{
 "Affix": [
  { "#Key": "# increased Physical Damage", "Eval": ">=", "Min": "135", "OrFlag": "1" },
  { "#Key": "(Pseudo) Add Physical Damage to Attacks_Avg", "Eval": ">=", "Min": "21", "OrFlag": "1" },
  { "#Key": "# to Global Critical Strike Multiplier", "Eval": ">=", "Min": "25", "OrFlag": "1" },
  { "#Key": "# increased Attack Speed", "Eval": ">=", "Min": "20", "OrFlag": "1" },
  { "#Key": "# increased Critical Strike Chance", "Eval": ">=", "Min": "25", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 2, "StashTab": "2" },
 "Prop": [
  { "#Key": "RarityRare", "Eval": "=", "Min": "1", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" },
  { "#Key": "IsWeapon", "Eval": "=", "Min": "1", "OrFlag": "0" }
 ]
}
```

**Elemental Weapon Filter**

```JSON
{
 "Affix": [
  { "#Key": "(Pseudo) Total Elemental Damage to Attacks_Avg", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "(Pseudo) Add Physical Damage to Attacks_Avg", "Eval": ">=", "Min": "21", "OrFlag": "1" },
  { "#Key": "# to Global Critical Strike Multiplier", "Eval": ">=", "Min": "25", "OrFlag": "1" },
  { "#Key": "# increased Attack Speed", "Eval": ">=", "Min": "20", "OrFlag": "1" },
  { "#Key": "# increased Critical Strike Chance", "Eval": ">=", "Min": "25", "OrFlag": "1" },
  { "#Key": "# increased Elemental Damage with Attack Skills", "Eval": ">=", "Min": "37", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 2, "StashTab": "2" },
 "Prop": [
  { "#Key": "RarityRare", "Eval": "=", "Min": "1", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" },
  { "#Key": "IsWeapon", "Eval": "=", "Min": "1", "OrFlag": "0" }
 ]
}
```

**Jewel Filter**

```JSON
{
 "Affix": [
  { "#Key": "# increased maximum Life", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# increased maximum Energy Shield", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to maximum Life", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to maximum Energy Shield", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "Players have a # chance to gain Onslaught on Kill For 4 seconds", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# chance to gain Phasing for 4 seconds on Kill", "Eval": ">=", "Min": "1", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 1, "StashTab": "2" },
 "Prop": [
  { "#Key": "ItemClass", "Eval": "~", "Min": "Jewel", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" }
 ]
}
```
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