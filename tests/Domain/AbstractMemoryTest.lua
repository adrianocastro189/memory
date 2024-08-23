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
-- @covers AbstractMemory:save()
-- @covers AbstractMemory:shouldTakeScreenshot()
TestCase.new()
    :setName('abstract methods')
    :setTestClass(TestAbstractMemory)
    :setExecution(function(data)
        local abstractClass = TestAbstractMemory.getClass()

        lu.assertErrorMsgContains('This is an abstract method and should be implemented by this class inheritances',
            function()
                abstractClass[data.abstractMethod]()
            end)
    end)
    :setScenarios({
        ['getScreenshotMessage'] = { abstractMethod = 'getScreenshotMessage' },
        ['save'] = { abstractMethod = 'save' },
        ['shouldTakeScreenshot'] = { abstractMethod = 'shouldTakeScreenshot' },
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

-- @covers AbstractMemory:takeScreenshot()
TestCase.new()
    :setName('takeScreenshot')
    :setTestClass(TestAbstractMemory)
    :setExecution(function()
        MemoryCore.compatibilityHelper = Spy
            .new()
            :mockMethod('wait')

        MemoryCore.screenshotController = Spy
            .new()
            :mockMethod('prepareScreenshot')

        MemoryCore.screenshotController.takeScreenshot = 'mock'

        local levelMemory = Spy
            .new(TestAbstractMemory.getClass())
            :mockMethod('getScreenshotMessage', function() return 'message' end)

        levelMemory:takeScreenshot()

        MemoryCore.screenshotController
            :getMethod('prepareScreenshot')
            :assertCalledOnceWith('message')

        MemoryCore.compatibilityHelper
            :getMethod('wait')
            :assertCalledOnceWith(2, 'mock')
    end)
    :register()
-- End of TestAbstractMemory
