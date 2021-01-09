# Memory

A World of Warcraft addon to register memories while players do stuff around the world.

## Changelog

### 202n.nn.nn - version 1.0.0
* Fix - Fix a bug when players were considered NPCs in the fight event
* Fix - Fix memory sentences being generated with double spaces
* Fix - Fix a bug on Classic that was preventing memories of looting items
* Dev - New logging/debug system
* Dev - Players are now stored with their full names, not with their GUID anymore

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
