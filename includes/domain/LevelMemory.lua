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

    --[[
    Generates a message to be placed in the screenshot taken when the player
    levels up.

    @treturn string
    ]]
    function LevelMemory:getScreenshotMessage()
    -- @TODO: Implement this method in HN5 <2024.06.14>
    end

    --[[
    May take a screenshot to store a visual memory of the moment when the player
    leveled up.
    ]]
    function LevelMemory:maybeTakeScreenshot()
    -- @TODO: Implement this method in HN5 <2024.06.14>
    end

    --[[
    Sets the date when the player leveled up.

    @tparam string value

    @return self
    ]]
    function LevelMemory:setDate(value)
        self.date = value
        return self
    end

    --[[
    Sets the level.

    @tparam int value

    @return self
    ]]
    function LevelMemory:setLevel(value)
        self.level = value
        return self
    end

    --[[
    Sets the current moment index when the player leveled up.

    @tparam int value

    @return self
    ]]
    function LevelMemory:setMoment(value)
        self.moment = value
        return self
    end

    --[[
    Sets the sub zone where the player leveled up.

    @tparam string value

    @return self
    ]]
    function LevelMemory:setSubZone(value)
        self.subZone = value
        return self
    end

    --[[
    Sets the zone where the player leveled up.

    @tparam string value

    @return self
    ]]
    function LevelMemory:setZone(value)
        self.zone = value
        return self
    end

    --[[
    Takes a screenshot to represent the moment when the player leveled up.
    ]]
    function LevelMemory:takeScreenshot()
    -- @TODO: Implement this method in HN5 <2024.06.14>
    end
-- end of LevelMemory

-- allows this class to be instantiated
MemoryCore.__:addClass('Memory/LevelMemory', LevelMemory)