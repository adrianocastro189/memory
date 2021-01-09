--[[
The settings repository prototype.

Provides all read and write methods to manipulate the player settings.

@since 1.0.0
]]
MemoryAddon_SettingsRepository = {};
MemoryAddon_SettingsRepository.__index = MemoryAddon_SettingsRepository;

--[[
Constructs a new instance of a settings repository.

@since 1.0.0

@return MemoryAddon_SettingsRepository
]]
function MemoryAddon_SettingsRepository:new()

  local instance = {};
  setmetatable( instance, MemoryAddon_SettingsRepository );


  --[[
  Inserts a setting value.

  @since 1.0.0

  @param string key setting's key using the dot-notation
  @param string value the value to be set
  ]]
  function instance:insert( key, value )

    -- will allow the algorithm to access nested settings
    settingsAux = MemoryAddon_Settings;

    -- walks through the settings saved variable
    for part in string.gmatch(key, '[^%.]+') do

      -- creates a new setting path if it doesn't exist yet
      if nil == settingsAux[ part ] then settingsAux[ part ] = {}; end

      settingsAux = settingsAux[ part ];
    end

    -- inserts the value in the correct index
    table.insert( settingsAux, value );
  end


  -- destroys the prototype, so instance will be unique
  MemoryAddon_SettingsRepository = nil;

  return instance;
end
