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
  setmetatable(instance, MemoryRepository);
  instance.player = player;
  instance.realm = realm;


  --[[
  Determines whether the memory data set is set.

  @since 0.2.0-alpha

  @return bool
  ]]
  instance.testConnection = function()
  
    return MemoryDataSet ~= nil;
  end

  return instance;
end
