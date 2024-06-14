---@diagnostic disable: unused-function, duplicate-set-field

TestGetMomentCommand = BaseTestClass:new()
    -- @covers includes/commands/GetMomentCommand.lua
    function TestGetMomentCommand:testCommandArgsValidator()
        local function execution(hasCurrentMoment, expectedResult)
            MemoryCore.getMomentRepository = function ()
                return {
                    hasCurrentMoment = function() return hasCurrentMoment end
                }
            end

            lu.assertEquals(expectedResult, MemoryCore.__.commands.operations.getm.argsValidator())
        end

        execution(true, 'valid')
        execution(false, 'There\'s no moment in the player\'s memory yet. Add one by typing /memoryaddon addm "Your moment here"')
    end

    -- @covers includes/commands/GetMomentCommand.lua
    function TestGetMomentCommand:testCommandCallback()
        local messagePrinted = nil

        -- mocks
        function MemoryCore:getMomentRepository() return {
            getCurrentMoment = function() return 'test-moment' end
        } end
        function MemoryCore:print(message) messagePrinted = message end

        MemoryCore.__.commands.operations.getm.callback()

        lu.assertEquals('test-moment', messagePrinted)
    end

    -- @covers includes/commands/GetMomentCommand.lua
    function TestGetMomentCommand:testCommandWasAdded()
        local operations = MemoryCore.__.commands.operations

        lu.assertNotIsNil(MemoryCore.__.arr:get(operations, 'getm'))
    end
-- end of TestGetMomentCommand