TestUpdateSettingCommand = BaseTestClass:new()

-- @covers includes/commands/UpdateSettingCommand.lua
TestCase.new()
    :setName('command callback')
    :setTestClass(TestUpdateSettingCommand)
    :setExecution(function()
        MemoryCore = Spy
            .new(MemoryCore)
            :mockMethod('setting')
            :mockMethod('print')

        MemoryCore.commands.operations.set.callback('test-key', 'test-value')

        MemoryCore
            :getMethod('setting')
            :assertCalledOnceWith('test-key', 'test-value', true)

        MemoryCore
            :getMethod('print')
            :assertCalledOnceWith('test-key set to test-value')
    end)
    :register()

-- @covers includes/commands/UpdateSettingCommand.lua
TestCase.new()
    :setName('callback with empty values')
    :setTestClass(TestUpdateSettingCommand)
    :setExecution(function(data)
        MemoryCore = Spy
            .new(MemoryCore)
            :mockMethod('print')

        MemoryCore.commands.operations.set.callback(data.key, data.value)

        lu.assertEquals('Please, provide a key and a value to be set', data.expectedMessage)
    end)
    :setScenarios({
        ['no key provided'] = {
            key = nil,
            value = 'test-value',
            expectedMessage = 'Please, provide a key and a value to be set'
        },
        ['no value provided'] = {
            key = 'test-key',
            value = nil,
            expectedMessage = 'Please, provide a key and a value to be set'
        }
    })
    :register()

-- @covers includes/commands/UpdateSettingCommand.lua
TestCase.new()
    :setName('command was added')
    :setTestClass(TestUpdateSettingCommand)
    :setExecution(function()
        local operations = MemoryCore.commands.operations

        lu.assertNotIsNil(MemoryCore.arr:get(operations, 'set'))
    end)
    :register()
-- end of TestUpdateSettingCommand
