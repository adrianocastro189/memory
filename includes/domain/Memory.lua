--[[
Adds the memory prototype and creation method to repository.

@since 0.5.0-beta

@param MemoryAddon_MemoryRepository repository the memory repository instance
]]
function MemoryAddon_addMemoryPrototype( repository )

  --[[
  The memory prototype.

  @since 0.5.0-beta
  ]]
  local MemoryAddon_Memory = {};
  MemoryAddon_Memory.__index = MemoryAddon_Memory;

  --[[
  Builds a new instance of a memory.

  @since 0.5.0-beta

  @return MemoryAddon_Memory
  ]]
  function MemoryAddon_Memory:new()

    local instance = {};

    setmetatable( instance, MemoryAddon_Memory );

    -- placeholder for some getters when properties are null
    instance.DATA_PLACEHOLDER = 'undefined';

    instance.category        = '';
    instance.first           = -1;
    instance.interactionType = '';
    instance.last            = -1;
    instance.path            = {};
    instance.x               =  0;


    --[[
    Gets the memory category.

    @since 0.5.0-beta

    @return string the memory category
    ]]
    function instance:getCategory()

      return self.category;
    end


    --[[
    Gets how many days have passed since the first occurrence of this memory.

    @since 0.6.0-beta

    @return int -1 if this memory has no first defined
    ]]
    function instance:getDaysSinceFirstDay()

      if not self:hasFirst() then

        return -1;
      end

      return MemoryCore:getDateHelper():getDaysDiff( self:getFirst():getDate(), MemoryCore:getDateHelper():getToday() );
    end


    --[[
    Gets how many days have passed since the last occurrence of this memory.

    @since 0.6.0-beta

    @return int -1 if this memory has no last defined
    ]]
    function instance:getDaysSinceLastDay()

      if not self:hasLast() then

        return -1;
      end

      return MemoryCore:getDateHelper():getDaysDiff( self:getLast():getDate(), MemoryCore:getDateHelper():getToday() );
    end


    --[[
    Gets the first time player had this memory.

    @since 0.5.0-beta

    @return MemoryAddon_MemoryString
    ]]
    function instance:getFirst()

      return self.first;
    end


    --[[
    Gets a formatted date for the first time this memory was experienced.

    This methods gets information from the memory string.

    @since 0.6.0-beta

    @return string
    ]]
    function instance:getFirstFormattedDate()

      if ( not self:hasFirst() ) or ( not self:getFirst():hasDate() ) then

        return self.DATA_PLACEHOLDER;
      end

      return MemoryCore:getDateHelper():getFormattedDate( self:getFirst():getDate() );
    end


    --[[
    Gets the level the player was when collected the first memory.

    @since 1.1.1

    @return string
    ]]
    function instance:getFirstPlayerLevel()

      if ( not self:hasFirst() ) or ( not self:getFirst():hasLevel() ) then

        return '';
      end

      return self:getFirst():getPlayerLevel();
    end


    --[[
    Gets the memory interaction type.

    @since 0.5.0-beta

    @return string the memory interaction type.
    ]]
    function instance:getInteractionType()

      return self.interactionType;
    end


    --[[
    Gets the last time player had this memory.

    @since 0.5.0-beta

    @return MemoryAddon_MemoryString
    ]]
    function instance:getLast()

      return self.last;
    end


    --[[
    Gets a formatted date for the last time this memory was experienced.

    This methods gets information from the memory string.

    @since 0.6.0-beta

    @return string
    ]]
    function instance:getLastFormattedDate()

      if not self:hasLast() then

        return self.DATA_PLACEHOLDER;
      end

      return MemoryCore:getDateHelper():getFormattedDate( self:getLast():getDate() );
    end


    --[[
    Gets the level the player was when collected the last memory.

    @since 1.1.1

    @return string
    ]]
    function instance:getLastPlayerLevel()

      if ( not self:hasLast() ) or ( not self:getLast():hasLevel() ) then

        return '';
      end

      return self:getLast():getPlayerLevel();
    end


    --[[
    Gets the memory path.

    @since 0.5.0-beta

    @return string[] the memory path
    ]]
    function instance:getPath()

      return self.path;
    end


    --[[
    Gets the number of times player had this memory.

    @since 0.5.0-beta

    @return int
    ]]
    function instance:getX()

      return self.x;
    end


    --[[
    Determines whether the memory has a category.

    @since 0.5.0-beta

    @return bool
    ]]
    function instance:hasCategory()

      return self:getCategory() ~= nil and self:getCategory() ~= '';
    end


    --[[
    Determines whether the player had already experienced this memory before.

    @since 0.5.0-beta

    @return bool
    ]]
    function instance:hasFirst()

      return nil ~= self.first and -1 ~= self:getFirst() and self:getFirst():hasDate();
    end


    --[[
    Determines whether the first memory has a moment.

    @since 1.0.0

    @return bool
    ]]
    function instance:hasFirstMoment()

      return self:hasFirst() and self:getFirst():hasMoment();
    end


    --[[
    Determines whether the memory has an interaction type.

    @since 0.5.0-beta

    @return bool
    ]]
    function instance:hasInteractionType()

      return self:getInteractionType() ~= nil and self:getInteractionType() ~= '';
    end


    --[[
    Determines whether the player had already experienced this memory before.

    @since 0.6.0-beta

    @return bool
    ]]
    function instance:hasLast()

      return nil ~= self.last and -1 ~= self:getLast() and self:getLast():hasDate();
    end


    --[[
    Determines whether the last memory has a moment.

    @since 1.0.0

    @return bool
    ]]
    function instance:hasLastMoment()

      return self:hasLast() and self:getLast():hasMoment();
    end


    --[[
    Determines whether the memory has a path

    @since 0.5.0-beta

    @return bool
    ]]
    function instance:hasPath()

      return self:getPath() ~= nil and #self:getPath() > 0;
    end


    --[[
    Determines whether the memory is a valid memory based on its primary properties.

    @since 0.5.0-beta

    @return bool
    ]]
    function instance:isValid()

      return self:hasCategory() and self:hasInteractionType() and self:hasPath();
    end


    --[[
    May print the memory in the chat frame based on a random chance.

    @since 0.5.0-beta

    @param textFormatter MemoryAddon_MemorTextFormatter
    ]]
    function instance:maybePrint( textFormatter )

      if math.random() <= tonumber( MemoryCore:setting( 'memory.printChance', '0.2' ) ) then

        self:print( textFormatter );
      end
    end


    --[[
    May take a screenshot to store a visual memory.

    @since 1.2.0

    @param textFormatter MemoryAddon_MemorTextFormatter
    ]]
    function instance:maybeTakeScreenshot( textFormatter )

      if math.random() <= tonumber( MemoryCore:setting( 'memory.screenshotChance', '-1' ) ) then

        self:takeScreenshot( textFormatter );
      end
    end


    --[[
    Prints the memory in the chat frame.

    @since 0.5.0-beta

    @param textFormatter MemoryAddon_MemorTextFormatter
    ]]
    function instance:print( textFormatter )

      -- TODO: improve the way x = 1 is passed as a parameter {AC 2020-12-05}
      local sentence = textFormatter:getRandomChatMessage( self, 1 );

      MemoryCore:print( sentence );
    end


    --[[
    Takes a screenshot to store a visual memory.

    @since 1.2.0

    @param textFormatter MemoryAddon_MemorTextFormatter
    ]]
    function instance:takeScreenshot( textFormatter )

      -- TODO: improve the way x = 1 is passed as a parameter {AC 2021-06-12}
      local sentence = textFormatter:getPresentCount( self, 1, true );

      -- sanity check
      if nil == sentence then return; end

      -- @TODO: Move these two calls to a single and reused method <2024.06.14>
      MemoryCore:getScreenshotController():prepareScreenshot( sentence );
      MemoryCore:getCompatibilityHelper():wait( 2, MemoryCore.screenshotController.takeScreenshot );
    end


    --[[
    Saves this memory in the repository.

    @see MemoryAddon_MemoryRepository:storeMemory()

    @since 0.5.0-beta
    ]]
    function instance:save()

      MemoryCore:getRepository():storeMemory( self );
    end


    --[[
    Sets the memory category.

    @since 0.5.0-beta

    @param string memory category
    @return self MemoryAddon_Memory
    ]]
    function instance:setCategory( category )

      self.category = category or '';

      return self;
    end


    --[[
    Sets the first time player had this memory.

    @since 0.5.0-beta

    @param MemoryAddon_MemoryString a memory string instance
    @return self MemoryAddon_Memory
    ]]
    function instance:setFirst( first )

      self.first = first or -1;

      return self;
    end


    --[[
    Sets the memory interaction type.

    @since 0.5.0-beta

    @param string memory interaction type
    @return self MemoryAddon_Memory
    ]]
    function instance:setInteractionType( interactionType )

      self.interactionType = interactionType or '';

      return self;
    end


    --[[
    Sets the last time player had this memory.

    @since 0.5.0-beta

    @param MemoryAddon_MemoryString a memory string instance
    @return self MemoryAddon_Memory
    ]]
    function instance:setLast( last )

      self.last = last or -1;

      return self;
    end


    --[[
    Sets the memory path.

    @since 0.5.0-beta

    @param string[] memory path
    @return self MemoryAddon_Memory
    ]]
    function instance:setPath( path )

      self.path = path or {};

      return self;
    end


    --[[
    Sets the number of times player had this memory.

    @since 0.5.0-beta

    @param int x
    @return self MemoryAddon_Memory
    ]]
    function instance:setX( x )

      self.x = x or 0;

      return self;
    end


    return instance;
  end

  --[[
  Builds a new instance of a memory from repository.

  @since 0.5.0-beta

  @return MemoryAddon_Memory
  ]]
  function repository:newMemory()

    return MemoryAddon_Memory:new();
  end


  -- prevents this method to be called again
  MemoryAddon_addMemoryPrototype = nil;
end
