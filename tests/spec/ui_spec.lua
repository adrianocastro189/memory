local H, WoW = ...
local describe, it = H.describe, H.it

local function session()
  local ctl = WoW.start()
  ctl.units.npc = { guid = 'Creature-0-1-2-3-240-0001', name = 'Marshal Dughan' }
  ctl.event('GOSSIP_SHOW')
  ctl.event('PLAYER_DEAD')
  ctl.event('PLAYER_LEVEL_UP', 11)
  ctl.event('CHAT_MSG_LOOT', 'You receive loot: |cffffffff|Hitem:2589::|h[Linen Cloth]|h|r.', 'Tester')
  ctl.advance(400)
  ctl.moveTo('Westfall', 'Sentinel Hill')
  ctl.advance(400)
  ctl.moveTo('Elwynn Forest', 'Goldshire')
  return ctl
end

describe('Queries', function()
  it('computes stats', function()
    local ctl = session()
    local s = ctl.ns.Queries.stats()
    H.eq(s.deaths, 1)
    H.eq(s.zones, 2)
    H.eq(s.subzones, 2)
    H.eq(s.mostVisited.label, 'Goldshire, Elwynn Forest')
    H.eq(s.mostVisited.x, 2)
    H.eq(s.deadliest.label, 'Goldshire, Elwynn Forest')
    H.eq(s.npcs, 1)
    H.eq(s.itemsLooted, 1)
    H.eq(s.levels, 1)
    H.eq(s.since, '26-11-12')
  end)

  it('names the player you grouped with most', function()
    local ctl = WoW.start()
    ctl.groupSize = 3
    ctl.units.party1 = { guid = 'Player-1-00000002', name = 'Sam' }
    ctl.units.party2 = { guid = 'Player-2-00000003', name = 'Alex', realm = 'Other Realm' }
    ctl.event('GROUP_ROSTER_UPDATE')
    ctl.advanceDays(1)
    ctl.groupSize = 2
    ctl.units.party2 = nil
    ctl.event('GROUP_ROSTER_UPDATE')
    local stats = ctl.ns.Queries.stats()
    H.eq(stats.players, 2)
    H.eq(stats.mostGrouped.label, 'Sam-ForeverRealm')
    H.eq(stats.mostGrouped.x, 2)
    ctl.slash('stats')
    H.contains(ctl.chatText(), 'Most grouped with')
    H.contains(ctl.chatText(), 'Sam-ForeverRealm (2)')
  end)

  it('sends a reminder to chat, a toast, both, or neither', function()
    local function remind(style)
      local ctl = WoW.start()
      ctl.randomValue = 0
      ctl.ns.Settings.set('printChance', 1)
      ctl.ns.Settings.set('reminderStyle', style)
      local shown = {}
      ctl.ns.Toast.show = function(_, text) table.insert(shown, text) end
      local before = #ctl.chat
      ctl.units.npc = { guid = 'Creature-0-1-2-3-240-0001', name = 'Marshal Dughan' }
      ctl.event('GOSSIP_SHOW')
      local added = {}
      for i = before + 1, #ctl.chat do table.insert(added, ctl.chat[i]) end
      return table.concat(added, '\n'), shown
    end

    local chat, toasts = remind('chat')
    H.contains(chat, 'Marshal Dughan')
    H.eq(#toasts, 0)
    chat, toasts = remind('toast')
    H.notContains(chat, 'Marshal Dughan')
    H.eq(#toasts, 1)
    chat, toasts = remind('both')
    H.contains(chat, 'Marshal Dughan')
    H.eq(#toasts, 1)
    chat, toasts = remind('off')
    H.notContains(chat, 'Marshal Dughan')
    H.eq(#toasts, 0)
  end)

  it('lists, filters and sorts journal entries', function()
    local ctl = session()
    local Q = ctl.ns.Queries
    local lines, total = Q.lines('zones', '', 'count')
    H.eq(total, 4)
    -- ties on count fall back to A-Z
    H.contains(lines[1], 'Elwynn Forest|r  visited 2')
    H.contains(lines[2], 'Goldshire, Elwynn Forest')
    H.contains(lines[4], 'Westfall')
    local filtered, count = Q.lines('zones', 'sentinel', 'name')
    H.eq(count, 1)
    H.contains(filtered[1], 'Sentinel Hill, Westfall')
    H.contains(Q.lines('npcs'), 'talked 1')
    H.contains(Q.lines('levels'), 'Level 11')
    H.contains(Q.lines('moments'), 'No moments yet')
    H.contains(Q.lines('deaths'), 'Goldshire, Elwynn Forest')
  end)

  it('builds the per-place timeline', function()
    local ctl = session()
    local lines, place = ctl.ns.Queries.here()
    H.eq(place, 'Goldshire, Elwynn Forest')
    H.contains(lines, 'Visited 2 times')
    H.contains(lines, 'Died here 1 time')
    H.contains(lines, 'First time I spoke with')
    H.contains(lines, 'reached level 11')
    H.contains(lines, 'First time I looted')
  end)
end)

describe('Commands', function()
  it('handles moments, settings, here, stats and status', function()
    local ctl = session()
    ctl.slash('moment "Leveling with Sam"')
    H.eq(ctl.ns.Moments.current(), 'Leveling with Sam')
    ctl.slash('addm "Second moment"')
    ctl.slash('getm')
    H.contains(ctl.chatText(), 'Current moment: ')
    ctl.slash('set printChance 50%')
    H.eq(ctl.ns.Settings.get('printChance'), 0.5)
    ctl.slash('set memory.showInTooltips 0')
    H.eq(ctl.ns.Settings.get('showInTooltips'), false)
    ctl.slash('get printChance')
    H.contains(ctl.chatText(), 'printChance = 0.5')
    ctl.slash('set nope 1')
    H.contains(ctl.chatText(), 'unknown setting')
    ctl.slash('settings')
    ctl.slash('here')
    ctl.slash('stats')
    ctl.slash('toast')
    ctl.slash('debug on')
    ctl.slash('bogus')
    H.contains(ctl.chatText(), 'Unknown command')
    H.noErrors(ctl)
  end)

  it('tokenizes quoted arguments', function()
    local ctl = WoW.start({ login = false })
    local tokens = ctl.ns.Commands.tokenize('addm "Hello there" x')
    H.eq(tokens[2], 'Hello there')
    H.eq(tokens[3], 'x')
  end)
end)

describe('UI', function()
  it('opens and drives the journal on every tab', function()
    local ctl = session()
    ctl.slash('')
    H.truthy(ctl.ns.Journal.isShown())
    for _, tab in ipairs(ctl.ns.Queries.TABS) do
      ctl.ns.Journal.open(tab.key)
      ctl.ns.Journal.refresh()
    end
    ctl.slash('journal')
    H.falsy(ctl.ns.Journal.isShown())
    H.noErrors(ctl)
  end)

  it('registers the options panel and opens it', function()
    local ctl = session()
    H.truthy(ctl.optionsCategory)
    ctl.slash('options')
    H.eq(ctl.openedCategory, 'category:Memory Forever')
    -- show the panel and click every button/checkbox in it
    local panel = ctl.optionsPanel
    panel._scripts.OnShow(panel)
    for _, frame in ipairs(ctl.frames) do
      if frame._parent == panel and frame._scripts.OnClick then
        frame._checked = not frame._checked
        frame:Click()
      end
    end
    H.noErrors(ctl)
  end)

  it('creates the minimap button and toggles it with the setting', function()
    local ctl = session()
    H.truthy(ctl.ns.MinimapButton.isShown())
    ctl.slash('set minimapButton off')
    H.falsy(ctl.ns.MinimapButton.isShown())
    ctl.env.MemoryForever_OnAddonCompartmentClick('MemoryForever', 'LeftButton')
    H.truthy(ctl.ns.Journal.isShown())
    H.noErrors(ctl)
  end)

  it('shows a toast and hides it after the timer', function()
    local ctl = WoW.start()
    ctl.ns.Toast.show('Goldshire', 'Hello')
    H.truthy(ctl.ns.Toast.isShown())
    ctl.runTimers()
    H.falsy(ctl.ns.Toast.isShown())
    H.noErrors(ctl)
  end)
end)
