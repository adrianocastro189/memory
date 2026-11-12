--[[
Deaths. Recorded as a total (misc/others/die, like the original addon) and per
place (deaths/<zone>/<subzone>/die) so the addon can say "You died here 3
times". The killer is not recorded: that needs the combat log, which is closed
to addons on the Midnight engine.

Forever build 70009 fires PLAYER_DEAD twice for one death, a few seconds
apart. A second event inside 30 seconds is ignored unless the player has been
alive again (PLAYER_ALIVE), so a real death after a revive still counts.
]]
local _, ns = ...

local ECHO = 30

local Deaths = { lastAt = nil, alive = true }
ns.Deaths = Deaths

local function record()
  ns.record({
    category = 'misc', path = { 'others' }, interaction = 'die',
    verbs = { past = 'died', present = 'die' },
  })

  local zone, subZone = ns.Zones.location()
  if not zone then return end
  local previous = ns.record({
    category = 'deaths', path = { zone, subZone or zone }, interaction = 'die', quiet = true,
  })
  ns.Reminders.placeDeath(subZone or zone, zone, subZone, previous.x + 1)
end

ns.Trackers.register('deaths', {
  label = 'Deaths',
  events = { 'PLAYER_DEAD' },
  setup = function(on)
    -- optional: a client without this event still records deaths
    on('PLAYER_ALIVE', function() Deaths.alive = true end)
    on('PLAYER_DEAD', function()
      if not ns.Repository.isReady() then return end
      local now = ns.Events.now()
      if Deaths.lastAt and not Deaths.alive and (now - Deaths.lastAt) < ECHO then return end
      Deaths.lastAt = now
      Deaths.alive = false
      record()
    end)
  end,
})
