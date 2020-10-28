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
    function( listener, event, params )

    end
  ) );

  --[[
  Event triggered when a player speaks with an NPC.

  @since 0.4.0-alpha
  ]]
  core:addEventListener( MemoryEvent:new(
    "EventNpcTalk",
    {},
    function( listener, event, params )

    end
  ) );

  --[[
  Event triggered when a player fights with an NPC.

  @since 0.4.0-alpha
  ]]
  core:addEventListener( MemoryEvent:new(
    "EventNpcFight",
    {},
    function( listener, event, params )

    end
  ) );

  --[[
  Event triggered when a player turns in a quest for an NPC.

  @since 0.4.0-alpha
  ]]
  core:addEventListener( MemoryEvent:new(
    "EventNpcQuest",
    {},
    function( listener, event, params )

    end
  ) );

  --[[
  Event triggered when a player parties with another player.

  @since 0.4.0-alpha
  ]]
  core:addEventListener( MemoryEvent:new(
    "EventPlayerParty",
    {},
    function( listener, event, params )

    end
  ) );

  --[[
  Event triggered when a player visits a zone.

  @since 0.4.0-alpha
  ]]
  local eventZoneVisit = MemoryEvent:new(
    "EventZoneVisit",
    { "ZONE_CHANGED_NEW_AREA", "PLAYER_CONTROL_GAINED" },
    function( listener, event, params )

      -- prevents the memory to be saved if player has no control of itself like
      -- flying or being controlled by cinematics, etc
      if not HasFullControl() or UnitOnTaxi( "player" ) then

        listener:debug( "Player has no full control of itself, no memories will be recorded" );
        return;
      end

      -- gets the zone name
      local zoneName = GetZoneText();

      -- this event can be triggered whether the player is changing zones or not, so
      -- we need to check if it had really changed zones
      if zoneName == listener.lastZone then

        listener:debug( "Player hasn't changed zones, no memories will be recorded" );
        return;
      end

      -- sanity check
      if "" == zoneName then

        listener:debug( "The zone name couldn't be retrieved, no memories will be recorded" );
        return;
      end

      -- stores a memory about the new zone player is visiting
      MemoryCore:getRepository():store( "zones", { zoneName }, "visit" );

      -- will prevent the memory to be recorded twice in another event call
      listener.lastZone = zoneName;
    end
  );
  eventZoneVisit.lastZone = "";
  core:addEventListener( eventZoneVisit );

  --[[
  Event triggered when a player visits a sub zone.

  @since 0.4.0-alpha
  ]]
  core:addEventListener( MemoryEvent:new(
    "EventSubZoneVisit",
    {},
    function( listener, event, params )

    end
  ) );

  --[[
  Event triggered when a player loots an item.

  @since 0.4.0-alpha
  ]]
  core:addEventListener( MemoryEvent:new(
    "EventItemLoot",
    {},
    function( listener, event, params )

    end
  ) );

  core:debug( "Events appended" );
end
