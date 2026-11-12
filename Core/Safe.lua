--[[
Safe access to game data that may be hidden from addons.

On the Midnight-era engine that WoW: Forever runs on, some values (unit names,
GUIDs, chat text in instances, ...) are handed to addons as "secret values"
during combat and in restricted content. Comparing, concatenating or indexing
them throws a Lua error. Everything that reads unit or chat data goes through
this module: secret values are turned into nil ("unknown") and API errors are
swallowed, so a hidden value skips a memory instead of breaking the addon.
]]
local _, ns = ...

local Safe = {}
ns.Safe = Safe

--[[
True when the value is a secret value (or when the check itself fails, which
we treat as "not safe to touch").
]]
function Safe.isSecret(value)
  local check = issecretvalue
  if type(check) ~= 'function' then return false end
  local ok, result = pcall(check, value)
  if not ok then return true end
  return result == true
end

--[[
Returns the value, or nil when it's secret.
]]
function Safe.value(value)
  if Safe.isSecret(value) then return nil end
  return value
end

--[[
Returns a non-empty, non-secret string or nil.
]]
function Safe.str(value)
  if Safe.isSecret(value) then return nil end
  if type(value) ~= 'string' or value == '' then return nil end
  return value
end

local function scrub(ok, ...)
  if not ok then return nil end
  local count = select('#', ...)
  if count == 0 then return nil end
  local values = { ... }
  for i = 1, count do
    if Safe.isSecret(values[i]) then values[i] = nil end
  end
  return unpack(values, 1, count)
end

--[[
Calls a function protected; returns its results with secret values replaced by
nil, or nil if the function is missing or errors.
]]
function Safe.call(fn, ...)
  if type(fn) ~= 'function' then return nil end
  return scrub(pcall(fn, ...))
end

--[[
Resolves a global API by name ("UnitName" or "C_Item.GetItemInfo").
]]
function Safe.resolve(name)
  local value = _G
  for part in string.gmatch(name, '[^%.]+') do
    if type(value) ~= 'table' then return nil end
    value = value[part]
  end
  return value
end

--[[
Calls a global API by name through Safe.call.
]]
function Safe.api(name, ...)
  return Safe.call(Safe.resolve(name), ...)
end

function Safe.has(name)
  return type(Safe.resolve(name)) == 'function'
end

-- unit helpers --------------------------------------------------------------

function Safe.unitGUID(unit)
  return Safe.str(Safe.api('UnitGUID', unit))
end

--[[
Returns name and realm (realm is nil for units from the player's realm).
]]
function Safe.unitName(unit)
  local name, realm = Safe.api('UnitName', unit)
  return Safe.str(name), Safe.str(realm)
end

function Safe.unitExists(unit)
  return Safe.api('UnitExists', unit) == true
end

--[[
Returns the GUID type prefix: "Player", "Creature", "Vehicle", "GameObject"...
]]
function Safe.guidType(guid)
  if type(guid) ~= 'string' then return nil end
  return string.match(guid, '^([^%-]+)')
end

function Safe.isNpcGuid(guid)
  local kind = Safe.guidType(guid)
  return kind == 'Creature' or kind == 'Vehicle'
end

function Safe.isPlayerGuid(guid)
  return Safe.guidType(guid) == 'Player'
end
