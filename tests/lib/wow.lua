--[[
A stubbed WoW: Forever client for tests.

Builds a sandboxed global environment that looks like the game (no io/os,
WoW globals, frames, events, timers) and loads the addon through its TOC the
way the client does: every file gets (addonName, namespace).

It simulates the Forever/Midnight restrictions this port must survive:
  - registering COMBAT_LOG_EVENT(_UNFILTERED) raises an error;
  - registering unknown events raises an error (configurable list);
  - ctl.SECRET is a "secret value": indexing, concatenating, comparing or
    tostring-ing it raises, and issecretvalue() recognizes it;
  - ctl.restricted = true makes every non-player unit read return SECRET.
]]
local M = {}

local ADDON = 'MemoryForever'

local function noop() end

local SECRET = newproxy(true)
do
  local mt = getmetatable(SECRET)
  local function fail() error('attempt to use a secret value', 2) end
  mt.__index = fail
  mt.__newindex = fail
  mt.__concat = fail
  mt.__lt = fail
  mt.__le = fail
  mt.__len = fail
  mt.__call = fail
  mt.__tostring = fail
  mt.__add = fail
end
M.SECRET = SECRET

local function deepCopy(value)
  if type(value) ~= 'table' then return value end
  local copy = {}
  for k, v in pairs(value) do copy[deepCopy(k)] = deepCopy(v) end
  return copy
end
M.deepCopy = deepCopy

--[[
Serializes a SavedVariable like the client does. Errors on anything the
client couldn't save (functions, userdata such as secret values).
]]
local function serialize(value, indent)
  indent = indent or ''
  local kind = type(value)
  if kind == 'string' then return string.format('%q', value) end
  if kind == 'number' or kind == 'boolean' or kind == 'nil' then return tostring(value) end
  if kind ~= 'table' then error('cannot save a ' .. kind .. ' in SavedVariables') end
  local parts = {}
  local keys = {}
  for k in pairs(value) do table.insert(keys, k) end
  table.sort(keys, function(a, b)
    if type(a) == type(b) and (type(a) == 'string' or type(a) == 'number') then return a < b end
    return type(a) < type(b)
  end)
  for _, k in ipairs(keys) do
    if type(k) ~= 'string' and type(k) ~= 'number' then error('cannot save a ' .. type(k) .. ' key') end
    table.insert(parts, indent .. '  [' .. serialize(k) .. '] = ' .. serialize(value[k], indent .. '  ') .. ',')
  end
  return '{\n' .. table.concat(parts, '\n') .. '\n' .. indent .. '}'
end
M.serialize = serialize

