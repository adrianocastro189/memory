TestMemory = BaseTestClass:new()

-- @covers MemoryCore:addMoment()
TestCase.new()
    :setName('addMoment')
    :setTestClass(TestMemory)
    :setExecution(function ()
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
    end)
    :register()

-- @covers MemoryCore
TestCase.new()
    :setName('globalMemoryInstanceIsSet')
    :setTestClass(TestMemory)
    :setExecution(function ()
        lu.assertNotIsNil(MemoryCore)
    end)
    :register()

TestCase.new()
    :setName('printVersion')
    :setTestClass(TestMemory)
    :setExecution(function ()
        local printedMessage = nil

        -- mocks the print function
        function MemoryCore:print(message)
            printedMessage = message
        end

        lu.assertIsNil(printedMessage)

        MemoryCore:printVersion()

        lu.assertEquals('1.5.0', printedMessage)
    end)
    :register()

-- end of TestMemory