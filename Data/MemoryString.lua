--[[
A memory string is the compact snapshot stored for the first and last time
something happened: 'date|level|zone|subzone|moment', for example
'26-11-12|14|Elwynn Forest|Goldshire|2'. Unknown parts are '-'. This is the
same format the original Memory addon used, so its data parses unchanged.
]]
local _, ns = ...

local MemoryString = {}
MemoryString.__index = MemoryString
ns.MemoryString = MemoryString

local NONE = '-'
local SEPARATOR = '|'

local function clean(value)
  value = ns.Safe.str(value)
  if not value then return nil end
  -- the separator can't appear inside a field
  return (string.gsub(value, '|', '/'))
end

function MemoryString.new(fields)
  local instance = setmetatable({}, MemoryString)
  fields = fields or {}
  instance.date = fields.date
  instance.level = tonumber(fields.level)
  instance.zone = fields.zone
  instance.subZone = fields.subZone
  instance.moment = tonumber(fields.moment)
  return instance
end

--[[
Parses a stored string; returns nil for missing/invalid values (the original
addon stored -1 for "never").
]]
function MemoryString.parse(value)
  if type(value) ~= 'string' then return nil end
  local date, level, zone, subZone, moment = unpack(ns.Util.split(value, SEPARATOR))
  if not ns.Util.isDate(date) then return nil end
  local function field(v) if v == nil or v == '' or v == NONE then return nil end return v end
  return MemoryString.new({
    date = date,
    level = field(level),
    zone = field(zone),
    subZone = field(subZone),
    moment = field(moment),
  })
end

--[[
Snapshot of "now": today's date, player level, zone, subzone and moment.
]]
function MemoryString.capture(overrides)
  overrides = overrides or {}
  local level = overrides.level or ns.Safe.api('UnitLevel', 'player')
  if tonumber(level) == 0 then level = nil end
  local moment = ns.Moments.currentIndex()
  return MemoryString.new({
    date = overrides.date or ns.Util.today(),
    level = level,
    zone = overrides.zone or clean(ns.Safe.api('GetZoneText')),
    subZone = overrides.subZone or clean(ns.Safe.api('GetSubZoneText')),
    moment = moment > 0 and moment or nil,
  })
end

function MemoryString:toString()
  local function field(v) if v == nil or v == '' then return NONE end return tostring(v) end
  return table.concat({
    field(self.date), field(self.level), field(self.zone), field(self.subZone), field(self.moment),
  }, SEPARATOR)
end

function MemoryString:hasLevel() return self.level ~= nil end
function MemoryString:hasMoment() return self.moment ~= nil and self.moment > 0 end

--[[
'Goldshire, Elwynn Forest', 'Elwynn Forest', or '' when unknown.
]]
function MemoryString:location()
  local zone, subZone = self.zone, self.subZone
  if subZone and zone and subZone ~= zone then return subZone .. ', ' .. zone end
  return zone or subZone or ''
end

function MemoryString:isAt(zone, subZone)
  if self.zone ~= zone then return false end
  if subZone == nil then return true end
  return self.subZone == subZone
end

function MemoryString:momentLabel()
  if not self:hasMoment() then return nil end
  return ns.Moments.get(self.moment)
end
