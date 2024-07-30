---@diagnostic disable: duplicate-set-field

TestMemory = BaseTestClass:new()
    -- @covers MemoryCore:addMoment()
    function TestMemory:testAddMoment()
        local momentAdded = nil
        local printedMessage = nil

        -- mocks the repository
        function MemoryCore:getMomentRepository()
            return {
                addMoment = function(_, moment) momentAdded = moment end
            }
        end

        -- mocks the print function
        function MemoryCore:print(message)
            printedMessage = message
        end

        lu.assertIsNil(momentAdded)
        lu.assertIsNil(printedMessage)

        MemoryCore:addMoment('test-moment')

        lu.assertEquals(momentAdded, 'test-moment')
        lu.assertEquals(printedMessage, 'Current moment updated')
    end

    -- @covers Memory
    function TestMemory:testGlobalMemoryInstanceIsSet()
        lu.assertNotIsNil(MemoryCore)
    end
-- end of TestMemory