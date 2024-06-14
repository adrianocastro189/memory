TestMemoryRepository = BaseTestClass:new()
    -- @covers TestMemoryRepository:__construct()
    function TestMemoryRepository:testGetInstance()
        lu.assertNotIsNil(MemoryCore:getRepository())
    end
-- end of TestMemoryRepository.lua