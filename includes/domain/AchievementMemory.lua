--[[
The AchievementMemory class represents a memory that's captured when the player
gets an achievement.
]]
local AchievementMemory = {}
    AchievementMemory.__index = AchievementMemory
    -- allows this class to be instantiated
    MemoryCore:addChildClass('Memory/AchievementMemory', AchievementMemory, 'Memory/AbstractMemory')

    --[[
    AchievementMemory constructor.
    ]]
    function AchievementMemory.__construct()
        return setmetatable({}, AchievementMemory)
    end
-- End of AchievementMemory