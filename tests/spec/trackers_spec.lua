local H, WoW = ...
local describe, it = H.describe, H.it

local DUGHAN = { guid = 'Creature-0-1-2-3-240-0001', name = 'Marshal Dughan' }
local KOBOLD_A = { guid = 'Creature-0-1-2-3-6-0001', name = 'Kobold Vermin', canAttack = true }
local KOBOLD_B = { guid = 'Creature-0-1-2-3-6-0002', name = 'Kobold Vermin', canAttack = true }
local LINK = '|cffffffff|Hitem:2589::::::::10:::::::|h[Linen Cloth]|h|r'

describe('Deaths', function()
  it('records the total and the place', function()
    local ctl = WoW.start()
    ctl.event('PLAYER_DEAD')
    local char = ctl.char()
    H.eq(char.misc.others.die.x, 1)
    H.eq(char.deaths['Elwynn Forest']['Goldshire'].die.x, 1)
    H.noErrors(ctl)
  end)

  it('ignores the extra PLAYER_DEAD Forever fires for one death', function()
    local ctl = WoW.start()
    ctl.event('PLAYER_DEAD')
    ctl.advance(4)
    ctl.event('PLAYER_DEAD')
    H.eq(ctl.char().misc.others.die.x, 1)
    ctl.advance(31)
    ctl.event('PLAYER_DEAD')
    H.eq(ctl.char().misc.others.die.x, 2)
  end)

  it('counts a death within 30 seconds when they were revived in between', function()
    local ctl = WoW.start()
    ctl.event('PLAYER_DEAD')
    ctl.advance(5)
    ctl.event('PLAYER_ALIVE')
    ctl.advance(5)
    ctl.event('PLAYER_DEAD')
    H.eq(ctl.char().misc.others.die.x, 2)
    H.eq(ctl.char().deaths['Elwynn Forest']['Goldshire'].die.x, 2)
  end)

  it('pops up when dying where you died before', function()
    local ctl = WoW.start()
    local shown = {}
    ctl.ns.Toast.show = function(title, text) table.insert(shown, text) end
    ctl.event('PLAYER_DEAD')
    ctl.advance(4)
    ctl.event('PLAYER_DEAD')
    H.eq(#shown, 0)
    ctl.event('PLAYER_ALIVE')
    ctl.event('PLAYER_DEAD')
    H.contains(shown, 'You have died here 2 times')
  end)
end)

describe('Levels', function()
  it('stores the level with place and takes a screenshot', function()
    local ctl = WoW.start()
    ctl.ns.Moments.add('Leveling with Sam')
    ctl.event('PLAYER_LEVEL_UP', 11)
    local level = ctl.char().levels[11]
    H.eq(level.zone, 'Elwynn Forest')
    H.eq(level.subZone, 'Goldshire')
    H.eq(level.moment, 1)
    H.eq(ctl.screenshots, 1)
    H.contains(ctl.raidNotices, 'Reached level 11')
  end)

  it('skips the screenshot when disabled', function()
    local ctl = WoW.start()
    ctl.ns.Settings.set('screenshotOnLevelUp', false)
    ctl.event('PLAYER_LEVEL_UP', 11)
    H.eq(ctl.screenshots, 0)
    H.truthy(ctl.char().levels[11])
  end)
end)

describe('Achievements', function()
  it('screenshots and counts', function()
    local ctl = WoW.start()
    ctl.event('ACHIEVEMENT_EARNED', 6, false)
    H.eq(ctl.screenshots, 1)
    H.eq(ctl.char().misc.achievements['Achievement 6'].earn.x, 1)
  end)
end)

describe('NPC interactions', function()
  it('records talking via the npc unit, once per 10 minutes', function()
    local ctl = WoW.start()
    ctl.units.npc = DUGHAN
    ctl.event('GOSSIP_SHOW')
    ctl.event('GOSSIP_SHOW')
    H.eq(ctl.char().npcs['Marshal Dughan'].talk.x, 1)
    ctl.advance(601)
    ctl.event('QUEST_DETAIL')
    H.eq(ctl.char().npcs['Marshal Dughan'].talk.x, 2)
  end)

  it('records quest turn-ins (upstream known issue)', function()
    local ctl = WoW.start()
    ctl.units.npc = DUGHAN
    ctl.event('QUEST_COMPLETE')
    ctl.event('QUEST_TURNED_IN', 123, 100, 0)
    ctl.event('QUEST_COMPLETE')
    ctl.event('QUEST_TURNED_IN', 124, 100, 0)
    H.eq(ctl.char().npcs['Marshal Dughan'].quest.x, 2)
  end)

  it('counts a turn-in that arrives inside the 15 second window', function()
    local ctl = WoW.start()
    ctl.units.npc = DUGHAN
    ctl.event('QUEST_COMPLETE')
    ctl.advance(10)
    ctl.event('QUEST_TURNED_IN', 123, 100, 0)
    H.eq(ctl.char().npcs['Marshal Dughan'].quest.x, 1)
  end)

  it('drops a turn-in that arrives after the quest window closes', function()
    local ctl = WoW.start()
    ctl.units.npc = DUGHAN
    ctl.event('QUEST_COMPLETE')
    ctl.advance(16)
    ctl.event('QUEST_TURNED_IN', 123, 100, 0)
    H.eq(ctl.char().npcs['Marshal Dughan'].quest, nil)
  end)

  it('ignores game objects such as wanted posters', function()
    local ctl = WoW.start()
    ctl.units.npc = { guid = 'GameObject-0-1-2-3-55-0001', name = 'Wanted Poster' }
    ctl.units.target = DUGHAN
    ctl.event('QUEST_DETAIL')
    H.eq(ctl.char().npcs['Wanted Poster'], nil)
    H.eq(ctl.char().npcs['Marshal Dughan'], nil)
  end)

  it('records business when money changes at a merchant', function()
    local ctl = WoW.start()
    ctl.units.npc = { guid = 'Creature-0-1-2-3-1213-0001', name = 'Corina Steele' }
    ctl.event('PLAYER_MONEY')
    H.eq(ctl.char().npcs['Corina Steele'], nil)
    ctl.event('MERCHANT_SHOW')
    ctl.event('PLAYER_MONEY')
    ctl.event('PLAYER_MONEY')
    ctl.event('MERCHANT_CLOSED')
    ctl.event('PLAYER_MONEY')
    local npc = ctl.char().npcs['Corina Steele']
    H.eq(npc.talk.x, 1)
    H.eq(npc.business.x, 1)
  end)
end)

describe('Fights (no combat log)', function()
  it('records attackable NPCs targeted during combat', function()
    local ctl = WoW.start()
    ctl.units.target = KOBOLD_A
    ctl.event('PLAYER_REGEN_DISABLED')
    ctl.units.target = KOBOLD_B
    ctl.event('PLAYER_TARGET_CHANGED')
    ctl.units.target = DUGHAN -- friendly: not attackable
    ctl.event('PLAYER_TARGET_CHANGED')
    ctl.event('PLAYER_REGEN_ENABLED')
    local npcs = ctl.char().npcs
    H.eq(npcs['Kobold Vermin'].fight.x, 2)
    H.eq(npcs['Marshal Dughan'], nil)
    H.noErrors(ctl)
  end)

  it('records an attackable focus that was never the target', function()
    local ctl = WoW.start()
    ctl.units.focus = KOBOLD_A
    ctl.event('PLAYER_REGEN_DISABLED')
    ctl.event('PLAYER_REGEN_ENABLED')
    H.eq(ctl.char().npcs['Kobold Vermin'].fight.x, 1)
    H.noErrors(ctl)
  end)

  it('ignores target changes out of combat', function()
    local ctl = WoW.start()
    ctl.units.target = KOBOLD_A
    ctl.event('PLAYER_TARGET_CHANGED')
    ctl.event('PLAYER_REGEN_ENABLED')
    H.eq(ctl.char().npcs['Kobold Vermin'], nil)
  end)
end)

describe('Loot', function()
  it('parses own loot messages in the open world', function()
    local ctl = WoW.start()
    ctl.event('CHAT_MSG_LOOT', 'You receive loot: ' .. LINK .. 'x3.', 'Tester')
    ctl.event('CHAT_MSG_LOOT', 'You receive loot: ' .. LINK .. '.', 'Tester')
    ctl.event('CHAT_MSG_LOOT', 'Sam receives loot: ' .. LINK .. '.', 'Sam')
    H.eq(ctl.char().items['Linen Cloth'].loot.x, 4)
    H.noErrors(ctl)
  end)

  it('uses the loot window and bag counts in instances (chat is secret there)', function()
    local ctl = WoW.start()
    ctl.inInstance = true
    ctl.bags[2589] = 5
    ctl.lootSlots = { LINK, '|cff00ccff|Hcurrency:1::|h[Some Currency]|h|r' }
    ctl.event('LOOT_OPENED')
    ctl.event('CHAT_MSG_LOOT', ctl.SECRET, ctl.SECRET)
    ctl.bags[2589] = 7
    ctl.event('LOOT_CLOSED')
    H.eq(ctl.char().items['Linen Cloth'].loot.x, 2)
    H.eq(ctl.char().items['Some Currency'], nil)
    H.noErrors(ctl)
  end)

  it('does not count items that were not taken', function()
    local ctl = WoW.start()
    ctl.inInstance = true
    ctl.lootSlots = { LINK }
    ctl.event('LOOT_OPENED')
    ctl.event('LOOT_CLOSED')
    H.eq(ctl.char().items['Linen Cloth'], nil)
  end)
end)

describe('Grouping', function()
  local function party(ctl)
    ctl.groupSize = 3
    ctl.units.party1 = { guid = 'Player-1-00000002', name = 'Sam' }
    ctl.units.party2 = { guid = 'Player-2-00000003', name = 'Alex', realm = 'Other Realm' }
  end

  it('records each member once per day with full names', function()
    local ctl = WoW.start()
    party(ctl)
    ctl.event('GROUP_ROSTER_UPDATE')
    ctl.event('GROUP_ROSTER_UPDATE')
    local players = ctl.char().players
    H.eq(players['Sam-ForeverRealm'].party.x, 1)
    H.eq(players['Alex-OtherRealm'].party.x, 1)
    ctl.advanceDays(1)
    ctl.event('GROUP_ROSTER_UPDATE')
    H.eq(players['Sam-ForeverRealm'].party.x, 2)
  end)

  it('records a party that is already formed at login', function()
    local ctl = WoW.start({ configure = function(client)
      client.groupSize = 2
      client.units.party1 = { guid = 'Player-1-00000002', name = 'Sam' }
    end })
    H.eq(ctl.char().players['Sam-ForeverRealm'].party.x, 1)
    H.noErrors(ctl)
  end)

  it('keeps a member who leaves before combat ends', function()
    local ctl = WoW.start()
    party(ctl)
    ctl.inCombat = true
    ctl.event('GROUP_ROSTER_UPDATE')
    ctl.groupSize = 1
    ctl.units.party1 = nil
    ctl.units.party2 = nil
    ctl.inCombat = false
    ctl.event('PLAYER_REGEN_ENABLED')
    H.eq(ctl.char().players['Sam-ForeverRealm'].party.x, 1)
    H.eq(ctl.char().players['Alex-OtherRealm'].party.x, 1)
  end)

  it('waits until combat ends to read names', function()
    local ctl = WoW.start()
    party(ctl)
    ctl.inCombat = true
    ctl.event('GROUP_ROSTER_UPDATE')
    H.eq(ctl.char().players['Sam-ForeverRealm'], nil)
    ctl.inCombat = false
    ctl.event('PLAYER_REGEN_ENABLED')
    H.eq(ctl.char().players['Sam-ForeverRealm'].party.x, 1)
  end)
end)
