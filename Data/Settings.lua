--[[
Typed settings with defaults. Values live in MemoryForeverDB.settings
(account-wide, like the original addon) and are coerced on read, so values
typed through '/mem set' or imported from the original Memory addon (which
stored strings such as '1' and '0.2') work.
]]
local _, ns = ...

local Settings = {}
ns.Settings = Settings

Settings.DEFINITIONS = {
  printChance             = { type = 'number', default = 0.2, min = 0, max = 1,
                              label = 'Chance to show a reminder when a memory is stored (0-1)' },
  reminderStyle           = { type = 'enum', default = 'chat', values = { 'chat', 'toast', 'both', 'off' },
                              label = 'Where random reminders appear: chat, toast, both or off' },
  placeToasts             = { type = 'bool', default = true,
                              label = 'Pop-up when you return to a place or die where you died before' },
  placeToastCooldown      = { type = 'number', default = 30, min = 0, max = 1440,
                              label = 'Minutes before the same place can pop up again' },
  showInTooltips          = { type = 'bool', default = true,
                              label = 'Show memories in unit and item tooltips' },
  screenshotOnLevelUp     = { type = 'bool', default = true,
                              label = 'Take a screenshot when you level up' },
  screenshotOnAchievement = { type = 'bool', default = true,
                              label = 'Take a screenshot when you earn an achievement' },
  screenshotChance        = { type = 'number', default = 0, min = 0, max = 1,
                              label = 'Chance to take a screenshot when a memory is stored (0-1)' },
  minimapButton           = { type = 'bool', default = true,
                              label = 'Show the minimap button' },
  minimapAngle            = { type = 'number', default = 225, min = 0, max = 360,
                              label = 'Minimap button position (degrees)' },
  debug                   = { type = 'bool', default = false,
                              label = 'Print debug messages' },
}

-- keys used by the original Memory addon
Settings.ALIASES = {
  ['memory.printChance']             = 'printChance',
  ['memory.showInTooltips']          = 'showInTooltips',
  ['memory.screenshotOnLevelUp']     = 'screenshotOnLevelUp',
  ['memory.screenshotOnAchievement'] = 'screenshotOnAchievement',
  ['memory.screenshotChance']        = 'screenshotChance',
}

local TRUE_VALUES = { ['1'] = true, ['true'] = true, ['yes'] = true, ['on'] = true, ['y'] = true }
local FALSE_VALUES = { ['0'] = true, ['false'] = true, ['no'] = true, ['off'] = true, ['n'] = true }

function Settings.resolveKey(key)
  if type(key) ~= 'string' then return nil end
  if Settings.DEFINITIONS[key] then return key end
  if Settings.ALIASES[key] then return Settings.ALIASES[key] end
  local lower = string.lower(key)
  for name in pairs(Settings.DEFINITIONS) do
    if string.lower(name) == lower then return name end
  end
  return nil
end

--[[
Coerces a raw value for a definition. Returns value or nil, errorMessage.
]]
function Settings.coerce(definition, raw)
  if definition.type == 'bool' then
    if type(raw) == 'boolean' then return raw end
    if type(raw) == 'number' then return raw ~= 0 end
    local text = string.lower(ns.Util.trim(tostring(raw)))
    if TRUE_VALUES[text] then return true end
    if FALSE_VALUES[text] then return false end
    return nil, 'expected on/off'
  end

  if definition.type == 'number' then
    local number
    if type(raw) == 'number' then
      number = raw
    else
      local text = ns.Util.trim(tostring(raw))
      local percent = string.match(text, '^(-?[%d%.]+)%%$')
      number = percent and (tonumber(percent) and tonumber(percent) / 100) or tonumber(text)
    end
    if not number then return nil, 'expected a number' end
    if definition.min and number < definition.min then number = definition.min end
    if definition.max and number > definition.max then number = definition.max end
    return number
  end

  if definition.type == 'enum' then
    local text = string.lower(ns.Util.trim(tostring(raw)))
    if text == 'toasts' or text == 'popup' then text = 'toast' end
    for _, allowed in ipairs(definition.values) do
      if allowed == text then return allowed end
    end
    return nil, 'expected one of: ' .. table.concat(definition.values, ', ')
  end

  return raw
end

local function store()
  if ns.db and type(ns.db.settings) == 'table' then return ns.db.settings end
  return nil
end

function Settings.get(key)
  local name = Settings.resolveKey(key)
  if not name then return nil end
  local definition = Settings.DEFINITIONS[name]
  local values = store()
  local raw = values and values[name]
  if raw == nil then return definition.default end
  local value = Settings.coerce(definition, raw)
  if value == nil then return definition.default end
  return value
end

--[[
Sets a setting. Returns the stored value, or nil and an error message.
]]
function Settings.set(key, raw)
  local name = Settings.resolveKey(key)
  if not name then return nil, 'unknown setting "' .. tostring(key) .. '"' end
  local value, err = Settings.coerce(Settings.DEFINITIONS[name], raw)
  if value == nil then return nil, err end
  local values = store()
  if not values then return nil, 'saved data is not loaded yet' end
  values[name] = value
  return value, name
end

function Settings.names()
  local names = {}
  for name in pairs(Settings.DEFINITIONS) do table.insert(names, name) end
  table.sort(names)
  return names
end
