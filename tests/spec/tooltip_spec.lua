local H, WoW = ...
local describe, it = H.describe, H.it

describe('Tooltips', function()
  it('installs through TooltipDataProcessor', function()
    local ctl = WoW.start()
    H.eq(ctl.ns.Tooltip.installed, 'TooltipDataProcessor')
  end)

  it('shows NPC memories, including from the target frame', function()
    local ctl = WoW.start()
    ctl.units.npc = { guid = 'Creature-0-1-2-3-240-0001', name = 'Marshal Dughan' }
    ctl.event('GOSSIP_SHOW')
    ctl.units.target = ctl.units.npc
    local lines = ctl.showUnitTooltip('target')
    H.contains(lines, 'Memory Forever')
    H.contains(lines, 'Talked | x1')
    H.contains(lines, 'When | Nov 12, 2026 [10]')
  end)

  it('shows player memories keyed by name and realm', function()
    local ctl = WoW.start()
    ctl.groupSize = 2
    ctl.units.party1 = { guid = 'Player-1-00000002', name = 'Sam' }
    ctl.event('GROUP_ROSTER_UPDATE')
    ctl.units.mouseover = ctl.units.party1
    H.contains(ctl.showUnitTooltip('mouseover'), 'Grouped | x1')
  end)

  it('shows item memories', function()
    local ctl = WoW.start()
    ctl.event('CHAT_MSG_LOOT', 'You receive loot: |cffffffff|Hitem:2589::|h[Linen Cloth]|h|rx2.', 'Tester')
    ctl.advanceDays(3)
    ctl.event('CHAT_MSG_LOOT', 'You receive loot: |cffffffff|Hitem:2589::|h[Linen Cloth]|h|r.', 'Tester')
    local lines = ctl.showItemTooltip('Linen Cloth', 2589)
    H.contains(lines, 'Looted | x3')
    H.contains(lines, 'First | Nov 12, 2026')
    H.contains(lines, 'Last | Nov 15, 2026')
  end)

  it('adds nothing for unknown units, secret units, or when disabled', function()
    local ctl = WoW.start()
    ctl.units.mouseover = { guid = 'Creature-0-1-2-3-9-0001', name = 'Stranger' }
    H.eq(#ctl.showUnitTooltip('mouseover'), 0)
    ctl.units.npc = { guid = 'Creature-0-1-2-3-240-0001', name = 'Marshal Dughan' }
    ctl.event('GOSSIP_SHOW')
    ctl.units.mouseover = ctl.units.npc
    ctl.restricted = true
    H.eq(#ctl.showUnitTooltip('mouseover'), 0)
    ctl.restricted = false
    ctl.ns.Settings.set('showInTooltips', false)
    H.eq(#ctl.showUnitTooltip('mouseover'), 0)
    H.noErrors(ctl)
  end)
end)
