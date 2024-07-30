local str = MemoryCore.str

local command = MemoryCore
    :new('Command')
    :setOperation('get')
    :setDescription("Gets a configuration value")
    :setCallback(function (key)
        -- sanity check
        if str:isEmpty(key) then
            MemoryCore:print('Please, provide a setting key to get its value');
            return
        end

        -- gets the setting
        local value = MemoryCore:setting(key);

        if nil ~= value then
            MemoryCore:print(key .. '=' .. value);
            return
        end

        MemoryCore:print('No setting with key = ' .. key .. ' was found');
    end)

MemoryCore.commands:add(command)