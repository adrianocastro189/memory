---@diagnostic disable: unused-function, duplicate-set-field

TestAddMomentCommand = BaseTestClass:new()
    -- @covers includes/commands/AddMomentCommand.lua
    function TestAddMomentCommand:testCommandCallback()
        local function execution(moment, rest, expectedErrorMessage, expectedAddedMoment)
            -- expectations
            local addedMoment, errorMessage = nil, nil

            -- mocks
            function MemoryCore:addMoment(momentToBeAdded) addedMoment = momentToBeAdded end
            function MemoryCore:print(message) errorMessage = message end

            MemoryCore.__.commands.operations.addm.callback(moment, rest)

            lu.assertEquals(expectedErrorMessage, errorMessage)
            lu.assertEquals(expectedAddedMoment, addedMoment)
        end


        execution('test-moment', nil, nil, 'test-moment')
        execution('test-moment', 'rest', 'The moment must be wrapped in quotation marks', nil)
        execution(nil, nil, 'Please, provide a moment to be added wrapped in quotation marks', nil)
    end

    -- @covers includes/commands/AddMomentCommand.lua
    function TestAddMomentCommand:testCommandWasAdded()
        local operations = MemoryCore.__.commands.operations

        lu.assertNotIsNil(MemoryCore.__.arr:get(operations, 'addm'))
    end
-- end of TestAddMomentCommand