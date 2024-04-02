
if (StormwindLibrary_v0_0_8) then return end
        
StormwindLibrary_v0_0_8 = {}
StormwindLibrary_v0_0_8.__index = StormwindLibrary_v0_0_8

function StormwindLibrary_v0_0_8.new(props)
    local self = setmetatable({}, StormwindLibrary_v0_0_8)
    -- Library version = '0.0.8'

--[[
The Arr support class contains helper functions to manipulate arrays.
]]
local Arr = {}
    Arr.__index = Arr
    Arr.__ = self

    --[[
    Gets a value in an array using the dot notation.

    With the dot notation search, it's possible to query a value in a multidimensional array
    by passing a single string containing keys separated by dot.
    ]]
    function Arr:get(list, key, default)
        local keys = self.__.str:split(key, '.')
        local current = list[keys[1]]

        for i = 2, #keys do current = current and current[keys[i]] or nil end

        return current or default
    end

    --[[
    Combines the elements of a table into a single string, separated by a
    specified delimiter.

    @tparam string the delimiter used to separate the elements in the resulting string
    @tparam array the table containing elements to be combined into a string

    @treturn string
    ]]
    function Arr:implode(delimiter, list)
        if not (self:isArray(list)) then
            return list
        end

        return table.concat(list, delimiter)
    end

    --[[
    Determines whether a value is in an array.

    If so, returns true and the index, false and 0 otherwise.

    Class instances can also be checked in this method, not only primitive
    types, as long as they implement the __eq method.

    @treturn boolean, int
    ]]
    function Arr:inArray(list, value)
        local results = {}

        for i, val in pairs(list) do
            if val == value then
                return true, i
            end
        end

        return false, 0
    end

    --[[
    Inserts a value in an array if it's not in the array yet.

    It's important to mention that this method only works for arrays with
    numeric indexes. After all, if using string keys, there's no need to check,
    but only setting and replacing the value.

    Class instances can also be passed as the value, not only primitive types,
    as long as they implement the __eq method.
    ]]
    function Arr:insertNotInArray(list, value)
        if not self:isArray(list) or self:inArray(list, value) then
            return false
        end

        table.insert(list, value)
        return true
    end

    --[[
    Determines whether the value is an array or not.

    The function checks whether the parameter passed is a table in Lua.
    If it is, it iterates over the table's key-value pairs, examining each key
    to determine if it is numeric. If all keys are numeric, indicating an
    array-like structure, the function returns true; otherwise, it returns
    false.

    This strategy leverages Lua's type checking and table iteration
    capabilities to ascertain whether the input value qualifies as an array.

    @return boolean
    ]]
    function Arr:isArray(value)
        if type(value) == "table" then
            local isArray = true
            for k, v in pairs(value) do
                if type(k) ~= "number" then
                    isArray = false
                    break
                end
            end
            return isArray
        end
        return false
    end

    --[[
    Iterates over the list values and calls the callback function in the second
    argument for each of them.

    The callback function must be a function that accepts (val) or (val, i)
    where val is the object in the interaction and i it's index.

    This method accepts arrays and tables.
    ]]
    function Arr:map(list, callback)
        local results = {}

        for i, val in pairs(list) do results[i] = callback(val, i) end

        return results
    end

    --[[
    Initializes a value in a table if it's not initialized yet.

    The key accepts a dot notation key just like get() and set().
    ]]
    function Arr:maybeInitialize(list, key, initialValue)
        if self:get(list, key) == nil then self:set(list, key, initialValue) end
    end

    --[[
    Extracts a list of values from a list of objects based on a given key.

    It's important to mention that nil values won't be returned in the
    resulted list. Which means: objects that have no property or when their
    properties are nil, the values won't be returned. That said, a list with n
    items can return a smaller list.

    The key accepts a dot notation key just like get() and set().
    ]]
    function Arr:pluck(list, key)
        local results = {}
        for _, item in ipairs(list) do
            table.insert(results, self:get(item, key))
        end
        return results
    end

    --[[
    Removes a value from an indexed array.

    Tables with non numeric keys won't be affected by this method.

    The value must be the value to be removed and not the index.
    ]]
    function Arr:remove(list, value)
        if not self:isArray(list) then return false end

        local found, index = self:inArray(list, value)

        if not found then return false end

        table.remove(list, index)
        return true
    end

    --[[
    Sets a value using arrays dot notation.

    It will basically iterate over the keys separated by "." and create
    the missing indexes, finally setting the last key with the value in
    the args list.
    ]]
    function Arr:set(list, key, value)
        local keys = self.__.str:split(key, '.')
        local current = list

        for i = 1, #keys do
            local key = keys[i]

            if i == #keys then
                -- this is the last key, so just the value and return
                current[key] = value
                return
            end

            -- creates an empty table
            if current[key] == nil then current[key] = {} end
            
            -- sets the "pointer" for the next iteration
            current = current[key]
        end
    end

    --[[
    Calls the available unpack() method given the running environment.

    This method is an important helper because World of Warcraft supports
    the unpack() function but not table.unpack(). At the same time, some
    Lua installations have no unpack() but table.unpack().

    @codeCoverageIgnore this method is just a facade to the proper unpack
                        method and won't be tested given that it's tied to
                        the running environment
    ]]
    function Arr:unpack(list, i, j)
        if unpack then return unpack(list, i, j) end

        return table.unpack(list, i, j)
    end

    --[[
    Wraps a value in a table.

    This method is very useful for methods that accept objects and arrays
    on the same variable. That way, they don't need to check the type, but
    wrap it and work with an array.

    If the value provided is a table, this method won't result in a
    bidimensional table, but will return the table itself.

    @treturn array|table
    ]]
    function Arr:wrap(value)
        if type(value) == 'table' then return value end

        return {value}
    end
