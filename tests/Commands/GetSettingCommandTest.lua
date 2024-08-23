TestGetSettingCommand = BaseTestClass:new()

-- @covers includes/commands/GetSettingCommand.lua
TestCase.new()
    :setName('command callback')
    :setTestClass(TestGetSettingCommand)
    :setExecution(function(data)
        MemoryCore = Spy
            .new(MemoryCore)
            :mockMethod('setting', function() return data.settingValue end)
            :mockMethod('print')

        MemoryCore.commands.operations.get.callback(data.key)

        MemoryCore
            :getMethod('print')
            :assertCalledOnceWith(data.expectedMessage)
    end)
    :setScenarios({
        ['no key provided'] = {
            key = nil,
            settingValue = nil,
            expectedMessage = 'Please, provide a setting key to get its value'
        },
        ['key provided'] = {
            key = 'test-key',
            settingValue = 'test-value',
            expectedMessage = 'test-key=test-value'
        },
        ['no setting found'] = {
            key = 'test-key',
            settingValue = nil,
            expectedMessage = 'No setting with key = test-key was found'
        },
    })
    :register()

-- @covers includes/commands/GetSettingCommand.lua
TestCase.new()
    :setName('command was added')
    :setTestClass(TestGetSettingCommand)
    :setExecution(function()
        local operations = MemoryCore.commands.operations

        lu.assertNotIsNil(MemoryCore.arr:get(operations, 'get'))
    end)
    :register()
-- end of TestGetSettingCommand
