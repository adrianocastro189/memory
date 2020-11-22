--[[
Adds the memory prototype and creation method to repository.

@since 0.5.0-beta

@param MemoryRepository repository the memory repository instance
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
end
