TestAchievementMemory = BaseTestClass:new()

-- @covers AchievementMemory:__construct()
TestCase.new()
    :setName('__construct')
    :setTestClass(TestAchievementMemory)
    :setExecution(function()
        local instance = MemoryCore:new('Memory/AchievementMemory')

        lu.assertNotNil(instance)
    end)
    :register()

-- @covers AchievementMemory:getScreenshotMessage()
TestCase.new()
    :setName('getScreenshotMessage')
    :setTestClass(TestAchievementMemory)
    :setExecution(function()
        local instance = MemoryCore
            :new('Memory/AchievementMemory')
            :setDate('2024-01-01')

        local result = instance:getScreenshotMessage()

        lu.assertEquals(result, 'Achievement earned on January 1, 2024')
    end)
    :register()

-- @covers AchievementMemory:save()
TestCase.new()
    :setName('save')
    :setTestClass(TestAchievementMemory)
    :setExecution(function()
        local instance = MemoryCore:new('Memory/AchievementMemory')

        -- just asserts that no error is thrown
        instance:save()
    end)
    :register()
