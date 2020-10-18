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
@returns MemoryRepository
]]
function MemoryRepository:new( player, realm )

  local instance = {};
  setmetatable( instance, MemoryRepository );
  instance.player = player;
  instance.realm = realm;


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
    if playerLevel == nil or playerLevel == 0 then playerLevel = '-' end
    if zoneName    == nil then zoneName    = '-' end
    if subZoneName == nil then subZoneName = '-' end

    -- crafts and returns the memory string
    return currentDate .. "|" .. playerLevel .. "|" .. zoneName .. "|" .. subZoneName;
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

  return instance;
end
