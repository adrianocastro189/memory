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
  Sets a setting value.

  @since 1.0.0

  @param string key setting's key
  @param mixed value the value to be set
  @return mixed
  ]]
  function instance:set( key, value )

    MemoryAddon_Settings[ key ] = value;

    return value;
  end

  --[[
  Gets or sets a setting value.

  @since 1.0.0

  @param string key setting's key
  @param string value the value to be set (optional)
  @return mixed
  ]]
  function instance:value( key, --[[optional]] value )

    -- sets the setting if value is informed
    if nil ~= value and nil == MemoryAddon_Settings[ key ] then MemoryAddon_Settings[ key ] = value; end

    return MemoryAddon_Settings[ key ];
  end


  -- destroys the prototype, so instance will be unique
  MemoryAddon_SettingsRepository = nil;

  return instance;
end
