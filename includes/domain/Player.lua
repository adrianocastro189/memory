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
  @param string realm player's realm
  @return MemoryAddon_Player
  ]]
  function MemoryAddon_Player:new( guid, name, realm )

    local instance = {};

    -- defines a constant to represent npcs
    instance.TYPE_NPC = 'npc';

    -- defines a constant to represent human players
    instance.TYPE_PLAYER = 'player';

    setmetatable( instance, MemoryAddon_Player );
    instance.guid  = guid;
    instance.name  = name;
    instance.realm = realm;
    instance.type  = nil;


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

    @return string player's name
    ]]
    function instance:getName()

      return self.name;
    end


    --[[
    Gets the player realm.

    @since 1.1.0

    @return string player's realm
    ]]
    function instance:getRealm()

      return self.realm;
    end


    --[[
    Gets the player type.

    @since 0.4.0-alpha

    @return string player's type
    ]]
    function instance:getType()

      return self.type or '';
    end


    --[[
    Determines whether the player is an npc.

    @since 0.4.0-alpha

    @return bool
    ]]
    function instance:isNpc()

      return self.TYPE_NPC == self:getType();
    end


    --[[
    Determines whether the player is a human player.

    @since 0.4.0-alpha

    @return bool
    ]]
    function instance:isPlayer()

      return self.TYPE_PLAYER == self:getType();
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
      elseif MemoryCore:getArrayHelper():inArray( type, { 'Creature', 'Vehicle' } ) then

        -- target is a non-playable character
        self.type = self.TYPE_NPC;
      end
    end


    -- sets the player type
    instance:setPlayerType();

    return instance;
  end


  --[[
  Gets the player by GUID.

  @since 1.0.0

  @param string guid player's unique ID (optional)
  @param string name player's name (optional)
  @param string realm player's realm (optional)
  @return MemoryAddon_Player
  ]]
  function core:getPlayerByGuid( guid, --[[optional]] name, --[[optional]] realm )

    return MemoryAddon_Player:new( guid or '', name or '', realm or '' );
  end


  --[[
  Gets the player by its unit.

  @since 1.1.0

  @param string unit unit to be queried
  @return MemoryAddon_Player
  ]]
  function core:getPlayerByUnit( unit )

    return MemoryAddon_Player:new(
      UnitGUID( unit ) or '', -- gets the unit guid or use an empty string instead of nil
      UnitName( unit ) or '', -- gets the unit name or use an empty string instead of nil
                          ''
    );
  end


  -- prevents this method to be called again
  MemoryAddon_addPlayerPrototype = nil;
end
