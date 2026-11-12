--[[
What happens after a memory is stored: maybe a reminder (chat and/or toast),
maybe a screenshot, and the "you've been here before" place pop-ups.
]]
local _, ns = ...

local Reminders = {}
ns.Reminders = Reminders

local Settings = ns.Settings

--[[
Takes a screenshot, flashing a caption first so it ends up in the picture.
]]
function Reminders.screenshot(caption)
  if type(Screenshot) ~= 'function' then return false end
  if caption and type(RaidNotice_AddMessage) == 'function' and RaidWarningFrame then
    pcall(RaidNotice_AddMessage, RaidWarningFrame, caption, { r = 1, g = 1, b = 1 })
  end
  ns.Events.after(1, function() Screenshot() end)
  return true
end

local function roll(chance)
  chance = tonumber(chance) or 0
  return chance > 0 and math.random() < chance
end

--[[
Shows a reminder line according to the reminderStyle setting.
]]
function Reminders.show(text)
  local style = Settings.get('reminderStyle')
  if style == 'chat' or style == 'both' then ns.print(text) end
  if style == 'toast' or style == 'both' then ns.Toast.show(ns.NAME, text) end
end

--[[
Called with the memory as it was before the event.
]]
function Reminders.afterStore(previous, verbs, x)
  if Settings.get('reminderStyle') ~= 'off' and roll(Settings.get('printChance')) then
    Reminders.show(ns.Formatter.random(previous, verbs, x))
  end
  if roll(Settings.get('screenshotChance')) then
    Reminders.screenshot(ns.Formatter.count(previous, verbs, x))
  end
end

--[[
Records a memory and runs the reminder logic. spec = {
  category, path, interaction, verbs, x (default 1), quiet (no reminders)
}. Returns the memory as it was before.
]]
function ns.record(spec)
  local previous = ns.Repository.get(spec.category, spec.path, spec.interaction)
  local x = spec.x or 1
  ns.Repository.store(spec.category, spec.path, spec.interaction, x)
  ns.debug(spec.interaction .. ' -> ' .. spec.category .. ' / ' .. table.concat(spec.path, ' / '))
  if not spec.quiet and spec.verbs then
    Reminders.afterStore(previous, spec.verbs, x)
  end
  return previous
end

-- place pop-ups ----------------------------------------------------------------

local lastPlaceToast = {}
local lastAnyToast
local GLOBAL_GAP = 60

function Reminders.resetPlaceThrottle()
  lastPlaceToast = {}
  lastAnyToast = nil
end

local function throttled(key, ignoreGap)
  local now = ns.Events.now()
  local cooldown = (Settings.get('placeToastCooldown') or 30) * 60
  if lastPlaceToast[key] and now - lastPlaceToast[key] < cooldown then return true end
  if not ignoreGap and lastAnyToast and now - lastAnyToast < GLOBAL_GAP then return true end
  lastPlaceToast[key] = now
  lastAnyToast = now
  return false
end

--[[
Pop-up when returning to a place visited before. previous is the visit memory
before this visit; zone/subZone identify the place.
]]
function Reminders.placeReturn(place, zone, subZone, previous)
  if not Settings.get('placeToasts') then return false end
  if not previous or previous.x < 1 then return false end
  if throttled('visit:' .. zone .. ':' .. (subZone or '')) then return false end

  local lines = { "You've been here " .. ns.Util.plural(previous.x + 1, 'time') .. '.' }
  if previous.last then
    table.insert(lines, 'Last visit: ' .. ns.Util.relativeDate(previous.last.date) .. '.')
  end
  local deaths = ns.Repository.get('deaths', { zone, subZone or zone }, 'die').x
  if deaths > 0 then
    table.insert(lines, 'You died here ' .. ns.Util.plural(deaths, 'time') .. '.')
  end
  ns.Toast.show(place, table.concat(lines, ' '))
  return true
end

--[[
Pop-up when dying somewhere you've died before.
]]
function Reminders.placeDeath(place, zone, subZone, deathsHere)
  if not Settings.get('placeToasts') then return false end
  if deathsHere < 2 then return false end
  if throttled('death:' .. zone .. ':' .. (subZone or ''), true) then return false end
  ns.Toast.show(place, 'You have died here ' .. ns.Util.plural(deathsHere, 'time') .. '.')
  return true
end
