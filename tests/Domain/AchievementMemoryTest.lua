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

-- @covers AchievementMemory:shouldTakeScreenshot()
TestCase.new()
    :setName('shouldTakeScreenshot')
    :setTestClass(TestAchievementMemory)
    :setExecution(function(data)
        MemoryCore.settingsRepository:set('memory.screenshotOnAchievement', data.settingValue)

        local instance = MemoryCore:new('Memory/AchievementMemory')

        lu.assertEquals(data.expectedResult, instance:shouldTakeScreenshot())
    end)
    :setScenarios({
        ['setting is nil'] = {
            settingValue = nil,
            expectedResult = true,
        },
        ['setting is 0'] = {
            settingValue = 0,
            expectedResult = false,
        },
        ['setting is "no"'] = {
            settingValue = 'no',
            expectedResult = false,
        },
        ['setting is "false"'] = {
            settingValue = 'false',
            expectedResult = false,
        },
        ['setting is 1'] = {
            settingValue = 1,
            expectedResult = true,
        },
        ['setting is "yes"'] = {
            settingValue = 'yes',
            expectedResult = true,
        },
        ['setting is "true"'] = {
            settingValue = 'true',
            expectedResult = true,
        },
    })
    :register()
-- End of TestAchievementMemory