--[[
The date helper prototype.

Provides helper methods to work with dates.

@since 0.6.0-alpha
]]
MemoryAddon_DateHelper = {};
MemoryAddon_DateHelper.__index = MemoryAddon_DateHelper;

--[[
Constructs a new instance of an date helper.

@since 0.6.0-alpha

@return MemoryAddon_DateHelper
]]
function MemoryAddon_DateHelper:new()

  local instance = {};
  setmetatable( instance, MemoryAddon_DateHelper );


  -- destroys the prototype, so instance will be unique
  MemoryAddon_DateHelper = nil;

  return instance;
end