function M.newClient(options)
  options = options or {}
  local ctl = {
    SECRET = SECRET,
    errors = {},
    chat = {},
    timers = {},
    frames = {},
    screenshots = 0,
    raidNotices = {},
    now = os.time({ year = 2026, month = 11, day = 12, hour = 15 }),
    clock = 1000,
    zone = 'Elwynn Forest',
    subzone = 'Goldshire',
    level = 10,
    realm = 'Forever Realm',
    inCombat = false,
    inInstance = false,
    onTaxi = false,
    flying = false,
    fullControl = true,
    raid = false,
    restricted = false,
    units = {
      player = { guid = 'Player-1-00000001', name = 'Tester', level = 10 },
    },
    bags = {},
    lootSlots = {},
    invalidEvents = {},
    forbiddenEvents = { COMBAT_LOG_EVENT_UNFILTERED = true, COMBAT_LOG_EVENT = true },
    tooltipCallbacks = {},
    registeredEvents = {},
    randomValue = 0.99,
  }

  -- frames ------------------------------------------------------------------

  local methods = {}
  local FrameMT = {
    __index = function(_, key)
      return methods[key] or noop
    end,
  }

  local function newObject(kind, name, parent)
    local object = setmetatable({
      _kind = kind, _name = name, _parent = parent, _shown = true, _scripts = {},
      _events = {}, _width = 100, _height = 100, _lines = {},
    }, FrameMT)
    table.insert(ctl.frames, object)
    return object
  end
  ctl.newObject = newObject

  function methods:RegisterEvent(event)
    if ctl.forbiddenEvents[event] then
      error('Frame:RegisterEvent(): ' .. event .. ' is not available to addons')
    end
    if ctl.invalidEvents[event] then
      error('Frame:RegisterEvent(): Attempt to register unknown event "' .. event .. '"')
    end
    self._events[event] = true
    ctl.registeredEvents[event] = true
  end
  function methods:UnregisterEvent(event) self._events[event] = nil end
  function methods:IsEventRegistered(event) return self._events[event] == true end
  function methods:SetScript(script, fn) self._scripts[script] = fn end
  function methods:GetScript(script) return self._scripts[script] end
  function methods:HasScript(script)
    return script ~= 'OnTooltipSetUnit' and script ~= 'OnTooltipSetItem'
  end
  function methods:HookScript(script, fn)
    if not self:HasScript(script) then error(self._kind .. " doesn't have a \"" .. script .. '" script') end
    local old = self._scripts[script]
    self._scripts[script] = function(...) if old then old(...) end fn(...) end
  end
  function methods:Show() self._shown = true end
  function methods:Hide() self._shown = false end
  function methods:IsShown() return self._shown end
  function methods:IsVisible() return self._shown end
  function methods:SetShown(shown) self._shown = shown and true or false end
  function methods:SetText(text) self._text = text end
  function methods:GetText() return self._text end
  function methods:GetName() return self._name end
  function methods:GetParent() return self._parent end
  function methods:CreateFontString(name) return newObject('FontString', name, self) end
  function methods:CreateTexture(name) return newObject('Texture', name, self) end
  function methods:CreateAnimationGroup() return newObject('AnimationGroup', nil, self) end
  function methods:CreateAnimation() return newObject('Animation', nil, self) end
  function methods:SetSize(w, h) self._width, self._height = w, h end
  function methods:SetWidth(w) self._width = w end
  function methods:SetHeight(h) self._height = h end
  function methods:GetWidth() return self._width end
  function methods:GetHeight() return self._height end
  function methods:GetStringHeight() return 14 end
  function methods:GetCenter() return 500, 400 end
  function methods:GetEffectiveScale() return 1 end
  function methods:SetChecked(value) self._checked = value end
  function methods:GetChecked() return self._checked end
  function methods:AddLine(text) table.insert(self._lines, text) end
  function methods:AddDoubleLine(left, right) table.insert(self._lines, tostring(left) .. ' | ' .. tostring(right)) end
  function methods:ClearLines() self._lines = {} end
  function methods:NumLines() return #self._lines end
  function methods:GetUnit()
    local unit = self._unit
    if not unit then return nil end
    local data = ctl.units[unit]
    return data and data.name, unit, data and data.guid
  end
  function methods:GetItem()
    if not self._item then return nil end
    return self._item.name, self._item.link, self._item.id
  end
  function methods:Click(button)
    local fn = self._scripts.OnClick
    if fn then fn(self, button or 'LeftButton') end
  end

  -- env -----------------------------------------------------------------------

  local env = {}
  local base = {
    assert = assert, error = error, ipairs = ipairs, next = next, pairs = pairs, pcall = pcall,
    xpcall = xpcall, select = select, tonumber = tonumber, tostring = tostring, type = type,
    unpack = unpack, setmetatable = setmetatable, getmetatable = getmetatable, rawget = rawget,
    rawset = rawset, rawequal = rawequal, string = string, table = table, coroutine = coroutine,
    print = function(...) local t = {} for i = 1, select('#', ...) do t[i] = tostring(select(i, ...)) end table.insert(ctl.chat, table.concat(t, ' ')) end,
  }
  for k, v in pairs(base) do env[k] = v end
  env._G = env
  env.math = setmetatable({ random = function(m, n)
    local r = ctl.randomValue
    if m == nil then return r end
    if n == nil then m, n = 1, m end
    return math.min(n, m + math.floor(r * (n - m + 1)))
  end }, { __index = math })

  -- Lua helpers the client adds
  env.strsplit = function(sep, str)
    local out = {}
    for piece in string.gmatch(str .. sep, '(.-)' .. sep:gsub('%p', '%%%0')) do table.insert(out, piece) end
    return unpack(out)
  end
  env.strtrim = function(s) return (s:gsub('^%s*(.-)%s*$', '%1')) end
  env.tinsert, env.tremove, env.format = table.insert, table.remove, string.format
  env.wipe = function(t) for k in pairs(t) do t[k] = nil end return t end
  env.date = function(fmt, t) return os.date(fmt, t or ctl.now) end
  env.time = function(t) if t then return os.time(t) end return ctl.now end
  env.GetTime = function() return ctl.clock end

  -- secrets
  env.issecretvalue = function(value) return rawequal(value, SECRET) end

  local function unitData(unit)
    return ctl.units[unit]
  end
  local function restrictedRead(unit, value)
    if ctl.restricted and unit ~= 'player' and value ~= nil then return SECRET end
    return value
  end

  env.UnitGUID = function(unit) local d = unitData(unit) return d and restrictedRead(unit, d.guid) end
  env.UnitName = function(unit)
    local d = unitData(unit)
    if not d then return nil end
    return restrictedRead(unit, d.name), restrictedRead(unit, d.realm)
  end
  env.UnitExists = function(unit) local d = unitData(unit) return d ~= nil and restrictedRead(unit, true) end
  env.UnitLevel = function(unit) if unit == 'player' then return ctl.level end local d = unitData(unit) return d and d.level or 0 end
  env.UnitClass = function() return 'Warrior', 'WARRIOR', 1 end
  env.UnitCanAttack = function(_, unit) local d = unitData(unit) return d and restrictedRead(unit, d.canAttack and true or false) end
  env.UnitIsUnit = function(a, b)
    local da, db = unitData(a), unitData(b)
    return da ~= nil and db ~= nil and da.guid == db.guid
  end
  env.UnitOnTaxi = function() return ctl.onTaxi end
  env.HasFullControl = function() return ctl.fullControl end
  env.IsFlying = function() return ctl.flying end
  env.InCombatLockdown = function() return ctl.inCombat end
  env.IsInInstance = function() return ctl.inInstance, ctl.inInstance and 'party' or 'none' end
  env.IsInRaid = function() return ctl.raid end
  env.GetNumGroupMembers = function() return ctl.groupSize or 0 end
  env.GetNumSubgroupMembers = function() return math.max(0, (ctl.groupSize or 0) - 1) end
  env.GetRealmName = function() return ctl.realm end
  env.GetNormalizedRealmName = function() return (ctl.realm:gsub('%s', '')) end
  env.GetZoneText = function() return ctl.zone end
  env.GetSubZoneText = function() return ctl.subzone end
  env.GetMinimapZoneText = function() return ctl.subzone ~= '' and ctl.subzone or ctl.zone end
  env.GetAchievementInfo = function(id) return id, 'Achievement ' .. tostring(id) end
  env.Screenshot = function() ctl.screenshots = ctl.screenshots + 1 end
  env.RaidWarningFrame = newObject('Frame', 'RaidWarningFrame')
  env.RaidNotice_AddMessage = function(_, message) table.insert(ctl.raidNotices, message) end
  env.UIFrameFadeOut = noop
  env.GetCursorPosition = function() return 600, 400 end
  env.geterrorhandler = function() return function(err) table.insert(ctl.errors, err) end end

  env.LOOT_ITEM_SELF = 'You receive loot: %s.'
  env.LOOT_ITEM_SELF_MULTIPLE = 'You receive loot: %sx%d.'
  env.GetNumLootItems = function() return #ctl.lootSlots end
  env.GetLootSlotLink = function(slot) return ctl.lootSlots[slot] end
  env.C_Item = {
    GetItemCount = function(id) return ctl.bags[id] or 0 end,
    GetItemInfo = function(link) return type(link) == 'string' and link:match('%[(.-)%]') or nil end,
    GetItemNameByID = function(id) return ctl.itemNames and ctl.itemNames[id] end,
  }

  env.C_Timer = { After = function(_, fn) table.insert(ctl.timers, fn) end }
  env.C_EventUtils = { IsEventValid = function(event) return not ctl.invalidEvents[event] end }
  env.C_AddOns = { GetAddOnMetadata = function(_, field) if field == 'Version' then return '2.0.0-test' end end }

  env.Enum = { TooltipDataType = { Item = 0, Unit = 2 }, LootSlotType = { Item = 1 } }
  env.TooltipDataProcessor = {
    AddTooltipPostCall = function(kind, fn)
      ctl.tooltipCallbacks[kind] = ctl.tooltipCallbacks[kind] or {}
      table.insert(ctl.tooltipCallbacks[kind], fn)
    end,
  }
  env.Settings = {
    RegisterCanvasLayoutCategory = function(frame, name)
      ctl.optionsPanel = frame
      return { GetID = function() return 'category:' .. name end }
    end,
    RegisterAddOnCategory = function(category) ctl.optionsCategory = category end,
    OpenToCategory = function(id) ctl.openedCategory = id end,
  }

  env.CreateFrame = function(kind, name, parent)
    local frame = newObject(kind, name, parent)
    if name then env[name] = frame end
    return frame
  end
  env.UIParent = newObject('Frame', 'UIParent')
  env.Minimap = newObject('Frame', 'Minimap')
  env.Minimap._width = 140
  env.GameTooltip = newObject('GameTooltip', 'GameTooltip')
  env.DEFAULT_CHAT_FRAME = { AddMessage = function(_, message) table.insert(ctl.chat, message) end }
  env.UISpecialFrames = {}
  env.SlashCmdList = {}

  ctl.env = env
  ctl.ns = {}

  -- control helpers ------------------------------------------------------------

  local function protected(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then table.insert(ctl.errors, err) end
  end

  function ctl.fire(event, ...)
    for _, frame in ipairs(ctl.frames) do
      if frame._events[event] and frame._scripts.OnEvent then
        protected(frame._scripts.OnEvent, frame, event, ...)
      end
    end
  end

  function ctl.runTimers()
    local guard = 0
    while #ctl.timers > 0 do
      guard = guard + 1
      if guard > 500 then error('timer loop') end
      local fn = table.remove(ctl.timers, 1)
      protected(fn)
    end
  end

  -- fire an event and let delayed checks run
  function ctl.event(event, ...)
    ctl.fire(event, ...)
    ctl.runTimers()
  end

  function ctl.advance(seconds) ctl.clock = ctl.clock + seconds end
  function ctl.advanceDays(days) ctl.now = ctl.now + days * 86400 end

  function ctl.moveTo(zone, subzone)
    ctl.zone, ctl.subzone = zone, subzone or ''
    ctl.event('ZONE_CHANGED_NEW_AREA')
  end

  function ctl.slash(line)
    protected(env.SlashCmdList.MEMORYFOREVER, line or '')
  end

  function ctl.showUnitTooltip(unit)
    env.GameTooltip._lines = {}
    env.GameTooltip._unit = unit
    for _, fn in ipairs(ctl.tooltipCallbacks[env.Enum.TooltipDataType.Unit] or {}) do
      protected(fn, env.GameTooltip, { guid = ctl.units[unit] and ctl.units[unit].guid })
    end
    return env.GameTooltip._lines
  end

  function ctl.showItemTooltip(name, id)
    env.GameTooltip._lines = {}
    env.GameTooltip._unit = nil
    env.GameTooltip._item = { name = name, link = '|cffffffff|Hitem:' .. id .. '::|h[' .. name .. ']|h|r', id = id }
    for _, fn in ipairs(ctl.tooltipCallbacks[env.Enum.TooltipDataType.Item] or {}) do
      protected(fn, env.GameTooltip, { id = id })
    end
    return env.GameTooltip._lines
  end

  function ctl.chatText()
    return table.concat(ctl.chat, '\n')
  end

  function ctl.char()
    local realm = env.MemoryForeverDB.realms[ctl.realm]
    return realm and realm[ctl.units.player.guid]
  end

  -- SavedVariables as the client would write and read them on /reload
  function ctl.saved()
    local result = {}
    for _, name in ipairs(ctl.savedVariableNames or {}) do
      if env[name] ~= nil then
        local chunk = 'return ' .. serialize(env[name])
        result[name] = assert(loadstring(chunk))()
      end
    end
    return result
  end

  return ctl
end

--[[
Reads the file list (and SavedVariables names) from a TOC.
]]
function M.readToc(path)
  local files, savedVariables, meta = {}, {}, {}
  for line in io.lines(path) do
    line = line:gsub('\r$', '')
    local key, value = line:match('^##%s*([%w%-_]+):%s*(.-)%s*$')
    if key then
      meta[key] = value
      if key == 'SavedVariables' then
        for name in value:gmatch('[^,%s]+') do table.insert(savedVariables, name) end
      end
    elseif line:match('%S') and not line:match('^#') then
      table.insert(files, (line:gsub('\\', '/'):gsub('^%s+', ''):gsub('%s+$', '')))
    end
  end
  return files, savedVariables, meta
end

--[[
Creates a client, loads the addon through the TOC, restores SavedVariables
and fires the login events.
]]
function M.start(options)
  options = options or {}
  local ctl = M.newClient(options)
  if options.configure then options.configure(ctl) end
  local files, savedVariables = M.readToc(options.toc or 'MemoryForever_Camelot.toc')
  ctl.savedVariableNames = savedVariables
  for _, file in ipairs(files) do
    local chunk, err = loadfile(file)
    if not chunk then error('cannot load ' .. file .. ': ' .. tostring(err)) end
    setfenv(chunk, ctl.env)
    local ok, runErr = pcall(chunk, ADDON, ctl.ns)
    if not ok then table.insert(ctl.errors, file .. ': ' .. tostring(runErr)) end
  end
  for name, value in pairs(options.saved or {}) do ctl.env[name] = deepCopy(value) end
  if options.login ~= false then
    ctl.fire('ADDON_LOADED', ADDON)
    ctl.fire('PLAYER_LOGIN')
    ctl.fire('PLAYER_ENTERING_WORLD', true, false)
    ctl.runTimers()
  end
  return ctl
end

return M
