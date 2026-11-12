--[[
Moments: user-set labels attached to every memory recorded while they're the
current moment ('/mem moment "Leveling with Sam"'). Memories store the moment
index; the labels live in MemoryForeverDB.moments.
]]
local _, ns = ...

local Moments = {}
ns.Moments = Moments

local function list()
  if ns.db and type(ns.db.moments) == 'table' then return ns.db.moments end
  return {}
end

function Moments.add(label)
  label = ns.Util.trim(label)
  if label == '' or not ns.db then return nil end
  table.insert(ns.db.moments, label)
  return #ns.db.moments
end

function Moments.currentIndex()
  return #list()
end

function Moments.current()
  local moments = list()
  return moments[#moments]
end

function Moments.get(index)
  index = tonumber(index)
  if not index then return nil end
  return list()[index]
end

function Moments.all()
  return list()
end
