TestAbstractMemory = BaseTestClass:new()

--[[
Utility function to get the class under test.
]]
function TestAbstractMemory.getClass()
    return MemoryCore
        .classes
        [MemoryCore.environment.constants.TEST_SUITE]
        ['Memory/AbstractMemory']
        ['structure']
end

-- @covers AbstractMemory:getScreenshotMessage()
TestCase.new()
    :setName('abstract methods')
    :setTestClass(TestAbstractMemory)
    :setExecution(function(data)
        local abstractClass = TestAbstractMemory.getClass()

        lu.assertErrorMsgContains('This is an abstract method and should be implemented by this class inheritances', function ()
            abstractClass[data.abstractMethod]()
        end)
    end)
    :setScenarios({
        ['getScreenshotMessage'] = {abstractMethod = 'getScreenshotMessage'}
    })
    :register()

-- @covers AbstractMemory
TestCase.new()
    :setName('class is available for inheritance')
    :setTestClass(TestAbstractMemory)
    :setExecution(function()
        local abstractClass = TestAbstractMemory.getClass()

        lu.assertNotNil(abstractClass)
    end)
    :register()
-- End of TestAbstractMemory