--[[
Level-ups: stores date, zone, subzone and moment per level, and takes a
screenshot with a caption (memory.screenshotOnLevelUp).
]]
local _, ns = ...

ns.Trackers.register('levels', {
  label = 'Level-ups',
  events = { 'PLAYER_LEVEL_UP' },
  setup = function(on)
    on('PLAYER_LEVEL_UP', function(_, newLevel)
      if not ns.Repository.isReady() then return end
      -- UnitLevel can still return the old level during this event
      local level = tonumber(ns.Safe.value(newLevel)) or tonumber(ns.Safe.api('UnitLevel', 'player'))
      if not level then return end
      local snapshot = ns.MemoryString.capture({ level = level })
      ns.Repository.storeLevel(level, snapshot)
      if ns.Settings.get('screenshotOnLevelUp') then
        ns.Reminders.screenshot(string.format('Reached level %d on %s', level, ns.Util.formatDate(snapshot.date)))
      end
    end)
  end,
})
