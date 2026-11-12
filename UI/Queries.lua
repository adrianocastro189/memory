--[[
Read-only views over the stored memories, used by the journal window and the
chat commands (/mem here, /mem stats). No UI code here, so it's testable.
]]
local _, ns = ...

local Queries = {}
ns.Queries = Queries

local Util = ns.Util
local Repository = ns.Repository

Queries.TABS = {
  { key = 'zones', label = 'Zones' },
  { key = 'npcs', label = 'NPCs' },
  { key = 'items', label = 'Items' },
  { key = 'players', label = 'Players' },
  { key = 'deaths', label = 'Deaths' },
  { key = 'levels', label = 'Levels' },
  { key = 'moments', label = 'Moments' },
  { key = 'here', label = 'Here' },
  { key = 'stats', label = 'Stats' },
}

Queries.SORTS = { 'count', 'recent', 'name' }
Queries.SORT_LABELS = { count = 'Most', recent = 'Recent', name = 'A-Z' }

local INTERACTION_WORDS = {
  talk = 'talked', business = 'business', fight = 'fought', quest = 'quests',
  party = 'grouped', loot = 'looted', visit = 'visited', die = 'died',
  login = 'logins', earn = 'earned',
}

-- past-tense phrases for the per-place timeline
local TIMELINE_WORDS = {
  talk = 'spoke with', business = 'did business with', fight = 'fought', quest = 'turned in a quest to',
  party = 'grouped with', loot = 'looted', die = 'died', login = 'logged in', earn = 'earned',
}

local function earlier(a, b)
  if not a then return b end
  if not b then return a end
  return Util.dateKey(a.date) <= Util.dateKey(b.date) and a or b
end

local function later(a, b)
  if not a then return b end
  if not b then return a end
  return Util.dateKey(a.date) >= Util.dateKey(b.date) and a or b
end

--[[
Collects entries for a memory category, grouping interactions by subject.
Entry: { label, x, first, last, parts = { interaction = x } }
]]
local function collect(category, labelFor)
  local byLabel, entries = {}, {}
  Repository.walk(category, function(memory)
    local label = labelFor(memory)
    if not label then return end
    local entry = byLabel[label]
    if not entry then
      entry = { label = label, x = 0, parts = {} }
      byLabel[label] = entry
      table.insert(entries, entry)
    end
    entry.x = entry.x + memory.x
    entry.parts[memory.interaction] = (entry.parts[memory.interaction] or 0) + memory.x
    entry.first = earlier(entry.first, memory.first)
    entry.last = later(entry.last, memory.last)
  end)
  return entries
end

local LABELERS = {
  zones = function(memory)
    local path = memory.path
    if #path == 1 then return path[1] end
    if #path == 3 and path[2] == 'subzones' then return path[3] .. ', ' .. path[1] end
    return nil
  end,
  deaths = function(memory)
    local zone, subZone = memory.path[1], memory.path[2]
    if not zone then return nil end
    if not subZone or subZone == zone then return zone end
    return subZone .. ', ' .. zone
  end,
  default = function(memory) return memory.path[1] end,
}

function Queries.entries(category)
  return collect(category, LABELERS[category] or LABELERS.default)
end

function Queries.filter(entries, search)
  search = Util.trim(search or '')
  if search == '' then return entries end
  local needle = string.lower(search)
  local result = {}
  for _, entry in ipairs(entries) do
    if string.find(string.lower(entry.label), needle, 1, true) then table.insert(result, entry) end
  end
  return result
end

function Queries.sort(entries, mode)
  table.sort(entries, function(a, b)
    if mode == 'recent' then
      local ka, kb = Util.dateKey(a.last and a.last.date), Util.dateKey(b.last and b.last.date)
      if ka ~= kb then return ka > kb end
    elseif mode == 'count' then
      if a.x ~= b.x then return a.x > b.x end
    end
    return string.lower(a.label) < string.lower(b.label)
  end)
  return entries
end

local function stamp(snapshot)
  if not snapshot then return '?' end
  local text = Util.formatDate(snapshot.date, true)
  if snapshot.level then text = text .. ' (lv ' .. snapshot.level .. ')' end
  return text
end

