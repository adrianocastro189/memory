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
    May take a screenshot to store a visual memory of when the player leveled up.
    ]]
    function LevelMemory:maybeTakeScreenshot()
    -- @TODO: Implement this method in HN5 <2024.06.14>
    end

    --[[
    Builds a new LevelMemory instance with the current data for storing the
    memory of when the player leveled up.

    This is a static method that should be called by getting a class reference
    from Stormwind Library and calling it as a method instead of calling it
    in any instance.

    @treturn LevelMemory
    ]]
    function LevelMemory.newWithCurrentData()
        -- @TODO: Improve this method implementation in HN3 <2024.06.14>
        return LevelMemory.__construct()
    end

    --[[
    Saves this level memory.
    ]]
    function LevelMemory:save()
    -- @TODO: Implement this method in HN4 <2024.06.14>
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
    Takes a screenshot to representing when the player leveled up.
    ]]
    function LevelMemory:takeScreenshot()
    -- @TODO: Implement this method in HN5 <2024.06.14>
    end
-- end of LevelMemory

-- allows this class to be instantiated
MemoryCore.__:addClass('Memory/LevelMemory', LevelMemory)