TestAchievementMemory = BaseTestClass:new()

-- @covers TestAchievementMemory:__construct()
TestCase.new()
    :setName('__construct')
    :setTestClass(TestAchievementMemory)
    :setExecution(function()
        local instance = MemoryCore:new('Memory/AchievementMemory')

        lu.assertNotNil(instance)
    end)
    :register()
