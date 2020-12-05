--[[
Adds the memory string prototype and creation method to repository.

@since 0.6.0-beta

@param MemoryRepository repository the memory repository instance
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

  @return MemoryAddon_MemoryString
  ]]
  function MemoryAddon_MemoryString:new()

    local instance = {};

    setmetatable( instance, MemoryAddon_MemoryString );

    -- default separator between data values in a memory string
    instance.DATA_SEPARATOR = '|';

    -- default value to be used if any information in the memory string is missing
    instance.DATA_DEFAULT_CHAR = '-';

    return instance;
  end


  --[[
  Builds a new instance of a memory string from repository.

  @since 0.6.0-beta

  @return MemoryAddon_MemoryString
  ]]
  function repository:newMemoryString()

    return MemoryAddon_MemoryString:new();
  end


  -- prevents this method to be called again
  MemoryAddon_addMemoryStringPrototype = nil;
end
