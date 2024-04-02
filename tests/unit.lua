lu = require('luaunit')

dofile('./lib/stormwind-library/stormwind-library.lua')
StormwindLibrary = StormwindLibrary_v0_0_3

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

os.exit(lu.LuaUnit.run())