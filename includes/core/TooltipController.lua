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
  Adds memories to the unit tooltips.

  @since 1.1.0
  ]]
  function instance:addMemoriesToTooltipUnit()

    local category = nil;

    -- gets the player on the mouse
    local player = MemoryCore:getPlayerByUnit( 'mouseover' );

    -- determines the category
    if player:isNpc() then category = 'npcs'; elseif player:isPlayer() then category = 'players'; end

    -- sanity check (pets and vehicles may also trigger this method)
    if nil == category then MemoryCore:getLogger():debug( 'Unit tooltip for an unrecognized unit type' ); return; end

    -- gets all the memories for the player/npc
    local memories = MemoryCore:getRepository():listMemories( category, { player:getFullName() } );

    -- sanity check
    if 0 == #memories then MemoryCore:getLogger():debug( 'No memories found for ' .. player:getFullName() ); return; end

    -- adds the memory addon tooltip header
    self:addMemoryHeader();

    -- just a pointer to the next interation
    local interactionType = nil;

    for i, j in ipairs( memories ) do

      -- gets the interaction type or a nil replacement
      interactionType = memories[i]:getInteractionType() or '-';

      self:addInteractionHeader( MemoryCore:getStringHelper():uppercaseFirst( interactionType ), memories[i]:getX() );
      self:addDoubleLine( '    First', memories[i]:getFirstFormattedDate() );
      self:addDoubleLine( '    Last', memories[i]:getLastFormattedDate() );
    end
  end


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
