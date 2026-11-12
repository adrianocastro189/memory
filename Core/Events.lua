--[[
A private event bus on a single frame.

- Registration is gated: events the client doesn't know (for example
  ACHIEVEMENT_EARNED on a client without achievements) or events addons may
  not register (COMBAT_LOG_EVENT_UNFILTERED on the Midnight engine) return
  false instead of raising, so the feature that needed them is disabled
  quietly.
- Each handler runs protected. An error in one tracker is reported through the
  client's error handler (BugSack/BugGrabber pick it up) and does not stop the
  other handlers.
]]
local _, ns = ...

local Events = {}
ns.Events = Events

local handlers = {}
local frame = CreateFrame('Frame')

local function report(err)
  local handler = geterrorhandler and geterrorhandler()
  if handler then
    handler(err)
  else
    ns.print('Error: ' .. tostring(err))
  end
end
Events.report = report

--[[
Whether the client knows about an event.
]]
function Events.isValid(event)
  if C_EventUtils and type(C_EventUtils.IsEventValid) == 'function' then
    local ok, valid = pcall(C_EventUtils.IsEventValid, event)
    if ok then return valid == true end
  end
  return true
end

--[[
Subscribes a handler(event, ...) to an event. Returns false when the event
cannot be registered on this client.
]]
function Events.on(event, handler)
  if not handlers[event] then
    if not Events.isValid(event) then return false end
    local ok = pcall(frame.RegisterEvent, frame, event)
    if not ok then return false end
    handlers[event] = {}
  end
  table.insert(handlers[event], handler)
  return true
end

function Events.isRegistered(event)
  return handlers[event] ~= nil
end

--[[
Dispatches an event to its handlers. Exposed so other modules (and tests) can
re-dispatch synthetic events.
]]
function Events.dispatch(event, ...)
  local list = handlers[event]
  if not list then return end
  for i = 1, #list do
    local ok, err = pcall(list[i], event, ...)
    if not ok then report(err) end
  end
end

frame:SetScript('OnEvent', function(_, event, ...)
  Events.dispatch(event, ...)
end)

--[[
Runs a function after a delay (C_Timer when available, immediately otherwise).
]]
function Events.after(seconds, fn)
  local wrapped = function()
    local ok, err = pcall(fn)
    if not ok then report(err) end
  end
  if C_Timer and type(C_Timer.After) == 'function' then
    C_Timer.After(seconds, wrapped)
  else
    wrapped()
  end
end

function Events.now()
  if type(GetTime) == 'function' then return GetTime() end
  return time()
end
