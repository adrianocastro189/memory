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

    -- defines a constant to represent npcs
    instance.TYPE_NPC = 'npc';

    -- defines a constant to represent human players
    instance.TYPE_PLAYER = 'player';

    setmetatable( instance, MemoryAddon_Player );
    instance.guid = guid;
    instance.name = name;
    instance.type = nil;


    --[[
    Gets the player GUID.

    @since 0.4.0-alpha

    @return string guid player's unique ID
    ]]
    function instance:getGuid()

      return self.guid;
    end


    --[[
    Gets the player name.

    @since 0.4.0-alpha

    @return string guid player's name
    ]]
    function instance:getName()

      return self.name;
    end


    --[[
    Determines whether the player is an npc.

    @since 0.4.0-alpha

    @return bool
    ]]
    function instance:isNpc()

      return self.type ~= nil and self.TYPE_NPC == self.type;
    end


    --[[
    Determines whether the player is a human player.

    @since 0.4.0-alpha

    @return bool
    ]]
    function instance:isPlayer()

      return self.type ~= nil and self.TYPE_PLAYER == self.type;
    end


    --[[
    Sets the player type based on its guid.

    @since 0.4.0-alpha
    ]]
    function instance:setPlayerType()

      -- sanity check
      if self.guid == nil or self.guid == '' then return; end

      -- breaks the guid to get its properties
      local type = strsplit( '-', self.guid );

      if 'Player' == type then

        -- target is a human player
        self.type = self.TYPE_PLAYER;
      elseif 'Creature' == type then

        -- target is a non-playable character
        self.type = self.TYPE_NPC;
      end
    end


    -- sets the player type
    instance:setPlayerType();

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
