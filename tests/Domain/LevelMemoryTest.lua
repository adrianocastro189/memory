TestLevelMemory = BaseTestClass:new()
    -- @covers TestLevelMemory:__construct()
    function TestLevelMemory:testConstruct()
        local instance = MemoryCore.__:new('Memory/LevelMemory')

        lu.assertNotNil(instance)
    end
-- end of TestLevelMemory