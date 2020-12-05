--[[
Adds the memory text formatter prototype and creation method to core.

@since 0.6.0-beta

@param MemoryRepository repository the memory repository instance
]]
function MemoryAddon_addMemoryTextFormatterPrototype( core )

  --[[
  The memory text formatter prototype.

  @since 0.6.0-beta
  ]]
  local MemoryAddon_MemorTextFormatter = {};
  MemoryAddon_MemorTextFormatter.__index = MemoryAddon_MemorTextFormatter;

  --[[
  Builds a new instance of a memory text formatter.

  @since 0.6.0-beta

  @return MemoryAddon_MemorTextFormatter
  ]]
  function MemoryAddon_MemorTextFormatter:new()

    local instance = {};

    setmetatable( instance, MemoryAddon_MemorTextFormatter );

    return instance;
  end


  --[[
  Builds a new instance of a memory text formatter from core.

  @since 0.6.0-beta

  @return MemoryAddon_MemorTextFormatter
  ]]
  function core:newMemoryTextFormatter()

    return MemoryAddon_MemorTextFormatter:new();
  end


  -- prevents this method to be called again
  MemoryAddon_addMemoryTextFormatterPrototype = nil;
end
