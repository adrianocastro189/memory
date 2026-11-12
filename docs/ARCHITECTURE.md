# Architecture

This document has two parts:

1. **Upstream Memory 1.6.0**: what the original addon looked like (tag `upstream-1.6.0`), why it can't run on WoW: Forever, and corrections to the assumptions in the porting handoff.
2. **Memory Forever 2.0**: how the port is built.

---

## 1. Upstream Memory 1.6.0

### File map (upstream)

| File | Lines | Role |
|---|---|---|
| `Memory.toc`, `Memory-Classic.toc`, `Memory-Cata.toc` | | Retail (`110002`), Classic Era (`11503`), Cata Classic (`40400`) |
| `lib/stormwind-library.lua` | 5006 | Vendored Stormwind Library **v1.12.2** (`StormwindLibrary_v1_12_2`) |
| `Memory.lua` | 342 | Creates `MemoryCore` (a library instance, slash `/memoryaddon`); on `PLAYER_LOGIN` builds singletons, an event frame and the listeners |
| `includes/commands/*.lua` | ~80 | `addm`, `getm`, `get`, `set`, registered with the library's command system |
| `includes/core/ScreenshotController.lua` | 56 | `RaidNotice_AddMessage` + `Screenshot()` |
| `includes/core/TooltipController.lua` | 213 | Listens to the library's `TOOLTIP_UNIT_SHOWN` / `TOOLTIP_ITEM_SHOWN`; reads the unit from `'mouseover'` |
| `includes/domain/AbstractMemory.lua`, `LevelMemory.lua`, `AchievementMemory.lua` | ~220 | Library-class hierarchy for level and achievement memories |
| `includes/domain/Memory.lua`, `MemoryString.lua` | ~680 | Memory value object and the `date\|level\|zone\|subzone\|moment` string |
| `includes/domain/Player.lua` | 213 | Unit wrapper (GUID → npc/player type, full name) |
| `includes/events/MemoryEvent.lua`, `MemoryEvents.lua` | ~570 | One `MemoryEvent` prototype instantiated 6 times (business, talk, fight, party, zone, loot, death) |
| `includes/helpers/*.lua` | ~660 | Array, compatibility (gossip titles, group names, loot parsing, `wait`), date, logger, string |
| `includes/repository/*.lua` | ~540 | Memory, moment and settings repositories |
| `includes/view/MemoryTextFormatter.lua` | 499 | Sentence builder |
| `tests/` | ~1900 | **luaunit** tests that load the library and the addon with WoW mocks |

### Corrections to the handoff's "Known architecture"

| Handoff said | Actually |
|---|---|
| `MemoryEvent` subclasses | There are no subclasses. `MemoryEvents.lua` instantiates the one `MemoryEvent` prototype six times, plus one more for deaths, and overrides `buildMemoryTextFormatter` per instance. Level and achievement memories use the library's `events:listen` instead. |
| `MemoryTextFormatter` is a class | It's a prototype injected into core (`MemoryCore:newMemoryTextFormatter()`), not a library class. |
| Players keyed by full name, not GUID | The **own character is keyed by GUID**: `MemoryAddon_DataSet[realm][UnitGUID('player')]`. *Other* players are keyed by `Name-Realm`, and NPCs and items by name. |
| `printChance` default about 10% | The code default is **0.2 (20%)**. `screenshotChance` defaults to `-1` (off). |
| Unit tests use a `TestCase` structure | Yes, on top of **luaunit**, and they depend on the library's test mode (`output:setTestingMode`, `events:notify`). |
| `AchievementMemory` stores achievements | `AchievementMemory:save()` is a **no-op**. Achievements only trigger a screenshot. |

### Why upstream can't run on Forever

