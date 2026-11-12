--[[
Adds memories to unit (NPC/player) and item tooltips.

Uses TooltipDataProcessor (the modern tooltip system) and falls back to the
old OnTooltipSetUnit/OnTooltipSetItem scripts only if a client still has
them. The unit comes from the tooltip itself rather than 'mouseover', so
hovering the target frame works too (an issue in the original addon). Any
secret value makes the handler return silently.
]]
local _, ns = ...

local Tooltip = {}
ns.Tooltip = Tooltip

local Safe = ns.Safe

Tooltip.LABELS = {
  talk = 'Talked', business = 'Business', fight = 'Fought', quest = 'Quests turned in',
  party = 'Grouped', loot = 'Looted', visit = 'Visited', die = 'Died',
}

local function stamp(snapshot)
  if not snapshot then return '-' end
  local text = ns.Util.formatDate(snapshot.date, true)
  if snapshot.level then text = text .. ' [' .. snapshot.level .. ']' end
  return text
end

function Tooltip.addMemories(tooltip, memories)
  if #memories == 0 then return false end
  tooltip:AddLine(' ')
  tooltip:AddLine(ns.highlight(ns.NAME))
  for _, memory in ipairs(memories) do
    local label = Tooltip.LABELS[memory.interaction] or ns.Util.ucfirst(memory.interaction)
    tooltip:AddDoubleLine(label, 'x' .. memory.x, 1, 1, 1, 1, 1, 1)
    if memory.x == 1 then
      tooltip:AddDoubleLine('    When', stamp(memory.first))
    else
      tooltip:AddDoubleLine('    First', stamp(memory.first))
      tooltip:AddDoubleLine('    Last', stamp(memory.last))
    end
  end
  return true
end

--[[
Category and key for a unit: ('npcs', name) or ('players', 'Name-Realm').
]]
function Tooltip.unitKey(unit)
  local guid = Safe.unitGUID(unit)
  if not guid then return nil end
  local name, realm = Safe.unitName(unit)
  if not name then return nil end
  if Safe.isNpcGuid(guid) then return 'npcs', name end
  if Safe.isPlayerGuid(guid) then
    realm = realm or Safe.str(Safe.api('GetRealmName')) or ''
    realm = string.gsub(realm, '%s', '')
    if realm == '' then return 'players', name end
    return 'players', name .. '-' .. realm
  end
  return nil
end

function Tooltip.onUnit(tooltip)
  if not ns.Repository.isReady() or not ns.Settings.get('showInTooltips') then return end
  if not tooltip or type(tooltip.GetUnit) ~= 'function' then return end
  local _, unit = Safe.call(tooltip.GetUnit, tooltip)
  if type(unit) ~= 'string' then return end
  local category, key = Tooltip.unitKey(unit)
  if not category then return end
  Tooltip.addMemories(tooltip, ns.Repository.list(category, { key }))
end

function Tooltip.onItem(tooltip, data)
  if not ns.Repository.isReady() or not ns.Settings.get('showInTooltips') then return end
  if not tooltip then return end
  local name
  if type(tooltip.GetItem) == 'function' then
    name = Safe.str((Safe.call(tooltip.GetItem, tooltip)))
  end
  if not name and type(data) == 'table' then
    local id = Safe.value(data.id)
    if id then name = Safe.str((Safe.api('C_Item.GetItemNameByID', id))) end
  end
  if not name then return end
  Tooltip.addMemories(tooltip, ns.Repository.list('items', { name }))
end

local function guarded(fn)
  return function(tooltip, data)
    local ok, err = pcall(fn, tooltip, data)
    if not ok then ns.Events.report(err) end
  end
end

--[[
Installs the tooltip hooks. Returns the method used, or nil.
]]
function Tooltip.setup()
  if Tooltip.installed then return Tooltip.installed end
  local processor = TooltipDataProcessor
  local types = Enum and Enum.TooltipDataType
  if processor and type(processor.AddTooltipPostCall) == 'function' and types then
    if types.Unit then processor.AddTooltipPostCall(types.Unit, guarded(Tooltip.onUnit)) end
    if types.Item then processor.AddTooltipPostCall(types.Item, guarded(Tooltip.onItem)) end
    Tooltip.installed = 'TooltipDataProcessor'
    return Tooltip.installed
  end
  if GameTooltip and GameTooltip.HasScript and GameTooltip:HasScript('OnTooltipSetUnit') then
    GameTooltip:HookScript('OnTooltipSetUnit', guarded(Tooltip.onUnit))
    if GameTooltip:HasScript('OnTooltipSetItem') then
      GameTooltip:HookScript('OnTooltipSetItem', guarded(Tooltip.onItem))
    end
    Tooltip.installed = 'HookScript'
    return Tooltip.installed
  end
  return nil
end
