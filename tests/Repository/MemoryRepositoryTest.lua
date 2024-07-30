-- @TODO: Move this test class to the new TestCase structure <2024.07.30>

TestMemoryRepository = BaseTestClass:new()
    -- @covers TestMemoryRepository:__construct()
    function TestMemoryRepository:testGetInstance()
        lu.assertNotIsNil(MemoryCore:getRepository())
    end

    -- @covers TestMemoryRepository:storeLevelMemory()
    function TestMemoryRepository:testStoreLevelMemory()
        MemoryCore:getRepository().realm = 'test-realm'
        MemoryCore:getRepository().player = 'test-player'

        local levelMemory = MemoryCore:new('Memory/LevelMemory')
            :setLevel(5)
            :setDate('2024-01-01')
            :setMoment(9)
            :setSubZone('test-subzone')
            :setZone('test-zone')

        MemoryCore:getRepository():storeLevelMemory(levelMemory)

        local levels = MemoryCore.arr:get(MemoryAddon_DataSet, 'test-realm.test-player.levels')

        lu.assertEquals({
            ['5'] = {
                ['date'] = '2024-01-01',
                ['moment'] = 9,
                ['subZone'] = 'test-subzone',
                ['zone'] = 'test-zone',
            },
        }, levels)
    end
-- end of TestMemoryRepository.lua