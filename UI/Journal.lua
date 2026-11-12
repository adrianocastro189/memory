--[[
The journal window: browse memories by Zones, NPCs, Items, Players, Deaths,
Levels and Moments, the timeline of the current place (Here) and totals
(Stats). Search filters by name; the sort button cycles Most / Recent / A-Z.

Built only from long-standing templates (BackdropTemplate, UIPanelButtonTemplate,
UIPanelCloseButton, InputBoxTemplate, UIPanelScrollFrameTemplate). The content
is a single wrapped FontString in a scroll frame.
]]
local _, ns = ...

local Journal = { tab = 'zones', sort = 'count', search = '' }
ns.Journal = Journal

local WIDTH, HEIGHT = 640, 480
local frame, content, scroll, text, summary, sortButton, searchBox
local tabButtons = {}

local function refresh()
  if not frame or not frame:IsShown() then return end
  local lines, total = ns.Queries.lines(Journal.tab, Journal.search, Journal.sort)
  text:SetText(table.concat(lines, '\n'))
  content:SetHeight(math.max(1, (text:GetStringHeight() or 0) + 12))
  scroll:SetVerticalScroll(0)

  local listTab = Journal.tab ~= 'stats' and Journal.tab ~= 'here' and Journal.tab ~= 'levels' and Journal.tab ~= 'moments'
  summary:SetText(listTab and (total .. ' remembered') or '')
  searchBox:SetShown(listTab)
  sortButton:SetShown(listTab)
  sortButton:SetText('Sort: ' .. ns.Queries.SORT_LABELS[Journal.sort])
  for key, button in pairs(tabButtons) do
    if key == Journal.tab then button:LockHighlight() else button:UnlockHighlight() end
  end
end
Journal.refresh = refresh

local function build()
  frame = CreateFrame('Frame', 'MemoryForeverJournal', UIParent, 'BackdropTemplate')
  frame:SetSize(WIDTH, HEIGHT)
  frame:SetPoint('CENTER')
  frame:SetFrameStrata('DIALOG')
  frame:SetClampedToScreen(true)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag('LeftButton')
  frame:SetScript('OnDragStart', frame.StartMoving)
  frame:SetScript('OnDragStop', frame.StopMovingOrSizing)
  if frame.SetBackdrop then
    frame:SetBackdrop({
      bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
      edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
      tile = true, tileSize = 32, edgeSize = 32,
      insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
  end
  frame:Hide()
  if type(UISpecialFrames) == 'table' then table.insert(UISpecialFrames, 'MemoryForeverJournal') end

  local title = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  title:SetPoint('TOP', frame, 'TOP', 0, -18)
  title:SetText(ns.NAME)

  local close = CreateFrame('Button', nil, frame, 'UIPanelCloseButton')
  close:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -6, -6)

  local x = 20
  for _, tab in ipairs(ns.Queries.TABS) do
    local button = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
    button:SetSize(64, 22)
    button:SetPoint('TOPLEFT', frame, 'TOPLEFT', x, -44)
    button:SetText(tab.label)
    button:SetScript('OnClick', function()
      Journal.tab = tab.key
      refresh()
    end)
    tabButtons[tab.key] = button
    x = x + 66
  end

  searchBox = CreateFrame('EditBox', 'MemoryForeverJournalSearch', frame, 'InputBoxTemplate')
  searchBox:SetSize(200, 20)
  searchBox:SetPoint('TOPLEFT', frame, 'TOPLEFT', 28, -74)
  searchBox:SetAutoFocus(false)
  searchBox:SetScript('OnTextChanged', function(self)
    Journal.search = self:GetText() or ''
    refresh()
  end)
  searchBox:SetScript('OnEscapePressed', function(self) self:ClearFocus() end)
  searchBox:SetScript('OnEnterPressed', function(self) self:ClearFocus() end)

  sortButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
  sortButton:SetSize(110, 22)
  sortButton:SetPoint('LEFT', searchBox, 'RIGHT', 10, 0)
  sortButton:SetScript('OnClick', function()
    local sorts = ns.Queries.SORTS
    for i, mode in ipairs(sorts) do
      if mode == Journal.sort then
        Journal.sort = sorts[(i % #sorts) + 1]
        break
      end
    end
    refresh()
  end)

  summary = frame:CreateFontString(nil, 'OVERLAY', 'GameFontDisableSmall')
  summary:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -30, -78)

  scroll = CreateFrame('ScrollFrame', 'MemoryForeverJournalScroll', frame, 'UIPanelScrollFrameTemplate')
  scroll:SetPoint('TOPLEFT', frame, 'TOPLEFT', 22, -104)
  scroll:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -40, 20)

  content = CreateFrame('Frame', nil, scroll)
  content:SetSize(WIDTH - 70, 1)
  scroll:SetScrollChild(content)

  text = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  text:SetPoint('TOPLEFT', content, 'TOPLEFT', 4, -4)
  text:SetWidth(WIDTH - 80)
  text:SetJustifyH('LEFT')
  text:SetJustifyV('TOP')
  if text.SetSpacing then text:SetSpacing(3) end

  frame:SetScript('OnShow', refresh)
end

local function ensure()
  if frame == nil then
    local ok, err = pcall(build)
    if not ok then
      frame = false
      ns.Events.report(err)
    end
  end
  return frame or nil
end

function Journal.open(tab)
  if not ns.Repository.isReady() then
    ns.print('Memories are still loading.')
    return false
  end
  if not ensure() then
    ns.print('The journal window could not be created. Try /mem stats or /mem here.')
    return false
  end
  if tab then Journal.tab = tab end
  frame:Show()
  refresh()
  return true
end

function Journal.toggle(tab)
  if frame and frame:IsShown() and (not tab or tab == Journal.tab) then
    frame:Hide()
    return
  end
  Journal.open(tab)
end

function Journal.isShown()
  return frame and frame:IsShown() or false
end
