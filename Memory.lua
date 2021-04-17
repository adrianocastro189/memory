--[[
Fires up the addon.

@since 0.1.0-alpha
]]
local function MemoryAddon_initializeCore()

  -- initializes the memory data set that stores all the players memories
  if not MemoryAddon_DataSet then MemoryAddon_DataSet = {} end

  -- initializes the settings saved variable that stores all the players settings
  if not MemoryAddon_Settings then MemoryAddon_Settings = {} end

  MemoryCore = {};

  -- the addon name
  MemoryCore.ADDON_NAME = 'Memory';

  -- the addon version which is the same as the toc file
  MemoryCore.ADDON_VERSION = '1.1.1';

  -- the default hex color used highlight text
  MemoryCore.HIGHLIGHT_COLOR = 'ffee77';

  -- the ArrayHelper instance
  MemoryCore.arrayHelper = nil;

  -- the CompatibilityHelper instance
  MemoryCore.compatibilityHelper = nil;

  -- the DateHelper instance
  MemoryCore.dateHelper = nil;

  -- the memory event listeners that will add memories
  MemoryCore.eventListeners = {};

  -- the unique logger instance
  MemoryCore.logger = nil;

  -- the unique moment repository instance
  MemoryCore.momentRepository = nil;

  -- the unique repository instance
  MemoryCore.repository = nil;

  -- the unique settings repository instance
  MemoryCore.settingsRepository = nil;

  -- the StringHelper instance
  MemoryCore.stringHelper = nil;

  -- the tooltip controller
  MemoryCore.tooltipController = nil;


  --[[
  Attaches an event listener to the core.

  Listeners will be triggered by player actions in the game.

  @param MemoryAddon_MemoryEvent listener
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
  Gets the unique array helper instance.

  @since 0.4.0-alpha

  @return MemoryAddon_ArrayHelper
  ]]
  function MemoryCore:getArrayHelper()

    return self.arrayHelper;
  end


  --[[
  Gets the unique compatibility helper instance.

  @since 0.4.0-alpha

  @return MemoryAddon_CompatibilityHelper
  ]]
  function MemoryCore:getCompatibilityHelper()

    return self.compatibilityHelper;
  end


  --[[
  Gets the unique date helper instance.

  @since 0.6.0-beta

  @return MemoryAddon_DateHelper
  ]]
  function MemoryCore:getDateHelper()

    return self.dateHelper;
  end


  --[[
  Gets the unique logger helper instance.

  @since 1.0.0

  @return MemoryAddon_DateHelper
  ]]
  function MemoryCore:getLogger()

    return self.logger;
  end


  --[[
  Gets the unique moment repository instance.

  @since 1.1.0

  @return MemoryAddon_MomentRepository
  ]]
  function MemoryCore:getMomentRepository()

    return self.momentRepository;
  end


  --[[
  Gets the unique repository instance.

  @since 0.2.0-alpha

  @return MemoryAddon_MemoryRepository
  ]]
  function MemoryCore:getRepository()

    return self.repository;
  end


  --[[
  Gets the unique string helper instance.

  @since 0.6.0-beta

  @return MemoryAddon_StringHelper
  ]]
  function MemoryCore:getStringHelper()

    return self.stringHelper;
  end


  --[[
  Gets the unique tooltip controller instance.

  @since 1.1.0

  @return MemoryAddon_TooltipController
  ]]
  function MemoryCore:getTooltipController()

    return self.tooltipController;
  end


  --[[
  Highlights a string using the addon highlight color.

  @since 0.1.0-alpha

  @param string value
  @param string hexColor accept any hexadecimal color to override the default highlight color (optional)
  @return string
  ]]
  function MemoryCore:highlight( value, --[[optional]] hexColor )

    -- may use the default color if no hex color is informed
    hexColor = hexColor or MemoryCore.HIGHLIGHT_COLOR;

    return string.gsub( '\124cff' .. hexColor .. '{0}\124r', '{0}', value );
  end


  --[[
  Initializes all the singleton instances in the MemoryCore object.

  @since 0.1.0-alpha
  ]]
  function MemoryCore:initializeSingletons()

    self.arrayHelper         = MemoryAddon_ArrayHelper:new();
    self.compatibilityHelper = MemoryAddon_CompatibilityHelper:new();
    self.dateHelper          = MemoryAddon_DateHelper:new();
    self.logger              = MemoryAddon_LoggerHelper:new();
    self.momentRepository    = MemoryAddon_MomentRepository:new();
    self.repository          = MemoryAddon_MemoryRepository:new( UnitGUID( 'player' ), GetRealmName() );
    self.settingsRepository  = MemoryAddon_SettingsRepository:new();
    self.stringHelper        = MemoryAddon_StringHelper:new();
    self.tooltipController   = MemoryAddon_TooltipController:new();
  end


  --[[
  Prints a string in the default chat frame with the highlighted addon name as the prefix.

  @since 0.1.0-alpha

  @param string value
  @param string prefix (optional)
  ]]
  function MemoryCore:print( value, --[[optional]] prefix )

    -- creates a default prefix if not informed
    local prefix = prefix or MemoryCore:highlight( '<' .. MemoryCore.ADDON_NAME .. '>' );

    DEFAULT_CHAT_FRAME:AddMessage( prefix .. ' ' .. value );
  end


  --[[
  Prints the Memory addon version number.

  @since 0.1.0-alpha
  ]]
  function MemoryCore:printVersion()

    MemoryCore:print( MemoryCore.ADDON_VERSION );
  end


  --[[
  Gets or sets a setting value.

  @since 1.0.0

  @param string key setting's key
  @param mixed value the value to be set (optional)
  @param bool override whether to replace the current value (optional)
  @return mixed
  ]]
  function MemoryCore:setting( key, --[[optional]] default, --[[optional]] override )

    if override then return self.settingsRepository:set( key, default ); end

    return self.settingsRepository:get( key, default );
  end


  --[[
  Dispatch every registered events to the registered listeners.

  @since 0.3.0-alpha
  ]]
  MemoryEventFrame:SetScript( 'OnEvent',
    function( self, event, ... )

      -- This weird code below was the only way I found to convert ... to an array
      local params = {}; local param = nil; local counter = 1; repeat
        param = select(counter, ...);

        if nil ~= param then table.insert(params, param); end

        counter = counter + 1;
      until param == nil;

      for i, listener in ipairs( MemoryCore.eventListeners ) do

        -- dispatch the event to a listener
        listener:maybeTrigger( event, params );
      end
    end
  );

  MemoryCore:initializeSingletons();
  MemoryCore:printVersion();

  -- adds the memory prototype to the repository
  MemoryAddon_addMemoryPrototype( MemoryCore.repository );

  -- adds the memory prototype to the repository
  MemoryAddon_addMemoryStringPrototype( MemoryCore.repository );

  -- adds the memory text formatter prototype to core
  MemoryAddon_addMemoryTextFormatterPrototype( MemoryCore );

  -- adds the player prototype to core
  MemoryAddon_addPlayerPrototype( MemoryCore );

  -- will add all event listeners to this core instance
  MemoryAddon_addEvents( MemoryCore );

  -- stores a symbolic memory (this is the first memory stored by the addon!)
  MemoryCore:getRepository():store( 'misc', {}, 'login' );

  -- prints a debug message confirming the end of the initialization
  MemoryCore:getLogger():debug( 'MemoryCore initialized' );
end

-- the main event frame used to trigger all the Memory listeners
MemoryEventFrame = CreateFrame( 'Frame' );

-- registers the PLAYER_LOGIN event
MemoryEventFrame:RegisterEvent( 'PLAYER_LOGIN' );

-- fires up the Memory addon when the player logs in
MemoryEventFrame:SetScript( 'OnEvent',
  function( self, event, ... )

    if event == 'PLAYER_LOGIN' then

      MemoryAddon_initializeCore();
    end
  end
);
