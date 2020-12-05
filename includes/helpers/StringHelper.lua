--[[
The string helper prototype.

Provides helper methods to work with strings.

@since 0.6.0-alpha
]]
MemoryAddon_StringHelper = {};
MemoryAddon_StringHelper.__index = MemoryAddon_StringHelper;

--[[
Constructs a new instance of a string helper.

@since 0.6.0-alpha

@return MemoryAddon_StringHelper
]]
function MemoryAddon_StringHelper:new()

  local instance = {};
  setmetatable( instance, MemoryAddon_StringHelper );


  -- destroys the prototype, so instance will be unique
  MemoryAddon_StringHelper = nil;

  return instance;
end
