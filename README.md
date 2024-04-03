# Memory

A World of Warcraft addon to register memories while players do stuff around the world.

## Installation

No setup is required! **Just install the addon and play the game!** While you play, it will record memories about **players** you party with, **items** you loot, **zones** and **subzones** you visit and **NPCs** you fight, talk, turn quests, buy, sell and repair.

For each memory stored, it will have a small chance to print that memory in your chat frame, just like something you remember in real life!

Feel free to increase the print chance rate using a slash command described below or just have fun with the game and let the addon decide when it's the best time to bring a memory to you!

## Slash commands

The following slash commands let you customize the addon experience.

### Associating memories with moments

**Moments** can be anything happening while you play. They can refer to a moment in real life you're having while you play or even related to your current gameplay story. The current moment will be shared accross all your characters in this first version of this feature. In other words, you can't set a current moment for each character (yet).

Example: Let's say you're moving to another city in real life and you want to associate all of your player memories with this moment, then all you have to do is:

```
/memoryaddon addm "playing in a motel while my apartment is ready for us to move"
```

That way, after you add another moment, all the memories collected in the last moments will be appended to the chat frame like: _The first time I looted a Linen Cloth was 41 days ago \~playing in a motel while my apartment is ready for us to move\~_.

Make sure to wrap the moment in `""` or `''` so it can be recognized as a
single phrase instead of multiple words.

**⚠️ Important note:** There's a known issue with the `addm` command in
case it contains quotation characters (" or ') inside the moment besides
the ones wrapping it. This is due to the way the command is parsed and the
current limitations of the parser. This is is already being addressed for
future releases. That said:

* ✅ `/memoryaddon addm "This is a moment"` will work as expected
* ❌ `/memoryaddon addm "The time they didn't expect to come"` won't work
* ❌ `/memoryaddon addm 'The "serendipity" of life often surprises us'` won't work

To print the current moment, simply run:

```
/memoryaddon getm
```

### Setting the memory print chance

Every time a memory is stored, it has a chance to be printed to the chat window. In other words,
this is the chance your character will remember something!

The following command changes the print chance to 50% (`0.5`). Replace this number with
any decimal between `0` - to turn off memory printing - and `1` (inclusive) to print every memory.

```
/memoryaddon set memory.printChance 0.5
```

### Setting up the memory screenshot chance

Memory screenshots are disable by default and are part of the addon's 1.2.0 release. You can enable the screenshot chance with a setting called `memory.screenshotChance` which accepts any decimal between `0` - to turn off memory screenshots - and `1` (inclusive) to take screenshots for every memory.

It's advised to use a small chance like `0.025` to avoid taking multiple screenshots in a row and also to save some space given that every screenshot is stored as a new file under your World of Warcraft installation folder.

```
/memoryaddon set memory.screenshotChance 0.025
```

## Retail support

Although the addon interface version is defined to follow Retail's version, Memory is currently tested on Classic. If you find bugs while playing it on Retail, please post them on our [issues section](https://github.com/adrianocastro189/memory/issues).

## Changelog

### yyyy.mm.dd - version 1.2.4
* Tweak - The `/memoryaddon add moment` command was replaced by `/memoryaddon addm`
* Tweak - The `/memoryaddon get moment` command was replaced by `/memoryaddon getm`
* Dev - Add unit testing support
* Dev - Use the Stormwind Library event system to initialize core

### 2024.02.24 - version 1.2.3
* Dev - Import Stormwind Library, preparing the field for it to be used in the future

### 2024.02.04 - version 1.2.2
* Feature - Add the `/memoryaddon get moment` command

### 2024.02.04 - version 1.2.1
* Fix - Update the build version so it gets compatible with SoD

### 2021.06.13 - version 1.2.0
* Feature - Memories can take screenshots
* Fix - Addon support to Retail updated (thanks to @tflo for the GitHub issue post)
* Dev - Add a helper method to mimic functions like PHP's `sleep`

### 2021.05.16 - version 1.1.1
* Tweak - Memories printed to chat now may also show the location and level you were on when you got it
* Tweak - Tooltips now show the player level for their first and last memories

### 2021.03.20 - version 1.1.0
* Feature - Memories can be associated with **moments**
* Feature - Memories now are also shown in NPC, player and item tooltips
* Tweak - The _Invalid loot item msg_ is now a debug message instead of a warning

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

* The mouse over the target's frame won't show memories on the tooltip
