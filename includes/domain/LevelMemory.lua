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
    -- allows this class to be instantiated
    MemoryCore:addChildClass('Memory/LevelMemory', LevelMemory, 'Memory/AbstractMemory')

    --[[
    LevelMemory constructor.
    ]]
    function LevelMemory.__construct()
        return setmetatable({}, LevelMemory)
    end

    --[[
    Generates a message to be placed in the screenshot taken when the player
    levels up.

    @treturn string
    ]]
    function LevelMemory:getScreenshotMessage()
        local formattedDate = MemoryCore:getDateHelper():getFormattedDate(self.date)

        return string.format('Reached level %d on %s',
            self.level,
            formattedDate
        )
    end

    --[[
    Saves this level memory.
    ]]
    function LevelMemory:save()
        MemoryCore:getRepository():storeLevelMemory(self)
    end

    --[[
    @inheritDoc
    ]]
    function LevelMemory:shouldTakeScreenshot()
        return MemoryCore.bool:isTrue(MemoryCore:setting('memory.screenshotOnLevelUp', 1))
    end
-- end of LevelMemory