--[[
The repository prototype.

Provides all read and write methods to manipulate the player memory.

@since 0.2.0-alpha
]]
MemoryAddon_MemoryRepository = {};
MemoryAddon_MemoryRepository.__index = MemoryAddon_MemoryRepository;

--[[
Constructs a new instance of a memory repository.

@since 0.2.0-alpha

@param string realm
@param string player
@return MemoryAddon_MemoryRepository
]]
function MemoryAddon_MemoryRepository:new( player, realm )

  local instance = {};
  setmetatable( instance, MemoryAddon_MemoryRepository );
  instance.player = player;
  instance.realm = realm;


  --[[
  Checks if a full memory path is set.

  A full memory path is where all the player memories about a thing are stored.

  If this is the first time of a player in a realm, the full memory path will be
  created with the interaction type. Use MemoryAddon_MemoryRepository:exist if you
  intend to do a check with no collateral effects.

  @since 0.2.0-alpha

  @param string category
  @param string[] path
  @param string interactionType
  ]]
  function instance:check( category, path, interactionType )

    -- creates a pointer to the current path in the memory array
    local memoryDataSetAux = MemoryAddon_DataSet[ self.realm ][ self.player ][ category ];

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
      memoryDataSetAux[ interactionType ]['first'] = -1;

      -- initializes the last time player experienced this memory
      memoryDataSetAux[ interactionType ]['last'] = -1;

      -- initializes the number of times player experienced this memory
      memoryDataSetAux[ interactionType ]['x'] = 0;
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

    if MemoryAddon_DataSet[ self.realm ][ self.player ] == nil then

      -- initializes the player memory
      MemoryAddon_DataSet[ self.realm ][ self.player ] = {};

      -- initializes the miscellaneous memories, mainly for admin purposes
      MemoryAddon_DataSet[ self.realm ][ self.player ]['misc'] = {};

      -- initializes the player memories about npcs
      MemoryAddon_DataSet[ self.realm ][ self.player ]['npcs'] = {};

      -- initializes the player memories about other players
      MemoryAddon_DataSet[ self.realm ][ self.player ]['players'] = {};

      -- initializes the player memories about zones
      MemoryAddon_DataSet[ self.realm ][ self.player ]['zones'] = {};

      -- initializes the player memories about items
      MemoryAddon_DataSet[ self.realm ][ self.player ]['items'] = {};
    end
  end


  --[[
  Checks if the current realm is already initialized in memory.

  If this is the first time of a player in a realm, it will be created as an
  empty array.

  @since 0.2.0-alpha
  ]]
  function instance:checkRealm()

    if MemoryAddon_DataSet[ self.realm ] == nil then

      MemoryAddon_DataSet[ self.realm ] = {}
    end
  end


  --[[
  Gets a player's memory.

  This method has a collateral effect of preparing the database to a memory store
  by calling check. So, don't use it to test whether the database has a given memory.
  This get call must be used to retrieve valid memories or to save a valid memory.

  @since 0.5.0-beta

  @param string category
  @param string[] path
  @param string interactionType
  @return MemoryAddon_Memory memory
  ]]
  function instance:get( category, path, interactionType )

    -- creates the memory instance
    local memoryInstance = MemoryCore
      :new('Memory/Memory')
      :setCategory( category )
      :setPath( path )
      :setInteractionType( interactionType );

    -- may return a memory already saved or prepare the database for a new one
    local savedMemory = self:check( category, path, interactionType );

    -- populates the memory with saved or new values
    memoryInstance
      :setFirst( self:newMemoryString( savedMemory['first'] ) )
      :setLast( self:newMemoryString( savedMemory['last'] ) )
      :setX( savedMemory['x'] );

    return memoryInstance;
  end


  --[[
  Determines whether a full memory path exists.

  This method should be called instead of MemoryAddon_MemoryRepository::check()
  to prevent the path from being created.

  @since 1.1.0

  @param string category
  @param string[] path
  @param string interactionType
  @return bool|array the memory path
  ]]
  function instance:exist( category, --[[optional]] path, --[[optional]] interactionType )

    -- creates a pointer to the current path in the memory array
    local memoryDataSetAux = MemoryAddon_DataSet[ self.realm ][ self.player ][ category ];

    -- category check
    if nil == memoryDataSetAux then return false; end

    if nil ~= path then

      for i = 1, #path, 1 do

        -- path check
        if memoryDataSetAux[ path[ i ] ] == nil then return false; end

        -- sets the current path index in the pointer
        memoryDataSetAux = memoryDataSetAux[ path[ i ] ];
      end
    end

    if nil ~= interactionType then

      -- interaction check
      if memoryDataSetAux[ interactionType ] == nil then return false; end
    end

    -- if the execution hits this line it means the full memory path exists
    return memoryDataSetAux;
  end


  --[[
  Lists memories from a given category and path.

  TODO: Fix this method to work with nested paths (zones, subzones) {AC 2021-02-14}

  @since 1.1.0

  @param string category
  @param string[] path
  @return MemoryAddon_Memory[] memories
  ]]
  function instance:listMemories( category, path )

    -- tries to get the memory path
    local memoryPath = self:exist( category, path );

    -- list of memories to be returned
    local memories = {};

    -- if no memory path can be established
    if not memoryPath then return memories; end

    -- iterates over all the interaction types under the path
    for interactionType, values in pairs( memoryPath ) do

      -- creates the memory instance
      table.insert( memories, MemoryCore
        :new('Memory/Memory')
        :setCategory( category )
        :setPath( path )
        :setInteractionType( interactionType )
        :setFirst( self:newMemoryString( values['first'] ) )
        :setLast( self:newMemoryString( values['last'] ) )
        :setX( values['x'] )
      );
    end

    return memories;
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
    local memoryString = self:newMemoryString():toString();

    -- stores the first time player experienced this memory
    if memoryPath['first'] == -1 then memoryPath['first'] = memoryString; end

    -- stores the last time player experienced this memory
    memoryPath['last'] = memoryString;

    -- increases the number of times player experienced this memory
    memoryPath['x'] = memoryPath['x'] + x;

    -- just a debug message to... help us debug!
    MemoryCore:getLogger():info( '|TInterface\\MoneyFrame\\UI-GoldIcon:0|t ' .. interactionType .. ' memory stored for ' .. category );
  end


  --[[
  Stores a player memory when leveling up.

  @since 1.4.0

  @tparam Memory/LevelMemory levelMemory
  ]]
  function instance:storeLevelMemory(levelMemory)
    local arr = MemoryCore.arr
    local key = self.realm .. '.' .. self.player .. '.levels.' .. levelMemory.level .. '.'

    arr:set(MemoryAddon_DataSet, key .. 'date', levelMemory.date)
    arr:set(MemoryAddon_DataSet, key .. 'moment', levelMemory.moment)
    arr:set(MemoryAddon_DataSet, key .. 'subZone', levelMemory.subZone)
    arr:set(MemoryAddon_DataSet, key .. 'zone', levelMemory.zone)
  end


  --[[
  Overload to instance:store that accepts a MemoryAddon_Memory instance.

  Note: although a memory instance has first, last and x properties, this method will
        make use of category, path, interactionType and x only due to how store works.
        That being said, you may want to change x to 1 or any other number in order to
        avoid multiplying the current x if it's loaded by MemoryAddon_MemoryRepository:get().

  @since 0.5.0-beta

  @param MemoryAddon_Memory memory
  ]]
  function instance:storeMemory( memory )

    -- sanity check
    if memory == nil or not memory:isValid() then

      MemoryCore:getLogger():warn( 'Attempt to save an invalid memory' );

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

    return MemoryAddon_DataSet ~= nil;
  end

  -- may initialize the player's memories
  instance:checkMyself();

  -- destroys the prototype, so instance will be unique
  MemoryAddon_MemoryRepository = nil;

  return instance;
end
