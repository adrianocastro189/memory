--[[
The abstract memory class contains generic methods that are shared by all memory
types.

This class was designed in version 1.6.0 to serve as a base class for a bigger
refactoring of the addon.
]]
local AbstractMemory = {}
    AbstractMemory.__index = AbstractMemory
    -- allows this class to be extended
    MemoryCore:addAbstractClass('Memory/AbstractMemory', AbstractMemory)

    --[[
    Gets a message to be printed on the screen when the user takes a screenshot.

    @return string
    ]]
    function AbstractMemory:getScreenshotMessage()
        error('This is an abstract method and should be implemented by this class inheritances')
    end

    --[[
    Saves the memory data.
    ]]
    function AbstractMemory:save()
        error('This is an abstract method and should be implemented by this class inheritances')
    end

    --[[
    Determines whether this memory should trigger a screenshot.

    @return boolean
    ]]
    function AbstractMemory:shouldTakeScreenshot()
        error('This is an abstract method and should be implemented by this class inheritances')
    end
-- End of AbstractMemory
