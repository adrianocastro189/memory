--[[
Adds the player prototype and creation method to core.

@since 0.4.0-alpha

@param MemoryCore core the memory core instance
]]
function MemoryAddon_addPlayerPrototype( core )

  --[[
  The player prototype.

  @since 0.4.0-alpha
  ]]
  local MemoryAddon_Player = {};
  MemoryAddon_Player.__index = MemoryAddon_Player;


  --[[
  Builds a new instance of a player.

  @since 0.4.0-alpha

  @param string guid player's unique ID
  @param string name player's name
  @return MemoryAddon_Player
  ]]
  function MemoryAddon_Player:new( guid, name )

    local instance = {};
    setmetatable( instance, MemoryAddon_Player );
    instance.guid = guid;
    instance.name = name;
    instance.type = nil;

    return instance;
  end


  --[[
  Gets the player of the current player's target.

  @since 0.4.0-alpha

  @return MemoryAddon_Player
  ]]
  function core:getPlayerOnTarget()

    return MemoryAddon_Player:new(
      UnitGUID( 'target' ) or '', -- gets the target unit ID or use an empty string instead of nil
      UnitName( 'target' ) or ''  -- gets the target unit name or use an empty string instead of nil
    );
  end


  -- prevents this method to be called again
  MemoryAddon_addPlayerPrototype = nil;
end