function Queries.formatEntry(entry)
  local parts = {}
  for interaction, x in pairs(entry.parts) do
    table.insert(parts, (INTERACTION_WORDS[interaction] or interaction) .. ' ' .. x)
  end
  table.sort(parts)
  local line = ns.highlight(entry.label) .. '  ' .. table.concat(parts, ', ')
  local meta = 'first ' .. stamp(entry.first)
  if entry.x > 1 and entry.last then meta = meta .. ' - last ' .. Util.relativeDate(entry.last.date) end
  return line .. '\n    ' .. ns.muted(meta)
end

local function levelLines()
  local lines = {}
  for _, level in ipairs(Repository.levels()) do
    local place = level.subZone and level.zone and level.subZone ~= level.zone and (level.subZone .. ', ' .. level.zone)
      or level.zone or level.subZone or 'somewhere'
    local line = ns.highlight('Level ' .. level.level) .. '  ' .. Util.formatDate(level.date, true) .. ' at ' .. place
    local moment = level.moment and level.moment > 0 and ns.Moments.get(level.moment)
    if moment then line = line .. ns.muted(' ~' .. moment .. '~') end
    table.insert(lines, line)
  end
  return lines
end

local function momentLines()
  local lines = {}
  local moments = ns.Moments.all()
  for i = #moments, 1, -1 do
    local marker = i == #moments and ns.highlight(' (current)') or ''
    table.insert(lines, i .. '. ' .. moments[i] .. marker)
  end
  return lines
end

--[[
Timeline of the current place: every first/last occurrence recorded in the
current subzone (or zone), oldest first.
]]
function Queries.here(zone, subZone)
  if not zone then zone, subZone = ns.Zones.location() end
  local lines = {}
  if not zone then return lines, nil end
  local place = subZone and (subZone .. ', ' .. zone) or zone

  local visitPath = subZone and { zone, 'subzones', subZone } or { zone }
  local visits = Repository.get('zones', visitPath, 'visit')
  local deaths = Repository.get('deaths', { zone, subZone or zone }, 'die')
  local summary = 'Visited ' .. Util.plural(visits.x, 'time')
  if visits.first then summary = summary .. ', first on ' .. stamp(visits.first) end
  if deaths.x > 0 then summary = summary .. '. Died here ' .. Util.plural(deaths.x, 'time') end
  table.insert(lines, summary .. '.')

  local events = {}
  local function consider(memory, snapshot, which)
    if snapshot and snapshot:isAt(zone, subZone) then
      table.insert(events, { snapshot = snapshot, memory = memory, which = which })
    end
  end
  for _, category in ipairs({ 'npcs', 'items', 'players', 'misc' }) do
    Repository.walk(category, function(memory)
      consider(memory, memory.first, 'first')
      if memory.x > 1 then consider(memory, memory.last, 'last') end
    end)
  end
  for _, level in ipairs(Repository.levels()) do
    if level.zone == zone and (subZone == nil or level.subZone == subZone) then
      table.insert(events, { snapshot = ns.MemoryString.new(level), level = level.level })
    end
  end
  table.sort(events, function(a, b) return Util.dateKey(a.snapshot.date) < Util.dateKey(b.snapshot.date) end)

  for _, event in ipairs(events) do
    local text
    if event.level then
      text = 'reached level ' .. event.level
    else
      local word = TIMELINE_WORDS[event.memory.interaction] or event.memory.interaction
      local subject = event.memory:subject() or ''
      if event.memory.category == 'misc' and event.memory.interaction == 'die' then subject = '' end
      text = (event.which == 'first' and 'First time I ' or 'Last time I ') .. word
        .. (subject ~= '' and (' ' .. ns.highlight(subject)) or '')
    end
    table.insert(lines, ns.muted(Util.formatDate(event.snapshot.date, true)) .. '  ' .. text)
  end
  return lines, place
end

