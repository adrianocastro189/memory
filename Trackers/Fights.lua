--[[
Fights (redesigned).

The original read combat log subevents (SWING_DAMAGE, SPELL_DAMAGE, ...). The
combat log is closed to addons on the Midnight engine, so this is now an
approximation: while you're in combat, every attackable NPC you target or
focus is remembered, and when combat ends each of them is recorded as
"fought X". Units whose GUID or name is secret are skipped.

Fighting three Kobold Vermin in one combat stores x = 3 on "Kobold Vermin".
]]
local _, ns = ...

local Safe = ns.Safe

local Fights = { active = false, seen = {} }
ns.Fights = Fights

local VERBS = { past = 'had a fight', pastConnector = 'with', present = 'have a fight', presentConnector = 'with' }

function Fights.snapshot(unit)
  if not Fights.active then return end
  if not Safe.unitExists(unit) then return end
  local guid = Safe.unitGUID(unit)
  if not guid or not Safe.isNpcGuid(guid) then return end
  if Safe.api('UnitCanAttack', 'player', unit) ~= true then return end
  local name = Safe.unitName(unit)
  if not name then return end
  Fights.seen[guid] = name
end

function Fights.start()
  Fights.active = true
  Fights.seen = {}
  Fights.snapshot('target')
  Fights.snapshot('focus')
end

function Fights.finish()
  if not Fights.active then return end
  Fights.active = false
  if not ns.Repository.isReady() then return end

  local counts, names = {}, {}
  for _, name in pairs(Fights.seen) do
    if not counts[name] then table.insert(names, name) end
    counts[name] = (counts[name] or 0) + 1
  end
  Fights.seen = {}
  table.sort(names)

  -- one reminder per combat at most
  local remindIndex = #names > 0 and math.random(#names) or 0
  for i, name in ipairs(names) do
    local verbs = ns.Util.copy(VERBS)
    verbs.subject = name
    ns.record({
      category = 'npcs', path = { name }, interaction = 'fight', x = counts[name],
      verbs = verbs, quiet = i ~= remindIndex,
    })
  end
end

ns.Trackers.register('fights', {
  label = 'Fights (approximate, no combat log)',
  events = { 'PLAYER_REGEN_DISABLED', 'PLAYER_REGEN_ENABLED' },
  setup = function(on)
    on('PLAYER_REGEN_DISABLED', Fights.start)
    on('PLAYER_REGEN_ENABLED', Fights.finish)
    on('PLAYER_TARGET_CHANGED', function() Fights.snapshot('target') end)
    on('PLAYER_FOCUS_CHANGED', function() Fights.snapshot('focus') end)
  end,
})
