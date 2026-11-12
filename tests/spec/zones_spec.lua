local H, WoW = ...
local describe, it = H.describe, H.it

local function visits(ctl, zone, subzone)
  local char = ctl.char()
  local node = char.zones[zone]
  if not node then return 0 end
  if subzone then
    node = node.subzones and node.subzones[subzone]
    if not node then return 0 end
  end
  return node.visit and node.visit.x or 0
end

describe('Zone visits', function()
  it('records zone and subzone on login', function()
    local ctl = WoW.start()
    H.noErrors(ctl)
    H.eq(visits(ctl, 'Elwynn Forest'), 1, 'zone-level visit (never stored by the original)')
    H.eq(visits(ctl, 'Elwynn Forest', 'Goldshire'), 1)
  end)

  it('counts a new subzone and ignores repeated events in the same place', function()
    local ctl = WoW.start()
    ctl.subzone = 'Lion\'s Pride Inn'
    ctl.event('ZONE_CHANGED_INDOORS')
    ctl.event('PLAYER_STOPPED_MOVING')
    ctl.event('ZONE_CHANGED')
    H.eq(visits(ctl, 'Elwynn Forest', 'Lion\'s Pride Inn'), 1)
    H.eq(visits(ctl, 'Elwynn Forest'), 1)
  end)

  it('debounces border flapping for 5 minutes', function()
    local ctl = WoW.start()
    ctl.subzone = 'Crystal Lake'; ctl.event('ZONE_CHANGED')
    ctl.subzone = 'Goldshire'; ctl.event('ZONE_CHANGED')
    ctl.subzone = 'Crystal Lake'; ctl.event('ZONE_CHANGED')
    H.eq(visits(ctl, 'Elwynn Forest', 'Goldshire'), 1)
    H.eq(visits(ctl, 'Elwynn Forest', 'Crystal Lake'), 1)
    ctl.advance(301)
    ctl.subzone = 'Goldshire'; ctl.event('ZONE_CHANGED')
    H.eq(visits(ctl, 'Elwynn Forest', 'Goldshire'), 2)
  end)

  it('does not record on a flight path, then catches up on landing', function()
    local ctl = WoW.start()
    ctl.onTaxi = true
    ctl.moveTo('Westfall', 'Sentinel Hill')
    H.eq(visits(ctl, 'Westfall'), 0)
    ctl.onTaxi = false
    ctl.event('PLAYER_CONTROL_GAINED')
    H.eq(visits(ctl, 'Westfall'), 1)
    H.eq(visits(ctl, 'Westfall', 'Sentinel Hill'), 1)
  end)

  it('does not record while flying or without control', function()
    local ctl = WoW.start()
    ctl.flying = true
    ctl.moveTo('Westfall', 'Moonbrook')
    ctl.flying = false
    ctl.fullControl = false
    ctl.event('ZONE_CHANGED')
    H.eq(visits(ctl, 'Westfall'), 0)
  end)

  it('treats a subzone equal to the zone as no subzone (dungeons)', function()
    local ctl = WoW.start()
    ctl.moveTo('The Deadmines', 'The Deadmines')
    H.eq(visits(ctl, 'The Deadmines'), 1)
    H.eq(ctl.char().zones['The Deadmines'].subzones, nil)
  end)

  it('shows a return pop-up with visit count and deaths, throttled', function()
    local ctl = WoW.start()
    local shown = {}
    ctl.ns.Toast.show = function(title, text) table.insert(shown, title .. ': ' .. text) end
    ctl.event('PLAYER_DEAD')
    ctl.moveTo('Westfall', 'Sentinel Hill')
    ctl.advance(400)
    ctl.moveTo('Elwynn Forest', 'Goldshire')
    H.eq(#shown, 1)
    H.contains(shown[1], 'Goldshire')
    H.contains(shown[1], "You've been here 2 times")
    H.contains(shown[1], 'You died here 1 time')

    -- same place again before the cooldown: no pop-up
    ctl.advance(400)
    ctl.moveTo('Westfall', 'Sentinel Hill')
    local before = #shown
    ctl.advance(400)
    ctl.moveTo('Elwynn Forest', 'Goldshire')
    H.eq(#shown > before and shown[#shown]:find('Goldshire') ~= nil, false)
    H.noErrors(ctl)
  end)

  it('respects the placeToasts setting', function()
    local ctl = WoW.start()
    local shown = 0
    ctl.ns.Toast.show = function() shown = shown + 1 end
    ctl.ns.Settings.set('placeToasts', false)
    ctl.moveTo('Westfall', 'Sentinel Hill')
    ctl.advance(400)
    ctl.moveTo('Elwynn Forest', 'Goldshire')
    H.eq(shown, 0)
  end)

  it('prints random reminders according to printChance', function()
    local ctl = WoW.start()
    ctl.randomValue = 0.0
    ctl.moveTo('Westfall', 'Sentinel Hill')
    H.contains(ctl.chatText(), 'This is the 1st time I visit')
    ctl.ns.Settings.set('printChance', 0)
    local count = #ctl.chat
    ctl.moveTo('Duskwood', 'Darkshire')
    H.eq(#ctl.chat, count)
  end)
end)
