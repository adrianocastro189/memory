--[[
Startup: SavedVariables on ADDON_LOADED, everything else on PLAYER_LOGIN
(when the player's GUID, realm and level are available).
]]
local ADDON, ns = ...

local started = false

local function start()
  if started then return end
  -- defensive: run the DB init again in case ADDON_LOADED was missed
  ns.DB.init()

  local realm = ns.Safe.str(ns.Safe.api('GetRealmName'))
  local guid = ns.Safe.unitGUID('player')
  if not realm or not guid then
    ns.print('Could not identify the character. Memories are off for this session.')
    return
  end
  local name = ns.Safe.unitName('player')
  local _, class = ns.Safe.api('UnitClass', 'player')
  ns.Repository.bind(realm, guid, name, class)
  started = true

  ns.Trackers.enableAll()
  ns.Tooltip.setup()
  ns.Options.setup()
  ns.MinimapButton.update()

  -- the first memory: logging in
  ns.record({ category = 'misc', path = {}, interaction = 'login', quiet = true })

  ns.print(ns.VERSION .. ' loaded. Type ' .. ns.highlight('/mem') .. ' to open the journal.')
  for _, notice in ipairs(ns.pendingNotices or {}) do ns.print(notice) end
  ns.pendingNotices = nil
  ns.debug('started ' .. ns.VERSION)
end

ns.Events.on('ADDON_LOADED', function(_, loaded)
  if loaded == ADDON then ns.DB.init() end
end)

ns.Events.on('PLAYER_LOGIN', start)

ns.start = start
