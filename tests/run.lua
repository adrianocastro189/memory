--[[
Test entry point. Run from the repository root with either:
  lua5.1 tests/run.lua
  python tests/run.py        (uses lupa's bundled Lua 5.1)
]]
local H = dofile('tests/lib/harness.lua')
local WoW = dofile('tests/lib/wow.lua')

local SPECS = {
  'tests/spec/load_spec.lua',
  'tests/spec/util_spec.lua',
  'tests/spec/data_spec.lua',
  'tests/spec/formatter_spec.lua',
  'tests/spec/zones_spec.lua',
  'tests/spec/trackers_spec.lua',
  'tests/spec/secrets_spec.lua',
  'tests/spec/tooltip_spec.lua',
  'tests/spec/ui_spec.lua',
}

for _, spec in ipairs(SPECS) do
  local chunk = assert(loadfile(spec))
  chunk(H, WoW)
end

local r = H.results
for _, failure in ipairs(r.failures) do
  print('FAIL ' .. failure.name)
  print('  ' .. tostring(failure.err):gsub('\n', '\n  '))
end
print(string.format('%d passed, %d failed', r.passed, r.failed))

if not RUN_EMBEDDED then os.exit(r.failed == 0 and 0 or 1) end
return r.failed
