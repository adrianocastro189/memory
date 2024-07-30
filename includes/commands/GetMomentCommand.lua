local command = MemoryCore
    :new('Command')
    :setOperation('getm')
    :setDescription("Gets the current moment in the player's memory")
    :setCallback(function ()
        MemoryCore:print(MemoryCore:getMomentRepository():getCurrentMoment())
    end)
    :setArgsValidator(function ()
        return MemoryCore:getMomentRepository():hasCurrentMoment()
            and 'valid'
            or 'There\'s no moment in the player\'s memory yet. Add one by typing /memoryaddon addm "Your moment here"'
    end)

MemoryCore.commands:add(command)