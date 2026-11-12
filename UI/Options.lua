--[[
Options panel registered with the Blizzard Settings API (Options > AddOns >
Memory Forever). It uses a canvas layout with plain check buttons and +/-
buttons, which avoids slider and dropdown templates that have changed between
client versions. Every option is also reachable through '/mem set'.
]]
local _, ns = ...

local Options = {}
ns.Options = Options

local panel, category
local refreshers = {}

local STYLE_LABELS = { chat = 'Chat', toast = 'Pop-up', both = 'Chat + pop-up', off = 'Off' }

local function addCheckbox(anchor, offsetY, key, label, onChange)
  local check = CreateFrame('CheckButton', nil, panel, 'UICheckButtonTemplate')
  check:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, offsetY)
  local text = panel:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  text:SetPoint('LEFT', check, 'RIGHT', 4, 0)
  text:SetText(label)
  check:SetScript('OnClick', function(self)
    ns.Settings.set(key, self:GetChecked() and true or false)
    if onChange then onChange() end
  end)
  table.insert(refreshers, function() check:SetChecked(ns.Settings.get(key) and true or false) end)
  return check
end

local function addStepper(anchor, offsetY, key, label, step, asPercent)
  local text = panel:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  text:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 4, offsetY)

  local minus = CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')
  minus:SetSize(24, 20)
  minus:SetPoint('LEFT', text, 'RIGHT', 10, 0)
  minus:SetText('-')

  local plus = CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')
  plus:SetSize(24, 20)
  plus:SetPoint('LEFT', minus, 'RIGHT', 4, 0)
  plus:SetText('+')

  local function show()
    local value = ns.Settings.get(key) or 0
    local shown = asPercent and (math.floor(value * 100 + 0.5) .. '%') or tostring(math.floor(value + 0.5))
    text:SetText(label .. ': ' .. ns.highlight(shown))
  end
  local function change(delta)
    ns.Settings.set(key, (ns.Settings.get(key) or 0) + delta)
    show()
  end
  minus:SetScript('OnClick', function() change(-step) end)
  plus:SetScript('OnClick', function() change(step) end)
  table.insert(refreshers, show)
  return text
end

local function build()
  panel = CreateFrame('Frame')
  panel.name = ns.NAME

  local title = panel:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  title:SetPoint('TOPLEFT', panel, 'TOPLEFT', 16, -16)
  title:SetText(ns.NAME .. ' ' .. ns.highlight(ns.VERSION, 'ffffff'))

  local credit = panel:CreateFontString(nil, 'OVERLAY', 'GameFontDisableSmall')
  credit:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -6)
  credit:SetText('A fork of Memory by Adriano Castro. Slash command: /mem')

  local tooltips = addCheckbox(credit, -14, 'showInTooltips', 'Show memories in tooltips')
  local places = addCheckbox(tooltips, -4, 'placeToasts', 'Pop-up when returning to a place or dying where you died before')
  local cooldown = addStepper(places, -8, 'placeToastCooldown', 'Same place pop-up cooldown (minutes)', 5, false)
  local levelShot = addCheckbox(cooldown, -12, 'screenshotOnLevelUp', 'Screenshot on level up')
  local achievementShot = addCheckbox(levelShot, -4, 'screenshotOnAchievement', 'Screenshot on achievement')
  local minimap = addCheckbox(achievementShot, -4, 'minimapButton', 'Show minimap button', function() ns.MinimapButton.update() end)

  local styleLabel = panel:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  styleLabel:SetPoint('TOPLEFT', minimap, 'BOTTOMLEFT', 4, -14)
  styleLabel:SetText('Random reminders:')
  local style = CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')
  style:SetSize(130, 22)
  style:SetPoint('LEFT', styleLabel, 'RIGHT', 10, 0)
  style:SetScript('OnClick', function(self)
    local values = ns.Settings.DEFINITIONS.reminderStyle.values
    local currentValue = ns.Settings.get('reminderStyle')
    for i, value in ipairs(values) do
      if value == currentValue then
        ns.Settings.set('reminderStyle', values[(i % #values) + 1])
        break
      end
    end
    self:SetText(STYLE_LABELS[ns.Settings.get('reminderStyle')])
  end)
  table.insert(refreshers, function() style:SetText(STYLE_LABELS[ns.Settings.get('reminderStyle')]) end)

  local chance = addStepper(styleLabel, -14, 'printChance', 'Reminder chance', 0.05, true)
  local shotChance = addStepper(chance, -12, 'screenshotChance', 'Random screenshot chance', 0.01, true)

  local journal = CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')
  journal:SetSize(140, 24)
  journal:SetPoint('TOPLEFT', shotChance, 'BOTTOMLEFT', -4, -20)
  journal:SetText('Open journal')
  journal:SetScript('OnClick', function() ns.Journal.open() end)

  panel:SetScript('OnShow', function()
    for _, refresh in ipairs(refreshers) do refresh() end
  end)

  if Settings and type(Settings.RegisterCanvasLayoutCategory) == 'function' then
    category = Settings.RegisterCanvasLayoutCategory(panel, ns.NAME)
    Settings.RegisterAddOnCategory(category)
  elseif type(InterfaceOptions_AddCategory) == 'function' then
    InterfaceOptions_AddCategory(panel)
  end
end

function Options.setup()
  if panel ~= nil then return panel ~= false end
  local ok, err = pcall(build)
  if not ok then
    panel = false
    ns.Events.report(err)
    return false
  end
  return true
end

function Options.open()
  if not Options.setup() then
    ns.print('Options panel unavailable. Use /mem set <key> <value> (see /mem settings).')
    return false
  end
  if category and Settings and type(Settings.OpenToCategory) == 'function' then
    local id = category.GetID and category:GetID() or category.ID
    Settings.OpenToCategory(id)
    return true
  end
  if type(InterfaceOptionsFrame_OpenToCategory) == 'function' then
    InterfaceOptionsFrame_OpenToCategory(panel)
    return true
  end
  ns.print('Open Options > AddOns > ' .. ns.NAME .. '.')
  return false
end
