--[[
Builds the reminder sentences. Ported from the original MemoryTextFormatter.

A tracker describes its action with "verbs":
  { past = 'spoke', pastConnector = 'with', present = 'speak',
    presentConnector = 'with', subject = 'Marshal Dughan' }
which produces sentences such as
  "The first time I spoke with Marshal Dughan was 41 days ago"
  "This is the 3rd time I speak with Marshal Dughan"

All sentences describe the memory as it was *before* the current event, so
"last time" means the previous occurrence.
]]
local _, ns = ...

local Formatter = {}
ns.Formatter = Formatter

local MOMENT_COLOR = '34c0eb'

local function phrase(verb, connector, subject)
  local text = verb or ''
  if connector and connector ~= '' then text = text .. ' ' .. connector end
  if subject and subject ~= '' then text = text .. ' ' .. ns.highlight(subject) end
  return text
end

local function pastPhrase(verbs)
  return phrase(verbs.past, verbs.pastConnector, verbs.subject)
end

local function presentPhrase(verbs)
  return phrase(verbs.present, verbs.presentConnector, verbs.subject)
end

--[[
Suffix such as ' at Goldshire, Elwynn Forest when my level was 5 ~Moment~'.
]]
function Formatter.details(memory, snapshot)
  local text = ''
  local location = snapshot:location()
  if location ~= '' and memory.interaction ~= 'visit' then
    text = text .. ' at ' .. ns.highlight(location)
  end
  if snapshot:hasLevel() then
    local currentLevel = tonumber(ns.Safe.api('UnitLevel', 'player'))
    if currentLevel ~= snapshot.level then
      text = text .. ' when my level was ' .. ns.highlight(snapshot.level)
    end
  end
  if snapshot:hasMoment() and snapshot.moment ~= ns.Moments.currentIndex() then
    local label = snapshot:momentLabel()
    if label then text = text .. ns.highlight(' ~' .. label .. '~', MOMENT_COLOR) end
  end
  return text
end

local function daysText(days)
  if days == nil then return 'a while ago' end
  if days == 0 then return 'today' end
  if days == 1 then return 'yesterday' end
  return days .. ' days ago'
end

function Formatter.firstWithDate(memory, verbs)
  if not memory:hasFirst() then return Formatter.count(memory, verbs, 1) end
  return 'The first time I ' .. pastPhrase(verbs) .. ' was on '
    .. ns.Util.formatDate(memory.first.date) .. Formatter.details(memory, memory.first)
end

function Formatter.firstWithDays(memory, verbs)
  if not memory:hasFirst() then return Formatter.count(memory, verbs, 1) end
  return 'The first time I ' .. pastPhrase(verbs) .. ' was '
    .. daysText(memory:daysSinceFirst()) .. Formatter.details(memory, memory.first)
end

function Formatter.lastWithDate(memory, verbs)
  if not memory:hasLast() then return Formatter.count(memory, verbs, 1) end
  return 'The last time I ' .. pastPhrase(verbs) .. ' was on '
    .. ns.Util.formatDate(memory.last.date) .. Formatter.details(memory, memory.last)
end

function Formatter.lastWithDays(memory, verbs)
  if not memory:hasLast() then return Formatter.count(memory, verbs, 1) end
  return 'The last time I ' .. pastPhrase(verbs) .. ' was '
    .. daysText(memory:daysSinceLast()) .. Formatter.details(memory, memory.last)
end

--[[
'This is the 5th time I visit Goldshire' (counting the current event).
]]
function Formatter.count(memory, verbs, add)
  local times = (memory and memory.x or 0) + (add or 1)
  return 'This is the ' .. ns.Util.ordinal(times) .. ' time I ' .. presentPhrase(verbs)
end

Formatter.TYPES = { 'firstWithDate', 'firstWithDays', 'lastWithDate', 'lastWithDays', 'count' }

--[[
A random sentence. On the very first occurrence it always uses the count
sentence ("This is the 1st time ..."), since there's nothing to remember yet.
]]
function Formatter.random(memory, verbs, add)
  if not memory:hasFirst() then return Formatter.count(memory, verbs, add) end
  local index = math.floor(math.random() * #Formatter.TYPES) + 1
  if index > #Formatter.TYPES then index = #Formatter.TYPES end
  local kind = Formatter.TYPES[index]
  if kind == 'count' then return Formatter.count(memory, verbs, add) end
  return Formatter[kind](memory, verbs)
end
