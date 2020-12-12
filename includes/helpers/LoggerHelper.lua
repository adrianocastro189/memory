--[[
The logger helper prototype.

Provides helper methods to log and debug.

@since 1.0.0
]]
MemoryAddon_LoggerHelper = {};
MemoryAddon_LoggerHelper.__index = MemoryAddon_LoggerHelper;

--[[
Constructs a new instance of a logger helper.

@since 1.0.0

@return MemoryAddon_LoggerHelper
]]
function MemoryAddon_LoggerHelper:new()

  local instance = {};
  setmetatable( instance, MemoryAddon_LoggerHelper );


  -- destroys the prototype, so instance will be unique
  MemoryAddon_LoggerHelper = nil;

  return instance;
end
