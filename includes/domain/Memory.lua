--[[
Represents a memory that the player has experienced in the game.

This class was completely refactored in version 1.5.0 to use the Stormwind Library
class system. This change was made to improve the code organization and to be part
of migrating the addon to a more object-oriented approach.
]]
local Memory = {}
    Memory.__index = Memory

    -- placeholder for some getters when properties are null
    Memory.DATA_PLACEHOLDER = 'undefined'

    --[[
    Memory constructor.
    ]]
    function Memory.__construct()
        local instance = setmetatable({}, Memory)
        
        instance.category = ''
        instance.first = -1
        instance.interactionType = ''
        instance.last = -1
        instance.path = {}
        instance.x = 0

        return instance
    end

    --[[
    Gets the memory category.

    @return string the memory category
    ]]
    function Memory:getCategory()
        return self.category
    end

    --[[
    Gets how many days have passed since the first occurrence of this memory.

    @return integer -1 if this memory has no first defined
    ]]
    function Memory:getDaysSinceFirstDay()
        if not self:hasFirst() then
          return -1
        end

        return MemoryCore
            :getDateHelper()
            :getDaysDiff(self:getFirst():getDate(), MemoryCore:getDateHelper():getToday())
    end

    --[[
    Gets how many days have passed since the last occurrence of this memory.

    @return integer -1 if this memory has no last defined
    ]]
    function Memory:getDaysSinceLastDay()
        if not self:hasLast() then
            return -1
        end

        return MemoryCore
            :getDateHelper()
            :getDaysDiff(self:getLast():getDate(), MemoryCore:getDateHelper():getToday())
    end

    --[[
    Gets the first time player had this memory.

    @return MemoryAddon_MemoryString
    ]]
    function Memory:getFirst()
        return self.first
    end

    --[[
    Gets a formatted date for the first time this memory was experienced.

    This methods gets information from the memory string.

    @return string
    ]]
    function Memory:getFirstFormattedDate()
        if (not self:hasFirst()) or (not self:getFirst():hasDate()) then
            return self.DATA_PLACEHOLDER
        end

        return MemoryCore
            :getDateHelper()
            :getFormattedDate(self:getFirst():getDate())
    end

    --[[
    Gets the level the player was when collected the first memory.

    @return string
    ]]
    function Memory:getFirstPlayerLevel()
        if (not self:hasFirst()) or (not self:getFirst():hasLevel()) then
            return ''
        end

        return self
            :getFirst()
            :getPlayerLevel()
    end

    --[[
    Gets the memory interaction type.

    @return string the memory interaction type.
    ]]
    function Memory:getInteractionType()
        return self.interactionType
    end

    --[[
    Gets the last time player had this memory.

    @return MemoryAddon_MemoryString
    ]]
    function Memory:getLast()
        return self.last
    end

    --[[
    Gets a formatted date for the last time this memory was experienced.

    This methods gets information from the memory string.

    @return string
    ]]
    function Memory:getLastFormattedDate()
        if (not self:hasLast()) or (not self:getLast():hasDate()) then
            return self.DATA_PLACEHOLDER
        end

        return MemoryCore
            :getDateHelper()
            :getFormattedDate(self:getLast():getDate())
    end

    --[[
    Gets the level the player was when collected the last memory.

    @return string
    ]]
    function Memory:getLastPlayerLevel()
        if (not self:hasLast()) or (not self:getLast():hasLevel()) then
            return ''
        end

        return self
            :getLast()
            :getPlayerLevel()
    end

    --[[
    Gets the memory path.

    @return string[] the memory path
    ]]
    function Memory:getPath()
        return self.path
    end

    --[[
    Gets the number of times player had this memory.

    @return integer
    ]]
    function Memory:getX()
        return self.x
    end

    --[[
    Determines whether the memory has a category.

    @return boolean
    ]]
    function Memory:hasCategory()
        return self:getCategory() ~= nil and self:getCategory() ~= ''
    end

    --[[
    Determines whether the player had already experienced this memory before.

    @return boolean
    ]]
    function Memory:hasFirst()
        return nil ~= self.first and -1 ~= self:getFirst() and self:getFirst():hasDate()
    end

    --[[
    Determines whether the first memory has a moment.

    @return boolean
    ]]
    function Memory:hasFirstMoment()
        return self:hasFirst() and self:getFirst():hasMoment()
    end

    --[[
    Determines whether the memory has an interaction type.

    @return boolean
    ]]
    function Memory:hasInteractionType()
        return self:getInteractionType() ~= nil and self:getInteractionType() ~= ''
    end

    --[[
    Determines whether the player had already experienced this memory before.

    @return boolean
    ]]
    function Memory:hasLast()
        return nil ~= self.last and -1 ~= self:getLast() and self:getLast():hasDate()
    end

    --[[
    Determines whether the last memory has a moment.

    @return boolean
    ]]
    function Memory:hasLastMoment()
        return self:hasLast() and self:getLast():hasMoment()
    end

    --[[
    Determines whether the memory has a path

    @return boolean
    ]]
    function Memory:hasPath()
        return self:getPath() ~= nil and #self:getPath() > 0
    end

    --[[
    Determines whether the memory is a valid memory based on its primary properties.

    @return boolean
    ]]
    function Memory:isValid()
        return self:hasCategory() and self:hasInteractionType() and self:hasPath()
    end

    --[[
    May print the memory in the chat frame based on a random chance.

    @param MemoryAddon_MemorTextFormatter textFormatter
    ]]
    function Memory:maybePrint(textFormatter)
        if self:randomNumber() <= tonumber(MemoryCore:setting('memory.printChance', '0.2')) then
            self:print(textFormatter)
        end
    end

    --[[
    May take a screenshot to store a visual memory.

    @param MemoryAddon_MemorTextFormatter textFormatter
    ]]
    function Memory:maybeTakeScreenshot(textFormatter)
        if self:randomNumber() <= tonumber(MemoryCore:setting('memory.screenshotChance', '-1')) then
            self:takeScreenshot(textFormatter)
        end
    end

    --[[
    Prints the memory in the chat frame.

    @param MemoryAddon_MemorTextFormatter textFormatter
    ]]
    function Memory:print(textFormatter)
        -- TODO: improve the way x = 1 is passed as a parameter {AC 2020-12-05}
        local sentence = textFormatter:getRandomChatMessage(self, 1)

        MemoryCore:print(sentence)
    end

    --[[
    Just a random number generator encapsulation to make it easier to test.

    @return number
    ]]
    function Memory:randomNumber()
        return math.random()
    end

    --[[
    Saves this memory in the repository.

    @see MemoryAddon_MemoryRepository:storeMemory()
    ]]
    function Memory:save()
        MemoryCore:getRepository():storeMemory(self)
    end

    --[[
    Sets the memory category.

    @param string value

    @return self
    ]]
    function Memory:setCategory(value)
        self.category = value or ''
        return self
    end

    --[[
    Sets the first time player had this memory.

    @param MemoryAddon_MemoryString value

    @return self
    ]]
    function Memory:setFirst(value)
        self.first = value or -1
        return self
    end


    --[[
    Sets the memory interaction type.

    @param string value

    @return self
    ]]
    function Memory:setInteractionType(value)
        self.interactionType = value or ''
        return self
    end


    --[[
    Sets the last time player had this memory.

    @param MemoryAddon_MemoryString value

    @return self
    ]]
    function Memory:setLast(value)
        self.last = value or -1
        return self
    end


    --[[
    Sets the memory path.

    @param string[] memory path

    @return self
    ]]
    function Memory:setPath(value)
        self.path = value or {}
        return self
    end


    --[[
    Sets the number of times player had this memory.

    @param integer x

    @return self
    ]]
    function Memory:setX(value)
        self.x = value or 0
        return self
    end

    --[[
    Takes a screenshot to store a visual memory.

    @param MemoryAddon_MemorTextFormatter textFormatter
    ]]
    function Memory:takeScreenshot(textFormatter)
        -- TODO: improve the way x = 1 is passed as a parameter {AC 2021-06-12}
        local sentence = textFormatter:getPresentCount(self, 1, true)

        -- sanity check
        if nil == sentence then return end

        -- @TODO: Move these two calls to a single and reused method <2024.06.14>
        MemoryCore:getScreenshotController():prepareScreenshot(sentence)
        MemoryCore:getCompatibilityHelper():wait(2, MemoryCore:getScreenshotController().takeScreenshot)
    end

-- allows this class to be instantiated
MemoryCore:addClass('Memory/Memory', Memory)