TestLevelMemory = BaseTestClass:new()
    -- @covers TestLevelMemory:__construct()
    function TestLevelMemory:testConstruct()
        local instance = MemoryCore.__:new('Memory/LevelMemory')

        lu.assertNotNil(instance)
    end

    -- @covers LevelMemory:getScreenshotMessage()
    function TestLevelMemory:testGetScreenshotMessage()
    -- @TODO: Implement this method in HN5 <2024.06.14>
    end

    -- @covers LevelMemory:maybeTakeScreenshot()
    function TestLevelMemory:testMaybeTakeScreenshot()
    -- @TODO: Implement this method in HN5 <2024.06.14>
    end

    -- @covers LevelMemory.newWithCurrentData()
    -- @TODO: Improve this method implementation in HN3 <2024.06.14>
    function TestLevelMemory:testNewWithCurrentData()
        -- mocks
        MemoryCore.getDateHelper = function() return { getToday = function() return 'test-date' end } end
        MemoryCore.__.currentPlayer = { level = 5 }
        MemoryCore.getMomentRepository = function() return { getCurrentMomentIndex = function() return 3 end } end
        GetSubZoneText = function() return 'test-sub-zone' end
        GetZoneText = function() return 'test-zone' end

        local instance = MemoryCore.__
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
    -- @TODO: Implement this method in HN4 <2024.06.14>
    end

    -- @covers LevelMemory:setDate()
    -- @covers LevelMemory:setLevel()
    -- @covers LevelMemory:setMoment()
    -- @covers LevelMemory:setSubZone()
    -- @covers LevelMemory:setZone()
    function TestLevelMemory:testSetters()
        local instance = MemoryCore.__:new('Memory/LevelMemory')

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
    -- @TODO: Implement this method in HN5 <2024.06.14>
    end
-- end of TestLevelMemory