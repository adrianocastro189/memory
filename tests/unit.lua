lu = require('luaunit')

--[[
Loads all addon files in the correct order.
]]
local function loadAddonFiles()

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
        function dd(...) MemoryCore.__:dd(...) end

        -- this makes the Environment class to return the proper client flavor when
        -- running this test suite
        _G['TEST_ENVIRONMENT'] = true

        dofile('./tests/wow-mocks.lua')

        dofile('./lib/stormwind-library/stormwind-library.lua')

        dofile('./Memory.lua')
        dofile('./includes/commands/AddMomentCommand.lua')
        dofile('./includes/commands/GetMomentCommand.lua')
        dofile('./includes/commands/GetSettingCommand.lua')
        dofile('./includes/commands/UpdateSettingCommand.lua')
        dofile('./includes/core/ScreenshotController.lua')
        dofile('./includes/core/TooltipController.lua')
        dofile('./includes/domain/LevelMemory.lua')
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

        MemoryAddon_DataSet = nil
        MemoryCore.__.events:notify('PLAYER_LOGIN')
        MemoryCore.__.output:setTestingMode()
    end,
}

dofile('./tests/MemoryTest.lua')
dofile('./tests/Commands/AddMomentCommandTest.lua')
dofile('./tests/Commands/GetMomentCommandTest.lua')
dofile('./tests/Commands/GetSettingCommandTest.lua')
dofile('./tests/Commands/UpdateSettingCommandTest.lua')
dofile('./tests/Core/TooltipControllerTest.lua')
dofile('./tests/Domain/LevelMemoryTest.lua')
dofile('./tests/Repository/MemoryRepositoryTest.lua')

lu.ORDER_ACTUAL_EXPECTED=false

os.exit(lu.LuaUnit.run())