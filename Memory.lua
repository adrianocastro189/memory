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
  MemoryCore.ADDON_VERSION = "0.1.0-alpha";

  -- the pattern used to wrap strings in the addon highlight color
  MemoryCore.HIGHLIGHT_PATTERN = "\124cffffee77{0}\124r";


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


  MemoryCore:initializeSingletons();
  MemoryCore:printVersion();

end

-- the main event frame used to trigger all the Memory listeners
local MemoryEventFrame = CreateFrame( "Frame" );

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
