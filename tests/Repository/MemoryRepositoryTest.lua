TestMemoryRepository = BaseTestClass:new()
    -- @covers TestMemoryRepository:__construct()
    function TestMemoryRepository:testGetInstance()
        lu.assertNotIsNil(MemoryCore:getRepository())
    end

    -- @covers TestMemoryRepository:storeLevelMemory()
    function TestMemoryRepository:testStoreLevelMemory()
        local function execution(levelMemory, expectedDataSetState)
            MemoryCore:getRepository():storeLevelMemory(levelMemory)
            
            local levels = MemoryCore.__.arr:get(MemoryAddon_DataSet, 'test-realm.test-player.levels')

            lu.assertEquals(levels, expectedDataSetState)
        end

        MemoryCore:getRepository().realm = 'test-realm'
        MemoryCore:getRepository().player = 'test-player'

        local levelMemoryWithNoZone = MemoryCore.__:new('Memory/LevelMemory')
            :setLevel(5)
            :setDate('2024-01-01')
            :setMoment(9)

        execution(levelMemoryWithNoZone, {
            ['5'] = {
                ['date'] = '2024-01-01',
                ['moment'] = 9,
                ['subZone'] = '(not set)',
                ['zone'] = '(not set)',
            },
        })

        local levelMemoryWithZone = MemoryCore.__:new('Memory/LevelMemory')
            :setLevel(5)
            :setDate('2024-01-01')
            :setMoment(9)
            :setSubZone('test-subzone')
            :setZone('test-zone')

        execution(levelMemoryWithZone, {
            ['5'] = {
                ['date'] = '2024-01-01',
                ['moment'] = 9,
                ['subZone'] = 'test-subzone',
                ['zone'] = 'test-zone',
            },
        })
    end
-- end of TestMemoryRepository.lua