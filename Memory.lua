--[[
Fires up the addon.

@since 0.1.0-alpha
]]
local function initializeCore()

  -- initializes the memory data set that stores all the players memories
  if not MemoryDataSet then MemoryDataSet = {} end

  MemoryCore = {};

  -- the addon name
  MemoryCore.ADDON_NAME = "Memory";

  -- the addon version which is the same as the toc file
  MemoryCore.ADDON_VERSION = "0.4.0-alpha";

  -- determines whether the addon is in debug mode or not
  MemoryCore.DEBUG = true;

  -- the pattern used to wrap strings in the addon highlight color
  MemoryCore.HIGHLIGHT_PATTERN = "\124cffffee77{0}\124r";

  -- the memory event listeners that will add memories
  MemoryCore.eventListeners = {};

  -- the unique repository instance
  MemoryCore.repository = nil;


  --[[
  Attaches an event listener to the core.

  Listeners will be triggered by player actions in the game.

  @param MemoryEvent listener
  ]]
  function MemoryCore:addEventListener( listener )

    table.insert( self.eventListeners, listener );

    for i, event in ipairs( listener.events ) do

      -- removes the event to avoid registering them twice
      MemoryEventFrame:UnregisterEvent( event );

      -- adds the event to the memory frame
      MemoryEventFrame:RegisterEvent( event );
    end
  end


  --[[
  Gets the unique repository instance.

  @since 0.2.0-alpha

  @return MemoryRepository
  ]]
  function MemoryCore:getRepository()

    return self.repository;
  end


  --[[
  Highlights a string using the addon highlight color.

  @since 0.1.0-alpha

  @param string value
  @return string
  ]]
  function MemoryCore:highlight( value )

    return string.gsub( MemoryCore.HIGHLIGHT_PATTERN, "{0}", value );
  end


  --[[
  Initializes all the singleton instances in the MemoryCore object.

  @since 0.1.0-alpha
  ]]
  function MemoryCore:initializeSingletons()

    self.repository = MemoryRepository:new( UnitGUID( "player" ), GetRealmName() );
  end


  --[[
  Prints a string in the default chat frame with the highlighted addon name as the prefix.

  @since 0.1.0-alpha

  @param string value
  ]]
  function MemoryCore:print( value )

    local prefix = MemoryCore:highlight( "<" .. MemoryCore.ADDON_NAME .. ">" );

    DEFAULT_CHAT_FRAME:AddMessage( prefix .. " " .. value );
  end


  --[[
  Prints the Memory addon version number.

  @since 0.1.0-alpha
  ]]
  function MemoryCore:printVersion()

    MemoryCore:print( MemoryCore.ADDON_VERSION );
  end


  --[[
  Dispatch every registered events to the registered listeners.

  @since 0.3.0-alpha
  ]]
  MemoryEventFrame:SetScript( "OnEvent",
    function( self, event, ... )

      local params = ...;

      for i, listener in ipairs( MemoryCore.eventListeners ) do

        -- dispatch the event to a listener
        listener:maybeTrigger( event, params );
      end
    end
  );

  MemoryCore:initializeSingletons();
  MemoryCore:printVersion();

  -- stores a symbolic memory (this is the first memory stored by the addon!)
  MemoryCore:getRepository():store( "misc", {}, "login" );

end

-- the main event frame used to trigger all the Memory listeners
MemoryEventFrame = CreateFrame( "Frame" );

-- registers the PLAYER_LOGIN event
MemoryEventFrame:RegisterEvent( "PLAYER_LOGIN" );

-- fires up the Memory addon when the player logs in
MemoryEventFrame:SetScript( "OnEvent",
  function( self, event, ... )

    if event == "PLAYER_LOGIN" then

      initializeCore();
    end
  end
);
