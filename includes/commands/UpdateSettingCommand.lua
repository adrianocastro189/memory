local __ = MemoryCore.__
local str = __.str

local command = __
    :new('Command')
    :setOperation('set')
    :setDescription("Updates a configuration value")
    :setCallback(function (key, value)
        -- sanity check
        if str:isEmpty(key) or str:isEmpty(value) then
            MemoryCore:print('Please, provide a key and a value to be set');
            return
        end

        -- sets the setting value
        MemoryCore:setting(key, value, true);

        -- confirmation to user
        MemoryCore:print(key .. ' set to ' .. value);
    end)

__.commands:add(command)