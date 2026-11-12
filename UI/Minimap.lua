--[[
A minimap button (left-click: journal, right-click: options, drag: move). No
LibDBIcon dependency. Also wires the AddOns compartment entry declared in the
TOC (AddonCompartmentFunc).
]]
local _, ns = ...

local MinimapButton = {}
ns.MinimapButton = MinimapButton

local button

local function place()
  local angle = math.rad(ns.Settings.get('minimapAngle') or 225)
  local radius = ((Minimap:GetWidth() or 140) / 2) + 6
  button:ClearAllPoints()
  button:SetPoint('CENTER', Minimap, 'CENTER', math.cos(angle) * radius, math.sin(angle) * radius)
end

local function onDragUpdate()
  local mx, my = Minimap:GetCenter()
  local px, py = GetCursorPosition()
  local scale = Minimap:GetEffectiveScale() or 1
  if not mx or not px then return end
  px, py = px / scale, py / scale
  local angle = math.deg(math.atan2(py - my, px - mx)) % 360
  ns.Settings.set('minimapAngle', angle)
  place()
end

local function build()
  button = CreateFrame('Button', 'MemoryForeverMinimapButton', Minimap)
  button:SetSize(31, 31)
  button:SetFrameStrata('MEDIUM')
  button:SetFrameLevel(8)
  button:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
  button:RegisterForDrag('LeftButton')
  button:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')

  local background = button:CreateTexture(nil, 'BACKGROUND')
  background:SetSize(20, 20)
  background:SetTexture('Interface\\Minimap\\UI-Minimap-Background')
  background:SetPoint('TOPLEFT', button, 'TOPLEFT', 7, -5)

  local icon = button:CreateTexture(nil, 'ARTWORK')
  icon:SetSize(17, 17)
  icon:SetTexture('Interface\\Icons\\INV_Misc_Book_09')
  icon:SetPoint('TOPLEFT', button, 'TOPLEFT', 7, -6)

  local border = button:CreateTexture(nil, 'OVERLAY')
  border:SetSize(53, 53)
  border:SetTexture('Interface\\Minimap\\MiniMap-TrackingBorder')
  border:SetPoint('TOPLEFT', button, 'TOPLEFT')

  button:SetScript('OnClick', function(_, mouseButton)
    if mouseButton == 'RightButton' then ns.Options.open() else ns.Journal.toggle() end
  end)
  button:SetScript('OnDragStart', function(self) self:SetScript('OnUpdate', onDragUpdate) end)
  button:SetScript('OnDragStop', function(self) self:SetScript('OnUpdate', nil) end)
  button:SetScript('OnEnter', function(self)
    GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
    GameTooltip:AddLine(ns.NAME)
    GameTooltip:AddLine('Left-click: journal', 1, 1, 1)
    GameTooltip:AddLine('Right-click: options', 1, 1, 1)
    GameTooltip:AddLine('Drag: move', 1, 1, 1)
    GameTooltip:Show()
  end)
  button:SetScript('OnLeave', function() GameTooltip:Hide() end)
  place()
end

function MinimapButton.update()
  if not Minimap then return end
  if ns.Settings.get('minimapButton') then
    if not button then
      local ok, err = pcall(build)
      if not ok then
        button = nil
        ns.Events.report(err)
        return
      end
    end
    button:Show()
  elseif button then
    button:Hide()
  end
end

function MinimapButton.isShown()
  return button ~= nil and button:IsShown()
end

-- AddOns compartment (the addon list button next to the minimap)
function MemoryForever_OnAddonCompartmentClick(_, mouseButton)
  if mouseButton == 'RightButton' then ns.Options.open() else ns.Journal.toggle() end
end
