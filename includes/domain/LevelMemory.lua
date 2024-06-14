--[[
The LevelMemory class represents a memory that's captured when the player
levels up.

It's a bit different from the regular memory so it was decided to have its
specific prototype.

@NOTE: This class was introduced after Memory started to use Stormwind
Library, which means it's using the class system it provides. That explains why
it's registered in a different way than the other classes.
]]
local LevelMemory = {}
    LevelMemory.__index = LevelMemory

    --[[
    LevelMemory constructor.
    ]]
    function LevelMemory.__construct()
        return setmetatable({}, LevelMemory)
    end
-- end of LevelMemory

-- allows this class to be instantiated
MemoryCore.__:addClass('Memory/LevelMemory', LevelMemory)