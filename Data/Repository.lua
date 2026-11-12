--[[
Reads and writes the current character's memories. Characters are keyed by
realm name and player GUID, as in the original addon.
]]
local _, ns = ...

local Repository = {}
ns.Repository = Repository

Repository.CATEGORIES = { 'misc', 'npcs', 'players', 'zones', 'items', 'deaths', 'levels' }

local current

local function isLeaf(value)
  return type(value) == 'table' and type(value.x) == 'number'
end
Repository.isLeaf = isLeaf

--[[
Selects (and creates if needed) the character's memory table.
]]
function Repository.bind(realm, guid, name, class)
  if not ns.db or not realm or not guid then return nil end
  local players = ns.db.realms[realm]
  if type(players) ~= 'table' then
    players = {}
    ns.db.realms[realm] = players
  end
  local char = players[guid]
  if type(char) ~= 'table' then
    char = {}
    players[guid] = char
  end
  for _, category in ipairs(Repository.CATEGORIES) do
    if type(char[category]) ~= 'table' then char[category] = {} end
  end
  char.meta = type(char.meta) == 'table' and char.meta or {}
  char.meta.name = name or char.meta.name
  char.meta.class = class or char.meta.class
  current = char
  return char
end

function Repository.char()
  return current
end

function Repository.isReady()
  return current ~= nil
end

--[[
Walks to the leaf for (category, path, interaction). With create, missing
tables are created. Returns the leaf table or nil.
]]
function Repository.node(category, path, interaction, create)
  if not current then return nil end
  local node = current[category]
  if type(node) ~= 'table' then return nil end
  for i = 1, #path do
    local key = path[i]
    if key == nil then return nil end
    local nextNode = node[key]
    -- never overwrite a stored memory with a path table
    if isLeaf(nextNode) then return nil end
    if type(nextNode) ~= 'table' then
      if not create then return nil end
      nextNode = {}
      node[key] = nextNode
    end
    node = nextNode
  end
  local leaf = node[interaction]
  if not isLeaf(leaf) then
    if not create then return nil end
    leaf = { first = -1, last = -1, x = 0 }
    node[interaction] = leaf
  end
  return leaf
end

--[[
Returns the stored memory (an empty one when it never happened). Unlike the
original addon this never creates data as a side effect.
]]
function Repository.get(category, path, interaction)
  return ns.Memory.new(category, path, interaction, Repository.node(category, path, interaction, false))
end

--[[
Records that something happened x times now. Returns the updated leaf.
]]
function Repository.store(category, path, interaction, x, snapshot)
  local leaf = Repository.node(category, path, interaction, true)
  if not leaf then return nil end
  local value = (snapshot or ns.MemoryString.capture()):toString()
  if not ns.MemoryString.parse(leaf.first) then leaf.first = value end
  leaf.last = value
  leaf.x = leaf.x + (x or 1)
  return leaf
end

--[[
All memories stored directly under a path (one per interaction type).
]]
function Repository.list(category, path)
  local memories = {}
  if not current or type(current[category]) ~= 'table' then return memories end
  local node = current[category]
  for i = 1, #path do
    node = node[path[i]]
    if type(node) ~= 'table' or isLeaf(node) then return memories end
  end
  for interaction, leaf in pairs(node) do
    if isLeaf(leaf) and leaf.x > 0 then
      table.insert(memories, ns.Memory.new(category, path, interaction, leaf))
    end
  end
  table.sort(memories, function(a, b) return tostring(a.interaction) < tostring(b.interaction) end)
  return memories
end

--[[
Calls fn(memory) for every stored memory in a category (recursively).
]]
function Repository.walk(category, fn)
  if not current or type(current[category]) ~= 'table' then return end
  local function visit(node, path)
    for key, value in pairs(node) do
      if isLeaf(value) then
        if value.x > 0 then
          local copy = {}
          for i = 1, #path do copy[i] = path[i] end
          fn(ns.Memory.new(category, copy, key, value))
        end
      elseif type(value) == 'table' then
        table.insert(path, key)
        visit(value, path)
        table.remove(path)
      end
    end
  end
  visit(current[category], {})
end

-- levels ---------------------------------------------------------------------

function Repository.storeLevel(level, snapshot)
  if not current then return end
  level = tonumber(level)
  if not level then return end
  current.levels[level] = {
    date = snapshot.date,
    zone = snapshot.zone or '-',
    subZone = snapshot.subZone or '-',
    moment = snapshot.moment or 0,
  }
end

function Repository.levels()
  local levels = {}
  if not current then return levels end
  for level, data in pairs(current.levels) do
    if tonumber(level) and type(data) == 'table' then
      table.insert(levels, {
        level = tonumber(level),
        date = data.date,
        zone = data.zone ~= '-' and data.zone or nil,
        subZone = data.subZone ~= '-' and data.subZone or nil,
        moment = tonumber(data.moment),
      })
    end
  end
  table.sort(levels, function(a, b) return a.level < b.level end)
  return levels
end
