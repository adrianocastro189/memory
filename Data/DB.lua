--[[
SavedVariables initialization and schema migrations.

MemoryForeverDB = {
  schemaVersion = 2,
  settings = { [name] = value },            -- account-wide, see Data/Settings.lua
  moments  = { 'label', ... },              -- account-wide, index is stored in memories
  realms   = {
    [realmName] = {
      [playerGUID] = {
        meta    = { name = 'Name', class = 'WARRIOR' },
        misc    = { others = { die = leaf }, login = leaf, achievements = { [name] = { earn = leaf } } },
        npcs    = { [npcName]  = { talk = leaf, business = leaf, fight = leaf, quest = leaf } },
        players = { [Name-Realm] = { party = leaf } },
        zones   = { [zone] = { visit = leaf, subzones = { [subzone] = { visit = leaf } } } },
        items   = { [itemName] = { loot = leaf } },
        deaths  = { [zone] = { [subzone or zone] = { die = leaf } } },
        levels  = { [level] = { date, zone, subZone, moment } },
      },
    },
  },
}
leaf = { first = MemoryString, last = MemoryString, x = count }

Schema versions:
  0 - nothing saved yet
  1 - the original Memory addon (MemoryAddon_DataSet / MemoryAddon_Settings)
  2 - Memory Forever 2.0

The init is defensive: it runs on ADDON_LOADED and again on PLAYER_LOGIN, and
repairs missing or mistyped tables instead of assuming the file loaded (the
Forever beta sometimes failed to load addon settings).
]]
local _, ns = ...

local DB = {}
ns.DB = DB

DB.SCHEMA_VERSION = 2

local function ensureTable(parent, key)
  if type(parent[key]) ~= 'table' then parent[key] = {} end
  return parent[key]
end

--[[
Repairs the top-level shape. Safe to call any number of times.
]]
function DB.ensureShape(db)
  ensureTable(db, 'settings')
  ensureTable(db, 'realms')
  local moments = ensureTable(db, 'moments')
  for i = #moments, 1, -1 do
    if type(moments[i]) ~= 'string' then moments[i] = tostring(moments[i]) end
  end
  for realm, players in pairs(db.realms) do
    if type(players) ~= 'table' then db.realms[realm] = nil end
  end
  return db
end

--[[
Imports the original Memory addon's SavedVariables when they're present
(the user copied the old SavedVariables file, see README) and this database
has no character data yet. Returns the number of characters imported.
]]
function DB.importLegacy(db)
  local legacyData = MemoryAddon_DataSet
  local legacySettings = MemoryAddon_Settings
  if type(legacyData) ~= 'table' and type(legacySettings) ~= 'table' then return 0 end

  if next(db.realms) ~= nil then
    db.legacyImportSkipped = true
    return 0
  end

  local characters = 0
  local copiedRows = false
  if type(legacyData) == 'table' then
    for realm, players in pairs(legacyData) do
      if type(realm) == 'string' and type(players) == 'table' then
        db.realms[realm] = ns.Util.copy(players)
        copiedRows = true
        for _ in pairs(players) do characters = characters + 1 end
      end
    end
  end

  local copiedSettings = false
  if type(legacySettings) == 'table' then
    if type(legacySettings.moments) == 'table' and #db.moments == 0 then
      for _, moment in ipairs(legacySettings.moments) do
        table.insert(db.moments, tostring(moment))
        copiedSettings = true
      end
    end
    for oldKey, newKey in pairs(ns.Settings.ALIASES) do
      if legacySettings[oldKey] ~= nil and db.settings[newKey] == nil then
        db.settings[newKey] = legacySettings[oldKey]
        copiedSettings = true
      end
    end
  end

  -- a file we could not read must stay on disk so it can be tried again
  if not copiedRows and not copiedSettings then return 0 end

  db.importedFrom = 'Memory 1.x'
  if copiedRows then MemoryAddon_DataSet = nil end
  if copiedSettings then MemoryAddon_Settings = nil end
  return characters
end

DB.MIGRATIONS = {
  -- 0/1 -> 2: create the new layout and import the original addon's data
  [2] = function(db)
    DB.ensureShape(db)
    local imported = DB.importLegacy(db)
    if imported > 0 then
      ns.pendingNotices = ns.pendingNotices or {}
      table.insert(ns.pendingNotices, 'Imported memories for ' .. ns.Util.plural(imported, 'character') .. ' from the original Memory addon.')
    end
  end,
}

local function detectVersion(db)
  local version = tonumber(db.schemaVersion)
  if version then return version end
  if next(db) == nil then return 0 end
  return 1
end

--[[
Loads (or creates) MemoryForeverDB, runs pending migrations and exposes it as
ns.db. Idempotent.
]]
function DB.init()
  local db = MemoryForeverDB
  if type(db) ~= 'table' then
    db = {}
    MemoryForeverDB = db
  end

  local version = detectVersion(db)
  if version > DB.SCHEMA_VERSION then
    -- written by a newer version: don't migrate down, just make it usable
    ns.pendingNotices = ns.pendingNotices or {}
    table.insert(ns.pendingNotices, 'Saved data is from a newer version (schema ' .. version .. '). Some memories may not show.')
  else
    for target = version + 1, DB.SCHEMA_VERSION do
      local migrate = DB.MIGRATIONS[target]
      if migrate then migrate(db) end
      db.schemaVersion = target
    end
  end

  DB.ensureShape(db)
  ns.db = db
  return db
end
