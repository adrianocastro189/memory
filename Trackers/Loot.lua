--[[
Looted items, keyed by item name like the original.

- Open world: parse your own "You receive loot: [Item]x2." lines from
  CHAT_MSG_LOOT. The patterns are built from the client's localized
  LOOT_ITEM_SELF(_MULTIPLE) strings, and the item name is read from the
  hyperlink itself, so no item-info lookup is needed.
- Instances: chat text is a secret value there, so instead the items in the
  loot window are noted when it opens, and the bag count of each is compared
  after it closes. Whatever increased was looted.

The two paths never run at the same time (IsInInstance decides), so nothing
is counted twice.
]]
local _, ns = ...

local Safe = ns.Safe
local Util = ns.Util

local Loot = { window = nil }
ns.Loot = Loot

local function verbs(name)
  return { past = 'looted', pastConnector = 'an item called', present = 'loot', presentConnector = 'an item called', subject = name }
end

function Loot.patterns()
  if Loot.cachedPatterns then return Loot.cachedPatterns end
  local patterns = {}
  if type(LOOT_ITEM_SELF_MULTIPLE) == 'string' then
    table.insert(patterns, { pattern = Util.formatToPattern(LOOT_ITEM_SELF_MULTIPLE), multiple = true })
  end
  if type(LOOT_ITEM_SELF) == 'string' then
    table.insert(patterns, { pattern = Util.formatToPattern(LOOT_ITEM_SELF), multiple = false })
  end
  Loot.cachedPatterns = patterns
  return patterns
end

--[[
Parses a loot message. Returns itemName, quantity or nil.
]]
function Loot.parse(message)
  message = Safe.str(message)
  if not message then return nil end
  for _, entry in ipairs(Loot.patterns()) do
    local link, quantity = string.match(message, entry.pattern)
    if link then
      local name = Util.itemNameFromLink(link)
      if not name then
        name = Safe.str((Safe.api('C_Item.GetItemInfo', link)))
          or Safe.str((Safe.api('GetItemInfo', link)))
      end
      if name then return name, tonumber(quantity) or 1 end
      return nil
    end
  end
  return nil
end

local function inInstance()
  return Safe.api('IsInInstance') == true
end

function Loot.record(name, quantity)
  if not name or not ns.Repository.isReady() then return end
  ns.record({ category = 'items', path = { name }, interaction = 'loot', x = quantity or 1, verbs = verbs(name) })
end

function Loot.onChat(_, message)
  if inInstance() then return end
  local name, quantity = Loot.parse(message)
  if name then Loot.record(name, quantity) end
end

local function itemCount(itemID)
  return tonumber(Safe.api('C_Item.GetItemCount', itemID)) or tonumber(Safe.api('GetItemCount', itemID)) or 0
end

function Loot.onWindowOpen()
  if not inInstance() then Loot.window = nil return end
  local slots = tonumber(Safe.api('GetNumLootItems')) or 0
  local window = {}
  for slot = 1, slots do
    local link = Safe.str(Safe.api('GetLootSlotLink', slot))
    local itemID = Util.itemIdFromLink(link)
    local name = Util.itemNameFromLink(link)
    if itemID and name and not window[itemID] then
      window[itemID] = { name = name, before = itemCount(itemID) }
    end
  end
  Loot.window = window
end

function Loot.onWindowClosed()
  local window = Loot.window
  Loot.window = nil
  if not window then return end
  -- bags update right after the window closes
  ns.Events.after(1, function()
    for itemID, entry in pairs(window) do
      local gained = itemCount(itemID) - entry.before
      if gained > 0 then Loot.record(entry.name, gained) end
    end
  end)
end

ns.Trackers.register('loot', {
  label = 'Looted items',
  setup = function(on)
    on('CHAT_MSG_LOOT', Loot.onChat)
    on('LOOT_OPENED', Loot.onWindowOpen)
    on('LOOT_CLOSED', Loot.onWindowClosed)
  end,
})
