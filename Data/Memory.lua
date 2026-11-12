--[[
A memory: how many times (x) the player did something, and the first and last
time it happened (MemoryString snapshots). Read-only view over a stored leaf.
]]
local _, ns = ...

local Memory = {}
Memory.__index = Memory
ns.Memory = Memory

function Memory.new(category, path, interaction, leaf)
  local instance = setmetatable({}, Memory)
  instance.category = category
  instance.path = path or {}
  instance.interaction = interaction
  instance.x = 0
  if type(leaf) == 'table' then
    instance.x = tonumber(leaf.x) or 0
    instance.first = ns.MemoryString.parse(leaf.first)
    instance.last = ns.MemoryString.parse(leaf.last)
  end
  return instance
end

function Memory:hasFirst() return self.first ~= nil end
function Memory:hasLast() return self.last ~= nil end

--[[
The thing this memory is about (last path element), e.g. NPC or zone name.
]]
function Memory:subject()
  return self.path[#self.path]
end

function Memory:daysSinceFirst()
  if not self.first then return nil end
  return ns.Util.daysAgo(self.first.date)
end

function Memory:daysSinceLast()
  if not self.last then return nil end
  return ns.Util.daysAgo(self.last.date)
end
