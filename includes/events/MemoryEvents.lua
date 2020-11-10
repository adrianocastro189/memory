--[[
Adds all the available memory event implementations to core as listeners.

@since 0.4.0-alpha

@param MemoryCore core the memory core instance
]]
function MemoryAddon_addEvents( core )

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
  local eventNpcTalk = MemoryEvent:new(
    "EventNpcTalk",
    { "GOSSIP_SHOW", "MERCHANT_SHOW", "ZONE_CHANGED" },
    function( listener, event, params )

      if "ZONE_CHANGED" == event then

        listener:debug( "Player changed zones, resetting last NPCs list" );
        listener.lastNpcs = {};
        return;
      end

      -- gets the player on target
      local target = MemoryCore:getPlayerOnTarget();

      -- sanity check
      if not target:isNpc() then

        MemoryCore:debug( "Target is not an NPC, no memories will be saved" );
        return;
      end

      -- when a player talks with an npc again before leaving the zone, we won't count that as another memory
      if MemoryCore:getArrayHelper():inArray( target:getName(), listener.lastNpcs ) then

        listener:debug( "Player had spoken with this npc recently, no memories will be recorded" );
        return;
      end

      -- stores the player memory about talking with that npc
      MemoryCore:getRepository():store( "npcs", { target:getName() }, "talk" );

      -- will prevent the memory to be recorded twice if player talks with the same npc again before leaving the zone
      table.insert( listener.lastNpcs, target:getName() );
    end
  );
  eventNpcTalk.lastNpcs = {};
  core:addEventListener( eventNpcTalk );

  --[[
  Event triggered when a player fights with an NPC.

  @since 0.4.0-alpha
  ]]
  local eventNpcFight = MemoryEvent:new(
    "EventNpcFight",
    { 'COMBAT_LOG_EVENT' },
    function( listener, event, params )

      -- gets the combat log current event info
      local timestamp, subEvent, _, sourceGuid, sourceName, sourceFlags, sourceRaidFlags, destGuid, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo();

      -- fix a possible nil value for subEvent
      subEvent = subEvent or 'NONE';

      -- gets player guid to be used on the next conditionals
      local playerGuid = UnitGUID( 'player' );

      if not playerGuid == sourceGuid then

        listener:debug( "Player wasn't the owner of this attack, no memories will be recorded" );
        return;
      end

      if playerGuid == destGuid then

        listener:debug( "Player was attacked, no memories will be recorded" );
        return;
      end

      if not MemoryCore:getArrayHelper():inArray( subEvent, { 'SWING_DAMAGE', 'SPELL_DAMAGE' } ) then

        listener:debug( 'subEvent = ' .. subEvent .. ', no memories will be recorded' );
        return;
      end

      if MemoryCore:getArrayHelper():inArray( destGuid, listener.lastNpcs ) then

        listener:debug( 'Player has already attacked this NPC, no memories will be recorded' );
        return;
      end

      -- sanity check
      if destName == nil or '' == destName then

        listener:debug( 'destName is null or empty, no memories will be recorded' );
        return;
      end

      -- stores a memory of fighting the npc
      MemoryCore:getRepository():store( "npcs", { destName }, "fight" );

      -- will prevent the memory to be recorded twice if player fights with the same npc again before TODO
      table.insert( listener.lastNpcs, destGuid );
    end
  );
  eventNpcFight.lastNpcs = {};
  core:addEventListener( eventNpcFight );

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
      if not HasFullControl() or UnitOnTaxi( "player" ) or MemoryCore:getCompatibilityHelper():isFlying() then

        listener:debug( "Player has no full control of itself or is flying, no memories will be recorded" );
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

  core:debug( "Events added" );

  -- prevents MemoryEvent from being exposed after all events are created
  MemoryEvent:destroyPrototype();

  -- prevents this method to be called again
  MemoryAddon_addEvents = nil;
end