1. **No Forever TOC.** The client falls back to `Memory.toc` (`110002`), which is flagged out of date.
2. **Stormwind Library misdetects the client.** `Environment:getClientFlavor()` maps any TOC version below 20000 to Classic Era, so Forever's `16001` counts as Classic Era. At file load the library then calls `GameTooltip:HookScript('OnTooltipSetItem')`. That script doesn't exist on the modern engine, so the hook **errors during load**.
3. **Combat log.** `EventNpcFight` registers `COMBAT_LOG_EVENT_UNFILTERED` and calls `CombatLogGetCurrentEventInfo()`. Both are closed to addons on the Midnight engine.
4. `ACHIEVEMENT_EARNED` is registered unconditionally. On a client without that event, `RegisterEvent` raises.
5. Gossip and quest name checks read the `GossipFrameNpcNameText` and `QuestFrameNpcNameText` globals, which no longer exist. As a result talk and quest memories silently fail. This is also the cause of the upstream "quest NPCs are not recorded" issue.

### Upstream bugs found while reading

- **Zone-level visits were never stored.** `if not zoneName == listener.lastZone` parses as `(not zoneName) == lastZone`, which is always false. Only subzones were recorded.
- `MemoryRepository:get()` creates empty path nodes (`x = 0`, `first = -1`) as a side effect, so the data grows with phantom entries.
- `listMemories` iterated non-leaf keys (the `subzones` table), as noted in the TODO.
- `getDaysDiff` returned fractional days across DST changes, producing output like "0.958 day(s) ago".
- Loot patterns were built with `gsub('%%s', '(.+)')` without escaping magic characters, which breaks some localized strings.
- The `OnEvent` dispatcher stopped copying event arguments at the first `nil`, so `CHAT_MSG_LOOT`'s GUID (argument 12) could shift.
- The compatibility helper leaked the globals `currentMember`, `itemLink` and `quantity`.
- `RaidNotice_AddMessage` was given colors as 0-255 instead of 0-1.

### Upstream SavedVariables

```
MemoryAddon_DataSet[realm][playerGUID] = {
  misc    = { login = leaf, others = { die = leaf } },
  npcs    = { [name] = { talk|business|fight = leaf } },
  players = { ['Name-Realm'] = { party = leaf } },
  zones   = { [zone] = { subzones = { [subzone] = { visit = leaf } } } },
  items   = { [name] = { loot = leaf } },
  levels  = { [level] = { date, zone, subZone, moment } },
}
leaf = { first = 'yy-mm-dd|level|zone|subzone|momentIndex' or -1, last = ..., x = count }
MemoryAddon_Settings = { moments = { ... }, ['memory.printChance'] = '0.2', ... }
```

---

## 2. Memory Forever 2.0

### Decisions

- **Stormwind Library was removed (Option B).** The addon used only a small part of it: the class system, three events, slash parsing and a few string, array and bool helpers. Its client detection breaks on Forever, as described above. It's replaced by about 100 lines across `Core/Events.lua`, `Commands.lua` and `Core/Util.lua`.
- **Forever only.** `MemoryForever_Camelot.toc` (`## Interface: 16001`), plus `MemoryForever.toc` with the same content as a fallback in case a client doesn't recognize the `_Camelot` suffix. No Retail or Classic TOCs ship.
- **Same data model.** The memory leaves and the memory-string format are unchanged, so the original addon's data imports by copying.
- Everything lives in the private addon namespace (`local ADDON, ns = ...`). The only globals are the SavedVariables, `SLASH_MEMORYFOREVER1/2`, `MemoryForever_OnAddonCompartmentClick` and the named frames. A test enforces this.

### File map

