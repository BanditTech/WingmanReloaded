## Using the Custom Loot Filter (CLF)

> Items are evaluated and given variables, which you can use to determine where they should end up in the stash  
> We will be referring to the selected affix or property as the "Selection Key" or "Key"  
> This is the Variable which you are evaluating against using the selected Evaluation type, and Minimum value

Using the CLF has become much easier to find the desired affix or property, press TAB while the Selected Key is active to search through the list.  
Press Enter to fill the Selected Key with the search result.

Assign the number of required OR matches, then check the OR box on all the affixes which you would like to become conditional on that count.

> I would suggest using the script's Item Info hotkey to learn which Properties and Affixes to look for on the item. 

> It is also possible to parse items from the clipboard as well, which you can get from trade websites. Simply copy the item clipboard contents, then press the item info hotkey while NOT hovering over any item. You should now see a readout of the parse from the item you copied.

### Getting Started
These examples will show both basic functionality as well as advanced usage of the CLF. Follow along with the descriptive text to learn more about how to use the CLF basic functionality.

> Import these examples to the CLF to use, and then edit them for your own personal taste.  
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

### Helmet Filter

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

### Boots Filter

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
  { "#Key": "#% increased Movement Speed", "Eval": ">=", "Min": "25", "OrFlag": "1" },
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

### Body Armour Filter

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

### Gloves Filter

