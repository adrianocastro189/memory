--[[
The tooltip controller prototype.

@since 1.1.0
]]
MemoryAddon_TooltipController = {};
MemoryAddon_TooltipController.__index = MemoryAddon_TooltipController;

--[[
Constructs a new instance of a tooltip controller.

@since 1.1.0

@return MemoryAddon_TooltipController
]]
function MemoryAddon_TooltipController:new()

  local instance = {};
  setmetatable( instance, MemoryAddon_TooltipController );


  --[[
  Intercepts the item tooltip.

  @since 1.1.0
  ]]
  function instance:handleTooltipItem()

  end


  --[[
  Intercepts the unit tooltip.

  @since 1.1.0
  ]]
  function instance:handleTooltipUnit()

  end

  -- destroys the prototype, so instance will be unique
  MemoryAddon_TooltipController = nil;

  return instance;
end
