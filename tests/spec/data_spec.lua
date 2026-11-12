local H, WoW = ...
local describe, it = H.describe, H.it

-- SavedVariables as written by the original Memory 1.6.0
local function legacySaved()
  return {
    MemoryAddon_DataSet = {
      ['Forever Realm'] = {
        ['Player-1-00000001'] = {
          misc = { login = { first = '24-08-01|1|-|-|0', last = '24-08-20|20|-|-|1', x = 30 },
                   others = { die = { first = '24-08-02|3|Elwynn Forest|Goldshire|0', last = '24-08-19|19|Duskwood|Darkshire|1', x = 7 } } },
          npcs = { ['Marshal Dughan'] = { talk = { first = '24-08-01|1|Elwynn Forest|Goldshire|0', last = '24-08-05|6|Elwynn Forest|Goldshire|0', x = 4 } } },
          players = {},
          zones = { ['Elwynn Forest'] = { subzones = { Goldshire = { visit = { first = '24-08-01|1|Elwynn Forest|Goldshire|0', last = '24-08-10|9|Elwynn Forest|Goldshire|1', x = 12 } } } } },
          items = { ['Linen Cloth'] = { loot = { first = '24-08-03|4|Elwynn Forest|Goldshire|0', last = '24-08-04|5|Elwynn Forest|Goldshire|0', x = 9 } },
                    -- path created but never stored by the original's get()
                    ['Ghost'] = { loot = { first = -1, last = -1, x = 0 } } },
          levels = { [2] = { date = '24-08-01', zone = 'Elwynn Forest', subZone = 'Northshire', moment = 0 } },
        },
      },
    },
    MemoryAddon_Settings = { moments = { 'Leveling with Sam' }, ['memory.printChance'] = '0.5', ['memory.showInTooltips'] = '0' },
  }
end

