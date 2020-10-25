--[[
The event handler that captures players actions and stores memories from them.

@since 0.3.0-alpha
]]
MemoryEvent = {};
MemoryEvent.__index = MemoryEvent;

--[[
Constructs a new instance of a memory event.

@since 0.3.0-alpha

@param string name
@param string[] events
@param callable action
]]
function MemoryEvent:new( name, events, action )

  local instance = {};
  setmetatable( instance, MemoryEvent );
  instance.name   = name;
  instance.events = events;
  instance.action = action;


  --[[
  Prints a debug message for the specific event.

  @since 0.4.0-alpha

  @param string message
  ]]
  function instance:debug( message )

    MemoryCore:debug( "[" .. self.name .. "] " .. message );
  end


  --[[
  Checks if the current instance triggers for the given event and call the action.

  @since 0.3.0-alpha

  @param string event
  @param string[] params
  ]]
  function instance:maybeTrigger( event, params )

    for i, value in ipairs( self.events ) do

      if value == event then

        -- calls the event action
        self:action( params );
        return;
      end
    end
  end

  return instance;
end
