-- @TODO: Move this test class to the new TestCase structure <2024.07.30>

TestUpdateSettingCommand = BaseTestClass:new()
    -- @covers includes/commands/UpdateSettingCommand.lua
    function TestUpdateSettingCommand:testCommandCallback()
        local keyArg, messageArg, overrideArg, valueArg

        -- mocks
        function MemoryCore:setting(key, value, override)
            keyArg = key
            valueArg = value
            overrideArg = override
        end
        function MemoryCore:print(message) messageArg = message end

        MemoryCore.commands.operations.set.callback('test-key', 'test-value')

        lu.assertEquals(keyArg, 'test-key')
        lu.assertEquals(valueArg, 'test-value')
        lu.assertEquals(overrideArg, true)
        lu.assertEquals(messageArg, 'test-key set to test-value')
    end

    -- @covers includes/commands/UpdateSettingCommand.lua
    function TestUpdateSettingCommand:testCommandCallbackWithEmptyValues()
        local function execution(key, value)
            local messageArg
            
            function MemoryCore:print(message) messageArg = message end

            MemoryCore.commands.operations.set.callback(key, value)

            lu.assertEquals('Please, provide a key and a value to be set', messageArg)
        end

        execution(nil, 'test-value')
        execution('test-key', nil)
    end

    -- @covers includes/commands/UpdateSettingCommand.lua
    function TestUpdateSettingCommand:testCommandWasAdded()
        local operations = MemoryCore.commands.operations

        lu.assertNotIsNil(MemoryCore.arr:get(operations, 'set'))
    end
-- end of TestUpdateSettingCommand