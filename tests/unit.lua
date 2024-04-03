-- mocks the CreateFrame World of Warcraft API method
-- @TODO: Move this to a separate file <2024.04.03>
function CreateFrame(name)
    local mockInstance = {}
    mockInstance.__index = mockInstance
    function mockInstance:AddMessage() end
    function mockInstance:RegisterEvent() end
    function mockInstance:SetPoint() end
    function mockInstance:SetScript() end
    function mockInstance:SetSize() end
    function mockInstance:SetText() end
    function mockInstance:UnregisterEvent() end
    return mockInstance
end
GameTooltip = {}
function GameTooltip:HookScript() end
SlashCmdList = {}
DEFAULT_CHAT_FRAME = CreateFrame('Frame')
LOOT_ITEM_SELF = 'You receive loot : %s|Hitem :%d :%d :%d :%d|h[%s]|h%s.'
LOOT_ITEM_SELF_MULTIPLE = 'You receive loot: %sx%d.'
GetZoneText = function() return 'Stormwind City' end
GetSubZoneText = function() return 'Trade District' end
UnitGUID = function(unit) return 'player' end
UnitLevel = function(unit) return 60 end
GetRealmName = function() return 'test-realm' end
date = function(format) return '2024-02-04' end
-- end of World of Warcraft mocks

lu = require('luaunit')

--[[
Loads all addon files in the correct order.
]]
local function loadAddonFiles()
    dofile('./lib/stormwind-library/stormwind-library.lua')
    dofile('./Memory.lua')
    dofile('./includes/commands/AddMomentCommand.lua')
    dofile('./includes/commands/GetMomentCommand.lua')
    dofile('./includes/core/ScreenshotController.lua')
    dofile('./includes/core/TooltipController.lua')
    dofile('./includes/domain/Memory.lua')
    dofile('./includes/domain/MemoryString.lua')
    dofile('./includes/domain/Player.lua')
    dofile('./includes/events/MemoryEvent.lua')
    dofile('./includes/events/MemoryEvents.lua')
    dofile('./includes/helpers/ArrayHelper.lua')
    dofile('./includes/helpers/DateHelper.lua')
    dofile('./includes/helpers/CompatibilityHelper.lua')
    dofile('./includes/helpers/LoggerHelper.lua')
    dofile('./includes/helpers/StringHelper.lua')
    dofile('./includes/repository/MemoryRepository.lua')
    dofile('./includes/repository/MomentRepository.lua')
    dofile('./includes/repository/SettingsRepository.lua')
    dofile('./includes/view/MemoryTextFormatter.lua') 
end

--[[
This is a base test class that sets everything up before each test.

Every test class should inherit from this class. That way, mocking objects
on tests won't affect the results of other tests.

The setUp() method is expected to be called before each test.
]]
BaseTestClass = {
    new = function(self)
        local instance = {}
        setmetatable(instance, self)
        self.__index = self
        return instance
    end,
    
    setUp = function()
        loadAddonFiles()
        MemoryCore.__.events:notify( 'PLAYER_LOGIN' )
    end,
}

lu.ORDER_ACTUAL_EXPECTED=false

dofile('./tests/MemoryTest.lua')

dofile('./tests/Commands/AddMomentCommandTest.lua')
dofile('./tests/Commands/GetMomentCommandTest.lua')

os.exit(lu.LuaUnit.run())