--[[
Zone and subzone visits (the core feature).

A visit is counted when you enter a zone or subzone different from the one
you were in. Re-entering the same place within 5 minutes doesn't count again,
so walking along a border doesn't inflate the numbers. Nothing is recorded on
a flight path, while flying, or while you don't control your character; the
place is checked again when control comes back.

Zone events can fire before GetZoneText() updates, so the check runs half a
second after the event.

Upstream fix: the original compared `not zoneName == lastZone` (always false),
so zone-level visits were never stored. Only subzones were.
]]
local _, ns = ...

local Safe = ns.Safe
local DEBOUNCE = 300
local CHECK_DELAY = 0.5

local Zones = { current = {}, recent = {}, pending = false }
ns.Zones = Zones

local function verbs(subject)
  return { past = 'visited', present = 'visit', subject = subject }
end

local function counted(key)
  local now = ns.Events.now()
  local last = Zones.recent[key]
  if last and now - last < DEBOUNCE then return true end
  Zones.recent[key] = now
  return false
end

local function canRecord()
  if Safe.api('UnitOnTaxi', 'player') then return false end
  if Safe.has('HasFullControl') and Safe.api('HasFullControl') == false then return false end
  if Safe.api('IsFlying') then return false end
  return true
end

--[[
Current zone and subzone (subzone is nil when it's empty or equals the zone).
]]
function Zones.location()
  local zone = Safe.str(Safe.api('GetZoneText'))
  local subZone = Safe.str(Safe.api('GetSubZoneText'))
  if subZone == zone then subZone = nil end
  return zone, subZone
end

function Zones.check()
  Zones.pending = false
  if not ns.Repository.isReady() or not canRecord() then return end

  local zone, subZone = Zones.location()
  if not zone then return end

  local zonePrevious
  if zone ~= Zones.current.zone then
    Zones.current.zone = zone
    Zones.current.subZone = nil
    if not counted(zone) then
      zonePrevious = ns.record({
        category = 'zones', path = { zone }, interaction = 'visit', verbs = verbs(zone),
      })
    end
  end

  if subZone and subZone ~= Zones.current.subZone then
    Zones.current.subZone = subZone
    if not counted(zone .. '\031' .. subZone) then
      local previous = ns.record({
        category = 'zones', path = { zone, 'subzones', subZone }, interaction = 'visit', verbs = verbs(subZone),
      })
      ns.Reminders.placeReturn(subZone, zone, subZone, previous)
    end
  elseif not subZone then
    Zones.current.subZone = nil
    if zonePrevious then ns.Reminders.placeReturn(zone, zone, nil, zonePrevious) end
  end
end

function Zones.schedule()
  if Zones.pending then return end
  Zones.pending = true
  ns.Events.after(CHECK_DELAY, Zones.check)
end

ns.Trackers.register('zones', {
  label = 'Zone and subzone visits',
  apis = { 'GetZoneText', 'GetSubZoneText' },
  events = { 'ZONE_CHANGED', 'ZONE_CHANGED_NEW_AREA' },
  setup = function(on)
    local function handler() Zones.schedule() end
    for _, event in ipairs({
      'ZONE_CHANGED', 'ZONE_CHANGED_NEW_AREA', 'ZONE_CHANGED_INDOORS',
      'PLAYER_ENTERING_WORLD', 'PLAYER_CONTROL_GAINED', 'PLAYER_STOPPED_MOVING',
    }) do
      on(event, handler)
    end
    Zones.schedule()
  end,
})
