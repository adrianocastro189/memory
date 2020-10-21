--[[
The event handler that captures players actions and stores memories from them.

@since 0.3.0-alpha
]]
MemoryEvent = {};
MemoryEvent.__index = MemoryEvent;

--[[
Constructs a new instance of a memory event.

@since 0.3.0-alpha

@param string[] events
@param callable action
]]
function MemoryEvent:new( events, action )

  local instance = {};
  setmetatable( instance, MemoryEvent );
  instance.events = events;
  instance.action = action;


end
