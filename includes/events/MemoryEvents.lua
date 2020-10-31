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

  The first approaches to this event were based on player switching zones, indoor zones,
  areas, etc. However, sometimes those events are triggered before GetZoneText() and
  GetMinimapZoneText() retrieve zone information.

  After thinking about what a visit means, it makes more sense to register the memories
  when the player walks through the place (moving or stop moving).

  @since 0.4.0-alpha
  ]]
  local eventZoneVisit = MemoryEvent:new(
    "EventZoneVisit",
    { "PLAYER_STARTED_MOVING", "PLAYER_STOPPED_MOVING" },
    function( listener, event, params )

      -- prevents the memory to be saved if player has no control of itself like
      -- flying or being controlled by cinematics, etc
      if not HasFullControl() or UnitOnTaxi( "player" ) or IsFlying() then

        listener:debug( "Player has no full control of itself, no memories will be recorded" );
        return;
      end

      -- gets the zone name
      local zoneName = GetZoneText();

      -- sanity check
      if "" == zoneName then

        listener:debug( "The zone name couldn't be retrieved, no memories will be recorded" );
        return;
      end

      -- this event can be triggered whether the player is changing zones or not, so
      -- we need to check if it had really changed zones
      if not zoneName == listener.lastZone then

        -- stores a memory about the new zone player is visiting
        MemoryCore:getRepository():store( "zones", { zoneName }, "visit" );

        -- will prevent the memory to be recorded twice in another event call
        listener.lastZone = zoneName;

        -- retests the last sub zones array when player changes zones
        listener.lastSubZones = {};
      end

      -- gets the zone name
      local subZoneName = GetSubZoneText() or GetMinimapZoneText();

      -- sanity check
      if "" == subZoneName then

        listener:debug( "The sub zone name couldn't be retrieved, no memories will be recorded" );
        return;
      end

      -- this event can be triggered whether the player is changing zones or not, so
      -- we need to check if it had really changed zones
      if MemoryCore:getArrayHelper():inArray( subZoneName, listener.lastSubZones ) then

        listener:debug( "Player hasn't changed subzones, no memories will be recorded" );
        return;
      end

      -- stores a memory about the new sub zone player is visiting
      MemoryCore:getRepository():store( "zones", { zoneName, "subzones", subZoneName }, "visit" );

      -- will prevent the memory to be recorded twice in another event call
      table.insert( listener.lastSubZones, subZoneName );
    end
  );
  eventZoneVisit.lastSubZones = {};
  eventZoneVisit.lastZone     = "";
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

  -- prevents MemoryEvent from being exposed after all events are created
  MemoryEvent:destroyPrototype();

  -- prevents this method to be called again
  MemoryAddon_appendEvents = nil;
end