describe('SavedVariables', function()
  it('creates a fresh schema-2 database', function()
    local ctl = WoW.start()
    local db = ctl.env.MemoryForeverDB
    H.eq(db.schemaVersion, 2)
    H.eq(type(db.settings), 'table')
    H.eq(type(db.moments), 'table')
    H.truthy(ctl.char())
    H.eq(ctl.char().meta.name, 'Tester')
  end)

  it('imports the original Memory data into an empty database', function()
    local ctl = WoW.start({ saved = legacySaved() })
    H.noErrors(ctl)
    local char = ctl.char()
    H.eq(char.npcs['Marshal Dughan'].talk.x, 4)
    H.eq(char.zones['Elwynn Forest'].subzones.Goldshire.visit.x >= 12, true)
    H.eq(char.levels[2].subZone, 'Northshire')
    H.eq(ctl.env.MemoryForeverDB.moments[1], 'Leveling with Sam')
    H.eq(ctl.ns.Settings.get('printChance'), 0.5)
    H.eq(ctl.ns.Settings.get('showInTooltips'), false)
    H.eq(ctl.env.MemoryAddon_DataSet, nil, 'legacy variable cleared after import')
    H.contains(ctl.chatText(), 'Imported memories for 1 character')
    -- the never-stored placeholder doesn't show up
    H.eq(#ctl.ns.Repository.list('items', { 'Ghost' }), 0)
    H.eq(#ctl.ns.Repository.list('items', { 'Linen Cloth' }), 1)
  end)

  it('does not import into a database that already has memories', function()
    local first = WoW.start()
    local saved = first.saved()
    local legacy = legacySaved()
    saved.MemoryAddon_DataSet = legacy.MemoryAddon_DataSet
    local ctl = WoW.start({ saved = saved })
    H.noErrors(ctl)
    H.eq(ctl.char().npcs['Marshal Dughan'], nil)
  end)

  it('upgrades a database that has memories but no schema version', function()
    local ctl = WoW.start({ saved = { MemoryForeverDB = {
      realms = { ['Forever Realm'] = { ['Player-1-00000001'] = {
        npcs = { Bob = { talk = { first = '24-08-01|1|Elwynn Forest|Goldshire|0', last = '24-08-01|1|Elwynn Forest|Goldshire|0', x = 2 } } },
      } } },
    } } })
    H.noErrors(ctl)
    H.eq(ctl.env.MemoryForeverDB.schemaVersion, 2)
    H.eq(ctl.char().npcs.Bob.talk.x, 2)
  end)

  it('keeps a Memory 1.x import whose realm and GUID are not this character', function()
    local saved = legacySaved()
    saved.MemoryAddon_DataSet = {
      Azeroth = {
        ['Player-9-OLD'] = saved.MemoryAddon_DataSet['Forever Realm']['Player-1-00000001'],
      },
    }
    local ctl = WoW.start({ saved = saved })
    H.noErrors(ctl)
    H.contains(ctl.chatText(), 'Imported memories for 1 character')
    H.eq(ctl.char().npcs['Marshal Dughan'], nil)
    local stored = ctl.env.MemoryForeverDB.realms.Azeroth['Player-9-OLD']
    H.eq(stored.npcs['Marshal Dughan'].talk.x, 4)
    H.eq(ctl.env.MemoryAddon_DataSet, nil)
  end)

  it('leaves the legacy file alone when no rows or settings can be copied', function()
    local junk = { [true] = { nope = true } }
    local ctl = WoW.start({ saved = { MemoryAddon_DataSet = junk } })
    H.noErrors(ctl)
    H.eq(type(ctl.env.MemoryAddon_DataSet), 'table')
    H.notContains(ctl.chatText(), 'Imported memories')
  end)

  it('leaves data from a newer schema alone', function()
    local ctl = WoW.start({ saved = { MemoryForeverDB = { schemaVersion = 99, realms = {}, settings = {}, moments = {} } } })
    H.noErrors(ctl)
    H.eq(ctl.env.MemoryForeverDB.schemaVersion, 99)
    H.contains(ctl.chatText(), 'newer version')
  end)

  it('repairs mistyped tables', function()
    local ctl = WoW.start({ saved = { MemoryForeverDB = { schemaVersion = 2, realms = 'x', settings = 5, moments = { 1, 'b' } } } })
    H.noErrors(ctl)
    local db = ctl.env.MemoryForeverDB
    H.eq(type(db.realms), 'table')
    H.eq(db.moments[1], '1')
  end)

  it('only saves plain values (no secrets or functions)', function()
    local ctl = WoW.start()
    ctl.restricted = true
    ctl.units.target = { guid = 'Creature-0-1-2-3-99-0001', name = 'Kobold', canAttack = true }
    ctl.event('PLAYER_REGEN_DISABLED')
    ctl.event('PLAYER_REGEN_ENABLED')
    ctl.event('PLAYER_DEAD')
    ctl.moveTo('Westfall', 'Sentinel Hill')
    WoW.serialize(ctl.env.MemoryForeverDB)
    H.noErrors(ctl)
  end)
end)

describe('MemoryString', function()
  local ctl = WoW.start()
  local MS = ctl.ns.MemoryString

  it('parses the original format', function()
    local s = MS.parse('24-08-01|5|Elwynn Forest|Goldshire|2')
    H.eq(s.level, 5)
    H.eq(s.zone, 'Elwynn Forest')
    H.eq(s.moment, 2)
    H.eq(s:location(), 'Goldshire, Elwynn Forest')
    H.eq(MS.parse(-1), nil)
    H.eq(MS.parse('garbage'), nil)
    local old = MS.parse('24-08-01|5|Elwynn Forest|-')
    H.eq(old.subZone, nil)
    H.eq(old.moment, nil)
  end)

  it('captures and round-trips, escaping the separator', function()
    ctl.zone, ctl.subzone = 'Odd|Zone', ''
    local s = MS.capture()
    local again = MS.parse(s:toString())
    H.eq(again.zone, 'Odd/Zone')
    H.eq(again.subZone, nil)
    H.eq(again.level, 10)
  end)
end)

describe('Settings', function()
  local ctl = WoW.start()
  local S = ctl.ns.Settings

  it('coerces values and accepts the original keys', function()
    H.eq(S.set('memory.printChance', '25%'), 0.25)
    H.eq(S.get('printChance'), 0.25)
    H.eq(S.set('printChance', '7'), 1, 'clamped')
    H.eq(S.set('showInTooltips', 'off'), false)
    H.eq(S.set('reminderStyle', 'TOAST'), 'toast')
    local value, err = S.set('reminderStyle', 'loud')
    H.eq(value, nil)
    H.contains(err, 'chat')
    H.eq(S.set('nope', 1), nil)
  end)

  it('falls back to defaults for bad stored values', function()
    ctl.env.MemoryForeverDB.settings.printChance = 'abc'
    H.eq(S.get('printChance'), 0.2)
  end)
end)
