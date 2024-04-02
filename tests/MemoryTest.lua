TestMemory = BaseTestClass:new()
    -- @covers Memory
    function TestMemory:testGlobalMemoryInstanceIsSet()
        lu.assertNotIsNil(MemoryCore)
        lu.assertNotIsNil(MemoryCore.__)
    end
-- end of TestMemory