# WingmanReloaded

This is the continuation of the PoE-Wingman script, my personally modified version released to the public.

As of now, the script is in active development, and setup is not as easy as the original. Find more information in the [**Installation Section**](/#?id=installation).


# What is it?

> This multi functional script can perform several actions based on states of the game:

    Potions
    Abilities
    Auto-Quit
    Mines
    Loot Vacuum
    Custom Loot Filter
    Manage Inventory (ID,Vendor,Stash,Divination)
    Automate going from Stash to vendor
    Skill-up Gems
    Cast Portal-Scroll
    Swap Gems
    Price information
    Pixel Information
    Game Controller support
    Chat Hotkeys
    Auto-Fill Metamorph panel

> Some functions may not work if you are using a non 1080 height resolution monitor, then you will need to input your own captures to get them working. I have made it so that anyone can add their own custom strings in to replace the default ones, so all hope is not lost if you really want to get those functions working. Find more information on the Strings tab docs, and I am always happy to add any submitted samples to the default dropdown lists.


## Flasks
> The script can automatically cast Flasks based on several triggers: 

    Life percentage
    ES Percentage
    Mana Percentage
    As Quicksilver
    With Primary or Secondary attack keys
    All flasks as one Hotkey

> Mana and Quicksilver flasks will wait on cooldown as a group

> Quicksilver Flasks trigger with an optional delay
>
> Quicksilver uses LButton default, and optionaly primary or secondary attack


## Utility spells
> Utilities allow for several triggers for abilities as well:

    On Cooldown
    Buff Icon showing/not
    With Quicksilver
    With Primary or Secondary attack keys
    Life percentage
    ES Percentage
    Mana Percentage


## Inventory Management
> One button can do so many things! The script detects which panels are active, so it knows what inventory routine to run when pressing the hotkey. 

    It can be pressed while you are elsewhere and no panels are open, then it will quickly open the inventory.
    If in a location with a stash, it can optionally search for a stash to open if no panels are open.
    If Inventory alone is open, it can go through your items and identify any needed.
    If Stash and Inventory is open, then it can send items to assigned stash tabs
        Supports Custom Loot Filter, currency, crafting, special item types, gems, maps, uniques + rings, and much more
    


## Stack Release
> Stack Release tool for abilities like Blade Flurry


## Auto-Detonate Mines
> Detonate mines with adjustable delay for stacking up mines between detonates. Also allows for pausing detonate so you can stack up for a boss by double tapping detonate key.


# How does it work?

> It gathers all information without reading from the games memory, so it is a bit safer from a detection standpoint. Primarily the script is using hotkeys intercepted from the keyboard and mouse, and pixel information from the game screen. The script is using incredibly fast screen captures to analyze several areas of the screen at once. It scans an area of the health globes for Life, ES and Mana percentages, and specific pixels on the screen being a set color to determine which panels are open. It also finds the Overhead Health Bar to know when it should pause the script, this setting can be disabled.


# Documentation

See [**Documentation**](/documentation?id=main-methods) for details about each of the settings panels.

See [**PLACEHOLDER**](/PLACEHOLDER) PLACEHOLDER.


# Installation

This script is a much more complex to set up than the original.
I will try and explain each process with detail to provide a clearer instruction to follow.


```code
Lorem ipsum dolor sit amet, ex vix autem movet dictas. Lobortis mandamus dissentias sed et. Pro ut odio quodsi, at vim meis singulis voluptatibus. Cu ius nostrum electram delicatissimi. Veritus vocibus quo no. Audire nostrud praesent cu qui. Tation saperet principes vix cu, sumo praesent moderatius at eos, cum epicuri scaevola an.

His alii modo assum cu. Vis an partem doming vivendo, id sit sanctus invidunt recteque. Vel no inani interesset, ad qui deleniti cotidieque. Nam id graece possit, adhuc percipit id mel.
```

```code
Lorem ipsum dolor sit amet, ex vix autem movet dictas. Lobortis mandamus dissentias sed et. Pro ut odio quodsi, at vim meis singulis voluptatibus. Cu ius nostrum electram delicatissimi. Veritus vocibus quo no. Audire nostrud praesent cu qui. Tation saperet principes vix cu, sumo praesent moderatius at eos, cum epicuri scaevola an.

His alii modo assum cu. Vis an partem doming vivendo, id sit sanctus invidunt recteque. Vel no inani interesset, ad qui deleniti cotidieque. Nam id graece possit, adhuc percipit id mel.
```

```code
Lorem ipsum dolor sit amet, ex vix autem movet dictas. Lobortis mandamus dissentias sed et. Pro ut odio quodsi, at vim meis singulis voluptatibus. Cu ius nostrum electram delicatissimi. Veritus vocibus quo no. Audire nostrud praesent cu qui. Tation saperet principes vix cu, sumo praesent moderatius at eos, cum epicuri scaevola an.

His alii modo assum cu. Vis an partem doming vivendo, id sit sanctus invidunt recteque. Vel no inani interesset, ad qui deleniti cotidieque. Nam id graece possit, adhuc percipit id mel.
```


# Examples

In the following example

Lorem ipsum dolor sit amet, ex vix autem movet dictas. Lobortis mandamus dissentias sed et. Pro ut odio quodsi, at vim meis singulis voluptatibus. Cu ius nostrum electram delicatissimi. Veritus vocibus quo no. Audire nostrud praesent cu qui. Tation saperet principes vix cu, sumo praesent moderatius at eos, cum epicuri scaevola an.

His alii modo assum cu. Vis an partem doming vivendo, id sit sanctus invidunt recteque. Vel no inani interesset, ad qui deleniti cotidieque. Nam id graece possit, adhuc percipit id mel.

In the next example, 

Lorem ipsum dolor sit amet, ex vix autem movet dictas. Lobortis mandamus dissentias sed et. Pro ut odio quodsi, at vim meis singulis voluptatibus. Cu ius nostrum electram delicatissimi. Veritus vocibus quo no. Audire nostrud praesent cu qui. Tation saperet principes vix cu, sumo praesent moderatius at eos, cum epicuri scaevola an.

His alii modo assum cu. Vis an partem doming vivendo, id sit sanctus invidunt recteque. Vel no inani interesset, ad qui deleniti cotidieque. Nam id graece possit, adhuc percipit id mel.

For the last example, 

Lorem ipsum dolor sit amet, ex vix autem movet dictas. Lobortis mandamus dissentias sed et. Pro ut odio quodsi, at vim meis singulis voluptatibus. Cu ius nostrum electram delicatissimi. Veritus vocibus quo no. Audire nostrud praesent cu qui. Tation saperet principes vix cu, sumo praesent moderatius at eos, cum epicuri scaevola an.

His alii modo assum cu. Vis an partem doming vivendo, id sit sanctus invidunt recteque. Vel no inani interesset, ad qui deleniti cotidieque. Nam id graece possit, adhuc percipit id mel.