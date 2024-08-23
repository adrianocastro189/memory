TestGetMomentCommand = BaseTestClass:new()

-- @covers includes/commands/GetMomentCommand.lua
TestCase.new()
    :setName('command args validator')
    :setTestClass(TestGetMomentCommand)
    :setExecution(function(data)
        MemoryCore = Spy
            .new(MemoryCore)
            :mockMethod('getMomentRepository', function()
                return {
                    hasCurrentMoment = function() return data.hasCurrentMoment end
                }
            end)

        lu.assertEquals(data.expectedResult, MemoryCore.commands.operations.getm.argsValidator())
    end)
    :setScenarios({
        ['has current moment'] = {
            hasCurrentMoment = true,
            expectedResult = 'valid'
        },
        ['no current moment'] = {
            hasCurrentMoment = false,
            expectedResult =
            'There\'s no moment in the player\'s memory yet. Add one by typing /memoryaddon addm "Your moment here"'
        }
    })
    :register()

-- @covers includes/commands/GetMomentCommand.lua
TestCase.new()
    :setName('command callback')
    :setTestClass(TestGetMomentCommand)
    :setExecution(function()
        MemoryCore = Spy
            .new(MemoryCore)
            :mockMethod('getMomentRepository',
                function() return { getCurrentMoment = function() return 'test-moment' end } end)
            :mockMethod('print')

        MemoryCore.commands.operations.getm.callback()

        MemoryCore
            :getMethod('print')
            :assertCalledOnceWith('test-moment')
    end)
    :register()

-- @covers includes/commands/GetMomentCommand.lua
TestCase.new()
    :setName('command was added')
    :setTestClass(TestGetMomentCommand)
    :setExecution(function()
        local operations = MemoryCore.commands.operations

        lu.assertNotIsNil(MemoryCore.arr:get(operations, 'getm'))
    end)
    :register()
-- end of TestGetMomentCommand
