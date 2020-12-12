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

  instance.LEVEL_DEBUG =  0;
  instance.LEVEL_INFO  = 10;
  instance.LEVEL_WARN  = 20;
  instance.LEVEL_ERROR = 30;
  instance.LEVEL_OFF   = 40;

  -- current log level
  instance.logLevel = instance.LEVEL_DEBUG;

  -- destroys the prototype, so instance will be unique
  MemoryAddon_LoggerHelper = nil;

  return instance;
end
