TestLevelMemory = BaseTestClass:new()

-- @covers TestLevelMemory:__construct()
TestCase.new()
    :setName('__construct')
    :setTestClass(TestLevelMemory)
    :setExecution(function()
        local instance = MemoryCore:new('Memory/LevelMemory')

        lu.assertNotNil(instance)
    end)
    :register()

-- @covers LevelMemory:getScreenshotMessage()
TestCase.new()
    :setName('getScreenshotMessage')
    :setTestClass(TestLevelMemory)
    :setExecution(function()
        local instance = MemoryCore:new('Memory/LevelMemory')
            :setDate('2024-01-01')
            :setLevel(13)

        local result = instance:getScreenshotMessage()

        lu.assertEquals(result, 'Reached level 13 on January 1, 2024')
    end)
    :register()

-- @covers LevelMemory:save()
TestCase.new()
    :setName('save')
    :setTestClass(TestLevelMemory)
    :setExecution(function()
        local repository = Spy
            .new()
            :mockMethod('storeLevelMemory')

        MemoryCore = Spy
            .new(MemoryCore)
            :mockMethod('getRepository', function () return repository end)
        
        local instance = MemoryCore
            :new('Memory/LevelMemory')
            :setLevel(13)
            :setDate('2024-01-01')
            :setMoment(2)

        instance:save()

        repository
            :getMethod('storeLevelMemory')
            :assertCalledOnceWith(instance)
    end)
    :register()

-- @covers LevelMemory:shouldTakeScreenshot()
TestCase.new()
    :setName('shouldTakeScreenshot')
    :setTestClass(TestLevelMemory)
    :setExecution(function(data)
        MemoryCore.settingsRepository:set('memory.screenshotOnLevelUp', data.settingValue)

        local instance = MemoryCore:new('Memory/LevelMemory')

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
-- end of TestLevelMemory