-- @TODO: Move this test class to the new TestCase structure <2024.07.30>

TestLevelMemory = BaseTestClass:new()
    -- @covers TestLevelMemory:__construct()
    function TestLevelMemory:testConstruct()
        local instance = MemoryCore:new('Memory/LevelMemory')

        lu.assertNotNil(instance)
    end

    -- @covers LevelMemory:getScreenshotMessage()
    function TestLevelMemory:testGetScreenshotMessage()
        local instance = MemoryCore:new('Memory/LevelMemory')
            :setDate('2024-01-01')
            :setLevel(13)

        local result = instance:getScreenshotMessage()

        lu.assertEquals(result, 'Reached level 13 on January 1, 2024')
    end

    -- @covers LevelMemory:maybeTakeScreenshot()
    function TestLevelMemory:testMaybeTakeScreenshot()
        local function execution(settingValue, shouldCallTakeScreenshot)
            MemoryCore.settingsRepository:set('memory.screenshotOnLevelUp', settingValue)

            local levelMemory = MemoryCore:new('Memory/LevelMemory')
            levelMemory.takeScreenshotInvoked = false
            levelMemory.takeScreenshot = function() levelMemory.takeScreenshotInvoked = true end

            levelMemory:maybeTakeScreenshot()

            lu.assertEquals(shouldCallTakeScreenshot, levelMemory.takeScreenshotInvoked)
        end

        -- setting is nil
        execution(nil, true)

        -- setting is false
        execution(0, false)
        execution('no', false)
        execution('false', false)

        -- setting is true
        execution(1, true)
        execution('yes', true)
        execution('true', true)
    end

    -- @covers LevelMemory.newWithCurrentData()
    function TestLevelMemory:testNewWithCurrentData()
        -- mocks
        MemoryCore.getDateHelper = function() return { getToday = function() return 'test-date' end } end
        MemoryCore.currentPlayer = { level = 5 }
        MemoryCore.getMomentRepository = function() return { getCurrentMomentIndex = function() return 3 end } end
        GetSubZoneText = function() return 'test-sub-zone' end
        GetZoneText = function() return 'test-zone' end

        local instance = MemoryCore
            :getClass('Memory/LevelMemory')
            .newWithCurrentData()

        lu.assertEquals(instance.date, 'test-date')
        lu.assertEquals(instance.level, 5)
        lu.assertEquals(instance.moment, 3)
        lu.assertEquals(instance.subZone, 'test-sub-zone')
        lu.assertEquals(instance.zone, 'test-zone')
    end

    -- @covers LevelMemory:save()
    function TestLevelMemory:testSave()
        -- mocks
        MemoryCore.getRepository = function()
            return {
                storeLevelMemory = function(self, levelMemory)
                    MemoryCore.levelMemoryArg = levelMemory
                end
            }
        end

        local instance = MemoryCore:new('Memory/LevelMemory')
            :setLevel(13)
            :setDate('2024-01-01')
            :setMoment(2)

        instance:save()

        lu.assertEquals(MemoryCore.levelMemoryArg, instance)
    end

    -- @covers LevelMemory:setDate()
    -- @covers LevelMemory:setLevel()
    -- @covers LevelMemory:setMoment()
    -- @covers LevelMemory:setSubZone()
    -- @covers LevelMemory:setZone()
    function TestLevelMemory:testSetters()
        local instance = MemoryCore:new('Memory/LevelMemory')

        local result = instance
            :setDate('2024-01-01')
            :setLevel(1)
            :setMoment(2)
            :setSubZone('test-sub-zone')
            :setZone('test-zone')

        lu.assertEquals(instance.date, '2024-01-01')
        lu.assertEquals(instance.level, 1)
        lu.assertEquals(instance.moment, 2)
        lu.assertEquals(instance.subZone, 'test-sub-zone')
        lu.assertEquals(instance.zone, 'test-zone')

        -- asserts that the setters return the instance for chaining
        lu.assertEquals(instance, result)
    end

    -- @covers LevelMemory:takeScreenshot()
    function TestLevelMemory:testTakeScreenshot()
        MemoryCore.compatibilityHelper = {
            wait = function(self, arg1, arg2)
                self.arg1 = arg1
                self.arg2 = arg2
            end,
        }

        MemoryCore.screenshotController = {
            prepareScreenshot = function(self, message) self.messageArg = message end,
            takeScreenshot = 'test-take-screenshot',
        }

        local levelMemory = MemoryCore:new('Memory/LevelMemory')
        
        levelMemory.getScreenshotMessage = function() return 'test-message' end
        levelMemory:takeScreenshot()

        lu.assertEquals('test-message', MemoryCore.screenshotController.messageArg)
        lu.assertEquals(2, MemoryCore.compatibilityHelper.arg1)
        lu.assertEquals(MemoryCore.screenshotController.takeScreenshot, MemoryCore.compatibilityHelper.arg2)
    end
-- end of TestLevelMemory