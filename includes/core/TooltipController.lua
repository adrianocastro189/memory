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
  Adds memories to a tooltip.

  @since 1.1.0

  @param MemoryAddon_Memory[] memory list
  ]]
  function instance:addMemoriesToTooltip( memories )

    -- adds the memory addon tooltip header
    self:addMemoryHeader();

    -- just a pointer to the next interation
    local interactionType = nil;

    for i, j in ipairs( memories ) do

      -- gets the interaction type or a nil replacement
      interactionType = memories[i]:getInteractionType() or '-';

      self:addInteractionHeader( MemoryCore:getStringHelper():uppercaseFirst( interactionType ), memories[i]:getX() );
      self:addDoubleLine( '    First', self:buildMemoryText( memories[i]:getFirstFormattedDate(), memories[i]:getFirstPlayerLevel() ) );
      self:addDoubleLine( '    Last' , self:buildMemoryText( memories[i]:getLastFormattedDate(), memories[i]:getLastPlayerLevel() ) );
    end
  end


  --[[
  Adds memories to the item tooltips.

  TODO: Add a cache to MemoryCore:getRepository():listMemories as this method is called multiple times as long as the mouse is over an item {AC 2021-02-06}

  @since 1.1.0

  @param string itemName
  ]]
  function instance:addMemoriesToTooltipItem( itemName )

    -- sanity check
    if nil == itemName or '' == itemName then return; end

    -- gets all the memories for the item
    local memories = MemoryCore:getRepository():listMemories( 'items', { itemName } );

    -- sanity check
    if 0 == #memories then MemoryCore:getLogger():debug( 'No memories found for ' .. itemName ); return; end

    -- adds the memories to the current tooltip
    self:addMemoriesToTooltip( memories );
  end


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

    -- adds the memories to the current tooltip
    self:addMemoriesToTooltip( memories );
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
  Adds an interation header to the memory tooltip.

  @since 1.1.0

  @param string header
  ]]
  function instance:addInteractionHeader( header, times )

    GameTooltip:AddDoubleLine( header, 'x' .. times );
  end


  --[[
  Adds the main memory header to the tooltip.

  @since 1.1.0
  ]]
  function instance:addMemoryHeader()

    GameTooltip:AddLine( ' ' );
    GameTooltip:AddLine( MemoryCore:highlight( '<' .. MemoryCore.ADDON_NAME .. '>' ) );
  end


  --[[
  Builds the memory text to be added to the tooltp.

  @since 1.1.1

  @return string
  ]]
  function instance:buildMemoryText( formattedDate, playerLevel )

    local memoryValue = formattedDate;

    if '' ~= playerLevel then

      memoryValue = memoryValue .. ' [' .. playerLevel .. ']';
    end

    return memoryValue;
  end


  --[[
  Intercepts the item tooltip.

  @since 1.1.0

  @param string itemName
  ]]
  function instance:handleTooltipItem( itemName )

    instance:addMemoriesToTooltipItem( itemName )
  end


  --[[
  Intercepts the unit tooltip.

  @since 1.1.0
  ]]
  function instance:handleTooltipUnit()

    MemoryCore:getTooltipController():addMemoriesToTooltipUnit();
  end


  --[[
  Determines whether memories should be added to the tooltip.

  It checks the setting 'memory.showInTooltips' and if it has a true value
  according to what the Stormwind Library considers true.

  In case the setting is not found, it returns true considering that the
  default behavior is to show memories in the tooltips as soon as the addon
  is enabled and collecting data.

  @since 1.2.4
  ]]
  function instance:shouldAddMemoriesToTooltip()
    
    local value = MemoryCore:setting( 'memory.showInTooltips' )

    return value == nil or MemoryCore.__.bool:isTrue( value )
  end


  -- hooks the item tooltip script to call the handler method
  GameTooltip:HookScript( 'OnTooltipSetItem', function( tooltip )

      local itemName = tooltip:GetItem();

      instance:handleTooltipItem( itemName );
    end
  );

  -- hooks the unit tooltip script to call the handler method
  GameTooltip:HookScript( 'OnTooltipSetUnit', instance.handleTooltipUnit );

  -- destroys the prototype, so instance will be unique
  MemoryAddon_TooltipController = nil;

  return instance;
end
