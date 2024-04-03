local __ = MemoryCore.__
local str = __.str

local command = __
    :new('Command')
    :setOperation('addm')
    :setDescription("Adds a new moment to the player's memory")
    :setCallback(function (moment, rest)
        -- sanity moment check
        if str:isEmpty(moment) then
            MemoryCore:print('Please, provide a moment to be added wrapped in quotation marks')
            return
        end

        -- sanity quotes check
        if str:isNotEmpty(rest) then
            -- if rest is set, it means the user didn't wrap the moment in quotation marks and the rest of the
            -- moment is handled as a separate argument
            -- although in that case there will be more than one rest argument, checking for the first one is
            -- enough to determine that the moment is not wrapped in quotation marks
            MemoryCore:print('The moment must be wrapped in quotation marks')
            return
        end

        MemoryCore:addMoment(moment)
    end)

__.commands:add(command)