| Path | Responsibility |
|---|---|
| `Core/Namespace.lua` | `ns`, version, `ns.print`, `ns.highlight`, `ns.debug` |
| `Core/Safe.lua` | **Secret-value guard.** `Safe.call`/`Safe.api` run protected and turn secret values into `nil`. It also provides unit helpers and GUID classification. |
| `Core/Util.lua` | Split/trim, ordinal, plural, dates (`yy-mm-dd`), localized format→pattern, item link parsing |
| `Core/Events.lua` | Private event bus. Registration is gated (unknown or forbidden events return `false`), each handler runs in `pcall` and reports through `geterrorhandler()`, and `Events.after` wraps `C_Timer.After`. |
| `Data/Settings.lua` | Typed settings with defaults and coercion. Accepts the original `memory.*` keys. |
| `Data/DB.lua` | `MemoryForeverDB` init: defensive repair, `schemaVersion`, migrations, legacy import |
| `Data/Moments.lua` | Moment labels |
| `Data/MemoryString.lua` | Parse, capture and serialize the first/last snapshot |
| `Data/Memory.lua` | Read-only memory value object |
| `Data/Repository.lua` | Per-character storage: `bind`, `get` (no side effects), `store`, `list`, `walk`, levels |
| `View/Formatter.lua` | Reminder sentences, ported from `MemoryTextFormatter` |
| `View/Toast.lua` | Pop-up frame |
| `View/Reminders.lua` | `ns.record(spec)` stores a memory and then runs the reminder logic: random chat or toast, random screenshot, and the place pop-ups for returns and repeat deaths, with throttling |
| `View/Tooltip.lua` | `TooltipDataProcessor` post-calls for units and items |
| `Trackers/Trackers.lua` | Tracker registry with API and event requirements, shown in `/mem status` |
| `Trackers/*.lua` | Zones, deaths, levels, achievements, NPCs, fights, loot, group |
| `UI/Queries.lua` | Journal lists, filters and sorts, per-place timeline, stats. No UI code, so it's testable. |
| `UI/Journal.lua`, `UI/Minimap.lua`, `UI/Options.lua` | Journal window, minimap button and compartment entry, Settings-API panel |
| `Commands.lua` | `/mem`, `/memoryforever` |
| `Init.lua` | `ADDON_LOADED` → DB init; `PLAYER_LOGIN` → bind the character, enable trackers, tooltips and UI |

### Data flow

```
game event ──► Events (pcall per handler)
                 └─► Tracker handler
                       ├─ reads game data only through Safe (secret → nil → skip)
                       └─► ns.record{category, path, interaction, verbs, x}
                             ├─ Repository.get (memory before)
                             ├─ Repository.store (first/last/x, MemoryString.capture)
                             └─ Reminders.afterStore (printChance → chat/toast, screenshotChance)
Zones/Deaths additionally call Reminders.placeReturn / placeDeath (place pop-ups)
```

### SavedVariables (schema 2)

```
MemoryForeverDB = {
  schemaVersion = 2,
  settings = { printChance = 0.2, reminderStyle = 'chat', placeToasts = true, ... },
  moments  = { 'label', ... },
  realms   = { [realm] = { [playerGUID] = {
    meta    = { name, class },
    misc    = { login = leaf, others = { die = leaf }, achievements = { [name] = { earn = leaf } } },
    npcs    = { [name] = { talk|business|fight|quest = leaf } },
    players = { ['Name-Realm'] = { party = leaf } },
    zones   = { [zone] = { visit = leaf, subzones = { [subzone] = { visit = leaf } } } },
    items   = { [name] = { loot = leaf } },
    deaths  = { [zone] = { [subzone or zone] = { die = leaf } } },
    levels  = { [level] = { date, zone, subZone, moment } },
  } } },
}
```

`MemoryAddon_DataSet` and `MemoryAddon_Settings` are also declared in the TOC. They are empty unless the user copies the original addon's SavedVariables file (see README). The 0/1 → 2 migration imports them into an empty database and then clears them.

Migrations live in `DB.MIGRATIONS[targetVersion]`. A database written by a newer schema is left untouched.

### Tests

`tests/lib/wow.lua` is a stubbed Forever client. It provides a sandboxed global environment without `io` or `os`, frames, events, timers, the Settings API, `TooltipDataProcessor` and a simulated secret value. It also simulates the Midnight restrictions: registering the combat log raises, unknown events raise, and `ctl.restricted` makes every non-player unit read secret. The harness loads the addon **through `MemoryForever_Camelot.toc`** under real Lua 5.1, then round-trips SavedVariables through a serializer that rejects anything the client couldn't save.

Run with `python tests/run.py` (needs `pip install -r requirements-dev.txt`) or `lua5.1 tests/run.lua`.
