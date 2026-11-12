--[[
Grouping with other players. Each player counts once per day.

Group member names are read out of combat only. If the roster changes during
combat, the update waits for PLAYER_REGEN_ENABLED, which avoids secret values
in restricted content.
]]
local _, ns = ...

local Safe = ns.Safe

local Group = { pending = false }
ns.Group = Group

function Group.fullName(unit)
  local name, realm = Safe.unitName(unit)
  if not name then return nil end
  realm = realm or Safe.str(Safe.api('GetRealmName')) or ''
  realm = string.gsub(realm, '%s', '')
  if realm == '' then return name end
  return name .. '-' .. realm
end

function Group.members()
  local units = {}
  if Safe.api('IsInRaid') then
    local count = tonumber(Safe.api('GetNumGroupMembers')) or 0
    for i = 1, count do table.insert(units, 'raid' .. i) end
  else
    local count = tonumber(Safe.api('GetNumSubgroupMembers')) or ((tonumber(Safe.api('GetNumGroupMembers')) or 1) - 1)
    for i = 1, count do table.insert(units, 'party' .. i) end
  end

  local names = {}
  for _, unit in ipairs(units) do
    local guid = Safe.unitGUID(unit)
    if guid and Safe.isPlayerGuid(guid) and Safe.api('UnitIsUnit', unit, 'player') ~= true then
      local fullName = Group.fullName(unit)
      if fullName then table.insert(names, fullName) end
    end
  end
  return names
end

function Group.update()
  if not ns.Repository.isReady() then return end
  if Safe.api('InCombatLockdown') then
    Group.pending = true
    return
  end
  Group.pending = false
  for _, fullName in ipairs(Group.members()) do
    local previous = ns.Repository.get('players', { fullName }, 'party')
    local groupedToday = previous.last and ns.Util.daysAgo(previous.last.date) == 0
    if not groupedToday then
      ns.record({
        category = 'players', path = { fullName }, interaction = 'party',
        verbs = { past = 'grouped', pastConnector = 'with', present = 'group', presentConnector = 'with', subject = fullName },
      })
    end
  end
end

ns.Trackers.register('group', {
  label = 'Grouping with players',
  events = { 'GROUP_ROSTER_UPDATE' },
  apis = { 'GetNumGroupMembers' },
  setup = function(on)
    on('GROUP_ROSTER_UPDATE', Group.update)
    on('PLAYER_REGEN_ENABLED', function()
      if Group.pending then Group.update() end
    end)
  end,
})
