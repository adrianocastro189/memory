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
  Adds a two column line to the memory tooltip.

  @since 1.1.0

  @param string header
  @param string content
  ]]
  function instance:addDoubleLine( header, content )

    GameTooltip:AddDoubleLine( header, content );
  end


  --[[
  Adds a header to the memory tooltip.

  @since 1.1.0

  @param string header
  ]]
  function instance:addHeader( header )

    GameTooltip:AddLine( header );
  end


  --[[
  Adds the main memory header to the tooltip.

  @since 1.1.0
  ]]
  function instance:addMemoryHeader()

    GameTooltip:AddLine( MemoryCore:highlight( '<' .. MemoryCore.ADDON_NAME .. '>' ) );
  end


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

    MemoryCore:getTooltipController():addMemoriesToTooltipUnit();
  end


  -- hooks the item tooltip script to call the handler method
  GameTooltip:HookScript( 'OnTooltipSetItem', instance.handleTooltipItem );

  -- hooks the unit tooltip script to call the handler method
  GameTooltip:HookScript( 'OnTooltipSetUnit', instance.handleTooltipUnit );

  -- destroys the prototype, so instance will be unique
  MemoryAddon_TooltipController = nil;

  return instance;
end
