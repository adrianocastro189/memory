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