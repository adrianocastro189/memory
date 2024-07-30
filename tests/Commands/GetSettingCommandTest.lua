---@diagnostic disable: unused-function, duplicate-set-field

TestGetSettingCommand = BaseTestClass:new()
    -- @covers includes/commands/GetSettingCommand.lua
    function TestGetSettingCommand:testCommandCallback()
        local function execution(key, settingValue, expectedMessage)
            local messagePrinted = nil

            -- mocks
            function MemoryCore:setting() return settingValue end
            function MemoryCore:print(message) messagePrinted = message end

            MemoryCore.commands.operations.get.callback(key)

            lu.assertEquals(expectedMessage, messagePrinted)
        end

        execution(nil, nil, 'Please, provide a setting key to get its value')
        execution('test-key', 'test-value', 'test-key=test-value')
        execution('test-key', nil, 'No setting with key = test-key was found')
    end

    -- @covers includes/commands/GetSettingCommand.lua
    function TestGetSettingCommand:testCommandWasAdded()
        local operations = MemoryCore.commands.operations

        lu.assertNotIsNil(MemoryCore.arr:get(operations, 'get'))
    end
-- end of TestGetSettingCommand