local H, WoW = ...
local describe, it = H.describe, H.it

describe('Loading through the Forever TOC', function()
  it('declares Interface 16001 and lists only existing files', function()
    local files, savedVariables, meta = WoW.readToc('MemoryForever_Camelot.toc')
    H.eq(meta.Interface, '16001')
    H.contains(savedVariables, 'MemoryForeverDB')
    for _, file in ipairs(files) do
      local handle = io.open(file, 'r')
      H.truthy(handle, 'missing file listed in TOC: ' .. file)
      handle:close()
    end
  end)

  it('ships a fallback TOC identical to the Camelot TOC and no Retail/Classic TOC', function()
    local a = io.open('MemoryForever_Camelot.toc'):read('*a')
    local b = io.open('MemoryForever.toc'):read('*a')
    H.eq(a, b)
    for _, flavor in ipairs({ 'Mainline', 'Classic', 'Vanilla', 'Cata', 'Mists' }) do
      H.falsy(io.open('MemoryForever_' .. flavor .. '.toc', 'r'), flavor .. ' TOC should not exist')
    end
  end)

  it('loads and logs in with zero Lua errors', function()
    local ctl = WoW.start()
    H.noErrors(ctl)
    H.truthy(ctl.ns.Repository.isReady())
    H.contains(ctl.chatText(), 'loaded')
    H.eq(ctl.env.MemoryForeverDB.schemaVersion, 2)
  end)

  it('creates no globals beyond its SavedVariables, slash command and named frames', function()
    local baseline = WoW.newClient().env
    local ctl = WoW.start()
    ctl.slash('')
    ctl.slash('toast')
    local allowed = {
      MemoryForeverDB = true, SLASH_MEMORYFOREVER1 = true, SLASH_MEMORYFOREVER2 = true,
      MemoryForever_OnAddonCompartmentClick = true,
    }
    for key in pairs(ctl.env) do
      if baseline[key] == nil and not allowed[key] and not string.match(key, '^MemoryForever%u') then
        error('unexpected global: ' .. tostring(key))
      end
    end
  end)

  it('never registers the combat log', function()
    local ctl = WoW.start()
    H.falsy(ctl.registeredEvents.COMBAT_LOG_EVENT_UNFILTERED)
    H.falsy(ctl.registeredEvents.COMBAT_LOG_EVENT)
  end)

  it('answers the slash command', function()
    local ctl = WoW.start()
    ctl.slash('help')
    H.contains(ctl.chatText(), '/mem here')
    ctl.slash('status')
    H.contains(ctl.chatText(), 'Zone and subzone visits')
    H.noErrors(ctl)
  end)

  it('survives /reload with memories intact', function()
    local first = WoW.start()
    first.moveTo('Elwynn Forest', 'Goldshire')
    first.event('PLAYER_DEAD')
    local saved = first.saved()

    local second = WoW.start({ saved = saved })
    H.noErrors(second)
    local char = second.char()
    H.eq(char.zones['Elwynn Forest'].subzones['Goldshire'].visit.x >= 1, true)
    H.eq(char.misc.others.die.x, 1)
    H.eq(char.misc.login.x, 2)
  end)

  it('works when SavedVariables failed to load (nil or garbage)', function()
    local ctl = WoW.start({ saved = { MemoryForeverDB = 'garbage' } })
    H.noErrors(ctl)
    H.truthy(ctl.ns.Repository.isReady())
  end)

  it('still starts if ADDON_LOADED was missed', function()
    local ctl = WoW.start({ login = false })
    ctl.fire('PLAYER_LOGIN')
    ctl.runTimers()
    H.noErrors(ctl)
    H.truthy(ctl.ns.Repository.isReady())
  end)

  it('disables achievements quietly when the client has no such event', function()
    local ctl = WoW.start({ configure = function(c) c.invalidEvents.ACHIEVEMENT_EARNED = true end })
    H.noErrors(ctl)
    H.eq(ctl.ns.Trackers.status.achievements, 'missing event ACHIEVEMENT_EARNED')
    H.eq(ctl.ns.Trackers.status.zones, 'on')
  end)

  it('disables a tracker whose API is missing without affecting others', function()
    local ctl = WoW.start({ configure = function(c) c.env.GetAchievementInfo = nil end })
    H.noErrors(ctl)
    H.eq(ctl.ns.Trackers.status.achievements, 'missing API GetAchievementInfo')
    H.eq(ctl.ns.Trackers.status.deaths, 'on')
  end)
end)
