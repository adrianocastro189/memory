--[[
Adds all the available memory event implementations to core as listeners.

@since 0.4.0-alpha

@param MemoryCore core the memory core instance
]]
function MemoryAddon_appendEvents( core )

  --[[
  Event triggered when a player buys, sells or repairs with an NPC.

  @since 0.4.0-alpha
  ]]
  core:addEventListener( MemoryEvent:new(
    "EventNpcBusiness",
    {},
    function( event, params )

    end
  ) );

  --[[
  Event triggered when a player speaks with an NPC.

  @since 0.4.0-alpha
  ]]
  core:addEventListener( MemoryEvent:new(
    "EventNpcTalk",
    {},
    function( event, params )

    end
  ) );

  --[[
  Event triggered when a player fights with an NPC.

  @since 0.4.0-alpha
  ]]
  core:addEventListener( MemoryEvent:new(
    "EventNpcFight",
    {},
    function( event, params )

    end
  ) );

  --[[
  Event triggered when a player turns in a quest for an NPC.

  @since 0.4.0-alpha
  ]]
  core:addEventListener( MemoryEvent:new(
    "EventNpcQuest",
    {},
    function( event, params )

    end
  ) );

  --[[
  Event triggered when a player parties with another player.

  @since 0.4.0-alpha
  ]]
  core:addEventListener( MemoryEvent:new(
    "EventPlayerParty",
    {},
    function( event, params )

    end
  ) );

  --[[
  Event triggered when a player visits a zone.

  @since 0.4.0-alpha
  ]]
  core:addEventListener( MemoryEvent:new(
    "EventZoneVisit",
    { "ZONE_CHANGED_NEW_AREA", "PLAYER_CONTROL_LOST", "PLAYER_CONTROL_GAINED" },
    function( event, params )

    end
  ) );

  --[[
  Event triggered when a player visits a sub zone.

  @since 0.4.0-alpha
  ]]
  core:addEventListener( MemoryEvent:new(
    "EventSubZoneVisit",
    {},
    function( event, params )

    end
  ) );

  --[[
  Event triggered when a player loots an item.

  @since 0.4.0-alpha
  ]]
  core:addEventListener( MemoryEvent:new(
    "EventItemLoot",
    {},
    function( event, params )

    end
  ) );

  core:debug( "Events appended" );
end
