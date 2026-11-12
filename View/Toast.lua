--[[
A small pop-up near the top of the screen ("You've been to Goldshire 7
times"). Click to dismiss. Falls back to chat if the frame can't be built.
]]
local _, ns = ...

local Toast = {}
ns.Toast = Toast

local frame, title, body
local token = 0

local function build()
  frame = CreateFrame('Frame', 'MemoryForeverToast', UIParent, 'BackdropTemplate')
  frame:SetSize(380, 64)
  frame:SetPoint('TOP', UIParent, 'TOP', 0, -150)
  frame:SetFrameStrata('HIGH')
  frame:SetClampedToScreen(true)
  if frame.SetBackdrop then
    frame:SetBackdrop({
      bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
      edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
      tile = true, tileSize = 16, edgeSize = 16,
      insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0.05, 0.05, 0.08, 0.9)
    frame:SetBackdropBorderColor(1, 0.93, 0.47, 0.9)
  end

  local icon = frame:CreateTexture(nil, 'ARTWORK')
  icon:SetSize(36, 36)
  icon:SetPoint('LEFT', frame, 'LEFT', 12, 0)
  icon:SetTexture('Interface\\Icons\\INV_Misc_Book_09')

  title = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  title:SetPoint('TOPLEFT', icon, 'TOPRIGHT', 10, 0)
  title:SetPoint('RIGHT', frame, 'RIGHT', -12, 0)
  title:SetJustifyH('LEFT')

  body = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  body:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -4)
  body:SetPoint('RIGHT', frame, 'RIGHT', -12, 0)
  body:SetJustifyH('LEFT')
  body:SetJustifyV('TOP')

  frame:EnableMouse(true)
  frame:SetScript('OnMouseUp', function(self) self:Hide() end)
  frame:Hide()
end

function Toast.show(heading, text, duration)
  if not frame then
    local ok = pcall(build)
    if not ok then frame = false end
  end
  if not frame then
    ns.print(heading and (heading .. ' - ' .. text) or text)
    return
  end

  title:SetText(heading or ns.NAME)
  body:SetText(text or '')
  local height = 40 + (body.GetStringHeight and body:GetStringHeight() or 14)
  frame:SetHeight(math.max(64, height))
  frame:SetAlpha(1)
  frame:Show()

  token = token + 1
  local mine = token
  ns.Events.after(duration or 6, function()
    if token ~= mine or not frame:IsShown() then return end
    if type(UIFrameFadeOut) == 'function' then
      UIFrameFadeOut(frame, 1, 1, 0)
      ns.Events.after(1.05, function()
        if token == mine then frame:Hide() end
      end)
    else
      frame:Hide()
    end
  end)
end

function Toast.isShown()
  return frame and frame:IsShown() or false
end