--[[
Totals for the stats view.
]]
function Queries.stats()
  local stats = {
    deaths = Repository.get('misc', { 'others' }, 'die').x,
    zones = 0, subzones = 0, npcs = 0, fights = 0, talks = 0, quests = 0,
    itemKinds = 0, itemsLooted = 0, players = 0, levels = #Repository.levels(),
  }
  local mostVisited, deadliest, mostGrouped
  Repository.walk('zones', function(memory)
    if #memory.path == 1 then
      stats.zones = stats.zones + 1
    else
      stats.subzones = stats.subzones + 1
      if not mostVisited or memory.x > mostVisited.x then mostVisited = memory end
    end
  end)
  Repository.walk('deaths', function(memory)
    if not deadliest or memory.x > deadliest.x then deadliest = memory end
  end)
  local npcs = {}
  Repository.walk('npcs', function(memory)
    npcs[memory.path[1]] = true
    if memory.interaction == 'fight' then stats.fights = stats.fights + memory.x end
    if memory.interaction == 'talk' then stats.talks = stats.talks + memory.x end
    if memory.interaction == 'quest' then stats.quests = stats.quests + memory.x end
  end)
  for _ in pairs(npcs) do stats.npcs = stats.npcs + 1 end
  Repository.walk('items', function(memory)
    stats.itemKinds = stats.itemKinds + 1
    stats.itemsLooted = stats.itemsLooted + memory.x
  end)
  Repository.walk('players', function(memory)
    stats.players = stats.players + 1
    if memory.interaction == 'party' and (not mostGrouped or memory.x > mostGrouped.x) then
      mostGrouped = memory
    end
  end)

  if mostVisited then
    stats.mostVisited = { label = mostVisited.path[3] .. ', ' .. mostVisited.path[1], x = mostVisited.x }
  end
  if deadliest then
    stats.deadliest = { label = LABELERS.deaths(deadliest), x = deadliest.x }
  end
  if mostGrouped then
    stats.mostGrouped = { label = mostGrouped.path[1], x = mostGrouped.x }
  end
  local login = Repository.get('misc', {}, 'login')
  stats.since = login.first and login.first.date
  return stats
end

function Queries.statsLines()
  local s = Queries.stats()
  local lines = {}
  local function add(label, value) table.insert(lines, ns.highlight(label) .. '  ' .. tostring(value)) end
  if s.since then add('Remembering since', Util.formatDate(s.since)) end
  add('Deaths', s.deaths)
  if s.deadliest then add('Most deaths', s.deadliest.label .. ' (' .. s.deadliest.x .. ')') end
  add('Zones discovered', s.zones)
  add('Places discovered', s.subzones)
  if s.mostVisited then add('Most visited place', s.mostVisited.label .. ' (' .. s.mostVisited.x .. ' visits)') end
  add('NPCs met', s.npcs)
  add('Conversations', s.talks)
  add('Quests turned in', s.quests)
  add('Fights', s.fights)
  add('Items looted', s.itemsLooted .. ' (' .. s.itemKinds .. ' different)')
  add('Players grouped with', s.players)
  if s.mostGrouped then add('Most grouped with', s.mostGrouped.label .. ' (' .. s.mostGrouped.x .. ')') end
  add('Levels remembered', s.levels)
  return lines
end

Queries.MAX_ROWS = 400

--[[
Lines for a journal tab. Returns lines, totalCount.
]]
function Queries.lines(tab, search, sort)
  if tab == 'stats' then
    local lines = Queries.statsLines()
    return lines, #lines
  end
  if tab == 'levels' then
    local lines = levelLines()
    return lines, #lines
  end
  if tab == 'moments' then
    local lines = momentLines()
    if #lines == 0 then lines = { 'No moments yet. Add one with /mem moment "Your moment"' } end
    return lines, #lines
  end
  if tab == 'here' then
    local lines, place = Queries.here()
    if place then table.insert(lines, 1, ns.highlight(place)) end
    return lines, #lines
  end

  local entries = Queries.sort(Queries.filter(Queries.entries(tab), search), sort or 'count')
  local lines = {}
  for i, entry in ipairs(entries) do
    if i > Queries.MAX_ROWS then
      table.insert(lines, ns.muted('...and ' .. (#entries - Queries.MAX_ROWS) .. ' more. Narrow it down with search.'))
      break
    end
    table.insert(lines, Queries.formatEntry(entry))
  end
  if #entries == 0 then table.insert(lines, ns.muted('Nothing remembered here yet.')) end
  return lines, #entries
end
