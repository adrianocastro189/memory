local MemoryString = {}
MemoryString.__index = MemoryString

    --[[
    MemoryString constructor.
    ]]
    function MemoryString.__construct(memoryString)
        local instance = setmetatable({}, MemoryString)

        -- default separator between data values in a memory string
        instance.DATA_SEPARATOR = '|'

        -- default value to be used if any information in the memory string is missing
        -- @TODO: Move this to a more broad scope, like a global constant <2024.06.14>
        instance.DATA_DEFAULT_CHAR = '-'

        -- the date when the memory string was collected
        instance.date = instance.DATA_DEFAULT_CHAR

        -- the moment player was passing through when the memory string was collected
        instance.moment = instance.DATA_DEFAULT_CHAR

        -- the player's level when the memory string was collected
        instance.playerLevel = instance.DATA_DEFAULT_CHAR

        -- the subzone where the memory string was collected
        instance.subZone = instance.DATA_DEFAULT_CHAR

        -- the zone where the memory string was collected
        instance.zone = instance.DATA_DEFAULT_CHAR

        -- builds or parses a memory string
        if nil ~= memoryString then instance:parse(memoryString) else instance:build() end

        return instance
    end

    --[[
    Crafts a memory string used to store important data to a player memory.

    @return self
    ]]
    function MemoryString:build()
        -- gets the memory string data values
        local date = MemoryCore:getDateHelper():getToday()
        local moment = MemoryCore:getMomentRepository():getCurrentMomentIndex()
        local playerLevel = UnitLevel('player')
        local zone = GetZoneText()
        local subZone = GetSubZoneText()

        -- replaces nil values with a slash
        if date == nil then date = self.DATA_DEFAULT_CHAR end
        if moment == nil then moment = self.DATA_DEFAULT_CHAR end
        if playerLevel == nil or playerLevel == 0 then playerLevel = self.DATA_DEFAULT_CHAR end
        if zone == nil or zone == '' then zone = self.DATA_DEFAULT_CHAR end
        if subZone == nil or subZone == '' then subZone = self.DATA_DEFAULT_CHAR end

        return self
            :setDate(date)
            :setMoment(moment)
            :setPlayerLevel(playerLevel)
            :setZone(zone)
            :setSubZone(subZone)
    end

    --[[
    Gets the date when the memory string was collected.

    @return string
    ]]
    function MemoryString:getDate()
        return self.date
    end

    --[[
    Gets the moment when the memory string was collected.

    @param string context will determine the returned moment of this method (index or description)

    @return string
    ]]
    function MemoryString:getMoment(context)
        if 'view' == context and self:hasMoment() then
            return MemoryCore:getMomentRepository():getMoment(tonumber(self.moment))
        end

        return self.moment
    end

    --[[
    Gets the player's level when the memory string was collected.

    @return string
    ]]
    function MemoryString:getPlayerLevel()
        return self.playerLevel
    end

    --[[
    Gets the subzone where the memory string was collected.

    @return string
    ]]
    function MemoryString:getSubZone()
        return self.subZone
    end

    --[[
    Gets the zone where the memory string was collected.

    @return string
    ]]
    function MemoryString:getZone()
        return self.zone
    end

    --[[
    Determines whether this memory string has a date or not.

    @return bool
    ]]
    function MemoryString:hasDate()
        return nil ~= self.date and '-1' ~= self.date
    end

    --[[
    Determines whether this memory string has a level or not.

    @return bool
    ]]
    function MemoryString:hasLevel()
        return nil ~= self.playerLevel and self.DATA_DEFAULT_CHAR ~= self.playerLevel
    end

    --[[
    Determines whether this memory string has a moment or not.

    @return bool
    ]]
    function MemoryString:hasMoment()
        return nil ~= self.moment and (tonumber(self.moment) or 0) > 0
    end

    --[[
    Determines whether this memory string has a subzone or not.

    @return bool
    ]]
    function MemoryString:hasSubZone()
        return nil ~= self.subZone and self.DATA_DEFAULT_CHAR ~= self.subZone
    end

    --[[
    Determines whether this memory string has a zone or not.

    @return bool
    ]]
    function MemoryString:hasZone()
        return nil ~= self.zone and self.DATA_DEFAULT_CHAR ~= self.zone
    end

    --[[
    Gets a location string based on the zone and the subzone this memory string
    was recorded on.

    @return string
    ]]
    function MemoryString:getLocation()
        local hasZone = self:hasZone()
        local hasSubZone = self:hasSubZone() and self:getZone() ~= self:getSubZone()

        -- has zone and subzone and they're different
        if hasZone and hasSubZone then return self:getSubZone() .. ', ' .. self:getZone() end

        -- has only zone
        if hasZone then return self:getZone() end

        -- has only subzone
        if hasSubZone then return self:getSubZone() end

        -- has no zone and no subzone
        return ''
    end

    --[[
    Parses a memory string to populate this instance properties.

    @param string memoryString

    @return self
    ]]
    function MemoryString:parse(memoryString)
        -- explodes the memory string
        local date, playerLevel, zone, subZone, moment = MemoryCore.arr:unpack(MemoryCore.str:split(memoryString or '', self.DATA_SEPARATOR))

        -- compatibility with older versions of the addon when moment wasn't a thing
        if moment == nil then moment = self.DATA_DEFAULT_CHAR end

        return self
            :setDate(date)
            :setMoment(moment)
            :setPlayerLevel(playerLevel)
            :setZone(zone)
            :setSubZone(subZone)
    end

    --[[
    Sets the date when the memory string was collected.

    @param string value

    @return self
    ]]
    function MemoryString:setDate(value)
        self.date = value
        return self
    end

    --[[
    Sets the moment when the memory string was collected.

    @param string value

    @return self
    ]]
    function MemoryString:setMoment(value)
        self.moment = value
        return self
    end

    --[[
    Sets the player's level when the memory string was collected.

    @param string value

    @return self
    ]]
    function MemoryString:setPlayerLevel(value)
        self.playerLevel = value
        return self
    end

    --[[
    Sets the subzone where the memory string was collected.

    @param string value

    @return self
    ]]
    function MemoryString:setSubZone(value)
        self.subZone = value
        return self
    end

    --[[
    Sets the zone where the memory string was collected.

    @param string zone

    @return self
    ]]
    function MemoryString:setZone(value)
        self.zone = value
        return self
    end

    --[[
    Gets a string representation of the memory string.

    @return string
    ]]
    function MemoryString:toString()
        return self:getDate() ..
            '|' .. self:getPlayerLevel() ..
            '|' .. self:getZone() ..
            '|' .. self:getSubZone() ..
            '|' .. self:getMoment()
    end
-- End of MemoryString

-- allows this class to be instantiated
MemoryCore:addClass('Memory/MemoryString', MemoryString)
