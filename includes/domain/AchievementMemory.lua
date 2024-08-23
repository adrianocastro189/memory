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

    --[[
    @inheritDoc
    ]]
    function AchievementMemory:getScreenshotMessage()
        local formattedDate = MemoryCore:getDateHelper():getFormattedDate(self.date)

        return string.format('Achievement earned on %s', formattedDate)
    end

    --[[
    @inheritDoc
    ]]
    function AchievementMemory:save() end

    --[[
    @inheritDoc
    ]]
    function AchievementMemory:shouldTakeScreenshot()
        return MemoryCore.bool:isTrue(MemoryCore:setting('memory.screenshotOnAchievement', 1))
    end
-- End of AchievementMemory