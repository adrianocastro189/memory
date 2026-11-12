local H, WoW = ...
local describe, it = H.describe, H.it

describe('Formatter', function()
  local ctl = WoW.start()
  local ns = ctl.ns
  local F = ns.Formatter
  local verbs = { past = 'spoke', pastConnector = 'with', present = 'speak', presentConnector = 'with', subject = 'Marshal Dughan' }

  local function memory(first, last, x, interaction)
    return ns.Memory.new('npcs', { 'Marshal Dughan' }, interaction or 'talk', { first = first, last = last, x = x })
  end

  it('builds the first-time sentences with location, level and moment', function()
    ns.Moments.add('Leveling with Sam')
    ns.Moments.add('Now')
    local m = memory('26-10-02|5|Elwynn Forest|Goldshire|1', '26-11-11|9|Elwynn Forest|Goldshire|2', 4)
    local text = F.firstWithDate(m, verbs)
    H.contains(text, 'The first time I spoke with')
    H.contains(text, 'Marshal Dughan')
    H.contains(text, 'October 2, 2026')
    H.contains(text, 'Goldshire, Elwynn Forest')
    H.contains(text, 'when my level was')
    H.contains(text, '~Leveling with Sam~')
    H.contains(F.firstWithDays(m, verbs), '41 days ago')
  end)

  it('omits level and moment when they match now, and location for visits', function()
    local m = memory('26-11-12|10|Elwynn Forest|Goldshire|0', '26-11-12|10|Elwynn Forest|Goldshire|0', 1, 'visit')
    local text = F.lastWithDays(m, verbs)
    H.contains(text, 'was today')
    H.notContains(text, 'level')
    H.notContains(text, ' at ')
  end)

  it('counts including the current event', function()
    local m = memory('26-11-01|10|-|-|-', '26-11-02|10|-|-|-', 2)
    H.contains(F.count(m, verbs, 1), 'This is the 3rd time I speak with')
  end)

  it('uses the count sentence for a first occurrence', function()
    local empty = ns.Memory.new('npcs', { 'X' }, 'talk', nil)
    H.contains(F.random(empty, verbs, 1), 'This is the 1st time')
  end)

  it('handles actions without a subject (deaths)', function()
    local m = ns.Memory.new('misc', { 'others' }, 'die', { first = '26-11-10|9|-|-|-', last = '26-11-11|9|-|-|-', x = 2 })
    local deathVerbs = { past = 'died', present = 'die' }
    H.eq(F.count(m, deathVerbs, 1), 'This is the 3rd time I die')
    H.contains(F.firstWithDays(m, deathVerbs), 'The first time I died was 2 days ago')
  end)
end)
