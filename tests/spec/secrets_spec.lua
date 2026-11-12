local H, WoW = ...
local describe, it = H.describe, H.it

--[[
A full "restricted content" session: every unit read except the player is a
secret value, chat text is secret. Nothing may raise, nothing secret may be
stored, and memories that need hidden data are skipped.
]]
describe('Restricted content (secret values)', function()
  it('runs a whole dungeon session without errors', function()
    local ctl = WoW.start()
    ctl.restricted = true
    ctl.inInstance = true
    ctl.units.target = { guid = 'Creature-0-1-2-3-639-0001', name = 'Edwin VanCleef', canAttack = true }
    ctl.units.focus = ctl.units.target
    ctl.units.npc = { guid = 'Creature-0-1-2-3-1-0001', name = 'Quest Giver' }
    ctl.units.party1 = { guid = 'Player-1-00000002', name = 'Sam' }
    ctl.groupSize = 2

    ctl.moveTo('The Deadmines', 'Ironclad Cove')
    ctl.event('GROUP_ROSTER_UPDATE')
    ctl.event('PLAYER_REGEN_DISABLED')
    ctl.event('PLAYER_TARGET_CHANGED')
    ctl.event('PLAYER_FOCUS_CHANGED')
    ctl.event('CHAT_MSG_LOOT', ctl.SECRET, ctl.SECRET)
    ctl.event('PLAYER_DEAD')
    ctl.event('PLAYER_REGEN_ENABLED')
    ctl.event('GOSSIP_SHOW')
    ctl.event('QUEST_COMPLETE')
    ctl.event('QUEST_TURNED_IN', 1, 1, 1)
    ctl.event('MERCHANT_SHOW')
    ctl.event('PLAYER_MONEY')
    ctl.event('LOOT_OPENED')
    ctl.event('LOOT_CLOSED')
    ctl.event('PLAYER_LEVEL_UP', ctl.SECRET)
    ctl.showUnitTooltip('target')
    ctl.slash('here')
    ctl.slash('stats')
    ctl.slash('')

    H.noErrors(ctl)
    local char = ctl.char()
    H.eq(char.npcs['Edwin VanCleef'], nil, 'secret target skipped')
    H.eq(char.npcs['Quest Giver'], nil)
    H.eq(char.players['Sam-ForeverRealm'], nil)
    H.eq(char.zones['The Deadmines'].visit.x, 1, 'zone data is not secret')
    H.eq(char.misc.others.die.x, 1)
    WoW.serialize(ctl.env.MemoryForeverDB)
  end)

  it('treats a secret zone name as unknown', function()
    local ctl = WoW.start()
    ctl.zone = ctl.SECRET
    ctl.subzone = ctl.SECRET
    ctl.event('ZONE_CHANGED_NEW_AREA')
    ctl.event('PLAYER_DEAD')
    ctl.event('PLAYER_LEVEL_UP', 12)
    H.noErrors(ctl)
    H.eq(ctl.char().levels[12].zone, '-')
    WoW.serialize(ctl.env.MemoryForeverDB)
  end)

  it('keeps going when a handler throws, and reports it', function()
    local ctl = WoW.start()
    ctl.ns.Npcs.current = function() error('broken tracker') end
    ctl.units.npc = { guid = 'Creature-0-1-2-3-1-0001', name = 'Someone' }
    ctl.event('GOSSIP_SHOW')
    H.eq(#ctl.errors > 0, true)
    ctl.errors = {}
    ctl.event('PLAYER_DEAD')
    H.noErrors(ctl)
    H.eq(ctl.char().misc.others.die.x, 1)
  end)
end)
