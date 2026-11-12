# API audit: upstream Memory 1.6.0 → WoW: Forever

Verdicts: ✅ works as-is · 🔁 swapped to a modern API · 🧱 redesigned · ❌ dropped · 🛡 kept behind a guard.

"Verified" means verified in the stubbed-client tests (`tests/`). **Nothing here has been verified in the live Forever client yet.** Use the in-game checklist in the README for that.

## Events

| Event | Upstream use | Verdict | Memory Forever |
|---|---|---|---|
| `PLAYER_LOGIN` | Bootstrap (via the library) | ✅ | `Init.lua`. Binds the character and enables trackers. |
| `ADDON_LOADED` | – | ✅ new | SavedVariables init and migrations |
| `PLAYER_STARTED_MOVING` / `PLAYER_STOPPED_MOVING` | Zone visit check | 🔁 | `STOPPED_MOVING` only, as a fallback trigger |
| `ZONE_CHANGED` | Visit check / NPC list reset | ✅ | Zone tracker trigger |
| `ZONE_CHANGED_NEW_AREA`, `ZONE_CHANGED_INDOORS`, `PLAYER_ENTERING_WORLD`, `PLAYER_CONTROL_GAINED` | – | ✅ new | Zone tracker triggers. The check runs 0.5 s later because zone text lags the event. |
| `PLAYER_DEAD` | Death memory | ✅ | Total plus per-place death count, with a pop-up on repeat deaths. No killer. |
| `PLAYER_LEVEL_UP` | Level memory + screenshot | ✅ | Uses the event's level argument, since `UnitLevel` can lag |
| `ACHIEVEMENT_EARNED` | Screenshot | 🛡 | Gated: tracker disabled if the event or `GetAchievementInfo` is missing. **Unconfirmed on Forever.** |
| `GOSSIP_SHOW`, `QUEST_GREETING`, `QUEST_DETAIL`, `QUEST_COMPLETE` | Talk | 🔁 | NPC from the `npc` unit instead of matching the target's name against frame titles |
| `QUEST_PROGRESS`, `QUEST_TURNED_IN` | – | ✅ new | Quest turn-in memory, which fixes the upstream known issue |
| `MERCHANT_SHOW`, `MERCHANT_CLOSED`, `PLAYER_MONEY` | Business | ✅ | Same logic, using the `npc` unit |
| `COMBAT_LOG_EVENT`, `COMBAT_LOG_EVENT_UNFILTERED` | Fights | ❌ | Closed to addons. **Never registered.** A test asserts this. |
| `PLAYER_REGEN_DISABLED` / `PLAYER_REGEN_ENABLED`, `PLAYER_TARGET_CHANGED`, `PLAYER_FOCUS_CHANGED` | – | 🧱 new | Fight redesign: attackable target and focus NPCs seen during combat are recorded when combat ends |
| `CHAT_MSG_LOOT` | Loot | 🔁 | Open world only. Text is checked with `issecretvalue` (secret in instances). Patterns are escaped and the name comes from the link. |
| `LOOT_OPENED`, `LOOT_CLOSED` | – | ✅ new | Instance loot: the bag-count delta of items that were in the loot window |
| `GROUP_ROSTER_UPDATE` | Party | ✅ | Deferred to `PLAYER_REGEN_ENABLED` when it fires in combat |
| `TOOLTIP_UNIT_SHOWN` / `TOOLTIP_ITEM_SHOWN` | Library pseudo-events | 🔁 | `TooltipDataProcessor.AddTooltipPostCall` |

## APIs

