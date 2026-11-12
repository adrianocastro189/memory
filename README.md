# Memory Forever

A World of Warcraft: Forever addon that remembers what you do in the world and occasionally reminds you of it:

> *The first time I looted a **Linen Cloth** was 41 days ago*
>
> **Goldshire**: You've been here 30 times. Last visit: 3 days ago. You died here 2 times.

Memory Forever is a fork of **[Memory](https://github.com/adrianocastro189/memory)** by **Adriano Castro** ([Squareone189 on CurseForge](https://www.curseforge.com/wow/addons/memory)), ported to WoW: Forever and modernized. Development of the original paused in November 2024. All credit for the original idea and design goes to Adriano. If you enjoy this addon, consider [supporting the original author](https://github.com/sponsors/adrianocastro189).

> **Status: 2.0.0-alpha.1.** Fully tested against a stubbed Forever client, **not yet verified in the live game**. Please report Lua errors (BugSack output) in the issues.

## What it remembers

For each of these it stores how many times it happened and the first and last time, with date, level, location and moment:

| | |
|---|---|
| **Places** | Every zone and subzone you enter. Returning within 5 minutes doesn't count twice. |
| **Deaths** | How often you died, and where |
| **Levels** | When and where you reached each level, with a screenshot |
| **NPCs** | Talking, doing business (buy, sell, repair), turning in quests, and fights |
| **Items** | Everything you loot |
| **Players** | Who you grouped with, counted once per day |
| **Achievements** | A screenshot and a count, if the client has achievements |

When a memory is stored there's a chance (20% by default) that you get reminded of it in chat, in a pop-up, or both. When you return to a place you've been before, or die somewhere you died before, a pop-up tells you. The same place won't pop up again for 30 minutes.

Memories also show in NPC, player and item tooltips.

## Commands

| Command | |
|---|---|
| `/mem` | Open the journal: Zones, NPCs, Items, Players, Deaths, Levels, Moments, Here, Stats |
| `/mem here` | Everything that happened in this place |
| `/mem stats` | Deaths, places discovered, most visited place, most deaths, most grouped with... |
| `/mem moment "Leveling with Sam"` | Start a new moment (alias: `addm`) |
| `/mem moment` | Show the current moment (alias: `getm`) |
| `/mem options` | Options panel (also under Options > AddOns) |
| `/mem settings` | List all settings |
| `/mem set <key> <value>` / `/mem get <key>` | Change or read a setting |
| `/mem status` | Version and which memory types are active on this client |
| `/mem toast` | Show a sample pop-up |

`/memoryforever` works as well. The minimap button opens the journal on left-click and the options on right-click, and you can drag it to move it.

### Moments

A moment is a label that gets attached to every memory you record while it's the current one. It could be something in real life ("playing in a motel while the apartment is ready") or something in the game ("Leveling with Sam"). Later reminders mention it:

> *The first time I looted a Linen Cloth was 41 days ago ~playing in a motel while the apartment is ready~*

### Settings

| Key | Default | |
|---|---|---|
| `printChance` | `0.2` | Chance of a reminder when a memory is stored (0-1, or `25%`) |
| `reminderStyle` | `chat` | `chat`, `toast`, `both` or `off` |
| `placeToasts` | `on` | Pop-ups for returning to a place or dying where you died before |
| `placeToastCooldown` | `30` | Minutes before the same place pops up again |
| `showInTooltips` | `on` | Memories in tooltips |
| `screenshotOnLevelUp` | `on` | |
| `screenshotOnAchievement` | `on` | |
| `screenshotChance` | `0` | Chance of a screenshot when a memory is stored |
| `minimapButton` | `on` | |
| `debug` | `off` | |

The original addon's keys (`memory.printChance`, `memory.showInTooltips`, ...) still work.

## WoW: Forever limitations

Forever runs on the modern (Midnight-era) engine with its addon restrictions:

- **No killer names.** Deaths record where and when, not who. The combat log is closed to addons.
- **Fights are approximate.** Any attackable NPC you target or focus during combat counts as fought when combat ends. Enemies you never target aren't counted.
- **Hidden ("secret") values.** In combat and in restricted content, some names and GUIDs are hidden from addons. Memory Forever skips those memories instead of erroring. For example, a tooltip in a dungeon may show nothing.
- **Dungeon loot** is read from the loot window and your bags, because loot chat is hidden in instances. Items won later by roll are not counted there.
- Achievements are recorded only if the client has them (`/mem status` shows it).

## Install

1. Download the release and extract it so the folder is named `MemoryForever`.
2. Put it in your Forever AddOns folder. During the beta this was `World of Warcraft/_classic_beta_/Interface/AddOns/`. Check where your live install keeps addons.
3. Log in. You should see `Memory Forever: 2.0.0-alpha.1 loaded` in chat.

### Bringing memories from the original Memory addon

Memory Forever can import the original addon's data **once, into an empty database**:

1. Log out. Do this before logging in with Memory Forever for the first time, or delete `WTF/Account/<ACCOUNT>/SavedVariables/MemoryForever.lua` first.
2. Copy `WTF/Account/<ACCOUNT>/SavedVariables/Memory.lua` from the install where you used Memory into the Forever install's `WTF/Account/<ACCOUNT>/SavedVariables/` folder, and rename it to `MemoryForever.lua`.
3. Log in. Chat says how many characters were imported.

Characters are matched by realm and character GUID, so only characters that exist on Forever with the same GUID will show their old memories.

## Development

No Stormwind Library: the addon is plain Lua 5.1 in a private namespace. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the design and [docs/API_AUDIT.md](docs/API_AUDIT.md) for every event and API, with what changed for Forever.

### Tests

The tests load the addon **through the Forever TOC** into a stubbed client. The stub simulates secret values, the closed combat log, unknown events and SavedVariables round-trips, and fires the core events.

```bash
python -m venv .venv
.venv/Scripts/pip install -r requirements-dev.txt   # or .venv/bin/pip
.venv/Scripts/python tests/run.py
```

`lua5.1 tests/run.lua` works too. CI runs the suite on every push.

### In-game test checklist

Install with BugGrabber and BugSack enabled, then:

- [ ] Fresh character: loads with no errors, `/mem status` shows which trackers are on
- [ ] `/reload`: no errors, memories still there
- [ ] Existing SavedVariables (second login)
- [ ] Walk between subzones: visits counted, return pop-up on a second visit
- [ ] Talk to an NPC, pick up and turn in a quest, buy, sell and repair: NPC tooltip shows Talked, Quests turned in, Business
- [ ] Open-world combat: "Fought" on the NPC's tooltip
- [ ] Loot in the open world, then hover the item
- [ ] Group with someone (`/mem journal` → Players)
- [ ] Dungeon (restricted content): no errors, zone visit recorded, loot recorded after closing the loot window
- [ ] Die and run back: per-place death count, pop-up on a second death there
- [ ] Level up: screenshot taken, Levels tab
- [ ] Relog
- [ ] Options panel under Options > AddOns, minimap button, journal tabs, search and sort

### Packaging

`.pkgmeta` is set up for the CurseForge/BigWigs packager. Releases follow semver starting at `2.0.0`. See [CHANGELOG.md](CHANGELOG.md).

## License

GPLv3, same as the original. See [LICENSE](LICENSE). Copyright © 2021-2024 Adriano Castro (Memory), © 2026 Jacob Rozell (Memory Forever changes).
