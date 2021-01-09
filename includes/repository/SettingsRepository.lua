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

  -- destroys the prototype, so instance will be unique
  MemoryAddon_SettingsRepository = nil;

  return instance;
end
