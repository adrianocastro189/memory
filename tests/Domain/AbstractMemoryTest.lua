TestAbstractMemory = BaseTestClass:new()

-- @covers AbstractMemory
TestCase.new()
    :setName('class is available for inheritance')
    :setTestClass(TestAbstractMemory)
    :setExecution(function()
        local abstractClass = MemoryCore.classes[MemoryCore.environment.constants.TEST_SUITE]['Memory/AbstractMemory']

        lu.assertNotNil(abstractClass)
    end)
    :register()
-- End of TestAbstractMemory