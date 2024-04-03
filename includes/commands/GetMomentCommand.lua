local __ = MemoryCore.__

local command = __
    :new('Command')
    :setOperation('getm')
    :setDescription("Gets the current moment in the player's memory")
    :setCallback(function ()
        MemoryCore:print(MemoryCore:getMomentRepository():getCurrentMoment())
    end)

__.commands:add(command)