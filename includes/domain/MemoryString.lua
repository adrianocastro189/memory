--[[
Adds the memory string prototype and creation method to repository.

@since 0.6.0-beta

@param MemoryAddon_MemoryRepository repository the memory repository instance
]]
function MemoryAddon_addMemoryStringPrototype( repository )

  --[[
  The memory string prototype.

  @since 0.6.0-beta
  ]]
  local MemoryAddon_MemoryString = {};
  MemoryAddon_MemoryString.__index = MemoryAddon_MemoryString;

  --[[
  Builds a new instance of a memory string.

  @since 0.6.0-beta

  @param string memoryString will parse the memory string instead of building a new one (optional)
  @return MemoryAddon_MemoryString
  ]]
  function MemoryAddon_MemoryString:new( --[[optional]] memoryString )

    local instance = {};

    setmetatable( instance, MemoryAddon_MemoryString );

    -- default separator between data values in a memory string
    instance.DATA_SEPARATOR = '|';

    -- default value to be used if any information in the memory string is missing
    -- @TODO: Move this to a more broad scope, like a global constant <2024.06.14>
    instance.DATA_DEFAULT_CHAR = '-';

    -- the date when the memory string was collected
    instance.date = instance.DATA_DEFAULT_CHAR;

    -- the moment player was passing through when the memory string was collected
    instance.moment = instance.DATA_DEFAULT_CHAR;

    -- the player's level when the memory string was collected
    instance.playerLevel = instance.DATA_DEFAULT_CHAR;

    -- the subzone where the memory string was collected
    instance.subZone = instance.DATA_DEFAULT_CHAR;

    -- the zone where the memory string was collected
    instance.zone = instance.DATA_DEFAULT_CHAR;


    --[[
    Crafts a memory string used to store important data to a player memory.

    @since 0.6.0-beta

    @return self MemoryAddon_MemoryString
    ]]
    function instance:build()

      -- gets the memory string data values
      local date        = MemoryCore:getDateHelper():getToday();
      local moment      = MemoryCore:getMomentRepository():getCurrentMomentIndex();
      local playerLevel = UnitLevel( 'player' );
      local zone        = GetZoneText();
      local subZone     = GetSubZoneText();

      -- replaces nil values with a slash
      if date        == nil                      then date        = self.DATA_DEFAULT_CHAR; end
      if moment      == nil                      then moment      = self.DATA_DEFAULT_CHAR; end
      if playerLevel == nil or playerLevel == 0  then playerLevel = self.DATA_DEFAULT_CHAR; end
      if zone        == nil or zone        == '' then zone        = self.DATA_DEFAULT_CHAR; end
      if subZone     == nil or subZone     == '' then subZone     = self.DATA_DEFAULT_CHAR; end

      return self
        :setDate( date )
        :setMoment( moment )
        :setPlayerLevel( playerLevel )
        :setZone( zone )
        :setSubZone( subZone );
    end


    --[[
    Gets the date when the memory string was collected.

    @since 0.6.0-beta

    @return string
    ]]
    function instance:getDate()

      return self.date;
    end


    --[[
    Gets the moment when the memory string was collected.

    @since 1.1.0

    @param string context will determine the returned moment of this method (index or description)
    @return string
    ]]
    function instance:getMoment( context )

      if 'view' == context and self:hasMoment() then

        return MemoryCore:getMomentRepository():getMoment( tonumber( self.moment ) );
      end

      return self.moment;
    end


    --[[
    Gets the player's level when the memory string was collected.

    @since 0.6.0-beta

    @return string
    ]]
    function instance:getPlayerLevel()

      return self.playerLevel;
    end


    --[[
    Gets the subzone where the memory string was collected.

    @since 0.6.0-beta

    @return string
    ]]
    function instance:getSubZone()

      return self.subZone;
    end


    --[[
    Gets the zone where the memory string was collected.

    @since 0.6.0-beta

    @return string
    ]]
    function instance:getZone()

      return self.zone;
    end


    --[[
    Determines whether this memory string has a date or not.

    @since 0.6.0-beta

    @return bool
    ]]
    function instance:hasDate()

      return nil ~= self.date and '-1' ~= self.date;
    end


    --[[
    Determines whether this memory string has a level or not.

    @since 1.1.1

    @return bool
    ]]
    function instance:hasLevel()

      return nil ~= self.playerLevel and self.DATA_DEFAULT_CHAR ~= self.playerLevel;
    end


    --[[
    Determines whether this memory string has a moment or not.

    @since 1.1.0

    @return bool
    ]]
    function instance:hasMoment()

      return nil ~= self.moment and ( tonumber( self.moment ) or 0 ) > 0;
    end


    --[[
    Determines whether this memory string has a subzone or not.

    @since 1.1.1

    @return bool
    ]]
    function instance:hasSubZone()

      return nil ~= self.subZone and self.DATA_DEFAULT_CHAR ~= self.subZone;
    end


    --[[
    Determines whether this memory string has a zone or not.

    @since 1.1.1

    @return bool
    ]]
    function instance:hasZone()

      return nil ~= self.zone and self.DATA_DEFAULT_CHAR ~= self.zone;
    end


    --[[
    Gets a location string based on the zone and the subzone this memory string
    was recorded on.

    @since 1.1.1

    @return string
    ]]
    function instance:getLocation()

      local hasZone    = self:hasZone();
      local hasSubZone = self:hasSubZone() and self:getZone() ~= self:getSubZone();

      -- has zone and subzone and they're different
      if hasZone and hasSubZone then return self:getSubZone() .. ', ' .. self:getZone(); end

      -- has only zone
      if hasZone then return self:getZone(); end

      -- has only subzone
      if hasSubZone then return self:getSubZone(); end

      -- has no zone and no subzone
      return '';
    end


    --[[
    Parses a memory string to populate this instance properties.

    @since 0.6.0-beta

    @param string memoryString
    @return self MemoryAddon_MemoryString
    ]]
    function instance:parse( memoryString )

      -- explodes the memory string
      local date, playerLevel, zone, subZone, moment = strsplit( self.DATA_SEPARATOR, memoryString );

      -- compatibility with older versions of the addon when moment wasn't a thing
      if moment == nil then moment = self.DATA_DEFAULT_CHAR; end

      return self
        :setDate( date )
        :setMoment( moment )
        :setPlayerLevel( playerLevel )
        :setZone( zone )
        :setSubZone( subZone );
    end


    --[[
    Sets the date when the memory string was collected.

    @since 0.6.0-beta

    @param string date
    @return self MemoryAddon_MemoryString
    ]]
    function instance:setDate( date )

      self.date = date;

      return self;
    end


    --[[
    Sets the moment when the memory string was collected.

    @since 1.1.0

    @param string moment
    @return self MemoryAddon_MemoryString
    ]]
    function instance:setMoment( moment )

      self.moment = moment;

      return self;
    end


    --[[
    Sets the player's level when the memory string was collected.

    @since 0.6.0-beta

    @param string playerLevel
    @return self MemoryAddon_MemoryString
    ]]
    function instance:setPlayerLevel( playerLevel )

      self.playerLevel = playerLevel;

      return self;
    end


    --[[
    Sets the subzone where the memory string was collected.

    @since 0.6.0-beta

    @param string subZone
    @return self MemoryAddon_MemoryString
    ]]
    function instance:setSubZone( subZone )

      self.subZone = subZone;

      return self;
    end


    --[[
    Sets the zone where the memory string was collected.

    @since 0.6.0-beta

    @param string zone
    @return self MemoryAddon_MemoryString
    ]]
    function instance:setZone( zone )

      self.zone = zone;

      return self;
    end


    --[[
    Gets a string representation of the memory string.

    @since 0.6.0-beta

    @return string
    ]]
    function instance:toString()

      return self:getDate() ..
        '|' .. self:getPlayerLevel() ..
        '|' .. self:getZone() ..
        '|' .. self:getSubZone() ..
        '|' .. self:getMoment();
    end


    -- builds or parses a memory string
    if nil ~= memoryString then instance:parse( memoryString ); else instance:build(); end

    return instance;
  end


  --[[
  Builds a new instance of a memory string from repository.

  @since 0.6.0-beta

  @param string memoryString will parse the memory string instead of building a new one (optional)
  @return MemoryAddon_MemoryString
  ]]
  function repository:newMemoryString( --[[optional]] memoryString )

    return MemoryAddon_MemoryString:new( memoryString );
  end


  -- prevents this method to be called again
  MemoryAddon_addMemoryStringPrototype = nil;
end
