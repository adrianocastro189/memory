--[[
NPC interactions: talking (gossip, quest and merchant windows), doing business
(money changes while a merchant is open: buy, sell, repair) and turning in
quests.

The NPC comes from the 'npc' unit, which is the creature whose window is
open, instead of comparing the target's name with the gossip frame title as
the original did. That comparison broke when the frame globals changed, and it
was the reason quest NPCs were never recorded.

Talk and business with the same NPC count once per 10 minutes; each quest
turn-in counts.
]]
local _, ns = ...

local Safe = ns.Safe
local DEDUPE = 600
local QUEST_WINDOW = 15

local Npcs = { recent = {} }
ns.Npcs = Npcs

local VERBS = {
  talk = { past = 'spoke', pastConnector = 'with', present = 'speak', presentConnector = 'with' },
  business = { past = 'had done business', pastConnector = 'with', present = 'do business', presentConnector = 'with' },
  quest = { past = 'turned in a quest', pastConnector = 'to', present = 'turn in a quest', presentConnector = 'to' },
}

--[[
Name of the NPC the player is interacting with, or nil (no NPC, a game object
such as a wanted poster, or a secret value).
]]
function Npcs.current()
  for _, unit in ipairs({ 'npc', 'questnpc' }) do
    local guid = Safe.unitGUID(unit)
    if guid then
      if not Safe.isNpcGuid(guid) then return nil end
      return (Safe.unitName(unit))
    end
  end
  local guid = Safe.unitGUID('target')
  if guid and Safe.isNpcGuid(guid) then return (Safe.unitName('target')) end
  return nil
end

local function recordInteraction(name, interaction, dedupe)
  if not name or not ns.Repository.isReady() then return end
  if dedupe then
    local key = interaction .. ':' .. name
    local now = ns.Events.now()
    if Npcs.recent[key] and now - Npcs.recent[key] < DEDUPE then return end
    Npcs.recent[key] = now
  end
  local verbs = ns.Util.copy(VERBS[interaction])
  verbs.subject = name
  ns.record({ category = 'npcs', path = { name }, interaction = interaction, verbs = verbs })
end

ns.Trackers.register('npcs', {
  label = 'NPC interactions (talk, business, quests)',
  apis = { 'UnitGUID', 'UnitName' },
  setup = function(on)
    local function talk() recordInteraction(Npcs.current(), 'talk', true) end
    for _, event in ipairs({ 'GOSSIP_SHOW', 'QUEST_GREETING', 'QUEST_DETAIL', 'QUEST_PROGRESS', 'QUEST_COMPLETE' }) do
      on(event, talk)
    end

    on('QUEST_COMPLETE', function()
      Npcs.questNpc = Npcs.current()
      Npcs.questNpcTime = ns.Events.now()
    end)
    on('QUEST_TURNED_IN', function()
      if Npcs.questNpc and ns.Events.now() - (Npcs.questNpcTime or 0) <= QUEST_WINDOW then
        recordInteraction(Npcs.questNpc, 'quest', false)
      end
      Npcs.questNpc = nil
    end)

    on('MERCHANT_SHOW', function()
      Npcs.merchant = Npcs.current()
      recordInteraction(Npcs.merchant, 'talk', true)
    end)
    on('MERCHANT_CLOSED', function() Npcs.merchant = nil end)
    on('PLAYER_MONEY', function()
      if Npcs.merchant then recordInteraction(Npcs.merchant, 'business', true) end
    end)
  end,
})