```JSON
{
 "Affix": [
  { "#Key": "# to maximum Mana", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Life", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Strength", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Dexterity", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Intelligence", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "# to Accuracy Rating", "Eval": ">=", "Min": "251", "OrFlag": "1" },
  { "#Key": "#% increased Attack Speed", "Eval": ">=", "Min": "14", "OrFlag": "1" },
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

### Shield Filter

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
  { "#Key": "#% increased Spell Damage", "Eval": ">=", "Min": "65", "OrFlag": "1" },
  { "#Key": "# to Level of all Fire Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Cold Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Lightning Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Chaos Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "#% increased Critical Strike Chance for Spells", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "#% Chance to Block Spell Damage", "Eval": ">=", "Min": "10", "OrFlag": "1" },
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

### Belt Filter

```JSON
{
 "Affix": [
  { "#Key": "(Pseudo) Total to Maximum Life", "Eval": ">=", "Min": "70", "OrFlag": "1" },
  { "#Key": "# to maximum Mana", "Eval": ">=", "Min": "55", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Strength", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Dexterity", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Intelligence", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Energy Shield", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "#% increased Elemental Damage with Attack Skills", "Eval": ">=", "Min": "31", "OrFlag": "1" },
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

### Amulet Filter

```JSON
{
 "Affix": [
  { "#Key": "(Pseudo) Total to Maximum Life", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "# to maximum Mana", "Eval": ">=", "Min": "66", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Strength", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Dexterity", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Intelligence", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Energy Shield", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "#% increased Elemental Damage with Attack Skills", "Eval": ">=", "Min": "31", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total Increased Energy Shield", "Eval": ">=", "Min": "14", "OrFlag": "1" },
  { "#Key": "(Pseudo) Add Physical Damage to Attacks_Avg", "Eval": ">=", "Min": "11", "OrFlag": "1" },
  { "#Key": "#% to Global Critical Strike Multiplier", "Eval": ">=", "Min": "25", "OrFlag": "1" },
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

### Ring Filter

```JSON
{
 "Affix": [
  { "#Key": "(Pseudo) Total to Maximum Life", "Eval": ">=", "Min": "50", "OrFlag": "1" },
  { "#Key": "# to maximum Mana", "Eval": ">=", "Min": "65", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Strength", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Dexterity", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Intelligence", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Energy Shield", "Eval": ">=", "Min": "32", "OrFlag": "1" },
  { "#Key": "#% increased Elemental Damage with Attack Skills", "Eval": ">=", "Min": "21", "OrFlag": "1" },
  { "#Key": "(Pseudo) Add Physical Damage to Attacks_Avg", "Eval": ">=", "Min": "6", "OrFlag": "1" },
  { "#Key": "# to Accuracy Rating", "Eval": ">=", "Min": "166", "OrFlag": "1" },
  { "#Key": "#% increased Cast Speed", "Eval": ">=", "Min": "5", "OrFlag": "1" },
  { "#Key": "#% increased Attack Speed", "Eval": ">=", "Min": "5", "OrFlag": "1" },
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

### Quiver Filter

```JSON
{
 "Affix": [
  { "#Key": "(Pseudo) Total to Maximum Life", "Eval": ">=", "Min": "70", "OrFlag": "1" },
  { "#Key": "# to maximum Mana", "Eval": ">=", "Min": "65", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total to Maximum Energy Shield", "Eval": ">=", "Min": "32", "OrFlag": "1" },
  { "#Key": "#% increased Elemental Damage with Attack Skills", "Eval": ">=", "Min": "31", "OrFlag": "1" },
  { "#Key": "#% increased Global Critical Strike Chance", "Eval": ">=", "Min": "30", "OrFlag": "1" },
  { "#Key": "#% to Global Critical Strike Multiplier", "Eval": ">=", "Min": "25", "OrFlag": "1" },
  { "#Key": "(Pseudo) Add Physical Damage to Attacks_Avg", "Eval": ">=", "Min": "4", "OrFlag": "1" },
  { "#Key": "# to Accuracy Rating", "Eval": ">=", "Min": "166", "OrFlag": "1" },
  { "#Key": "#% increased Attack Speed", "Eval": ">=", "Min": "8", "OrFlag": "1" },
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

### General Weapon Filter

```JSON
{
 "Affix": [
  { "#Key": "(Pseudo) Increased Cold Damage", "Eval": ">=", "Min": "80", "OrFlag": "1" },
  { "#Key": "(Pseudo) Increased Fire Damage", "Eval": ">=", "Min": "80", "OrFlag": "1" },
  { "#Key": "(Pseudo) Increased Lightning Damage", "Eval": ">=", "Min": "80", "OrFlag": "1" },
  { "#Key": "#% increased Spell Damage", "Eval": ">=", "Min": "65", "OrFlag": "1" },
  { "#Key": "(Pseudo) Total Elemental Damage to Spells_Avg", "Eval": ">=", "Min": "38", "OrFlag": "1" },
  { "#Key": "# to maximum Mana", "Eval": ">=", "Min": "120", "OrFlag": "1" },
  { "#Key": "# to Level of all Physical Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Fire Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Cold Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Lightning Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Chaos Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to Level of all Spell Skill Gems", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "Gain #% of Fire Damage as Extra Chaos Damage", "Eval": ">=", "Min": "11", "OrFlag": "1" },
  { "#Key": "Gain #% of Cold Damage as Extra Chaos Damage", "Eval": ">=", "Min": "11", "OrFlag": "1" },
  { "#Key": "Gain #% of Physical Damage as Extra Chaos Damage", "Eval": ">=", "Min": "11", "OrFlag": "1" },
  { "#Key": "Gain #% of Lightning Damage as Extra Chaos Damage", "Eval": ">=", "Min": "11", "OrFlag": "1" },
  { "#Key": "#% to Fire Damage over Time Multiplier", "Eval": ">=", "Min": "24", "OrFlag": "1" },
  { "#Key": "#% to Chaos Damage over Time Multiplier", "Eval": ">=", "Min": "24", "OrFlag": "1" },
  { "#Key": "#% to Cold Damage over Time Multiplier", "Eval": ">=", "Min": "24", "OrFlag": "1" },
  { "#Key": "#% increased Critical Strike Chance for Spells", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "#% to Global Critical Strike Multiplier", "Eval": ">=", "Min": "25", "OrFlag": "1" },
  { "#Key": "#% increased Cast Speed", "Eval": ">=", "Min": "17", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 2, "StashTab": "2" },
 "Prop": [
  { "#Key": "RarityRare", "Eval": "=", "Min": "1", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" },
  { "#Key": "IsWeapon", "Eval": "=", "Min": "1", "OrFlag": "0" }
 ]
}
```

### Physical Weapon Filter

```JSON
{
 "Affix": [
  { "#Key": "#% increased Physical Damage", "Eval": ">=", "Min": "135", "OrFlag": "1" },
  { "#Key": "(Pseudo) Add Physical Damage to Attacks_Avg", "Eval": ">=", "Min": "21", "OrFlag": "1" },
  { "#Key": "#% to Global Critical Strike Multiplier", "Eval": ">=", "Min": "25", "OrFlag": "1" },
  { "#Key": "#% increased Attack Speed", "Eval": ">=", "Min": "20", "OrFlag": "1" },
  { "#Key": "#% increased Critical Strike Chance", "Eval": ">=", "Min": "25", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 2, "StashTab": "2" },
 "Prop": [
  { "#Key": "RarityRare", "Eval": "=", "Min": "1", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" },
  { "#Key": "IsWeapon", "Eval": "=", "Min": "1", "OrFlag": "0" }
 ]
}
```

### Elemental Weapon Filter

```JSON
{
 "Affix": [
  { "#Key": "(Pseudo) Total Elemental Damage to Attacks_Avg", "Eval": ">=", "Min": "60", "OrFlag": "1" },
  { "#Key": "(Pseudo) Add Physical Damage to Attacks_Avg", "Eval": ">=", "Min": "21", "OrFlag": "1" },
  { "#Key": "#% to Global Critical Strike Multiplier", "Eval": ">=", "Min": "25", "OrFlag": "1" },
  { "#Key": "#% increased Attack Speed", "Eval": ">=", "Min": "20", "OrFlag": "1" },
  { "#Key": "#% increased Critical Strike Chance", "Eval": ">=", "Min": "25", "OrFlag": "1" },
  { "#Key": "#% increased Elemental Damage with Attack Skills", "Eval": ">=", "Min": "37", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 2, "StashTab": "2" },
 "Prop": [
  { "#Key": "RarityRare", "Eval": "=", "Min": "1", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" },
  { "#Key": "IsWeapon", "Eval": "=", "Min": "1", "OrFlag": "0" }
 ]
}
```

### Jewel Filter

```JSON
{
 "Affix": [
  { "#Key": "#% increased maximum Life", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "#% increased maximum Energy Shield", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to maximum Life", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "# to maximum Energy Shield", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "Players have a #% Chance to gain Onslaught on Kill For 4 seconds", "Eval": ">=", "Min": "1", "OrFlag": "1" },
  { "#Key": "#% Chance to gain Phasing for 4 seconds on Kill", "Eval": ">=", "Min": "1", "OrFlag": "1" }
 ],
 "Data": { "OrCount": 1, "StashTab": "2" },
 "Prop": [
  { "#Key": "ItemClass", "Eval": "~", "Min": "Jewel", "OrFlag": "0" },
  { "#Key": "Veiled", "Eval": "=", "Min": "0", "OrFlag": "0" }
 ]
}
```