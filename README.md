# Memory

A World of Warcraft addon to register memories while players do stuff around the world.

## Installation

No setup is required! **Just install the addon and play the game!** While you play, it will record memories about **players** you party with, **items** you loot, **zones** and **subzones** you visit and **NPCs** you fight, talk, turn quests, buy, sell and repair.

For each memory stored, it will have a small chance to print that memory in your chat frame, just like something you remember in real life!

Feel free to increase the print chance rate using a slash command described below or just have fun with the game and let the addon decide when it's the best time to bring a memory to you!

## Slash commands

The following slash commands let you customize the addon experience.

### Setting the memory print chance

Every time a memory is stored, it has a chance to be printed to the chat window. In other words,
this is the chance your character will remember something!

The following command changes the print chance to 50% (`0.5`). Replace this number with
any decimal between `0` - to turn off memory printing - and `1` (inclusive) to print every memory.

```
/memoryaddon set memory.printChance 0.5
```

## Changelog

### yyyy.mm.dd - version 1.1.0

### 2021.01.10 - version 1.0.0
* Feature - Add a slash command to set the memory print chance
* Tweak - `SPELL_AURA_APPLIED` and `SPELL_PERIODIC_DAMAGE` were added to count as fight events
* Tweak - Only one party event per player per day is registered now
* Fix - Fix a bug when players were considered NPCs in the fight event
* Fix - Fix memory sentences being generated with double spaces
* Fix - Fix a bug on Classic that was preventing memories of looting items
* Dev - New logging/debug system
* Dev - Players are now stored with their full names, not with their GUID anymore
* Dev - Rename `MemoryDataSet` to `MemoryAddon_DataSet` to avoid conflicting with other addons

### 2020.12.12 - version 0.6.0-beta
* Feature - Friendly memory sentences
* Dev - Add a date helper instance to core
* Dev - Add a string helper instance to core
* Dev - Add the `MemoryString` prototype
* Dev - Add the first `Memory` utility methods to access `MemoryString` data
* Dev - Add the `MemoryTextFormatter` prototype

### 2020.11.25 - version 0.5.0-beta
* Feature - Saved memories have a 10% chance to be printed to the chat frame
* Dev - Add the `Memory` prototype
* Dev - Add a `get` method to `MemoryRepository`

### 2020.11.20 - version 0.4.0-alpha
* Dev - Add a debug method to `MemoryCore`
* Dev - Add a debug method to `MemoryEvent`
* Dev - Add the `addEvents` method to attach all the listeners to core
* Dev - Add the first 6 event listeners to core
* Dev - Make `MemoryRepository` a real singleton
* Dev - Prevent `MemoryEvent`s from being initialized after core's initialization
* Dev - Add an array helper instance to core
* Dev - Add a compatibility helper instance to core
* Dev - Add the `MemoryAddon_Player` prototype

### 2020.10.23 - version 0.3.0-alpha
* Dev - Add the `MemoryEvent` superclass
* Dev - Add the `eventListeners` list to core
* Dev - Add the event dispatcher in MemoryCore

### 2020.10.18 - version 0.2.0-alpha
* Dev - Add the `MemoryRepository` and its unique instance to core
* Dev - Add the check and store methods to repository
* Dev - Craft the main memory string

### 2020.10.15 - version 0.1.0-alpha
* Dev - Add the `.toc` file
* Dev - Add the `MemoryCore` object
* Dev - Print the addon number after initialization

## Known issues

* The following windows won't generate NPC memories on Retail
    * Flight Master frame
    * Transmog frame
