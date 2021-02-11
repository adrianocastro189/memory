--[[
The moment repository prototype.

Provides all read and write methods to manipulate the player moments.

@since 1.1.0
]]
MemoryAddon_MomentRepository = {};
MemoryAddon_MomentRepository.__index = MemoryAddon_MomentRepository;

--[[
Constructs a new instance of a moment repository.

@since 1.1.0

@return MemoryAddon_MomentRepository
]]
function MemoryAddon_MomentRepository:new()

  local instance = {};
  setmetatable( instance, MemoryAddon_MomentRepository );

  -- the name of the moments saved in the settings array
  instance.MOMENT_SETTINGS_NAME = 'moments';

  -- destroys the prototype, so instance will be unique
  MemoryAddon_MomentRepository = nil;

  return instance;
end
