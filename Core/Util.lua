--[[
Small, dependency-free helpers (strings, dates, tables).
]]
local _, ns = ...

local Util = {}
ns.Util = Util

local MONTHS = {
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
}

--[[
Splits a string by a plain (non-pattern) separator, keeping empty fields.
]]
function Util.split(value, separator)
  local parts = {}
  if type(value) ~= 'string' then return parts end
  local start = 1
  while true do
    local i, j = string.find(value, separator, start, true)
    if not i then
      table.insert(parts, string.sub(value, start))
      break
    end
    table.insert(parts, string.sub(value, start, i - 1))
    start = j + 1
  end
  return parts
end

function Util.trim(value)
  return (string.gsub(value or '', '^%s*(.-)%s*$', '%1'))
end

function Util.ucfirst(value)
  if type(value) ~= 'string' or value == '' then return value end
  return (string.gsub(value, '^%l', string.upper))
end

function Util.contains(list, needle)
  for _, value in ipairs(list or {}) do
    if value == needle then return true end
  end
  return false
end

function Util.copy(value)
  if type(value) ~= 'table' then return value end
  local result = {}
  for k, v in pairs(value) do result[k] = Util.copy(v) end
  return result
end

function Util.ordinal(number)
  number = tonumber(number) or 0
  local j, k = number % 10, number % 100
  if j == 1 and k ~= 11 then return number .. 'st' end
  if j == 2 and k ~= 12 then return number .. 'nd' end
  if j == 3 and k ~= 13 then return number .. 'rd' end
  return number .. 'th'
end

function Util.plural(count, singular, pluralForm)
  if count == 1 then return '1 ' .. singular end
  return count .. ' ' .. (pluralForm or (singular .. 's'))
end

--[[
Converts a Lua format string such as LOOT_ITEM_SELF ("You receive loot: %s.")
into an anchored pattern that captures %s and %d. Magic characters are escaped
so localized strings with parentheses or dashes still match.
]]
function Util.formatToPattern(format)
  local pattern = string.gsub(format, '%%%d?%$?([sd])', '\001%1')
  pattern = string.gsub(pattern, '[%^%$%(%)%%%.%[%]%*%+%-%?]', '%%%0')
  pattern = string.gsub(pattern, '\001s', '(.+)')
  pattern = string.gsub(pattern, '\001d', '(%%d+)')
  return '^' .. pattern .. '$'
end

--[[
Extracts the display name from an item hyperlink.
]]
function Util.itemNameFromLink(link)
  if type(link) ~= 'string' then return nil end
  local name = string.match(link, '|h%[(.-)%]|h')
  if name and name ~= '' then return name end
  return nil
end

function Util.itemIdFromLink(link)
  if type(link) ~= 'string' then return nil end
  return tonumber(string.match(link, 'item:(%d+)'))
end

-- dates ----------------------------------------------------------------------
-- Dates are stored as 'yy-mm-dd' strings, the format used by the original
-- Memory addon, so old data stays readable.

function Util.today()
  return date('%y-%m-%d')
end

local function parseDate(value)
  if type(value) ~= 'string' then return nil end
  local year, month, day = string.match(value, '^(%d+)-(%d+)-(%d+)$')
  year, month, day = tonumber(year), tonumber(month), tonumber(day)
  if not year or not month or not day or month < 1 or month > 12 then return nil end
  if year < 100 then year = year + 2000 end
  return year, month, day
end

function Util.isDate(value)
  return parseDate(value) ~= nil
end

--[[
Whole days between two stored dates (absolute value). Uses noon to avoid DST
producing fractional days. Returns nil for invalid dates.
]]
function Util.daysBetween(from, to)
  local y1, m1, d1 = parseDate(from)
  local y2, m2, d2 = parseDate(to)
  if not y1 or not y2 then return nil end
  local t1 = time({ year = y1, month = m1, day = d1, hour = 12 })
  local t2 = time({ year = y2, month = m2, day = d2, hour = 12 })
  return math.floor(math.abs(t2 - t1) / 86400 + 0.5)
end

function Util.daysAgo(value)
  return Util.daysBetween(value, Util.today())
end

--[[
'26-11-12' -> 'November 12, 2026' (or 'Nov 12, 2026' when short is true).
]]
function Util.formatDate(value, short)
  local year, month, day = parseDate(value)
  if not year then return 'an unknown date' end
  local monthName = MONTHS[month]
  if short then monthName = string.sub(monthName, 1, 3) end
  return monthName .. ' ' .. day .. ', ' .. year
end

--[[
'today', 'yesterday', '3 days ago'.
]]
function Util.relativeDate(value)
  local days = Util.daysAgo(value)
  if days == nil then return 'an unknown date' end
  if days == 0 then return 'today' end
  if days == 1 then return 'yesterday' end
  return days .. ' days ago'
end

--[[
Sortable key for a stored date ('26-11-12' -> 20261112), 0 when invalid.
]]
function Util.dateKey(value)
  local year, month, day = parseDate(value)
  if not year then return 0 end
  return year * 10000 + month * 100 + day
end
