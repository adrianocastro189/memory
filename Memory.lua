--[[
Fires up the addon.

@since 0.1.0-alpha
]]
local function initializeCore()


  MemoryCore = {};

  -- The addon name
  MemoryCore.ADDON_NAME = "Memory"

  -- The addon version which is the same as the toc file
  MemoryCore.ADDON_VERSION = "0.1.0-alpha";


  --[[
  Initializes all the singleton instances in the MemoryCore object.

  @since 0.1.0-alpha
  ]]
  MemoryCore:initializeSingletons()

  end


  self:initializeSingletons();

end

-- The main event frame used to trigger all the Memory listeners
local MemoryEventFrame = CreateFrame( "Frame" );

-- Fires up the Memory addon when the player logs in
MemoryEventFrame:SetScript( "OnEvent",
  function( self, event, ... )

    if event == "PLAYER_LOGIN" then

      initializeCore();
    end
  end
);