| API | Upstream use | Verdict | Memory Forever |
|---|---|---|---|
| `GetZoneText`, `GetSubZoneText` | Location | ✅ | Through `Safe.api`. A secret value is treated as unknown. |
| `GetMinimapZoneText` | Subzone fallback | ❌ | Not needed |
| `HasFullControl`, `UnitOnTaxi`, `IsFlying` | Skip visits while not in control | ✅ | Same |
| `UnitGUID`, `UnitName` | NPC, player and target identity | 🛡 | `Safe.unitGUID` / `Safe.unitName`. Secret values become `nil` and the memory is skipped. |
| `UnitLevel('player')` | Level in memory strings | ✅ | Player data isn't secret |
| `UnitCanAttack` | – | 🛡 new | Fight filter |
| `UnitIsUnit`, `IsInRaid`, `GetNumGroupMembers`, `GetNumSubgroupMembers` | Group | ✅ | Proper raid/party unit iteration. Upstream mixed `raidN` and `partyN`. |
| `GetRealmName` | Character key, player realm | ✅ | Same, with spaces stripped for player keys as before |
| `InCombatLockdown` | Zone change NPC reset | ✅ | Group deferral |
| `IsInInstance` | – | ✅ new | Picks the chat or loot-window loot path |
| `CombatLogGetCurrentEventInfo` | Fights | ❌ | Closed |
| `GetItemInfo` | Loot name | 🔁 | Name parsed from the hyperlink. Falls back to `C_Item.GetItemInfo`, then to `GetItemInfo`. |
| `C_Item.GetItemCount` | – | 🔁 new | Instance loot (falls back to `GetItemCount`) |
| `C_Item.GetItemNameByID` | – | 🔁 new | Item tooltip fallback |
| `GetNumLootItems`, `GetLootSlotLink` | – | ✅ new | Instance loot |
| `LOOT_ITEM_SELF`, `LOOT_ITEM_SELF_MULTIPLE` | Loot patterns | ✅ | Converted with `Util.formatToPattern`, which escapes magic characters |
| `GossipFrameNpcNameText`, `QuestFrameNpcNameText` | Talk sanity check | ❌ | Replaced by the `npc` unit |
| `GameTooltip:HookScript('OnTooltipSetUnit'/'OnTooltipSetItem')` | Library (Classic path) | ❌ / 🛡 | Used only if `TooltipDataProcessor` is missing **and** the script exists |
| `TooltipDataProcessor`, `Enum.TooltipDataType` | Library (Retail path) | ✅ | Primary tooltip hook. The unit comes from `tooltip:GetUnit()`, so the target frame works too. |
| `Screenshot`, `RaidNotice_AddMessage`, `RaidWarningFrame` | Screenshots | ✅ | Colors fixed to the 0-1 range |
| `date`, `time` | Dates | ✅ | DST-safe whole-day math |
| `CreateFrame('Frame')` + `OnUpdate` wait helper | Delays | 🔁 | `C_Timer.After` |
| `issecretvalue` | – | ✅ new | `Safe.isSecret`. If the function is missing, nothing is treated as secret. |
| `C_EventUtils.IsEventValid` | – | ✅ new | Event gating, plus a `pcall` around `RegisterEvent` |
| `C_AddOns.GetAddOnMetadata` | – | 🔁 new | Version (falls back to `GetAddOnMetadata`) |
| `Settings.RegisterCanvasLayoutCategory`, `Settings.RegisterAddOnCategory`, `Settings.OpenToCategory` | – | ✅ new | Options panel. Falls back to `InterfaceOptions_AddCategory`. |
| `SlashCmdList` | Library command system | 🔁 | Direct: `/mem`, `/memoryforever` |
| `DEFAULT_CHAT_FRAME:AddMessage` | Output | ✅ | Same |

## Memory types

| Memory type | Expected (handoff) | Result |
|---|---|---|
| Zone / subzone visits | ✅ | ✅ Works, with the upstream bug fixed: zone-level visits are now stored. 5-minute re-entry debounce. |
| Deaths | ✅ | ✅ Total and per place. No killer. |
| Level-up + screenshot | ✅ | ✅ |
| NPC interactions | ✅/🔁 | 🔁 `npc` unit. Quest turn-ins added. |
| Loot | 🔁 | 🔁 Chat in the open world, loot window plus bag count in instances |
| Grouping | ✅/🔁 | ✅ Names read only out of combat |
| Tooltips | 🔁 | 🔁 `TooltipDataProcessor`, returns silently on secret values |
| Fights | 🧱 | 🧱 Target and focus during combat. Approximate. |
| Achievements | ❓ | 🛡 Gated. Disabled automatically if the client lacks them. **Check in game.** |
| Moments | ✅ | ✅ |

## Still to confirm in the live client

- [ ] The client picks up `MemoryForever_Camelot.toc`, and the install folder is `_classic_beta_` or something else.
- [ ] `ACHIEVEMENT_EARNED` and `GetAchievementInfo` exist (`/mem status` shows it).
- [ ] The `npc` unit is set during gossip, quest and merchant windows on Forever.
- [ ] `CHAT_MSG_LOOT` text is plain in the open world and secret in dungeons, as assumed.
- [ ] `Settings.RegisterCanvasLayoutCategory` exists. Otherwise the panel falls back to `InterfaceOptions_AddCategory`.
- [ ] The beta SavedVariables load bug is fixed. The init repairs data either way.
