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
  local eventNpcBusiness = MemoryEvent:new(
    "EventNpcBusiness",
    { 'MERCHANT_CLOSED', 'MERCHANT_SHOW', 'PLAYER_MONEY', 'ZONE_CHANGED' },
    function( listener, event, params )

      if 'ZONE_CHANGED' == event then

        listener.lastNpcs = {};
        return listener:debugAndExit( "Resetting last NPCs list" );
      end

      if 'MERCHANT_CLOSED' == event then

        listener.doingBusiness = false;
        return listener:debugAndExit( "Merchant window closed" );
      end

      if 'MERCHANT_SHOW' == event then

        listener.doingBusiness = true;
        return listener:debugAndExit( "Merchant window opened" );
      end

      -- sanity check
      if 'PLAYER_MONEY' == event then

        -- exit condition if player is not doing business
        if not listener.doingBusiness then return listener:debugAndExit( "Player is not doing business" ); end

        -- gets the player on target
        local target = MemoryCore:getPlayerOnTarget();

        -- sanity check
        if not target:isNpc() then return listener:debugAndExit( "Target is not an NPC" ); end

        -- when a player does business with an npc again before leaving the zone, we won't count that as another memory
        if MemoryCore:getArrayHelper():inArray( target:getName(), listener.lastNpcs ) then return listener:debugAndExit( "Recent business" ); end

        -- stores the player memory about doing business with that npc
        MemoryCore:getRepository():store( 'npcs', { target:getName() }, 'business' );

        -- will prevent the memory to be recorded twice if player does business with the same npc again before leaving the zone
        table.insert( listener.lastNpcs, target:getName() );
      end

    end
  );
  eventNpcBusiness.doingBusiness = false;
  eventNpcBusiness.lastNpcs      = {};
  core:addEventListener( eventNpcBusiness );

  --[[
  Event triggered when a player speaks with an NPC.

  @since 0.4.0-alpha
  ]]
  local eventNpcTalk = MemoryEvent:new(
    "EventNpcTalk",
    { 'GOSSIP_SHOW', 'MERCHANT_SHOW', 'QUEST_COMPLETE', 'QUEST_DETAIL', 'QUEST_GREETING', 'ZONE_CHANGED' },
    function( listener, event, params )

      if "ZONE_CHANGED" == event then

        listener.lastNpcs = {};
        return listener:debugAndExit( "Resetting last NPCs list" );
      end

      -- gets the player on target
      local target = MemoryCore:getPlayerOnTarget();

      -- sanity check
      if not target:isNpc() then return listener:debugAndExit( "Target is not an NPC" ); end

      -- sanity check for dialog frames and the target name
      if MemoryCore:getArrayHelper():inArray( event, { 'GOSSIP_SHOW' } ) and target:getName() ~= MemoryCore:getCompatibilityHelper():getDialogGossipTitle() then

        return listener:debugAndExit( 'NPC name / gossip window title incompatibility' );
      end

      -- sanity check for dialog frames and the target name
      if MemoryCore:getArrayHelper():inArray( event, { 'QUEST_COMPLETE', 'QUEST_DETAIL', 'QUEST_GREETING' } ) and target:getName() ~= MemoryCore:getCompatibilityHelper():getQuestGossipTitle() then

        return listener:debugAndExit( 'NPC name / quest window title incompatibility' );
      end

      -- when a player talks with an npc again before leaving the zone, we won't count that as another memory
      if MemoryCore:getArrayHelper():inArray( target:getName(), listener.lastNpcs ) then return listener:debugAndExit( "Spoke recently" ); end

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

  @see https://wow.gamepedia.com/COMBAT_LOG_EVENT

  @since 0.4.0-alpha
  ]]
  local eventNpcFight = MemoryEvent:new(
    "EventNpcFight",
    { 'COMBAT_LOG_EVENT', 'ZONE_CHANGED' },
    function( listener, event, params )

      if 'ZONE_CHANGED' == event and not InCombatLockdown() then

        listener.lastNpcs = {};
        return listener:debugAndExit( "Clearing last npcs list" );
      end

      -- gets the combat log current event info
      local timestamp, subEvent, _, sourceGuid, sourceName, sourceFlags, sourceRaidFlags, destGuid, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo();

      -- fix a possible nil value for subEvent
      subEvent = subEvent or 'NONE';

      -- gets player guid to be used on the next conditionals
      local playerGuid = UnitGUID( 'player' );

      -- exit condition if player is not the owner of the attack
      if not playerGuid == sourceGuid then return listener:debugAndExit( "Player didn't attack" ); end

      -- exit condition if player was attacked
      if playerGuid == destGuid then return listener:debugAndExit( "Player was attacked" ); end

      -- exit condition if subevent is not a known one
      if not MemoryCore:getArrayHelper():inArray( subEvent, { 'SWING_DAMAGE', 'SPELL_DAMAGE' } ) then return listener:debugAndExit( 'subEvent = ' .. subEvent ); end

      -- exit condition if player has already attacked this npc
      if MemoryCore:getArrayHelper():inArray( destGuid, listener.lastNpcs ) then return listener:debugAndExit( 'Already attacked' ); end

      -- sanity check
      if destName == nil or '' == destName then return listener:debugAndExit( 'destName is null or empty' ); end

      -- stores a memory of fighting the npc
      MemoryCore:getRepository():store( "npcs", { destName }, "fight" );

      -- will prevent the memory to be recorded twice if player fights with the same npc again before TODO
      table.insert( listener.lastNpcs, destGuid );
    end
  );
  eventNpcFight.lastNpcs = {};
  core:addEventListener( eventNpcFight );

  --[[
  Event triggered when a player parties with another player.

  @since 0.4.0-alpha
  ]]
  local eventPlayerParty = MemoryEvent:new(
    "EventPlayerParty",
    {},
    function( listener, event, params )

    end
  );
  core:addEventListener( eventPlayerParty );

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
      if not HasFullControl() or UnitOnTaxi( "player" ) or MemoryCore:getCompatibilityHelper():isFlying() then return listener:debugAndExit( "No full control" ); end

      -- gets the zone name
      local zoneName = GetZoneText();

      -- sanity check
      if "" == zoneName then return listener:debugAndExit( "Invalid zone name" ); end

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
      if "" == subZoneName then return listener:debugAndExit( "Invalid subzone name" ); end

      -- this event can be triggered whether the player is changing zones or not, so
      -- we need to check if it had really changed zones
      if MemoryCore:getArrayHelper():inArray( subZoneName, listener.lastSubZones ) then return listener:debugAndExit( "Player hasn't changed subzones" ); end

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
