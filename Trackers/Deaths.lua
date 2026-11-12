--[[
Deaths. Recorded as a total (misc/others/die, like the original addon) and per
place (deaths/<zone>/<subzone>/die) so the addon can say "You died here 3
times". The killer is not recorded: that needs the combat log, which is closed
to addons on the Midnight engine.
]]
local _, ns = ...

ns.Trackers.register('deaths', {
  label = 'Deaths',
  events = { 'PLAYER_DEAD' },
  setup = function(on)
    on('PLAYER_DEAD', function()
      if not ns.Repository.isReady() then return end
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
    end)
  end,
})