-- end of Arr

self.arr = Arr
--[[
The Bool support class contains helper functions to manipulate boolean
values.
]]
local Bool = {}
    Bool.__index = Bool
    Bool.__ = self

    --[[
    Determines whether a value represents true or not.

    This method checks if a value is in a range of possible values that
    represent a true value.

    @tparam mixed value

    @treturn bool
    ]]
    function Bool:isTrue(value)
        return self.__.arr:inArray({1, "1", "true", true, "yes"}, value)
    end
-- end of Bool

self.bool = Bool
--[[
The Str support class contains helper functions to manipulate strings.
]]
local Str = {}
    Str.__index = Str

    --[[
    Determines whether a string is empty or not.

    By empty, it means that the string is nil, has no characters, or has only
    whitespace characters. This last case is important because a string with
    only whitespace characters is not considered empty by Lua's standards,
    but it is by this function's standards.

    If a method shouldn't consider a string with only whitespace characters
    as empty, please do not use this function.
        
    @tparam string value

    @treturn bool
    ]]
    function Str:isEmpty(value)
        return value == nil or (string.len(self:trim(value)) == 0)
    end

    --[[
    Determines whether a string is not empty.

    This function is the opposite of Str:isEmpty.

    @tparam string value

    @treturn bool
    ]]
    function Str:isNotEmpty(value)
        return not self:isEmpty(value)
    end

    --[[
    Determines whether a string is wrapped by a prefix and a suffix.

    This function is useful to determine if a string is wrapped by a pair of
    strings, like quotes, parentheses, brackets, etc.

    The third parameter is optional. If it is not provided, the function will
    assume that the prefix and suffix are the same.

    Finally, this function will return true if the string contains only the
    prefix and suffix, like "", "()", "[]", etc. That would mean that an
    empty string is considered wrapped by something.

    @tparam string value
    @tparam string wrapper
    @tparam string endWrapper, optional

    @treturn bool
    ]]
    function Str:isWrappedBy(value, wrapper, endWrapper)
        endWrapper = endWrapper or wrapper

        return
            (value ~= nil) and
            (wrapper ~= nil) and
            (value ~= wrapper) and
            (value:sub(1, #wrapper) == wrapper and value:sub(-#endWrapper) == endWrapper)
    end

    --[[
    Removes the wrapping strings from a string.

    This function is useful to remove quotes, parentheses, brackets, etc,
    from a string.

    Similarly to Str:isWrappedBy, the third parameter is optional. If it is
    not provided, the function will assume that the prefix and suffix are
    the same.

    @tparam string value
    @tparam string wrapper
    @tparam string endWrapper, optional

    @treturn string
    ]]
    function Str:removeWrappers(value, wrapper, endWrapper)
        return self:isWrappedBy(value, wrapper, endWrapper)
            and value:sub(#wrapper + 1, -#(endWrapper or wrapper) - 1)
            or value
    end

    --[[
    Replaces all occurrences of a substring in a string with another
    substring.

    This function does not support regular expressions. If regular
    expressions are needed, please use Lua's string.gsub function. It was
    created for the convenience of allowing quick replacements that also
    accept characters like ".", "(", "[", etc, that would be interpreted as
    regular expressions metacharacters.

    @tparam string value
    @tparam string find
    @tparam string replace
    ]]
    function Str:replaceAll(value, find, replace)
        return (value:gsub(find:gsub("[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1"), replace))
    end

    --[[
    Splits a string in a table by breaking it where the separator is found.

    @tparam string value
    @tparam string separator

    @treturn table
    ]]
    function Str:split(value, separator)
        local values = {}
        for str in string.gmatch(value, "([^"..separator.."]+)") do
            table.insert(values, str)
        end
        return values
    end

    --[[
    Removes all whitespace from the beginning and end of a string.

    @tparam string value

    @treturn string
    ]]
    function Str:trim(value)
        return value and value:gsub("^%s*(.-)%s*$", "%1") or value
    end
-- end of Str

self.str = Str

--[[
Sets the addon properties.

Allowed properties = {
    colors: table, optional
        primary: string, optional
        secondary: string, optional
    command: string, optional
    name: string, optional
}
]]
self.addon = {}

self.addon.colors  = self.arr:get(props or {}, 'colors', {})
self.addon.command = self.arr:get(props or {}, 'command')
self.addon.name    = self.arr:get(props or {}, 'name')

local requiredProperties = {
    'name'
}

for _, property in ipairs(requiredProperties) do
    if not self.addon[property] then
        error(string.format('The addon property "%s" is required to initialize Stormwind Library.', property))
    end
end
--[[
Contains a list of classes that can be instantiated by the library.
]]
self.classes = {}

--[[
Registers a class so the library is able to instantiate it later.

This method's the same as updating self.classes.
]]
function self:addClass(classname, classStructure)
    self.classes[classname] = classStructure
end

--[[
This method emulates the new keyword in OOP languages by instantiating a
class by its name as long as the class has a __construct() method with or
without parameters.
]]
function self:new(classname, ...)
    return self.classes[classname].__construct(...)
end
--[[
The output structure controls everything that can be printed
in the Stormwind Library and also by the addons.
]]
local Output = {}
    Output.__index = Output
    Output.__ = self

    --[[
    Output constructor.
    ]]
    function Output.__construct()
        return setmetatable({}, Output)
    end

    --[[
    Colors a string with a given color according to how
    World of Warcraft handles colors in the chat and output.

    This method first looks for the provided color, if it's not
    found, it will use the primary color from the addon properties.
    And if the primary color is not found, it won't color the string,
    but return it as it is.

    @tparam string value
    @tparam string color
    @treturn string
    ]]
    function Output:color(value, --[[optional]] color)
        color = color or self.__.addon.colors.primary

        return color and string.gsub('\124cff' .. string.lower(color) .. '{0}\124r', '{0}', value) or value
    end

    --[[
    Formats a standard message with the addon name to be printed.

    @tparam string message
    ]]
    function Output:getFormattedMessage(message)
        local coloredAddonName = self:color(self.__.addon.name .. ' | ')

        return coloredAddonName .. message
    end

    --[[
    This is the default printing method for the output structure.
    
    Although there's a print() method in the output structure, it's
    recommended to use this method instead, as it will format the
    message with the addon name and color it according to the
    primary color from the addon properties.

    This method accepts a string or an array. If an array is passed
    it will print one line per value.

    @tparam array|string message
    ]]
    function Output:out(messages)
        for i, message in ipairs(self.__.arr:wrap(messages)) do
            self:print(self:getFormattedMessage(message))
        end
    end

    --[[
    Prints a message using the default Lua output resource.
    ]]
    function Output:print(message)
        print(message)
    end
-- end of Output

-- sets the unique library output instance
self.output = Output.__construct()

-- allows Output to be instantiated, very useful for testing
self:addClass('Output', Output)

--[[
The command class represents a command in game that can be executed with
/commandName.

Commands in the Stormwind Library are structured in two parts being:

1. The command operation
2. The command arguments

That said, a command called myAddonCommand that shows its settings screen
in dark mode would be executed with /myAddonCommand show darkMode.
]]
local Command = {}
    Command.__index = Command
    Command.__ = self
    self:addClass('Command', Command)

    --[[
    Command constructor.
    ]]
    function Command.__construct()
        return setmetatable({}, Command)
    end

    --[[
    Returns a human readable help content for the command.

    @treturn string
    ]]
    function Command:getHelpContent()
        local content = self.operation

        if self.description then
            content = content .. ' - ' .. self.description
        end

        return content
    end

    --[[
    Sets the command description.

    @return self
    ]]
    function Command:setDescription(description)
        self.description = description
        return self
    end

    --[[
    Sets the command operation.

    @return self
    ]]
    function Command:setOperation(operation)
        self.operation = operation
        return self
    end

    --[[
    Sets the command callback.

    @return self
    ]]
    function Command:setCallback(callback)
        self.callback = callback
        return self
    end
-- end of Command
--[[
The commands handler provides resources for easy command registration,
listening and triggering.
]]
local CommandsHandler = {}
    CommandsHandler.__index = CommandsHandler
    CommandsHandler.__ = self

    --[[
    CommandsHandler constructor.
    ]]
    function CommandsHandler.__construct()
        local self = setmetatable({}, CommandsHandler)

        self.operations = {}
        self:addHelpOperation()

        return self
    end

    --[[
    Adds a command that will be handled by the library.

    The command must have an operation and a callback.

    It's important to mention that calling this method with two commands
    sharing the same operation won't stack two callbacks, but the second
    one will replace the first.
    ]]
    function CommandsHandler:add(command)
        self.operations[command.operation] = command
    end

    --[[
    This method adds a help operation to the commands handler.

    The help operation is a default operation that can be overridden in
    case the addon wants to provide a custom help command. For that, just
    add a command with the operation "help" and a custom callback.

    When the help operation is not provided, a simple help command is
    printed to the chat frame with the available operations and their
    descriptions, when available.
    ]]
    function CommandsHandler:addHelpOperation()
        local helpCommand = self.__:new('Command')

        helpCommand:setOperation('help')
        helpCommand:setDescription('Shows the available operations for this command.')
        helpCommand:setCallback(function () self:printHelp() end)

        self:add(helpCommand)
    end

    --[[
    Builds a help content that lists all available operations and their
    descriptions.
    
    @NOTE: The operations are sorted alphabetically and not in the order they were added.
    @NOTE: The "help" operation is not included in the help content.
    
    @treturn array<string>
    ]]
    function CommandsHandler:buildHelpContent()
        local contentLines = {}
        self.__.arr:map(self.operations, function (command)
            if command.operation == 'help' then return end

            local fullCommand = self.slashCommand .. ' ' .. command:getHelpContent()

            table.insert(contentLines, fullCommand)
        end)

        if #contentLines > 0 then
            table.sort(contentLines)
            table.insert(contentLines, 1, 'Available commands:')
        end

        return contentLines
    end

    --[[
    This method is responsible for handling the command that was triggered
    by the user, parsing the arguments and invoking the callback that was
    registered for the operation.
    ]]
    function CommandsHandler:handle(commandArg)
        self:maybeInvokeCallback(
            self:parseOperationAndArguments(
                self:parseArguments(commandArg)
            )
        )
    end

    --[[
    This method is responsible for invoking the callback that was registered
    for the operation, if it exists.
    
    @codeCoverageIgnore this method's already tested by the handle() test method
    ]]
    function CommandsHandler:maybeInvokeCallback(operation, args)
        -- @TODO: Call a default callback if no operation is found <2024.03.18>
        if not operation then return end

        local command = self.operations[operation]
        local callback = command and command.callback or nil

        if callback then
            callback(self.__.arr:unpack(args))
        end
    end

    --[[
    This function is responsible for breaking the full argument word that's
    sent by World of Warcraft to the command callback.

    When a command is executed, everything after the command itself becomes
    the argument. Example: /myCommand arg1 arg2 arg3 will trigger the
    callback with "arg1 arg2 arg3".

    The Stormwind Library handles events like a OS console where arguments
    are separated by blank spaces. Arguments that must contain spaces can
    be wrapped by " or '. Example: /myCommand arg1 "arg2 arg3" will result
    in {'arg1', 'arg2 arg3'}.

    Limitations in this method: when designed, this method meant to allow
    escaping quotes so arguments could contain those characters. However,
    that would add more complexity to this method and its first version is
    focused on simplicity.

    Notes: the algorithm in this method deserves improvements, or even some
    handling with regular expression. This is something that should be
    revisited in the future and when updated, make sure
    TestCommandsHandler:testGetCommandsHandler() tests pass.
    ]]
    function CommandsHandler:parseArguments(input)
        if not input then return {} end

        local function removeQuotes(value)
            return self.__.str:replaceAll(self.__.str:replaceAll(value, "'", ''), '"', '')
        end

        local result = {}
        local inQuotes = false
        local currentWord = ""
        
        for i = 1, #input do
            local char = input:sub(i, i)
            if char == '"' or char == "'" then
                inQuotes = not inQuotes
                currentWord = currentWord .. char
            elseif char == " " and not inQuotes then
                if currentWord ~= "" then
                    table.insert(result, removeQuotes(currentWord))
                    currentWord = ""
                end
            else
                currentWord = currentWord .. char
            end
        end
        
        if currentWord ~= "" then
            table.insert(result, removeQuotes(currentWord))
        end
        
        return result
    end

    --[[
    This method selects the first command argument as the operation and the
    subsequent arguments as the operation arguments.

    Note that args can be empty, so there's no operation and no arguments.

    Still, if the size of args is 1, it means there's an operation and no
    arguments. If the size is greater than 1, the first argument is the
    operation and the rest are the arguments.
    ]]
    function CommandsHandler:parseOperationAndArguments(args)
        if not args or #args == 0 then
            return nil, {}
        elseif #args == 1 then
            return args[1], {}
        else
            -- the subset of the args table from the second element to the last
            -- represents the arguments
            return args[1], {self.__.arr:unpack(args, 2)}
        end
    end

    --[[
    Prints the help content to the chat frame.
    ]]
    function CommandsHandler:printHelp()
        local helpContent = self:buildHelpContent()

        if helpContent and (#helpContent > 0) then self.__.output:out(helpContent) end
    end

    --[[
    Register the main Stormwind Library command callback that will then redirect
    the command to the right operation callback.

    In terms of how the library was designed, this is the only real command
    handler and serves as a bridge between World of Warcraft command system
    and the addon itself.
    ]]
    function CommandsHandler:register()
        if (not SlashCmdList) or (not self.__.addon.command) then return end

        local lowercaseCommand = string.lower(self.__.addon.command)
        local uppercaseCommand = string.upper(self.__.addon.command)

        -- stores a global reference to the addon command
        self.slashCommand = '/' .. lowercaseCommand

        _G['SLASH_' .. uppercaseCommand .. '1'] = self.slashCommand
        SlashCmdList[uppercaseCommand] = function (args)
            self:handle(args)
        end
    end
-- end of CommandsHandler

-- sets the unique library commands handler instance
self.commands = CommandsHandler.__construct()
self.commands:register()

-- allows CommandHandler to be instantiated, very useful for testing
self:addClass('CommandsHandler', CommandsHandler)

--[[
The Events class is a layer between World of Warcraft events and events
triggered by the Stormwind Library.

When using this library in an addon, it should focus on listening to the
library events, which are more detailed and have more mapped parameters.
]]
local Events = {}
    Events.__index = Events
    Events.__ = self
    self:addClass('Events', Events)

    --[[
    Events constructor.
    ]]
    function Events.__construct()
        local self = setmetatable({}, Events)

        -- a set of properties to store the current state of the events
        self.eventStates = {}

        -- the list of addon listeners to Stormwind Library events
        self.listeners = {}

        -- the list of library listeners to World of Warcraft events
        self.originalListeners = {}

        self:createFrame()

        return self
    end

    --[[
    Creates the events frame, which will be responsible for capturing
    all World of Warcraft events and forwarding them to the library
    handlers.
    ]]
    function Events:createFrame()
        self.eventsFrame = CreateFrame('Frame')
        self.eventsFrame:SetScript('OnEvent', function (source, event, ...)
            self:handleOriginal(source, event, ...)
        end)
    end

    --[[
    This is the main event handler method, which will capture all
    subscribed World of Warcraft events and forwards them to the library
    handlers that will later notify other subscribers.

    It's important to mention that addons shouldn't care about this
    method, which is an internal method to the Events class.
    ]]
    function Events:handleOriginal(source, event, ...)
        local callback = self.originalListeners[event]

        if callback then
            callback(...)
        end
    end

    --[[
    Listens to a Stormwind Library event.

    This method is used by addons to listen to the library events.

    @tparam string event The Stormwind Library event to listen to
    @tparam function callback The callback to be called when the event is triggered
    ]]
    function Events:listen(event, callback)
        -- initializes the event listeners array, if not already initialized
        self.__.arr:maybeInitialize(self.listeners, event, {})

        table.insert(self.listeners[event], callback)
    end

    --[[
    Sets the Events Frame to listen to a specific event and also store the
    handler callback to be called when the event is triggered.

    It's important to mention that addons shouldn't care about this
    method, which is an internal method to the Events class.

    @tparam string event The World of Warcraft event to listen to
    @tparam function callback The callback to be called when the event is triggered
    ]]
    function Events:listenOriginal(event, callback)
        self.eventsFrame:RegisterEvent(event)
        self.originalListeners[event] = callback
    end

    --[[
    Notifies all listeners of a specific event.

    This method should be called by event handlers to notify all listeners
    of a specific Stormwind Library event.
    ]]
    function Events:notify(event, ...)
        local params = ...

        local listeners = self.__.arr:get(self.listeners, event, {})

        self.__.arr:map(listeners, function (listener)
            listener(params)
        end)
    end
-- end of Events

self.events = self:new('Events')
local events = self.events

-- the Stormwind Library event triggered when a player logs in
events.EVENT_NAME_PLAYER_LOGIN = 'PLAYER_LOGIN'

-- handles the World of Warcraft PLAYER_LOGIN event
events:listenOriginal('PLAYER_LOGIN', function ()
    events:notify(events.EVENT_NAME_PLAYER_LOGIN)
end)
local events = self.events

-- it's safe to announce that the event states are false here, given
-- that when the player logs in or /reload the game, the target is cleared
events.eventStates.playerHadTarget = false

-- the Stormwind Library event triggered when the player targets a unit
events.EVENT_NAME_PLAYER_TARGET = 'PLAYER_TARGET'

-- the Stormwind Library event triggered when the player target changes
events.EVENT_NAME_PLAYER_TARGET_CHANGED = 'PLAYER_TARGET_CHANGED'

-- the Stormwind Library event triggered when the player clears the target
events.EVENT_NAME_PLAYER_TARGET_CLEAR = 'PLAYER_TARGET_CLEAR'

--[[
Listens to the World of Warcraft PLAYER_TARGET_CHANGED event, which is
triggered when the player changes the target.

This method breaks the event into three different events:

- PLAYER_TARGET: triggered when the player targets a unit
- PLAYER_TARGET_CHANGED: triggered when the player target changes
- PLAYER_TARGET_CLEAR: triggered when the player clears the target

To achieve this, a pleyerHadTarget event state is used to keep track of
whether the player had a target or not when the World of Warcraft event
was captured.

When the player had no target and the event was captured, the
PLAYER_TARGET is triggered, meaning that player now targetted a unit.

When the player had a target, the event was captured and the player still
had a target, the PLAYER_TARGET_CHANGED is triggered, meaning that it was
changed.

Finally, when the player had a target and the event was captured, but the
player no longer has a target, the PLAYER_TARGET_CLEAR is triggered.
]]
function Events:playerTargetChangedListener()
    if self.eventStates.playerHadTarget then
        if self.__.target:hasTarget() then
            self:notify(self.EVENT_NAME_PLAYER_TARGET_CHANGED)
            return
        else
            self:notify(self.EVENT_NAME_PLAYER_TARGET_CLEAR)
            self.eventStates.playerHadTarget = false
            return
        end
    else
        self:notify(self.EVENT_NAME_PLAYER_TARGET)
        self.eventStates.playerHadTarget = true
    end
end

-- listens to the World of Warcraft PLAYER_TARGET_CHANGED event
events:listenOriginal('PLAYER_TARGET_CHANGED', function ()
    events:playerTargetChangedListener()
end)
--[[
The target facade maps all the information that can be retrieved by the
World of Warcraft API target related methods.

This class can also be used to access the target with many other purposes,
like setting the target marker.
]]
local Target = {}
    Target.__index = Target
    Target.__ = self
    self:addClass('Target', Target)

    --[[
    Target constructor.
    ]]
    function Target.__construct()
        return setmetatable({}, Target)
    end

    --[[
    Gets the target GUID.
    ]]
    function Target:getGuid()
        return UnitGUID('target')
    end

    --[[
    Gets the target health.

    In the World of Warcraft API, the UnitHealth('target') function behaves
    differently for NPCs and other players. For NPCs, it returns the absolute
    value of their health, whereas for players, it returns a value between
    0 and 100 representing the percentage of their current health compared
    to their total health.
    ]]
    function Target:getHealth()
        return self:hasTarget() and UnitHealth('target') or nil
    end

    --[[
    Gets the target health in percentage.

    This method returns a value between 0 and 1, representing the target's
    health percentage.
    ]]
    function Target:getHealthPercentage()
        return self:hasTarget() and (self:getHealth() / self:getMaxHealth()) or nil
    end

    --[[
    Gets the maximum health of the specified unit.

    In the World of Warcraft API, the UnitHealthMax function is used to
    retrieve the maximum health of a specified unit. When you call
    UnitHealthMax('target'), it returns the maximum amount of health points
    that the targeted unit can have at full health. This function is commonly
    used by addon developers and players to track and display health-related
    information, such as health bars and percentages.
    ]]
    function Target:getMaxHealth()
        return self:hasTarget() and UnitHealthMax('target') or nil
    end

    --[[
    Gets the target name.
    ]]
    function Target:getName()
        return UnitName('target')
    end

    --[[
    Determines whether the player has a target or not.
    ]]
    function Target:hasTarget()
        return nil ~= self:getName()
    end

    --[[
    Determines whether the target is alive.
    ]]
    function Target:isAlive()
        if self:hasTarget() then
            return not self:isDead()
        end
        
        return nil
    end

    --[[
    Determines whether the target is dead.
    ]]
    function Target:isDead()
        return self:hasTarget() and UnitIsDeadOrGhost('target') or nil
    end

    --[[
    Determines whether the target is taggable or not.

    In Classic World of Warcraft, a taggable enemy is an enemy is an enemy that
    can grant experience, reputation, honor, loot, etc. Of course, that would
    depend on the enemy level, faction, etc. But this method checks if another
    player hasn't tagged the enemy before the current player.

    As an example, if the player targets an enemy with a gray health bar, it
    means it's not taggable, then this method will return false.
    ]]
    function Target:isTaggable()
        if not self:hasTarget() then
            return nil
        end

        return not self:isNotTaggable()
    end

    --[[
    Determines whether the target is already tagged by other player.

    Read Target::isTaggable() method's documentation for more information.
    ]]
    function Target:isNotTaggable()
        return UnitIsTapDenied('target')
    end

    --[[
    Adds or removes a raid marker on the target.

    @see ./src/Models/RaidTarget.lua
    @see https://wowwiki-archive.fandom.com/wiki/API_SetRaidTarget

    @tparam RaidMarker raidMarker
    ]]
    function Target:mark(raidMarker)
        if raidMarker then
            SetRaidTarget('target', raidMarker.id)
        end
    end
-- end of Target

-- sets the unique library target instance
self.target = self:new('Target')

--[[
The macro class maps macro information and allow in game macro updates.
]]
local Macro = {}
    Macro.__index = Macro
    Macro.__ = self
    self:addClass('Macro', Macro)

    --[[
    Macro constructor.

    @tparam string name the macro's name
    ]]
    function Macro.__construct(name)
        local self = setmetatable({}, Macro)

        self.name = name

        -- defaults
        self:setIcon("INV_Misc_QuestionMark")

        return self
    end

    --[[
    Determines whether this macro exists.

    @treturn boolean
    ]]
    function Macro:exists()
        return GetMacroIndexByName(self.name) > 0
    end

    --[[
    Saves the macro, returning the macro id.

    If the macro, identified by its name, doesn't exist yet, it will be created.

    It's important to mention that this whole Macro class can have weird
    behavior if it tries to save() a macro with dupicated names. Make sure this
    method is called for unique names.

    Future implementations may fix this issue, but as long as it uses unique
    names, this model will work as expected.

    @treturn integer the macro id
    ]]
    function Macro:save()
        if self:exists() then
            return EditMacro(self.name, self.name, self.icon, self.body)
        end

        return CreateMacro(self.name, self.icon, self.body)
    end

    --[[
    Sets the macro body.

    The macro's body is the code that will be executed when the macro's
    triggered.

    If the value is an array, it's considered a multiline body, and lines will
    be separated by a line break.

    @tparam array<string>|string value the macro's body

    @return self
    ]]
    function Macro:setBody(value)
        self.body = self.__.arr:implode('\n', value)
        return self
    end

    --[[
    Sets the macro icon.

    @tparam integer|string value the macro's icon texture id

    @return self
    ]]
    function Macro:setIcon(value)
        self.icon = value
        return self
    end

    --[[
    Sets the macro name.

    This is the macro's identifier, which means the one World of Warcraft API
    will use when accessing the game's macro.

    @tparam string value the macro's name

    @return self
    ]]
    function Macro:setName(value)
        self.name = value
        return self
    end
-- end of Macro
--[[
The raid marker model represents those icon markers that can
be placed on targets, mostly used in raids and dungeons, especially
skull and cross (x).

This model is used to represent the raid markers in the game, but
not only conceptually, but it maps markers and their indexes to
be represented by objects in the addon environment.
]]
local RaidMarker = {}
    RaidMarker.__index = RaidMarker
    RaidMarker.__ = self

    --[[
    The raid marker constructor.
    ]]
    function RaidMarker.__construct(id, name)
        local self = setmetatable({}, RaidMarker)

        self.id = id
        self.name = name

        return self
    end

    --[[
    Returns a string representation of the raid marker that can
    be used to print it in the chat output in game.
    ]]
    function RaidMarker:getPrintableString()
        if self.id == 0 then
            -- the raid marker represented by 0 can't be printed
            return ''
        end

        return '\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_' .. self.id .. ':0\124t'
    end
-- end of RaidMarker

-- collection of raid markers exposed to the library
self.raidMarkers = {}

for name, id in pairs({
    remove   = 0,
    star     = 1,
    circle   = 2,
    diamond  = 3,
    triangle = 4,
    moon     = 5,
    square   = 6,
    x        = 7,
    skull    = 8,
}) do
    self.raidMarkers[id]   = RaidMarker.__construct(id, name)
    self.raidMarkers[name] = self.raidMarkers[id]
end
    return self
end