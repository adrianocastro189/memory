--[[
Slash commands: /mem and /memoryforever. (/memory is taken by WoW Memory+, and
/memoryaddon was the original addon's command.)
]]
local _, ns = ...

local Commands = {}
ns.Commands = Commands

--[[
Splits a command line into words, keeping "quoted text" together.
]]
function Commands.tokenize(line)
  local tokens = {}
  line = line or ''
  local i, length = 1, #line
  while i <= length do
    local char = string.sub(line, i, i)
    if char:match('%s') then
      i = i + 1
    elseif char == '"' then
      local close = string.find(line, '"', i + 1, true)
      if close then
        table.insert(tokens, string.sub(line, i + 1, close - 1))
        i = close + 1
      else
        table.insert(tokens, string.sub(line, i + 1))
        i = length + 1
      end
    else
      local stop = string.find(line, '%s', i) or (length + 1)
      table.insert(tokens, string.sub(line, i, stop - 1))
      i = stop
    end
  end
  return tokens
end

local function restOf(line, command)
  local rest = string.match(line or '', '^%s*%S+%s+(.*)$') or ''
  rest = ns.Util.trim(rest)
  local unquoted = string.match(rest, '^"(.*)"$') or string.match(rest, "^'(.*)'$")
  return unquoted or rest
end

local HELP = {
  { '', 'open the journal' },
  { 'here', 'what happened in this place' },
  { 'stats', 'totals: deaths, places, most visited...' },
  { 'moment "label"', 'start a new moment (alias: addm)' },
  { 'moment', 'show the current moment (alias: getm)' },
  { 'options', 'open the options panel' },
  { 'settings', 'list settings and their values' },
  { 'set <key> <value>', 'change a setting' },
  { 'get <key>', 'show a setting' },
  { 'status', 'version and which memory types are active' },
  { 'toast', 'show a sample pop-up' },
}

local function printHelp()
  ns.print('Commands:')
  for _, entry in ipairs(HELP) do
    local usage = '/mem' .. (entry[1] ~= '' and (' ' .. entry[1]) or '')
    ns.print('  ' .. ns.highlight(usage) .. ' - ' .. entry[2])
  end
end

local function formatValue(value)
  if type(value) == 'number' then
    return (string.gsub(string.format('%.2f', value), '%.?0+$', ''))
  end
  return tostring(value)
end

local handlers = {}

handlers.help = printHelp

handlers.journal = function() ns.Journal.toggle() end

handlers.here = function()
  local lines, place = ns.Queries.here()
  if not place then
    ns.print("I don't know where we are yet.")
    return
  end
  ns.print(ns.highlight(place))
  local limit = 12
  for i, line in ipairs(lines) do
    if i > limit then
      ns.print(ns.muted('  ...' .. (#lines - limit) .. ' more in /mem journal (Here tab)'))
      break
    end
    ns.print('  ' .. line)
  end
end

handlers.stats = function()
  for _, line in ipairs(ns.Queries.statsLines()) do ns.print(line) end
end

handlers.moment = function(tokens, line)
  local label = restOf(line)
  if label == '' then
    local current = ns.Moments.current()
    if current then
      ns.print('Current moment: ' .. ns.highlight(current))
    else
      ns.print('No moment yet. Start one with /mem moment "Your moment here"')
    end
    return
  end
  ns.Moments.add(label)
  ns.print('Current moment updated: ' .. ns.highlight(label))
end
handlers.addm = function(tokens, line)
  if restOf(line) == '' then
    ns.print('Please provide a moment, for example /mem moment "Leveling with Sam"')
    return
  end
  handlers.moment(tokens, line)
end
handlers.getm = function() handlers.moment({}, '') end

handlers.get = function(tokens)
  local key = tokens[2]
  if not key then
    ns.print('Usage: /mem get <key>. See /mem settings.')
    return
  end
  local name = ns.Settings.resolveKey(key)
  if not name then
    ns.print('No setting called ' .. key .. '. See /mem settings.')
    return
  end
  ns.print(name .. ' = ' .. formatValue(ns.Settings.get(name)))
end

handlers.set = function(tokens)
  local key, value = tokens[2], tokens[3]
  if not key or value == nil then
    ns.print('Usage: /mem set <key> <value>. See /mem settings.')
    return
  end
  local stored, nameOrError = ns.Settings.set(key, value)
  if stored == nil then
    ns.print('Could not set ' .. key .. ': ' .. tostring(nameOrError))
    return
  end
  ns.print(nameOrError .. ' set to ' .. formatValue(stored))
  if nameOrError == 'minimapButton' then ns.MinimapButton.update() end
end

handlers.settings = function()
  for _, name in ipairs(ns.Settings.names()) do
    local definition = ns.Settings.DEFINITIONS[name]
    ns.print(ns.highlight(name) .. ' = ' .. formatValue(ns.Settings.get(name)) .. ns.muted('  ' .. definition.label))
  end
end

handlers.options = function() ns.Options.open() end
handlers.config = handlers.options

handlers.status = function()
  ns.print('Version ' .. ns.VERSION .. ', data schema ' .. tostring(ns.db and ns.db.schemaVersion))
  for _, tracker in ipairs(ns.Trackers.list()) do
    local state = tracker.status == 'on' and ns.highlight('on', '33ff33') or ns.highlight(tracker.status, 'ff6666')
    ns.print('  ' .. tracker.label .. ': ' .. state)
  end
  ns.print('  Tooltips: ' .. tostring(ns.Tooltip.installed or 'unavailable'))
end

handlers.toast = function()
  ns.Toast.show('Goldshire', "You've been here 7 times. Last visit: 3 days ago. You died here 2 times.")
end

handlers.debug = function(tokens)
  local value = tokens[2] or (ns.Settings.get('debug') and 'off' or 'on')
  local stored = ns.Settings.set('debug', value)
  ns.print('Debug ' .. (stored and 'on' or 'off'))
end

function Commands.run(line)
  local tokens = Commands.tokenize(line)
  local command = string.lower(tokens[1] or '')
  if command == '' then
    if not ns.Journal.open() then printHelp() end
    return
  end
  if not ns.db then
    ns.print('Still loading, try again in a moment.')
    return
  end
  local handler = handlers[command]
  if not handler then
    ns.print('Unknown command "' .. command .. '".')
    printHelp()
    return
  end
  handler(tokens, line)
end

SLASH_MEMORYFOREVER1 = '/mem'
SLASH_MEMORYFOREVER2 = '/memoryforever'
SlashCmdList.MEMORYFOREVER = function(line)
  local ok, err = pcall(Commands.run, line)
  if not ok then ns.Events.report(err) end
end
