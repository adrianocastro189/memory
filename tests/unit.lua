-- mocks the CreateFrame World of Warcraft API method
function CreateFrame(name)
    local mockInstance = {}
    mockInstance.__index = mockInstance
    function mockInstance:RegisterEvent() end
    function mockInstance:SetPoint() end
    function mockInstance:SetScript() end
    function mockInstance:SetSize() end
    function mockInstance:SetText() end
    return mockInstance
end

SlashCmdList = {}

lu = require('luaunit')

dofile('./lib/stormwind-library/stormwind-library.lua')

dofile('./Memory.lua')

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
        -- @TODO: Implement this method once there are objects to be mocked <2024.02.04>
    end,
}

lu.ORDER_ACTUAL_EXPECTED=false

dofile('./tests/MemoryTest.lua')

os.exit(lu.LuaUnit.run())