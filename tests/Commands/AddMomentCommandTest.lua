TestAddMomentCommand = BaseTestClass:new()

-- @covers includes/commands/AddMomentCommand.lua
TestCase.new()
    :setName('command callback')
    :setTestClass(TestAddMomentCommand)
    :setExecution(function(data)
        MemoryCore = Spy
            .new(MemoryCore)
            :mockMethod('addMoment')
            :mockMethod('print')

        MemoryCore.commands.operations.addm.callback(data.moment, data.rest)

        if data.expectedAddedMoment then
            MemoryCore:getMethod('addMoment'):assertCalledOnceWith(data.expectedAddedMoment)
        else
            MemoryCore:getMethod('addMoment'):assertNotCalled()
        end

        if data.expectedErrorMessage then
            MemoryCore:getMethod('print'):assertCalledOnceWith(data.expectedErrorMessage)
            return
        end

        MemoryCore:getMethod('print'):assertNotCalled()
    end)
    :setScenarios({
        ['simple moment'] = {
            moment = 'test-moment',
            rest = nil,
            expectedErrorMessage = nil,
            expectedAddedMoment = 'test-moment'
        },
        ['moment with more than one word'] = {
            moment = 'test-moment',
            rest = 'rest',
            expectedErrorMessage = 'The moment must be wrapped in quotation marks',
            expectedAddedMoment = nil
        },
        ['no moment'] = {
            moment = nil,
            rest = nil,
            expectedErrorMessage = 'Please, provide a moment to be added wrapped in quotation marks',
            expectedAddedMoment = nil
        }
    })
    :register()

-- @covers includes/commands/AddMomentCommand.lua
TestCase.new()
    :setName('command was added')
    :setTestClass(TestAddMomentCommand)
    :setExecution(function()
        local operations = MemoryCore.commands.operations

        lu.assertNotIsNil(MemoryCore.arr:get(operations, 'addm'))
    end)
    :register()
-- end of TestAddMomentCommand
