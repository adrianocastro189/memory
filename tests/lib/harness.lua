--[[
Minimal test harness (no dependencies): describe / it / assertions.
]]
local H = { results = { passed = 0, failed = 0, failures = {} } }

local currentSuite = ''

function H.describe(name, body)
  local previous = currentSuite
  currentSuite = (previous ~= '' and (previous .. ' > ') or '') .. name
  body()
  currentSuite = previous
end

function H.it(name, body)
  local fullName = currentSuite .. ' > ' .. name
  local ok, err = xpcall(body, function(e) return debug.traceback(tostring(e), 2) end)
  if ok then
    H.results.passed = H.results.passed + 1
  else
    H.results.failed = H.results.failed + 1
    table.insert(H.results.failures, { name = fullName, err = err })
  end
end

local function show(value)
  if type(value) == 'string' then return string.format('%q', value) end
  return tostring(value)
end

function H.eq(actual, expected, message)
  if actual ~= expected then
    error((message and (message .. ': ') or '') .. 'expected ' .. show(expected) .. ', got ' .. show(actual), 2)
  end
end

function H.truthy(value, message)
  if not value then error(message or ('expected a truthy value, got ' .. show(value)), 2) end
end

function H.falsy(value, message)
  if value then error(message or ('expected a falsy value, got ' .. show(value)), 2) end
end

function H.contains(haystack, needle, message)
  if type(haystack) == 'table' then
    for _, value in ipairs(haystack) do
      if type(value) == 'string' and string.find(value, needle, 1, true) then return end
      if value == needle then return end
    end
    error((message and (message .. ': ') or '') .. 'no entry contains ' .. show(needle) .. ' in {' .. table.concat(haystack, ' || ') .. '}', 2)
  end
  if not string.find(tostring(haystack), needle, 1, true) then
    error((message and (message .. ': ') or '') .. show(needle) .. ' not found in ' .. show(haystack), 2)
  end
end

function H.notContains(haystack, needle, message)
  if type(haystack) == 'table' then haystack = table.concat(haystack, '\n') end
  if string.find(tostring(haystack), needle, 1, true) then
    error((message and (message .. ': ') or '') .. show(needle) .. ' unexpectedly found in ' .. show(haystack), 2)
  end
end

function H.noErrors(ctl)
  if #ctl.errors > 0 then
    error('Lua errors raised in the client:\n  ' .. table.concat(ctl.errors, '\n  '), 2)
  end
end

return H
