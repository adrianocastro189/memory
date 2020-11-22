--[[
The repository prototype.

Provides all read and write methods to manipulate the player memory.

@since 0.2.0-alpha
]]
MemoryRepository = {};
MemoryRepository.__index = MemoryRepository;

--[[
Constructs a new instance of a memory repository.

@since 0.2.0-alpha

@param string realm
@param string player
@return MemoryRepository
]]
function MemoryRepository:new( player, realm )

  local instance = {};
  setmetatable( instance, MemoryRepository );
  instance.player = player;
  instance.realm = realm;


  --[[
  Checks if a full memory path is set.

  A full memory path is where all the player memories about a thing are stored.

  If this is the first time of a player in a realm, the full memory path will be
  created with the interaction type.

  @since 0.2.0-alpha

  @param string category
  @param string[] path
  @param string interactionType
  ]]
  function instance:check( category, path, interactionType )

    -- creates a pointer to the current path in the memory array
    local memoryDataSetAux = MemoryDataSet[ self.realm ][ self.player ][ category ];

    for i = 1, #path, 1 do

      if memoryDataSetAux[ path[ i ] ] == nil then

        -- initializes the current path
        memoryDataSetAux[ path[ i ] ] = {};
      end

      -- sets the current path index in the pointer
      memoryDataSetAux = memoryDataSetAux[ path[ i ] ];
    end

    if memoryDataSetAux[ interactionType ] == nil then

      -- initializes the memory interaction type
      memoryDataSetAux[ interactionType ] = {};

      -- initializes the first time player experienced this memory
      memoryDataSetAux[ interactionType ]["first"] = -1;

      -- initializes the last time player experienced this memory
      memoryDataSetAux[ interactionType ]["last"] = -1;

      -- initializes the number of times player experienced this memory
      memoryDataSetAux[ interactionType ]["x"] = 0;
    end

    -- returns the current pointer to ease on the store method
    return memoryDataSetAux[ interactionType ];
  end


  --[[
  Checks if the player memories are already initialized.

  If this is the first time of a player in a realm, it will be created as an
  empty array along with the player's memories about npcs, players, zones, etc.

  @since 0.2.0-alpha
  ]]
  function instance:checkMyself()

    self:checkRealm();

    if MemoryDataSet[ self.realm ][ self.player ] == nil then

      -- initializes the player memory
      MemoryDataSet[ self.realm ][ self.player ] = {};

      -- initializes the miscellaneous memories, mainly for admin purposes
      MemoryDataSet[ self.realm ][ self.player ]["misc"] = {};

      -- initializes the player memories about npcs
      MemoryDataSet[ self.realm ][ self.player ]["npcs"] = {};

      -- initializes the player memories about other players
      MemoryDataSet[ self.realm ][ self.player ]["players"] = {};

      -- initializes the player memories about zones
      MemoryDataSet[ self.realm ][ self.player ]["zones"] = {};

      -- initializes the player memories about items
      MemoryDataSet[ self.realm ][ self.player ]["items"] = {};
    end
  end


  --[[
  Checks if the current realm is already initialized in memory.

  If this is the first time of a player in a realm, it will be created as an
  empty array.

  @since 0.2.0-alpha
  ]]
  function instance:checkRealm()

    if MemoryDataSet[ self.realm ] == nil then

      MemoryDataSet[ self.realm ] = {}
    end
  end


  --[[
  Crafts a memory string used to store important data to a player memory.

  @since 0.2.0-alpha

  @return string
  ]]
  function instance:craftMemoryString()

    -- gets the memory string data values
    local currentDate = date( "%y-%m-%d" );
    local playerLevel = UnitLevel( "player" );
    local zoneName    = GetZoneText();
    local subZoneName = GetSubZoneText();

    -- replaces nil values with a slash
    if currentDate == nil then currentDate = '-' end
    if playerLevel == nil or playerLevel == 0  then playerLevel = '-' end
    if zoneName    == nil or zoneName    == "" then zoneName    = '-' end
    if subZoneName == nil or subZoneName == "" then subZoneName = '-' end

    -- crafts and returns the memory string
    return currentDate .. "|" .. playerLevel .. "|" .. zoneName .. "|" .. subZoneName;
  end


  --[[
  Gets a player's memory.

  @since 0.5.0-beta

  @param string category
  @param string[] path
  @param string interactionType
  ]]
  function instance:get( category, path, interactionType )

    -- creates the memory instance
    local memoryInstance = self
      :newMemory()
      :setCategory( category )
      :setPath( path )
      :setInteractionType( interactionType );

    return memoryInstance;
  end


  --[[
  Stores a player's memory.

  @since 0.2.0-alpha

  @param string category
  @param string[] path
  @param string interactionType
  @param int x (optional)
  ]]
  function instance:store( category, path, interactionType, --[[optional]] x )

    -- sets the default value for x if not defined
    x = x or 1;

    -- makes sure the full memory path is already set
    local memoryPath = self:check( category, path, interactionType );

    -- gets the memory string to store the player's memory
    local memoryString = self:craftMemoryString();

    -- stores the first time player experienced this memory
    if memoryPath["first"] == -1 then memoryPath["first"] = memoryString; end

    -- stores the last time player experienced this memory
    memoryPath["last"] = memoryString;

    -- increases the number of times player experienced this memory
    memoryPath["x"] = memoryPath["x"] + x;

    -- just a debug message to... help us debug!
    MemoryCore:debug( '|TInterface\\MoneyFrame\\UI-GoldIcon:0|t ' .. interactionType .. ' memory stored for ' .. category, true );
  end


  --[[
  Overload to instance:store that accepts a MemoryAddon_Memory instance.

  Note: although a memory instance has first, last and x properties, this method will
        make use of category, path, interactionType and x only due to how store works.
        That being said, you may want to change x to 1 or any other number in order to
        avoid multiplying the current x if it's loaded by MemoryRepository:get().

  @since 0.5.0-beta

  @param MemoryAddon_Memory memory
  ]]
  function instance:storeMemory( memory )

    -- sanity check
    if memory == nil or not memory:isValid() then

      MemoryCore:debug( 'Attempt to save an invalid memory' );

      return;
    end

    -- stores the memory
    self:store( memory:getCategory(), memory:getPath(), memory:getInteractionType(), memory:getX() );
  end


  --[[
  Determines whether the memory data set is set.

  @since 0.2.0-alpha

  @return bool
  ]]
  function instance:testConnection()

    return MemoryDataSet ~= nil;
  end

  -- may initialize the player's memories
  instance:checkMyself();

  -- destroys the prototype, so instance will be unique
  MemoryRepository = nil;

  return instance;
end
