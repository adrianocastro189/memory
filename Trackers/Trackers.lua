--[[
Tracker registry. Each memory type is a tracker that declares what it needs
from the client. A tracker whose APIs or events are missing is disabled
quietly (see '/mem status') instead of breaking the addon.

  ns.Trackers.register('zones', {
    label  = 'Zone and subzone visits',
    apis   = { 'GetZoneText' },          -- required global functions
    events = { 'ZONE_CHANGED' },         -- required events
    setup  = function(on) on('ZONE_CHANGED', handler) end,
  })

setup receives on(event, handler), which registers optional events and
returns false for unknown ones.
]]
local _, ns = ...

local Trackers = {}
ns.Trackers = Trackers

local order = {}
local definitions = {}
Trackers.status = {}

function Trackers.register(name, definition)
  if not definitions[name] then table.insert(order, name) end
  definition.name = name
  definitions[name] = definition
end

local function missingRequirement(definition)
  for _, api in ipairs(definition.apis or {}) do
    if not ns.Safe.has(api) then return 'missing API ' .. api end
  end
  for _, event in ipairs(definition.events or {}) do
    if not ns.Events.isValid(event) then return 'missing event ' .. event end
  end
  return nil
end

function Trackers.enable(name)
  local definition = definitions[name]
  if not definition or Trackers.status[name] == 'on' then return end
  local missing = missingRequirement(definition)
  if missing then
    Trackers.status[name] = missing
    return
  end
  for _, event in ipairs(definition.events or {}) do
    -- required events must register; optional ones are registered in setup
    if not ns.Events.on(event, function() end) then
      Trackers.status[name] = 'cannot register ' .. event
      return
    end
  end
  local ok, err = pcall(definition.setup, ns.Events.on)
  if ok then
    Trackers.status[name] = 'on'
  else
    Trackers.status[name] = 'setup failed'
    ns.Events.report(err)
  end
end

function Trackers.enableAll()
  for _, name in ipairs(order) do Trackers.enable(name) end
end

function Trackers.list()
  local result = {}
  for _, name in ipairs(order) do
    table.insert(result, { name = name, label = definitions[name].label or name, status = Trackers.status[name] or 'off' })
  end
  return result
end
