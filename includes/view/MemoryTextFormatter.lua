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

    instance.MESSAGE_TYPE_FIRST_WITH_DATE = 1;
    instance.MESSAGE_TYPE_FIRST_WITH_DAYS = 2;
    instance.MESSAGE_TYPE_LAST_WITH_DATE  = 3;
    instance.MESSAGE_TYPE_LAST_WITH_DAYS  = 4;
    instance.MESSAGE_TYPE_COUNT           = 5;
    instance.UNDEFINED_PROPERTY           = '(undefined property)';
    instance.UNDEFINED_MESSAGE_TYPE       = '(undefined message type)';

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
