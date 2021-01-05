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
    'EventNpcBusiness',
    { 'MERCHANT_CLOSED', 'MERCHANT_SHOW', 'PLAYER_MONEY', 'ZONE_CHANGED' },
    function( listener, event, params )

      if 'ZONE_CHANGED' == event then

        listener.lastNpcs = {};
        return listener:debugAndExit( 'Resetting last NPCs list' );
      end

      if 'MERCHANT_CLOSED' == event then

        listener.doingBusiness = false;
        return listener:debugAndExit( 'Merchant window closed' );
      end

      if 'MERCHANT_SHOW' == event then

        listener.doingBusiness = true;
        return listener:debugAndExit( 'Merchant window opened' );
      end

      -- sanity check
      if 'PLAYER_MONEY' == event then

        -- exit condition if player is not doing business
        if not listener.doingBusiness then return listener:debugAndExit( 'Player is not doing business' ); end

        -- gets the player on target
        local target = MemoryCore:getPlayerOnTarget();

        -- sanity check
        if not target:isNpc() then return listener:debugAndExit( 'Target is not an NPC' ); end

        -- when a player does business with an npc again before leaving the zone, we won't count that as another memory
        if MemoryCore:getArrayHelper():inArray( target:getName(), listener.lastNpcs ) then return listener:debugAndExit( 'Recent business' ); end

        -- sets the subject for memory text formatting
        listener.subject = target:getName();

        -- stores the player memory about doing business with that npc
        listener:printAndSave( 'npcs', { target:getName() }, 'business' );

        -- will prevent the memory to be recorded twice if player does business with the same npc again before leaving the zone
        table.insert( listener.lastNpcs, target:getName() );
      end

    end
  );
  eventNpcBusiness.doingBusiness = false;
  eventNpcBusiness.lastNpcs      = {};
  function eventNpcBusiness:buildMemoryTextFormatter()

    return MemoryCore:newMemoryTextFormatter()
      :setPastActionSentence( 'had done business' )
      :setPastActionSentenceConnector( 'with' )
      :setPresentActionSentence( 'do business' )
      :setPresentActionSentenceConnector( 'with' )
      :setSubject( self.subject );
  end
  core:addEventListener( eventNpcBusiness );

  --[[
  Event triggered when a player speaks with an NPC.

  @since 0.4.0-alpha
  ]]
  local eventNpcTalk = MemoryEvent:new(
    'EventNpcTalk',
    { 'GOSSIP_SHOW', 'MERCHANT_SHOW', 'QUEST_COMPLETE', 'QUEST_DETAIL', 'QUEST_GREETING', 'ZONE_CHANGED' },
    function( listener, event, params )

      if 'ZONE_CHANGED' == event then

        listener.lastNpcs = {};
        return listener:debugAndExit( 'Resetting last NPCs list' );
      end

      -- gets the player on target
      local target = MemoryCore:getPlayerOnTarget();

      -- sanity check
      if not target:isNpc() then return listener:debugAndExit( 'Target is not an NPC' ); end

      -- sanity check for dialog frames and the target name
      if MemoryCore:getArrayHelper():inArray( event, { 'GOSSIP_SHOW' } ) and target:getName() ~= MemoryCore:getCompatibilityHelper():getDialogGossipTitle() then

        return listener:debugAndExit( 'NPC name / gossip window title incompatibility' );
      end

      -- sanity check for dialog frames and the target name
      if MemoryCore:getArrayHelper():inArray( event, { 'QUEST_COMPLETE', 'QUEST_DETAIL', 'QUEST_GREETING' } ) and target:getName() ~= MemoryCore:getCompatibilityHelper():getQuestGossipTitle() then

        return listener:debugAndExit( 'NPC name / quest window title incompatibility' );
      end

      -- when a player talks with an npc again before leaving the zone, we won't count that as another memory
      if MemoryCore:getArrayHelper():inArray( target:getName(), listener.lastNpcs ) then return listener:debugAndExit( 'Spoke recently' ); end

      -- sets the subject for memory text formatting
      listener.subject = target:getName();

      -- stores the player memory about talking with that npc
      listener:printAndSave( 'npcs', { target:getName() }, 'talk' );

      -- will prevent the memory to be recorded twice if player talks with the same npc again before leaving the zone
      table.insert( listener.lastNpcs, target:getName() );
    end
  );
  eventNpcTalk.lastNpcs = {};
  function eventNpcTalk:buildMemoryTextFormatter()

    return MemoryCore:newMemoryTextFormatter()
      :setPastActionSentence( 'spoke' )
      :setPastActionSentenceConnector( 'with' )
      :setPresentActionSentence( 'speak' )
      :setPresentActionSentenceConnector( 'with' )
      :setSubject( self.subject );
  end
  core:addEventListener( eventNpcTalk );

  --[[
  Event triggered when a player fights with an NPC.

  @see https://wow.gamepedia.com/COMBAT_LOG_EVENT

  @since 0.4.0-alpha
  ]]
  local eventNpcFight = MemoryEvent:new(
    'EventNpcFight',
    { 'COMBAT_LOG_EVENT', 'COMBAT_LOG_EVENT_UNFILTERED', 'ZONE_CHANGED' },
    function( listener, event, params )

      if 'ZONE_CHANGED' == event and not InCombatLockdown() then

        listener.lastNpcs = {};
        return listener:debugAndExit( 'Clearing last npcs list' );
      end

      -- gets the combat log current event info
      local timestamp, subEvent, _, sourceGuid, sourceName, sourceFlags, sourceRaidFlags, destGuid, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo();

      -- fix a possible nil value for subEvent
      subEvent = subEvent or 'NONE';

      -- gets player guid to be used on the next conditionals
      local playerGuid = UnitGUID( 'player' );
      local playerName = UnitName( 'player' );

      -- exit condition if player is not the owner of the attack
      if playerName ~= sourceName then return listener:debugAndExit( 'Player didn\'t attack' ); end

      -- exit condition if player was attacked
      if playerGuid == destGuid then return listener:debugAndExit( 'Player was attacked' ); end

      -- exit condition if subevent is not a known one
      if not MemoryCore:getArrayHelper():inArray( subEvent, { 'SWING_DAMAGE', 'SPELL_DAMAGE' } ) then return listener:debugAndExit( 'subEvent = ' .. subEvent ); end

      -- gets the player object
      local player = MemoryCore:getPlayerByGuid( destGuid, destName );

      -- sanity check
      if not player:isNpc() then

        -- TODO: Remove this log message once this rule is validated
        MemoryCore:getLogger():warn( 'Target is not an NPC' );

        return listener:debugAndExit( 'Target is not an NPC' );
      end

      -- exit condition if player has already attacked this npc
      if MemoryCore:getArrayHelper():inArray( destGuid, listener.lastNpcs ) then return listener:debugAndExit( 'Already attacked' ); end

      -- sanity check
      if destName == nil or '' == destName then return listener:debugAndExit( 'destName is null or empty' ); end

      -- sets the subject for memory text formatting
      listener.subject = destName;

      -- stores a memory of fighting the npc
      listener:printAndSave( 'npcs', { destName }, 'fight' );

      -- will prevent the memory to be recorded twice if player fights with the same npc again before
      table.insert( listener.lastNpcs, destGuid );
    end
  );
  eventNpcFight.lastNpcs = {};
  function eventNpcFight:buildMemoryTextFormatter()

    return MemoryCore:newMemoryTextFormatter()
      :setPastActionSentence( 'had a fight' )
      :setPastActionSentenceConnector( 'with' )
      :setPresentActionSentence( 'have a fight' )
      :setPresentActionSentenceConnector( 'with' )
      :setSubject( self.subject );
  end
  core:addEventListener( eventNpcFight );

  --[[
  Event triggered when a player parties with another player.

  @since 0.4.0-alpha
  ]]
  local eventPlayerParty = MemoryEvent:new(
    'EventPlayerParty',
    { 'GROUP_ROSTER_UPDATE' },
    function( listener, event, params )

      -- gets all member full names regardless of player is in a party or raid
      local groupMemberGuids = MemoryCore:getCompatibilityHelper():getGroupFullNames();

      -- select group members that weren't added yet to the player's memory
      local uniqueMembers = MemoryCore:getArrayHelper():arrayDiff( groupMemberGuids, listener.lastPlayers );

      for i, playerFullName in pairs( uniqueMembers ) do

        -- sets the subject for memory text formatting
        listener.subject = playerFullName;

        -- adds a party memory
        listener:printAndSave( 'players', { playerFullName }, 'party' );

        -- will prevent the memory to be recorded twice if player has grouped with that member recently
        table.insert( listener.lastPlayers, playerFullName );
      end
    end
  );
  eventPlayerParty.lastPlayers = {};
  function eventPlayerParty:buildMemoryTextFormatter()

    return MemoryCore:newMemoryTextFormatter()
      :setPastActionSentence( 'grouped' )
      :setPastActionSentenceConnector( 'with' )
      :setPresentActionSentence( 'group' )
      :setPresentActionSentenceConnector( 'with' )
      :setSubject( self.subject );
  end
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
    'EventZoneVisit',
    { 'PLAYER_STARTED_MOVING', 'PLAYER_STOPPED_MOVING' },
    function( listener, event, params )

      -- prevents the memory to be saved if player has no control of itself like
      -- flying or being controlled by cinematics, etc
      if not HasFullControl() or UnitOnTaxi( 'player' ) or MemoryCore:getCompatibilityHelper():isFlying() then return listener:debugAndExit( 'No full control' ); end

      -- gets the zone name
      local zoneName = GetZoneText();

      -- sanity check
      if '' == zoneName then return listener:debugAndExit( 'Invalid zone name' ); end

      -- this event can be triggered whether the player is changing zones or not, so
      -- we need to check if it had really changed zones
      if not zoneName == listener.lastZone then

        -- sets the subject for memory text formatting
        listener.subject = zoneName;

        -- stores a memory about the new zone player is visiting
        listener:printAndSave( 'zones', { zoneName }, 'visit' );

        -- will prevent the memory to be recorded twice in another event call
        listener.lastZone = zoneName;

        -- retests the last sub zones array when player changes zones
        listener.lastSubZones = {};
      end

      -- gets the zone name
      local subZoneName = GetSubZoneText() or GetMinimapZoneText();

      -- sanity check
      if '' == subZoneName then return listener:debugAndExit( 'Invalid subzone name' ); end

      -- this event can be triggered whether the player is changing zones or not, so
      -- we need to check if it had really changed zones
      if MemoryCore:getArrayHelper():inArray( subZoneName, listener.lastSubZones ) then return listener:debugAndExit( 'Player hasn\'t changed subzones' ); end

      -- sets the subject for memory text formatting
      listener.subject = subZoneName;

      -- stores a memory about the new sub zone player is visiting
      listener:printAndSave( 'zones', { zoneName, 'subzones', subZoneName }, 'visit' );

      -- will prevent the memory to be recorded twice in another event call
      table.insert( listener.lastSubZones, subZoneName );
    end
  );
  eventZoneVisit.lastSubZones = {};
  eventZoneVisit.lastZone     = '';
  function eventZoneVisit:buildMemoryTextFormatter()

    return MemoryCore:newMemoryTextFormatter()
      :setPastActionSentence( 'visited' )
      :setPastActionSentenceConnector( '' )
      :setPresentActionSentence( 'visit' )
      :setPresentActionSentenceConnector( '' )
      :setSubject( self.subject );
  end
  core:addEventListener( eventZoneVisit );

  --[[
  Event triggered when a player loots an item.

  @see https://wow.gamepedia.com/CHAT_MSG_LOOT

  @since 0.4.0-alpha
  ]]
  local eventItemLoot = MemoryEvent:new(
    'EventItemLoot',
    { 'CHAT_MSG_LOOT' },
    function( listener, event, params )

      local lootString = params[1];
      -- #12 for Retail and #5 for Classic
      local playerIdentification = params[12] or ( params[5] or '' );

      -- sanity check in case this is triggered by another player message
      if UnitGUID( 'player' ) ~= playerIdentification and UnitName( 'player' ) ~= playerIdentification   then return listener:debugAndExit( 'Player didn\'t loot it' ); end

      -- gets the item loot information
      local itemLootInfo = MemoryCore:getCompatibilityHelper():parseChatMsgLoot( lootString );

      -- another sanity check
      if not itemLootInfo.valid then return listener:debugAndExit( 'Invalid item' ); end

      -- sets the subject for memory text formatting
      listener.subject = itemLootInfo.name;

      -- stores a memory about looting the item
      listener:printAndSave( 'items', { itemLootInfo.name }, 'loot', itemLootInfo.quantity );
    end
  );
  function eventItemLoot:buildMemoryTextFormatter()

    return MemoryCore:newMemoryTextFormatter()
      :setPastActionSentence( 'looted' )
      :setPastActionSentenceConnector( 'an item called' )
      :setPresentActionSentence( 'loot' )
      :setPresentActionSentenceConnector( 'an item called' )
      :setSubject( self.subject );
  end
  core:addEventListener( eventItemLoot );

  core:getLogger():debug( 'Events added' );

  -- prevents MemoryEvent from being exposed after all events are created
  MemoryEvent:destroyPrototype();

  -- prevents this method to be called again
  MemoryAddon_addEvents = nil;
end
