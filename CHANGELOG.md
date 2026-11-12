# Changelog

All notable changes to Memory Forever. Releases follow [semver](https://semver.org/). The original Memory addon's history is in the `upstream-1.6.0` tag and earlier tags.

## [2.0.0-alpha.1] - unreleased

First Memory Forever release: a port of Memory 1.6.0 by Adriano Castro to WoW: Forever. Not yet verified in the live client.

### Changed
- Renamed to **Memory Forever**. The folder is `MemoryForever`, the slash command is `/mem` (or `/memoryforever`) and the SavedVariable is `MemoryForeverDB`.
- Targets WoW: Forever only (`MemoryForever_Camelot.toc`, `## Interface: 16001`).
- Removed the Stormwind Library dependency. Its client detection treats Forever as Classic Era, and it hooks tooltip scripts that don't exist on the modern engine.
- Fights are recorded from target and focus during combat. The combat log is closed to addons.
- NPC interactions use the `npc` unit instead of matching frame titles.
- Tooltips use `TooltipDataProcessor`, and the unit is read from the tooltip.
- Loot is read from chat in the open world and from the loot window plus bag counts in instances.
- Group members are read out of combat only.
- Sentences say "yesterday" and "3 days ago" instead of "3 day(s) ago".

### Added
- A secret-value guard (`Safe`). Hidden unit and chat data skips a memory instead of raising Lua errors.
- Memory types are gated on the client's APIs and events and disabled quietly when something is missing (`/mem status`).
- Quest turn-in memories. Fixes the upstream known issue that quest NPCs weren't recorded.
- Per-place death counts.
- Return pop-ups ("You've been here 7 times... You died here 2 times") and repeat-death pop-ups, with throttling.
- Reminder style setting: chat (default), pop-up, both or off.
- Journal window with Zones, NPCs, Items, Players, Deaths, Levels, Moments, Here and Stats, plus search and sort.
- `/mem here` (per-place timeline) and `/mem stats`.
- Options panel under Options > AddOns, a minimap button and an AddOns compartment entry.
- `schemaVersion` with migrations, defensive SavedVariables init, and a one-time import of the original Memory data.
- A stubbed-client test suite under Lua 5.1, plus CI.

### Fixed (upstream bugs)
- Zone-level visits were never stored (`not zoneName == lastZone` was always false).
- Reading a memory created empty records as a side effect.
- Day differences could be fractional across DST changes.
- Localized loot strings with magic characters failed to match.
- Some helper variables leaked as globals.
