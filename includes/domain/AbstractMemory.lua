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

-- End of AbstractMemory
