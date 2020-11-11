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
@param callable action a callable function that must accept two params {
  @param string event
  @param string[] params
}
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
  Prints a debug message to indicate that the event won't store memories.

  @since 0.4.0-alpha

  @param string message
  @return int a symbolic value to indicate an exit
  ]]
  function instance:debugAndExit( message )

    self:debug( '\124cffff0000[E]\124r ' .. message );

    return -1;
  end


  --[[
  Checks if the current instance triggers for the given event and call the action.

  @since 0.3.0-alpha

  @param string event
  @param string[] params
  ]]
  function instance:maybeTrigger( event, params )

    if MemoryCore:getArrayHelper():inArray( event, self.events ) then

        self:debug( "Event " .. event .. " matched, calling action" );

        -- calls the event action
        self.action( self, event, params );
    end
  end


  -- prints a debug message after initializing the event
  instance:debug( "Event created" );

  return instance;
end


--[[
Destroys the MemoryEvent prototype to prevent it from being exposed after core's initialization.

@since 0.4.0-alpha
]]
function MemoryEvent:destroyPrototype()

  MemoryEvent = nil;
end
