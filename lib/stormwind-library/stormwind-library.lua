
--- Stormwind Library
-- @module stormwind-library
if (StormwindLibrary_v1_2_0) then return end
        
StormwindLibrary_v1_2_0 = {}
StormwindLibrary_v1_2_0.__index = StormwindLibrary_v1_2_0

function StormwindLibrary_v1_2_0.new(props)
    local self = setmetatable({}, StormwindLibrary_v1_2_0)
    -- Library version = '1.2.0'

--[[--
The Arr class contains helper functions to manipulate arrays.

@classmod Support.Arr

@usage
    -- library is an instance of the Stormwind Library
    library.arr
]]
local Arr = {}
    Arr.__index = Arr
    Arr.__ = self

    --[[--
    Iterates over the list values and calls the callback function in the
    second argument for each of them.

    The callback function must be a function that accepts (val) or (val, i)
    where val is the object in the interaction and i it's index.

    This method accepts arrays and tables.

    If you need to store the results of the callback, use the Arr:map() method.

    @see Arr.map

    @tparam table list the list to be iterated
    @tparam function callback the function to be called for each item in the list

    @usage
        local list = {1, 2, 3}
        local results = library.arr:map(list, function(val) print(val * 2) end)
    ]]
    function Arr:each(list, callback)
        for i, val in pairs(list) do callback(val, i) end
    end

    --[[--
    Freezes a table, making it immutable.

    This method is useful when you want to create a constant table that
    can't be changed after its creation, considering that Lua doesn't have
    a native way to define constants.

    The implementation below was inspired by the following article:
    https://andrejs-cainikovs.blogspot.com/2009/05/lua-constants.html

    @tparam table table the table to be frozen

    @treturn table the frozen table

    @usage
        local table = {a = 1}
        local frozen = library.arr:freeze(table)
        frozen.a = 2
        -- error: a is a constant and can't be changed
    ]]
    function Arr:freeze(table)
        return setmetatable({}, {
            __index = table,
            __newindex = function(t, key, value)
                error(key .. " is a constant and can't be changed", 2)
            end
        })
    end

    --[[--
    Gets a value in an array using the dot notation.
    
    With the dot notation search, it's possible to query a value in a
    multidimensional array by passing a single string containing keys
    separated by dot.
    
    @tparam table list the table containing the value to be retrieved
    @tparam string key a dot notation key to be used in the search
    @tparam ?any default the default value to be returned if the key is not found
    
    @treturn any|nil

    @usage
        local list = {a = {b = {c = 1}}}
        local value = library.arr:get(list, 'a.b.c')
        -- value = 1
    ]]
    function Arr:get(list, key, default)
        local keys = self.__.str:split(key, '.')
        local current = list
    
        for i = 1, #keys do
            current = current and current[keys[i]]
            if current == nil then
                return default
            end
        end
    
        return current
    end

    --[[--
    Combines the elements of a table into a single string, separated by
    a specified delimiter.
    
    @tparam string delimiter the delimiter used to separate the elements in the resulting string
    @tparam table list the table containing elements to be combined into a string
    
    @treturn string

    @usage
        local list = {1, 2, 3}
        local combined = library.arr:implode(', ', list)
        -- combined = '1, 2, 3'
    ]]
    function Arr:implode(delimiter, list)
        if not (self:isArray(list)) then
            return list
        end

        return table.concat(list, delimiter)
    end

    --[[--
    Determines whether a value is in an array.

    If so, returns true and the index, false and 0 otherwise.

    Class instances can also be checked in this method, not only primitive
    types, as long as they implement the __eq method.

    @tparam table list the array to be checked
    @tparam any value the value to be checked

    @treturn[1] boolean whether the value is in the array
    @treturn[1] integer the index of the value in the array

    @usage
        local list = {'a', 'b', 'c'}
        local found, index = library.arr:inArray(list, 'b')
        -- found = true, index = 2
    ]]
    function Arr:inArray(list, value)
        for i, val in pairs(list) do
            if val == value then
                return true, i
            end
        end

        return false, 0
    end

    --[[--
    Inserts a value in an array if it's not in the array yet.

    It's important to mention that this method only works for arrays with
    numeric indexes. After all, if using string keys, there's no need to check,
    but only setting and replacing the value.

    Class instances can also be passed as the value, not only primitive types,
    as long as they implement the __eq method.

    @tparam table list the array to have the value inserted
    @tparam any value the value to be inserted

    @treturn boolean whether the value was inserted or not

    @usage
        local list = {'a', 'b'}
        local inserted = library.arr:insertNotInArray(list, 'c')
        -- list = {'a', 'b', 'c'}, inserted = true
    ]]
    function Arr:insertNotInArray(list, value)
        if not self:isArray(list) or self:inArray(list, value) then
            return false
        end

        table.insert(list, value)
        return true
    end

    --[[--
    Determines whether the value is an array or not.

    The function checks whether the parameter passed is a table in Lua.
    If it is, it iterates over the table's key-value pairs, examining each key
    to determine if it is numeric. If all keys are numeric, indicating an
    array-like structure, the function returns true; otherwise, it returns
    false.

    This strategy leverages Lua's type checking and table iteration
    capabilities to ascertain whether the input value qualifies as an array.

    @tparam any value the value to be checked

    @return boolean

    @usage
        local value = {1, 2, 3}
        local isArray = library.arr:isArray(value)
        -- isArray = true

        value = {a = 1, b = 2, c = 3}
        isArray = library.arr:isArray(value)
        -- isArray = false
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

    --[[--
    Iterates over the list values and calls the callback function in the
    second argument for each of them, storing the results in a new list to
    be returned.

    The callback function must be a function that accepts (val) or (val, i)
    where val is the object in the interaction and i it's index.

    This method accepts arrays and tables.

    @tparam table list the list to be iterated
    @tparam function callback the function to be called for each item in the list

    @treturn table the list with the callback results

    @usage
        local list = {1, 2, 3}
        local results = library.arr:map(list, function(val) return val * 2 end)
        -- results = {2, 4, 6}
    ]]
    function Arr:map(list, callback)
        local results = {}

        for i, val in pairs(list) do results[i] = callback(val, i) end

        return results
    end

    --[[--
    Initializes a value in a table if it's not initialized yet.

    The key accepts a dot notation key just like get() and set().

    @tparam table list the table to have the value initialized
    @tparam string key the key to be initialized
    @tparam any initialValue the value to be set if the key is not initialized

    @usage
        local list = {}
        library.arr:maybeInitialize(list, 'a.b.c', 1)
        -- list = {a = {b = {c = 1}}}
    ]]
    function Arr:maybeInitialize(list, key, initialValue)
        if self:get(list, key) == nil then self:set(list, key, initialValue) end
    end

    --[[--
    Extracts a list of values from a list of objects based on a given key.

    It's important to mention that nil values won't be returned in the
    resulted list. Which means: objects that have no property or when their
    properties are nil, the values won't be returned. That said, a list with n
    items can return a smaller list.

    The key accepts a dot notation key just like get() and set().

    @tparam table list the list of objects to have the values extracted
    @tparam string key the key to be extracted from the objects

    @treturn table the list of values extracted from the objects

    @usage
        local list = {{a = 1}, {a = 2}, {a = 3}}
        local values = library.arr:pluck(list, 'a')
        -- values = {1, 2, 3}
    ]]
    function Arr:pluck(list, key)
        local results = {}
        for _, item in ipairs(list) do
            table.insert(results, self:get(item, key))
        end
        return results
    end

    --[[--
    Removes a value from an indexed array.

    Tables with non numeric keys won't be affected by this method.

    The value must be the value to be removed and not the index.

    @tparam table list the array to have the value removed
    @tparam any value the value to be removed

    @treturn boolean whether the value was removed or not

    @usage
        local list = {1, 2, 3}
        local removed = library.arr:remove(list, 2)
        -- list = {1, 3}, removed = true
    ]]
    function Arr:remove(list, value)
        if not self:isArray(list) then return false end

        local found, index = self:inArray(list, value)

        if not found then return false end

        table.remove(list, index)
        return true
    end

    --[[--
    Sets a value using arrays dot notation.

    It will basically iterate over the keys separated by "." and create
    the missing indexes, finally setting the last key with the value in
    the args list.

    @tparam table list the table to have the value set
    @tparam string key the key to be set
    @tparam any value the value to be set

    @usage
        local list = {}
        library.arr:set(list, 'a.b.c', 1)
        -- list is now {a = {b = {c = 1}}}
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

    --[[--
    Calls the available unpack() method given the running environment.

    This method is an important helper because World of Warcraft supports
    the unpack() function but not table.unpack(). At the same time, some
    Lua installations have no unpack() but table.unpack().

    @codeCoverageIgnore this method is just a facade to the proper unpack
                        method and won't be tested given that it's tied to
                        the running environment

    @tparam table list the list to be unpacked
    @tparam ?integer i the initial index
    @tparam ?integer j the final index

    @treturn any...

    @usage
        local list = {1, 2, 3}
        local a, b, c = library.arr:unpack(list)
        -- a = 1, b = 2, c = 3
    ]]
    function Arr:unpack(list, i, j)
        if unpack then return unpack(list, i, j) end

        return table.unpack(list, i, j)
    end

    --[[--
    Wraps a value in a table.

    This method is very useful for methods that accept objects and arrays
    on the same variable. That way, they don't need to check the type, but
    wrap it and work with an array.

    If the value provided is a table, this method won't result in a
    bidimensional table, but will return the table itself.

    @tparam any value the value to be wrapped

    @treturn table

    @usage
        local value = 1
        local wrapped = library.arr:wrap(value)
        -- wrapped = {1}
    ]]
    function Arr:wrap(value)
        if type(value) == 'table' then return value end

        return {value}
    end
-- end of Arr

self.arr = Arr

--[[--
The Bool support class contains helper functions to manipulate boolean
values.

@classmod Support.Bool

@usage
    -- library is an instance of the Stormwind Library
    library.bool
]]
local Bool = {}
    Bool.__index = Bool
    Bool.__ = self

    --[[--
    Determines whether a value represents true or not.

    This method checks if a value is in a range of possible values that
    represent a true value.

    @NOTE: Developers may notice this class has no isFalse() method.
           In terms of determining if a value is true, there's a limited
           range of values that can be considered true. On the other hand,
           anything else shouldn't be considered false. Consumers of this
           class can use isTrue() to determine if a value represents a true
           value, but using a isFalse() method would be a bit inconsistent.
           That said, instead of having a isFalse() method, consumers can
           use the not operator to determine if a value is false, which
           makes the code more readable, like: if this value is not true,
           then do something.

    @tparam integer|string|boolean value the value to be checked

    @treturn boolean whether the value represents a true value or not

    @usage
        -- library is an instance of the Stormwind Library
        library.bool:isTrue("yes") -- true
        library.bool:isTrue("no")  -- false
        library.bool:isTrue("1")   -- true
        library.bool:isTrue("0")   -- false
        library.bool:isTrue(1)     -- true
        library.bool:isTrue(0)     -- false
        library.bool:isTrue(true)  -- true
        library.bool:isTrue(false) -- false
    ]]
    function Bool:isTrue(value)
        local inArray, index = self.__.arr:inArray({1, "1", "true", true, "yes"}, value)

        -- it returns just the first inArray result, as the second value is the index
        -- which makes no sense in this context
        return inArray
    end
-- end of Bool

self.bool = Bool

--[[--
The Str support class contains helper functions to manipulate strings.

@classmod Support.Str

@usage
    -- library is an instance of the Stormwind Library
    library.str
]]
local Str = {}
    Str.__index = Str

    --[[--
    Determines whether a string is empty or not.

    By empty, it means that the string is nil, has no characters, or has only
    whitespace characters. This last case is important because a string with
    only whitespace characters is not considered empty by Lua's standards,
    but it is by this function's standards.

    If a method shouldn't consider a string with only whitespace characters
    as empty, please do not use this function.
        
    @tparam string value the string to be checked

    @treturn boolean whether the string is empty or not

    @usage
        local value = "  "
        library.str:isEmpty(value) -- true
    ]]
    function Str:isEmpty(value)
        return value == nil or (string.len(self:trim(value)) == 0)
    end

    --[[--
    Determines whether a string is not empty.

    This function is the opposite of Str:isEmpty.

    @tparam string value the string to be checked

    @treturn boolean whether the string is not empty

    @usage
        local value = "  "
        library.str:isNotEmpty(value) -- false
    ]]
    function Str:isNotEmpty(value)
        return not self:isEmpty(value)
    end

    --[[--
    Determines whether a string is quoted by " or '.

    @tparam string value the string to be checked

    @treturn boolean whether the string is quoted or not

    @usage
        local value = "'quoted'"
        library.str:isQuoted(value) -- true
    ]]
    function Str:isQuoted(value)
        return self:isWrappedBy(value, '"') or self:isWrappedBy(value, "'")
    end

    --[[--
    Determines whether a string is wrapped by a prefix and a suffix.

    This function is useful to determine if a string is wrapped by a pair of
    strings, like quotes, parentheses, brackets, etc.

    The third parameter is optional. If it is not provided, the function will
    assume that the prefix and suffix are the same.

    Finally, this function will return true if the string contains only the
    prefix and suffix, like "", "()", "[]", etc. That would mean that an
    empty string is considered wrapped by something.

    @tparam string value the string to be checked
    @tparam string wrapper the prefix of the wrapping
    @tparam ?string endWrapper the suffix of the wrapping, will assume
                    wrapper if not provided

    @treturn boolean whether the string is wrapped by the prefix and suffix

    @usage
        local value = "'quoted'"
        library.str:isWrappedBy(value, "'") -- true
    ]]
    function Str:isWrappedBy(value, wrapper, endWrapper)
        endWrapper = endWrapper or wrapper

        return
            (value ~= nil) and
            (wrapper ~= nil) and
            (value ~= wrapper) and
            (value:sub(1, #wrapper) == wrapper and value:sub(-#endWrapper) == endWrapper)
    end

    --[[--
    Removes quotes from a string.

    This method can't simply call removeWrappers twice for " or ', because
    the string could be wrapped by one type of quote and contain the other
    type inside it, so it first checks which type of quote is wrapping the
    string and then removes it.

    @tparam string value the string to be checked

    @treturn string the string without quotes

    @usage
        local value = "'quoted'"
        library.str:removeQuotes(value) -- quoted
    ]]
    function Str:removeQuotes(value)
        if self:isWrappedBy(value, '"') then
            return self:removeWrappers(value, '"')
        end

        return self:removeWrappers(value, "'")
    end

    --[[--
    Removes the wrapping strings from a string.

    This function is useful to remove quotes, parentheses, brackets, etc,
    from a string.

    Similarly to Str:isWrappedBy, the third parameter is optional. If it is
    not provided, the function will assume that the prefix and suffix are
    the same.

    @tparam string value the string to be checked
    @tparam string wrapper the prefix of the wrapping
    @tparam ?string endWrapper the suffix of the wrapping, will assume
                wrapper if not provided

    @treturn string the string without the prefix and suffix

    @usage
        local value = "'quoted'"
        library.str:removeWrappers(value, "'") -- quoted
    ]]
    function Str:removeWrappers(value, wrapper, endWrapper)
        return self:isWrappedBy(value, wrapper, endWrapper)
            and value:sub(#wrapper + 1, -#(endWrapper or wrapper) - 1)
            or value
    end

    --[[--
    Replaces all occurrences of a substring in a string with another
    substring.

    This function does not support regular expressions. If regular
    expressions are needed, please use Lua's string.gsub function. It was
    created for the convenience of allowing quick replacements that also
    accept characters like ".", "(", "[", etc, that would be interpreted as
    regular expressions metacharacters.

    @tparam string value the subject string to have the replacements
    @tparam string find the substring to be replaced
    @tparam string replace the substring to replace the find substring

    @treturn string the string after the replacements

    @usage
        local value = "Hello, world!"
        library.str:replaceAll(value, "world", "Lua") -- Hello, Lua!
    ]]
    function Str:replaceAll(value, find, replace)
        return (value:gsub(find:gsub("[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1"), replace))
    end

    --[[--
    Splits a string in a table by breaking it where the separator is found.

    @tparam string value the string to be split
    @tparam string separator the separator to split the string

    @treturn table a table with the split strings

    @usage
        local value = "Hello, world!"
        library.str:split(value, ", ") -- { "Hello", "world!" }
    ]]
    function Str:split(value, separator)
        local values = {}
        for str in string.gmatch(value, "([^"..separator.."]+)") do
            table.insert(values, str)
        end
        return values
    end

    --[[--
    Removes all whitespace from the beginning and end of a string.

    @tparam string value the string to be trimmed

    @treturn string the string without whitespace at the beginning and end

    @usage
        local value = "  Hello, world!  "
        library.str:trim(value) -- "Hello, world!"
    ]]
    function Str:trim(value)
        return value and value:gsub("^%s*(.-)%s*$", "%1") or value
    end
-- end of Str

self.str = Str


--[[--
The Environment class is used by the library to determine whether it's
running in a specific World of Warcraft client or in a test suite.

Sometimes it's necessary to execute different code depending on the
available API resources, like functions and tables that are available in
Retail but not in Classic and vice versa.

Environment is alvo available to addons, but as long as they register
multiple versions of a class for each supported client, everything should
be transparent and no additional handling is required, not even asking
this class for the current client version.

Note: Environment is registered before the library Factory, which means
it can't be instantiated with library:new(). For any class that needs to
know the current environment, use the library.environment instance.

@classmod Core.Environment
]]
local Environment = {}
    Environment.__index = Environment
    Environment.__ = self

    --[[--
    Constants for the available clients and test suite.

    @table constants
    @field CLIENT_CLASSIC     The current World of Warcraft Classic client,
                              which includes TBC, WotLK, and Cataclysm, etc
    @field CLIENT_CLASSIC_ERA Classic SoD, Hardcore, and any other clients
                              that have no expansions
    @field CLIENT_RETAIL      The current World of Warcraft Retail client
    @field TEST_SUITE         The unit test suite, that executes locally
                              without any World of Warcraft client
    ]]
    Environment.constants = self.arr:freeze({
        CLIENT_CLASSIC     = 'classic',
        CLIENT_CLASSIC_ERA = 'classic-era',
        CLIENT_RETAIL      = 'retail',
        TEST_SUITE         = 'test-suite',
    })

    --[[--
    Environment constructor.
    ]]
    function Environment.__construct()
        return setmetatable({}, Environment)
    end

    --[[--
    Gets the current client flavor, determined by the current TOC version.

    The client flavor is a string that represents the current World of
    Warcraft client and mapped to the constants.CLIENT_* values.

    If the addon is running in a test suite, create the TEST_ENVIRONMENT
    global variable and set it to true before instantiating the library so
    this method can return the proper value.

    @see Environment.constants

    @treturn string The current client flavor
    ]]
    function Environment:getClientFlavor()
        if TEST_ENVIRONMENT then return self.constants.TEST_SUITE end

        if self.clientFlavor then return self.clientFlavor end

        local tocVersion = self:getTocVersion()

        if tocVersion < 20000 then
            self.clientFlavor = self.constants.CLIENT_CLASSIC_ERA
        elseif tocVersion < 100000 then
            self.clientFlavor = self.constants.CLIENT_CLASSIC
        else
            self.clientFlavor = self.constants.CLIENT_RETAIL
        end

        return self.clientFlavor
    end

    --[[--
    Gets the World of Warcraft TOC version.

    @treturn integer The client's TOC version
    ]]
    function Environment:getTocVersion()
        local _, _, _, tocVersion = GetBuildInfo()

        return tocVersion
    end

    --[[--
    Determines whether the addon is running in a World of Warcraft client.

    @treturn boolean True if the addon is running in a World of Warcraft
                     client, false otherwise, like in a test suite
    ]]
    function Environment:inGame()
        return self:getClientFlavor() ~= self.constants.TEST_SUITE
    end
-- end of Environment

-- stores the current environment instance
self.environment = Environment.__construct()


--[[
Sets the addon properties.

Allowed properties = {
    data: table, optional
    colors: table, optional
        primary: string, optional
        secondary: string, optional
    command: string, optional
    name: string, optional
}
]]
self.addon = {}

self.addon.colors  = self.arr:get(props or {}, 'colors', {})
self.addon.data    = self.arr:get(props or {}, 'data')
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

--[[--
Registers a class so the library is able to instantiate it later.

This method just updates the library classes table by registering a class
for the client flavors it's supported.

@tparam string classname The name of the class to be registered
@tparam table classStructure The class structure to be registered
@tparam nil|string|table clientFlavors The client flavors the class is supported by
]]
function self:addClass(classname, classStructure, clientFlavors)
    local arr = self.arr

    clientFlavors = arr:wrap(clientFlavors or {
        self.environment.constants.CLIENT_CLASSIC,
        self.environment.constants.CLIENT_CLASSIC_ERA,
        self.environment.constants.CLIENT_RETAIL,
        self.environment.constants.TEST_SUITE,
    })

    arr:each(clientFlavors, function(clientFlavor)
        arr:set(self.classes, clientFlavor .. '.' .. classname, classStructure)
    end)
end

--[[
Returns a class structure by its name.

This method's the same as accessing self.classes[classname].

@tparam string classname The name of the class to be returned
]]
function self:getClass(classname)
    local clientFlavor = self.environment:getClientFlavor()

    return self.classes[clientFlavor][classname]
end

--[[
This method emulates the new keyword in OOP languages by instantiating a
class by its name as long as the class has a __construct() method with or
without parameters.
]]
function self:new(classname, ...)
    return self:getClass(classname).__construct(...)
end


--[[--
The Configuration class is responsible for managing the addon's
configurations, settings, options, and anything else that can be persisted
in the table used by the game client to store saved variables.

It provides methods to easily access and manipulate the configuration
properties. That reduces the need to pollute the addon code with sanity
checks, index initializations, etc.

All the configuration keys in this class can be accessed using the dot
notation, similar to the how the Arr class works.

@classmod Core.Configuration
]]
local Configuration = {}
    Configuration.__index = Configuration
    Configuration.__ = self

    --[[--
    Configuration constructor.

    The configuration instance expects a table with the configuration data
    which is also referenced in the TOC file. That way, each instance of this
    class will handle a saved variable.

    Stormwind Library will automatically create an instance of this class
    when the addon is loaded in case a table is referenced in the addon's
    properties, however, if the addon needs to have multiple configurations,
    one instance of this class should be created for each table.

    @tparam table savedVariable The configuration data to be used by the addon.
            This table instance must be the same one referenced in
            the TOC SavedVariables property.
    ]]
    function Configuration.__construct(savedVariable)
        local self = setmetatable({}, Configuration)

        self.data = savedVariable

        return self
    end

    --[[--
    Gets a configuration property by a dot notation key or returns a default
    value if the key does not exist.

    @tparam string key The dot notation key to be used to retrieve the configuration property
    @tparam any default The default value to be returned if the key does not exist

    @treturn any The configuration property value or the default value if the
                 key does not exist
    
    @usage
        library.configuration:get('test.property', 'default-value')
    ]]
    function Configuration:get(key, default)
        return self.__.arr:get(self.data, self:maybePrefixKey(key), default)
    end

    --[[--
    Gets a configuration property by a dot notation key or initializes it
    with a default value if the key does not exist.

    This method is similar to the get() method, but it also initializes the
    property with the default value if the key does not exist.

    @see Configuration.get

    @tparam string key The dot notation key to be used to retrieve the configuration property
    @tparam any default The default value to be returned if the key does not exist

    @treturn any The configuration property value or the default value if the
                 key does not exist

    @usage
        library.configuration:getOrInitialize('test.property', 'default-value')
    --]]
    function Configuration:getOrInitialize(key, default)
        self.__.arr:maybeInitialize(self.data, self:maybePrefixKey(key), default)

        return self:get(key, default)
    end

    --[[--
    The handle method is used forward the configuration operation coming
    from the library config() method.

    This method should not be called directly. It is used internally by the
    library to handle the configuration operations.

    @local
    ]]
    function Configuration:handle(...)
        if self.data == nil then
            self.__.output:out('There was an attempt to get or set configuration values with no addon respective data set. Please, pass the data variable name when initializing the Stormwind Library to use this feature.')
            return nil
        end

        local arg1, arg2, arg3 = ...

        if type(arg1) == 'string' then
            if self.__.bool:isTrue(arg3) then
                return self:getOrInitialize(arg1, arg2)
            else
                return self:get(arg1, arg2)
            end
        end

        if type(arg1) == 'table' then
            self.__.arr:each(arg1, function(value, key)
                self:set(key, value)
            end)
        end

        return nil
    end

    --[[--
    Prefixes a key with the prefix key if it's set.

    This method is used internally to prefix the configuration keys with the
    prefix key if it's set. It should not be called directly, especially
    when getting or setting configuration properties, otherwise the prefix
    may be added twice.

    @local

    @tparam string key The key to be prefixed

    @treturn string The key with the prefix if it's set, or the key itself
    ]]
    function Configuration:maybePrefixKey(key)
        return self.prefixKey and self.prefixKey .. '.' .. key or key
    end

    --[[--
    Sets a configuration property by a dot notation key.

    This will update the configuration property with the new value. If the key
    does not exist, it will be created.

    @tparam string key The dot notation key to be used to set the configuration property
    @tparam any value The value to be set in the configuration property

    @usage
        library.configuration:set('test.property', 'new-value')
    --]]
    function Configuration:set(key, value)      
        self.__.arr:set(self.data, self:maybePrefixKey(key), value)
    end

    --[[--
    Sets a prefix key that will be used to prefix all the configuration keys.

    If this method is not called during the addon lifecycle, no prefixes
    will be used.

    One of the reasons to use a prefix key is to group configuration values
    and settings per player, realm, etc.

    Note: The prefix will be concatenated with a dot before any key used in
    this class, which means that this method should not be called with a
    prefix key that already ends with a dot.

    @tparam string value The prefix key to be used to prefix all the configuration keys

    @treturn Core.Configuration The Configuration instance itself to allow method chaining
    ]]
    function Configuration:setPrefixKey(value)
        self.prefixKey = value
        return self
    end
-- end of Configuration

self:addClass('Configuration', Configuration)

--[[
Gets, sets or initializes a configuration property by a dot notation key.

This is the only method that should be used to handle the addon
configuration, unless the addon needs to have multiple configuration
instances.

config() is a proxy method that forwards the configuration operation to the
Configuration class that's internally handled by Configuration:handle().

@see Configuration.handle
]]
function self:config(...)
    if not self:isConfigEnabled() then return nil end

    return self.configuration:handle(...)
end

--[[
Determines whether the addon configuration is enabled.

To be enabled, the addon must have a configuration instance created, which
is instantiated by the library when the addon is loaded if it has a saved
variable property in the TOC file passed to the library constructor.

@treturn bool True if the configuration is enabled, false otherwise
--]]
function self:isConfigEnabled()
    -- @TODO: Remove this method once the library offers a structure to
    --        execute callbacks when it's loaded <2024.04.22>
    self:maybeInitializeConfiguration()

    return self.configuration ~= nil
end

--[[
May initialize the addon configuration if it's not set yet.

@TODO: Remove this method once the library offers a structure to execute
       callbacks when it's loaded <2024.04.22>
]]
function self:maybeInitializeConfiguration()
    local key = self.addon.data
    if key and (self.configuration == nil) then
        -- initializes the addon data if it's not set yet
        _G[key] = self.arr:get(_G, key, {})
        
        -- global configurations
        self.configuration = self:new('Configuration', _G[key])

        -- player configurations
        self.playerConfiguration = self:new('Configuration', _G[key])
        self.playerConfiguration:setPrefixKey(self.currentPlayer.realm.name .. '.' .. self.currentPlayer.name)
    end
end

--[[
Gets, sets or initializes a player configuration property by a dot notation
key.

This is the only method that should be used to handle the addon
player configurations, unless the addon needs to have multiple configuration
instances.

playerConfig() is a proxy method that forwards the configuration operation
to the player Configuration instance that's internally handled by
Configuration:handle().

@see Configuration.handle
]]
function self:playerConfig(...)
    if not self:isConfigEnabled() then return nil end

    return self.playerConfiguration:handle(...)
end

--[[--
The output structure controls everything that can be printed
in the Stormwind Library and also by the addons.

@classmod Core.Output
]]
local Output = {}
    Output.__index = Output
    Output.__ = self

    --[[--
    Output constructor.
    ]]
    function Output.__construct()
        local self = setmetatable({}, Output)

        self.mode = 'out'

        return self
    end

    --[[--
    Colors a string with a given color according to how
    World of Warcraft handles colors in the chat and output.

    This method first looks for the provided color, if it's not
    found, it will use the primary color from the addon properties.
    And if the primary color is not found, it won't color the string,
    but return it as it is.

    @tparam string value The string to be colored
    @tparam string color The color to be used

    @treturn string The colored string
    ]]
    function Output:color(value, color)
        color = color or self.__.addon.colors.primary

        return color and string.gsub('\124cff' .. string.lower(color) .. '{0}\124r', '{0}', value) or value
    end

    --[[--
    Dumps the values of variables and tables in the output, then dies.

    The dd() stands for "dump and die" and it's a helper function inspired by a PHP framework
    called Laravel. It's used to dump the values of variables and tables in the output and stop
    the execution of the script. It's only used for debugging purposes and should never be used
    in an addon that will be released.

    Given that it can't use the Output:out() method, there's no test coverage for dd(). After
    all it's a test and debugging helper resource.

    @param ... The variables and tables to be dumped

    @usage
        dd(someVariable)
        dd({ key = 'value' })
        dd(someVariable, { key = 'value' })
    ]]
    function Output:dd(...)
        local inGame = self.__.environment:inGame()

        if not inGame then print('\n\n\27[32m-dd-\n') end

        local function printTable(t, indent, printedTables)
            indent = indent or 0
            printedTables = printedTables or {}
            local indentStr = string.rep(" ", indent)
            for k, v in pairs(t) do
                if type(v) == "table" then
                    if not printedTables[v] then
                        printedTables[v] = true
                        print(indentStr .. k .. " => {")
                        printTable(v, indent + 4, printedTables)
                        print(indentStr .. "}")
                    else
                        print(indentStr .. k .. " => [circular reference]")
                    end
                else
                    print(indentStr .. k .. " => " .. tostring(v))
                end
            end
        end

        for i, v in ipairs({...}) do
            if type(v) == "table" then
                print("[" .. i .. "] => {")
                printTable(v, 4, {})
                print("}")
            else
                print("[" .. i .. "] => " .. tostring(v))
            end
        end

        -- this prevents os.exit() being called inside the game and also allows
        -- dd() to be tested
        if inGame then return end
        
        print('\n-end of dd-' .. (not inGame and '\27[0m' or ''))
        lu.unregisterCurrentSuite()
        os.exit(1)
    end

    --[[--
    Formats a standard message with the addon name to be printed.

    @tparam string message The message to be formatted

    @treturn string The formatted message
    ]]
    function Output:getFormattedMessage(message)
        local coloredAddonName = self:color(self.__.addon.name .. ' | ')

        return coloredAddonName .. message
    end

    --[[--
    Determines whether the output structure is in testing mode.

    @treturn boolean Whether the output structure is in testing mode
    ]]
    function Output:isTestingMode()
        return self.mode == 'test'
    end

    --[[--
    This is the default printing method for the output structure.
    
    Although there's a print() method in the output structure, it's
    recommended to use this method instead, as it will format the
    message with the addon name and color it according to the
    primary color from the addon properties.

    This method accepts a string or an array. If an array is passed
    it will print one line per value.

    @tparam table[string]|string messages The message or messages to be printed
    ]]
    function Output:out(messages)
        for i, message in ipairs(self.__.arr:wrap(messages)) do
            if self:isTestingMode() then
                table.insert(self.history, message)
                return
            end

            self:print(self:getFormattedMessage(message))
        end
    end

    --[[--
    Prints a message using the default Lua output resource.

    @tparam string message The message to be printed
    ]]
    function Output:print(message)
        print(message)
    end

    --[[--
    Determines whether a message was printed in the output structure with
    the out() method.

    This method must be used only in test environments and if
    self:setTestingMode() was called before self:out() calls, otherwise
    it will always return false.

    @tparam string message The message to be checked if it was printed

    @treturn boolean Whether the message was printed
    ]]
    function Output:printed(message)
        return self.__.arr:inArray(self.history or {}, message)
    end

    --[[--
    Sets the output mode to 'test', changing the state of the output
    structure to be used in tests.
    ]]
    function Output:setTestingMode()
        self.history = {}
        self.mode = 'test'
    end
-- end of Output

-- sets the unique library output instance
self.output = Output.__construct()
function self:dd(...) self.output:dd(...) end

-- allows Output to be instantiated, very useful for testing
self:addClass('Output', Output)


--[[--
The command class represents a command in game that can be executed with
/commandName.

Commands in the Stormwind Library are structured in two parts being:

1. The command operation
2. The command arguments

That said, a command called myAddonCommand that shows its settings screen
in dark mode would be executed with /myAddonCommand show darkMode.

@classmod Commands.Command
]]
local Command = {}
    Command.__index = Command
    Command.__ = self
    self:addClass('Command', Command)

    --[[--
    Command constructor.
    ]]
    function Command.__construct()
        return setmetatable({}, Command)
    end

    --[[--
    Returns a human readable help content for the command.

    @treturn string a human readable help content for the command
    ]]
    function Command:getHelpContent()
        local content = self.operation

        if self.description then
            content = content .. ' - ' .. self.description
        end

        return content
    end

    --[[--
    Sets the command description.

    @tparam string description the command description that will be shown in the help content

    @return self
    ]]
    function Command:setDescription(description)
        self.description = description
        return self
    end

    --[[--
    Sets the command operation.

    @tparam string operation the command operation that will be used to trigger the command
    callback

    @return self
    ]]
    function Command:setOperation(operation)
        self.operation = operation
        return self
    end

    --[[--
    Sets the command callback.

    @tparam function callback the callback that will be executed when the command is triggered

    @return self
    ]]
    function Command:setCallback(callback)
        self.callback = callback
        return self
    end
-- end of Command

--[[--
The commands handler provides resources for easy command registration,
listening and triggering.

@classmod Commands.CommandsHandler
]]
local CommandsHandler = {}
    CommandsHandler.__index = CommandsHandler
    CommandsHandler.__ = self

    --[[--
    CommandsHandler constructor.
    ]]
    function CommandsHandler.__construct()
        local self = setmetatable({}, CommandsHandler)

        self.operations = {}
        self:addHelpOperation()

        return self
    end

    --[[--
    Adds a command that will be handled by the library.

    The command must have an operation and a callback.

    It's important to mention that calling this method with two commands
    sharing the same operation won't stack two callbacks, but the second
    one will replace the first.

    @tparam Command command
    ]]
    function CommandsHandler:add(command)
        self.operations[command.operation] = command
    end

    --[[--
    This method adds a help operation to the commands handler.

    The help operation is a default operation that can be overridden in
    case the addon wants to provide a custom help command. For that, just
    add a command with the operation "help" and a custom callback.

    When the help operation is not provided, a simple help command is
    printed to the chat frame with the available operations and their
    descriptions, when available.

    @local
    ]]
    function CommandsHandler:addHelpOperation()
        local helpCommand = self.__:new('Command')

        helpCommand:setOperation('help')
        helpCommand:setDescription('Shows the available operations for this command.')
        helpCommand:setCallback(function () self:printHelp() end)

        self:add(helpCommand)
    end

    --[[--
    Builds a help content that lists all available operations and their
    descriptions.
    
    @NOTE: The operations are sorted alphabetically and not in the order they were added.
    @NOTE: The "help" operation is not included in the help content.
    
    @local

    @treturn table[string] A list of strings with the help content
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

    --[[--
    This method is responsible for handling the command that was triggered
    by the user, parsing the arguments and invoking the callback that was
    registered for the operation.

    @local

    @tparam string commandArg The full command argument
    ]]
    function CommandsHandler:handle(commandArg)
        self:maybeInvokeCallback(
            self:parseOperationAndArguments(
                self:parseArguments(commandArg)
            )
        )
    end

    --[[--
    This method is responsible for invoking the callback that was registered
    for the operation, if it exists.
    
    @codeCoverageIgnore this method's already tested by the handle() test method

    @local

    @tparam string operation The operation that was triggered
    @tparam table args The arguments that were passed to the operation
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

    --[[--
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

    @local

    @tparam string input The full command argument

    @treturn table[string] A list of strings representing the arguments
    ]]
    function CommandsHandler:parseArguments(input)
        if not input then return {} end

        local result = {}
        local inDoubleQuotes, inSingleQuotes = false, false
        local currentWord = ""
    
        for i = 1, #input do
            local char = input:sub(i, i)
            if char == "'" and not inDoubleQuotes then
                inSingleQuotes = not inSingleQuotes
            elseif char == '"' and not inSingleQuotes then
                inDoubleQuotes = not inDoubleQuotes
            elseif char == " " and not (inSingleQuotes or inDoubleQuotes) then
                if currentWord ~= "" then
                    table.insert(result, currentWord)
                    currentWord = ""
                end
            else
                currentWord = currentWord .. char
            end
        end
    
        if currentWord ~= "" then
            table.insert(result, currentWord)
        end
    
        return result
    end

    --[[--
    This method selects the first command argument as the operation and the
    subsequent arguments as the operation arguments.

    Note that args can be empty, so there's no operation and no arguments.

    Still, if the size of args is 1, it means there's an operation and no
    arguments. If the size is greater than 1, the first argument is the
    operation and the rest are the arguments.

    @local

    @tparam table[string] args The arguments that were passed to the operation

    @treturn[1] string The operation that was triggered
    @treturn[1] table[string] The arguments that were passed to the operation
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

    --[[--
    Prints the help content to the chat frame.

    @local
    ]]
    function CommandsHandler:printHelp()
        local helpContent = self:buildHelpContent()

        if helpContent and (#helpContent > 0) then self.__.output:out(helpContent) end
    end

    --[[--
    Register the main Stormwind Library command callback that will then redirect
    the command to the right operation callback.

    In terms of how the library was designed, this is the only real command
    handler and serves as a bridge between World of Warcraft command system
    and the addon itself.

    @local
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
    Gets the target raid marker in the target, if any.

    @treturn RaidMarker|nil
    ]]
    function Target:getMark()
        local mark = GetRaidTargetIndex('target')

        return mark and self.__.raidMarkers[mark] or nil
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
    Determines whether the target is marked or not.

    A marked target is a target that has a raid marker on it.

    @treturn boolean
    ]]
    function Target:isMarked()
        return nil ~= self:getMark()
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

--[[--
Abstract base class for tooltips.

It provides ways to interact with the game's tooltip system, but it's
abstract in a way that addons should work with the concrete classes that
inherit from this one, instantiated by the factory.

@classmod Facades.AbstractTooltip
]]
local AbstractTooltip = {}
    AbstractTooltip.__index = AbstractTooltip
    AbstractTooltip.__ = self

    --[[--
    AbstractTooltip constants.

    @table constants
    @field TOOLTIP_ITEM_SHOWN Represents the event fired when an item tooltip is shown
    @field TOOLTIP_UNIT_SHOWN Represents the event fired when a unit tooltip is shown
    ]]
    AbstractTooltip.constants = self.arr:freeze({
        TOOLTIP_ITEM_SHOWN = 'TOOLTIP_ITEM_SHOWN',
        TOOLTIP_UNIT_SHOWN = 'TOOLTIP_UNIT_SHOWN',
    })

    -- AbstractTooltip is meant to be inherited by other classes and should
    -- not be instantiated directly, only for testing purposes
    self:addClass('AbstractTooltip', AbstractTooltip, self.environment.constants.TEST_SUITE)

    --[[--
    AbstractTooltip constructor.
    ]]
    function AbstractTooltip.__construct()
        return setmetatable({}, AbstractTooltip)
    end

    --[[--
    Handles the event fired from the game when an item tooltip is shown.

    If the tooltip is consistent and represents a tooltip instance, this
    method notifies the library event system so subscribers can act upon it
    regardless of the client version.

    @local

    @tparam GameTooltip tooltip The tooltip that was shown
    ]]
    function AbstractTooltip:onItemTooltipShow(tooltip)
        if tooltip == GameTooltip then
            -- @TODO: Collect more information from items <2024.05.03>
            local item = self.__
                :new('Item')
                :setName(tooltip:GetItem())

            self.__.events:notify('TOOLTIP_ITEM_SHOWN', item)
        end
    end

    --[[--
    Handles the event fired from the game when a unit tooltip is shown.

    If the tooltip is consistent and represents a tooltip instance, this
    method notifies the library event system so subscribers can act upon it
    regardless of the client version.

    @local

    @tparam GameTooltip tooltip The tooltip that was shown
    ]]
    function AbstractTooltip:onUnitTooltipShow(tooltip)
        if tooltip == GameTooltip then
            -- @TODO: Send unit information <2024.05.03>
            self.__.events:notify('TOOLTIP_UNIT_SHOWN')
        end
    end

    --[[--
    Registers all tooltip handlers in game.

    This method should be implemented by the concrete classes that inherit
    from this one, as the way tooltips are handled may vary from one version
    of the game to another.
    ]]
    function AbstractTooltip:registerTooltipHandlers()
        error('This is an abstract method and should be implemented by this class inheritances')
    end
-- end of AbstractTooltip

--[[--
The default implementation of the AbstractTooltip class for the Classic
clients.

@classmod Facades.ClassicTooltip
]]
local ClassicTooltip = {}
    ClassicTooltip.__index = ClassicTooltip
    -- ClassicTooltip inherits from AbstractTooltip
    setmetatable(ClassicTooltip, AbstractTooltip)
    self:addClass('ClassicTooltip', ClassicTooltip, self.environment.constants.TEST_SUITE)
    self:addClass('Tooltip', ClassicTooltip, {
        self.environment.constants.TEST_SUITE,
        self.environment.constants.CLIENT_CLASSIC_ERA,
        self.environment.constants.CLIENT_CLASSIC,
    })

    --[[--
    ClassicTooltip constructor.
    ]]
    function ClassicTooltip.__construct()
        return setmetatable({}, ClassicTooltip)
    end

    --[[--
    Hooks into the GameTooltip events to handle item and unit tooltips.

    This is the implementation of the AbstractTooltip:registerTooltipHandlers()
    abstract method that works with Classic clients.
    ]]
    function ClassicTooltip:registerTooltipHandlers()
        GameTooltip:HookScript('OnTooltipSetItem', function (tooltip)
            self:onItemTooltipShow(tooltip)
        end)

        GameTooltip:HookScript('OnTooltipSetUnit', function (tooltip)
            self:onUnitTooltipShow(tooltip)
        end)
    end
-- end of ClassicTooltip

--[[--
The default implementation of the AbstractTooltip class for the Retail
client.

@classmod Facades.RetailTooltip
]]
local RetailTooltip = {}
    RetailTooltip.__index = RetailTooltip
    -- RetailTooltip inherits from AbstractTooltip
    setmetatable(RetailTooltip, AbstractTooltip)
    self:addClass('RetailTooltip', RetailTooltip, self.environment.constants.TEST_SUITE)
    self:addClass('Tooltip', RetailTooltip, {
        self.environment.constants.CLIENT_RETAIL,
    })

    --[[--
    RetailTooltip constructor.
    ]]
    function RetailTooltip.__construct()
        return setmetatable({}, RetailTooltip)
    end

    --[[--
    Add tooltip post call with the TooltipDataProcessor.
    ]]
    function RetailTooltip:registerTooltipHandlers()
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
            self:onItemTooltipShow(tooltip);
        end)

        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, data)
            self:onUnitTooltipShow(tooltip)
        end)
    end
-- end of RetailTooltip


-- @TODO: Move this to AbstractTooltip.lua once the library initialization callbacks are implemented <2024.05.04>
self.tooltip = self:new('Tooltip')
self.tooltip:registerTooltipHandlers()

--[[--
The Item class is a model that maps game items and their properties.

Just like any other model, it's used to standardize the way addons interact 
with game objects, especially when item information is passed as a parameter
to methods, events, datasets, etc.

This model will grow over time as new expansions are released and new
features are implemented in the library.

@classmod Models.Item
]]
local Item = {}
    Item.__index = Item
    Item.__ = self
    self:addClass('Item', Item)

    --[[--
    Item constructor.
    ]]
    function Item.__construct()
        return setmetatable({}, Item)
    end

    --[[--
    Sets the item name.

    @tparam string value the item's name

    @treturn Models.Item self
    ]]
    function Item:setName(value)
        self.name = value
        return self
    end
-- end of Item

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

--[[--
The Realm class is a model that maps realms also known as servers.

Just like any other model, it's used to standardize the way addons interact 
with realm information.

This model will grow over time as new features are implemented in the
library.

@classmod Models.Realm
]]
local Realm = {}
    Realm.__index = Realm
    Realm.__ = self
    self:addClass('Realm', Realm)

    --[[--
    Realm constructor.
    ]]
    function Realm.__construct()
        return setmetatable({}, Realm)
    end

    --[[--
    Instantiates a new Realm object with the current realm's information.

    This method acts as a constructor for the Realm model and should not be
    called in a realm object instance. Consider this a static builder
    method.

    @treturn Models.Realm a new Realm object with the current realm's information
    ]]
    function Realm.getCurrentRealm()
        local realm = Realm.__construct()

        realm:setName(GetRealmName())

        return realm
    end

    --[[--
    Sets the Realm name.

    @tparam string value the Realm's name

    @treturn Models.Realm self
    ]]
    function Realm:setName(value)
        self.name = value
        return self
    end
-- end of Realm

--[[--
The Player class is a model that maps player information.

Just like any other model, it's used to standardize the way addons interact 
with data related to players.

This model will grow over time as new features are implemented in the
library.

@TODO: Make this model extend Unit when the Unit model is implemented <2024.05.06>

@classmod Models.Player
]]
local Player = {}
    Player.__index = Player
    Player.__ = self
    self:addClass('Player', Player)

    --[[--
    Player constructor.
    ]]
    function Player.__construct()
        return setmetatable({}, Player)
    end

    --[[--
    Gets the current player information.

    This method acts as a constructor for the Player model and should not be
    called in a player object instance. Consider this a static builder
    method.

    @treturn Models.Player a new Player object with the current player's information
    ]]
    function Player.getCurrentPlayer()
        return Player.__construct()
            :setName(UnitName('player'))
            :setGuid(UnitGUID('player'))
            :setRealm(self:getClass('Realm'):getCurrentRealm())
    end

    --[[--
    Sets the Player GUID.

    @TODO: Move this method to Unit when the Unit model is implemented <2024.05.06>

    @tparam string value the Player's GUID

    @treturn Models.Player self
    ]]
    function Player:setGuid(value)
        self.guid = value
        return self
    end

    --[[--
    Sets the Player name.

    @TODO: Move this method to Unit when the Unit model is implemented <2024.05.06>

    @tparam string value the Player's name

    @treturn Models.Player self
    ]]
    function Player:setName(value)
        self.name = value
        return self
    end

    --[[--
    Sets the Player realm.

    It's most likely that a player realm will be the same realm as the
    player is logged in, but it's possible to have a player from a different
    realm, especially in Retail, where Blizzard allows players from other
    realms to share the same place or group.

    @tparam Models.Realm value the Player's realm

    @treturn Models.Player self
    ]]
    function Player:setRealm(value)
        self.realm = value
        return self
    end
-- end of Player

-- stores the current player information for easy access
self.currentPlayer = Player.getCurrentPlayer()


--[[--
The Window class is the base class for all windows in the library.

A window in this context is a standard frame that makes use of the World of
Warcraft CreateFrame function, but with some additional features: a title
bar that can move the window, a close button, a resize button at the bottom,
a content area with a scroll bar, plus a few other.

The motivation behind this class is to provide a simple way to create
windows, considering that the CreateFrame function is a bit cumbersome to
use, and that the standard window features can be enough for most addons.

It's necessary to note that this class is not as flexible as the CreateFrame
function, and that it's not meant to replace it. It's just a simple way to
create a basic window with some standard features. And if the addon developer
needs more flexibility, it's possible to extend this class to override some
methods and add new features.

@classmod Views.Windows.Window
]]
local Window = {}
    Window.__index = Window
    Window.__ = self
    self:addClass('Window', Window)

    --[[--
    Window constructor.

    When built with an id and the library is created with the data property,
    the window will be capable to persist its position, size, and other user
    preferences.

    @param string id The window identifier, which is used mostly to persist
                     information about the window, like its position and size
    ]]
    function Window.__construct(id)
        local self = setmetatable({}, Window)

        self.firstPosition = {point = 'CENTER', relativePoint = 'CENTER', xOfs = 0, yOfs = 0}
        self.firstSize = {width = 128, height = 128}
        self.firstVisibility = true
        self.id = id

        self.contentChildren = {}

        return self
    end

    --[[--
    Decides whether this window instance should proxy to the player's or the
    global configuration instance.

    By default, the window will proxy to the global configuration instance.
    ]]
    function Window:config(...)
        if self.persistStateByPlayer then
            return self.__:playerConfig(...)
        end
        
        return self.__:config(...)
    end

    --[[--
    Creates the window frame if it doesn't exist yet.

    @treturn Views.Windows.Window The window instance, for method chaining
    ]]
    function Window:create()
        if self.window then return self end

        self.window = self:createFrame()

        self:createTitleBar()
        self:createFooter()

        self:setWindowPositionOnCreation()
        self:setWindowSizeOnCreation()
        self:setWindowVisibilityOnCreation()

        self:createScrollbar()
        self:createContentFrame()

        self:positionContentChildFrames()

        return self
    end

    --[[--
    Creates a close button in the title bar.

    This method shouldn't be called directly. It's considered a complement
    to the createTitleBar() method.

    @local

    @treturn table The button created by CreateFrame
    ]]
    function Window:createCloseButton()
        local button = CreateFrame('Button', nil, self.titleBar, 'UIPanelCloseButton')
        button:SetPoint('RIGHT', self.titleBar, 'RIGHT', -5, 0)
        button:SetScript('OnClick', function()
            self:setVisibility(false)
        end)

        self.closeButton = button

        return self.closeButton
    end

    --[[--
    Creates the content frame, where the window's content will be placed.

    This method shouldn't be called directly. It's considered a complement
    to the create() method.

    @local

    @treturn table The content frame created by CreateFrame
    ]]
    function Window:createContentFrame()
        local contentFrame = CreateFrame('Frame', nil, self.scrollbar)
        contentFrame:SetSize(self.scrollbar:GetWidth(), self.scrollbar:GetHeight())
        self.scrollbar:SetScrollChild(contentFrame)

        self.contentFrame = contentFrame

        -- this is necessary to make the content frame width follow
        -- the scrollbar width
        self.scrollbar:SetScript('OnSizeChanged', function(target)
            self.contentFrame:SetWidth(target:GetWidth())
        end)

        return self.contentFrame
    end

    --[[--
    Creates a footer bar that contains a resize button.

    This method shouldn't be called directly. It's considered a complement
    to the create() method.

    @local

    @treturn table The footer bar frame created by CreateFrame
    ]]
    function Window:createFooter()
        local frame = CreateFrame('Frame', nil, self.window, 'BackdropTemplate')
        frame:SetPoint('BOTTOMLEFT', self.window, 'BOTTOMLEFT', 0, 0)
        frame:SetPoint('BOTTOMRIGHT', self.window, 'BOTTOMRIGHT', 0, 0)
        frame:SetHeight(35)
        frame:SetBackdrop({
            bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
            edgeFile = '',
            edgeSize = 4,
            insets = {left = 4, right = 4, top = 4, bottom = 4},
        })
        frame:SetBackdropColor(0, 0, 0, .8)

        self.footer = frame

        self:createResizeButton()

        return self.footer
    end

    --[[--
    This is just a facade method to call World of Warcraft's CreateFrame.

    @local

    @see Views.Windows.Window.create

    @treturn table The window frame created by CreateFrame
    ]]
    function Window:createFrame()
        local frame = CreateFrame('Frame', nil, UIParent, 'BackdropTemplate')

        frame:SetBackdrop({
            bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
            edgeFile = '',
            edgeSize = 4,
            insets = {left = 4, right = 4, top = 4, bottom = 4},
        })
        frame:SetBackdropColor(0, 0, 0, .5)
        frame:SetBackdropBorderColor(0, 0, 0, 1)
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:SetResizable(true)
        frame:SetScript('OnSizeChanged', function(target)
            local width, height = target:GetWidth(), target:GetHeight()
            if width < 100 then target:SetWidth(100) end
            if height < 100 then target:SetHeight(100) end

            self:storeWindowSize()
        end)

        return frame
    end

    --[[--
    Creates a resize button in the footer bar.

    This method shouldn't be called directly. It's considered a complement
    to the createFooter() method.

    @local

    @treturn table The button created by CreateFrame
    ]]
    function Window:createResizeButton()
        local button = CreateFrame('Button', nil, self.footer)
        button:SetPoint('RIGHT', self.footer, 'RIGHT', -10, 0)
        button:SetSize(20, 20)
        button:SetNormalTexture('Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up')
        button:SetHighlightTexture('Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight')
        button:SetScript('OnMouseDown', function(mouse, mouseButton)
            if mouseButton == 'LeftButton' then
                self.window:StartSizing('BOTTOMRIGHT')
                mouse:GetHighlightTexture():Hide()
            end
        end)
        button:SetScript('OnMouseUp', function(mouse)
            self.window:StopMovingOrSizing()
            mouse:GetHighlightTexture():Show()
        end)

        self.resizeButton = button

        return self.resizeButton
    end

    --[[--
    Creates a scrollbar to the window's content area.

    This method shouldn't be called directly. It's considered a complement
    to the create() method.

    @local

    @treturn table The scrollbar frame created by CreateFrame
    ]]
    function Window:createScrollbar()
        local scrollbar = CreateFrame('ScrollFrame', nil, self.window, 'UIPanelScrollFrameTemplate')
        scrollbar:SetPoint('TOP', self.titleBar, 'BOTTOM', 0, -5)
        scrollbar:SetPoint('BOTTOM', self.footer, 'TOP', 0, 5)
        scrollbar:SetPoint('LEFT', self.window, 'LEFT', 5, 0)
        scrollbar:SetPoint('RIGHT', self.window, 'RIGHT', -35, 0)

        self.scrollbar = scrollbar

        return self.scrollbar
    end

    --[[--
    Creates a title bar that contains a title and a close button.

    This method shouldn't be called directly. It's considered a complement
    to the create() method.

    @local

    @treturn table The title bar frame created by CreateFrame
    ]]
    function Window:createTitleBar()
        local frame = CreateFrame('Frame', nil, self.window, 'BackdropTemplate')

        frame:SetPoint('TOPLEFT', self.window, 'TOPLEFT', 0, 0)
        frame:SetPoint('TOPRIGHT', self.window, 'TOPRIGHT', 0, 0)
        frame:SetHeight(35)
        frame:SetBackdrop({
            bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
            edgeFile = '',
            edgeSize = 4,
            insets = {left = 4, right = 4, top = 4, bottom = 4},
        })
        frame:SetBackdropColor(0, 0, 0, .8)
        frame:SetScript('OnMouseDown', function(mouse, mouseButton)
            if mouseButton == 'LeftButton' then
                self.window:StartMoving()
            end
        end)
        frame:SetScript('OnMouseUp', function(mouse, mouseButton)
            if mouseButton == 'LeftButton' then
                self.window:StopMovingOrSizing()
                self:storeWindowPoint()
            end
        end)

        self.titleBar = frame

        self:createCloseButton()
        self:createTitleText()

        return self.titleBar
    end

    --[[--
    Creates the title text in the title bar.

    This method shouldn't be called directly. It's considered a complement
    to the createTitleBar() method.

    @local

    @treturn table The title text frame created by CreateFrame
    ]]
    function Window:createTitleText()
        local frame = self.titleBar:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        frame:SetPoint('LEFT', self.titleBar, 'LEFT', 10, 0)
        frame:SetText(self.title)

        self.titleText = frame

        return self.titleText
    end

    --[[--
    Gets a window property using the library configuration instance.

    This method is used internally by the library to persist the window's
    state. It's not meant to be called by addons.

    @local

    @tparam string key The property key

    @treturn any The property value
    ]]
    function Window:getProperty(key)
        return self:config(self:getPropertyKey(key))
    end

    --[[--
    Gets the property key used by the window instance to persist its state
    using the library configuration instance.

    A property key is a result of the concatenation of a static prefix, this
    window's id, and the key parameter.

    This method is used internally by the library to persist the window's
    state. It's not meant to be called by addons.

    @local

    @tparam string key The property key

    @treturn string The property key used by the window instance to persist
                    its state using the library configuration instance
    ]]
    function Window:getPropertyKey(key)
        return 'windows.' .. self.id .. '.' .. key
    end

    --[[--
    Gets the window's frame instance.

    This method has effect only after Window:create() is called.

    @treturn table The window frame instance
    ]]
    function Window:getWindow()
        return self.window
    end

    --[[--
    Hides the window.

    This is just a facade method to call the Hide method on the window frame.
    However, it shouldn't be used by addons as an internal method. Use
    setVisibility(false) instead.

    @local
    @see Views.Windows.Window.setVisibility
    ]]
    function Window:hide()
        self.window:Hide()
    end

    --[[--
    Determines if the window is persisting its state.

    A window is considered to be persisting its state if it has an id and the
    library is created with a configuration set.

    @treturn boolean true if the window is persisting its state, false otherwise
    ]]
    function Window:isPersistingState()
        return self.__.str:isNotEmpty(self.id) and self.__:isConfigEnabled()
    end

    --[[--
    Positions the content children frames inside the content frame.

    This is an internal method and it shouldn't be called by addons.

    @local
    --]]
    function Window:positionContentChildFrames()
        -- sets the first relative frame the content frame itself
        -- but after the first child, the relative frame will be the last
        local lastRelativeTo = self.contentFrame
        local totalChildrenHeight = 0

        for _, child in ipairs(self.contentChildren) do
            child:SetParent(self.contentFrame)
            child:SetPoint('TOPLEFT', lastRelativeTo, lastRelativeTo == self.contentFrame and 'TOPLEFT' or 'BOTTOMLEFT', 0, 0)
            child:SetPoint('TOPRIGHT', lastRelativeTo, lastRelativeTo == self.contentFrame and 'TOPRIGHT' or 'BOTTOMRIGHT', 0, 0)

            lastRelativeTo = child
            totalChildrenHeight = totalChildrenHeight + child:GetHeight()
        end

        self.contentFrame:SetHeight(totalChildrenHeight)
    end

    --[[--
    Sets the window's content, which is a table of frames.

    The Stormwind Library Window was designed to accept a list of frames to
    compose its content. When create() is called, a content frame wrapped by
    a vertical scrollbar is created, but the content frame is empty.

    This method is used to populate the content frame with the frames passed
    in the frames parameter. The frames then will be positioned sequentially
    from top to bottom, with the first frame being positioned at the top and
    the last frame at the bottom. Their width will be the same as the content
    frame's width and will grow horizontally to the right if the whole
    window is resized.

    Please, read the library documentation for more information on how to
    work with the frames inside the window's content.

    @tparam table frames The list of frames to be placed inside the content frame

    @treturn Views.Windows.Window The window instance, for method chaining

    @usage
        local frameA = CreateFrame(...)
        local frameB = CreateFrame(...)
        local frameC = CreateFrame(...)

        window:setContent({frameA, frameB, frameC})
    ]]
    function Window:setContent(frames)
        self.contentChildren = frames

        if self.contentFrame then self:positionContentChildFrames() end

        return self
    end

    --[[--
    Sets the window's first position.

    The first position is the position that the window will have when it's
    first created. If the player moves the window and this window is
    persisting its state, this property will be ignored.

    Because this class represents a window that's not tied to any specific
    frame, the relativeTo parameter will be omitted. The window will always
    be created with a nil relativeTo parameter.

    @tparam table position The position table, with the keys point, relativePoint, xOfs, and yOfs

    @treturn Views.Windows.Window The window instance, for method chaining

    @usage
        window:setFirstSize({point = 'CENTER', relativePoint = 'CENTER', xOfs = 0, yOfs = 0})
    ]]
    function Window:setFirstPosition(position)
        self.firstPosition = position
        return self
    end

    --[[--
    Sets the window's first size.

    The first size is the size that the window will have when it's first
    created. If the player resizes the window and this window is persisting
    its state, this property will be ignored.

    @tparam table size The size table, with the keys width and height

    @treturn Views.Windows.Window The window instance, for method chaining

    @usage
        window:setFirstSize({width = 200, height = 100})
    ]]
    function Window:setFirstSize(size)
        self.firstSize = size
        return self
    end

    --[[--
    Sets the window's first visibility.

    The first visibility is the visibility that the window will have when
    it's first created. If the player hides the window and this window is
    persisting its state, this property will be ignored.

    @tparam boolean visibility The first visibility state

    @treturn Views.Windows.Window The window instance, for method chaining

    @usage
        window:setFirstVisibility(false)
    ]]
    function Window:setFirstVisibility(visibility)
        self.firstVisibility = visibility
        return self
    end

    --[[--
    Sets the window instance to have its stated persisted in the player's
    configuration instead of the global one.

    @tparam boolean value Whether the window should persist its state by player

    @treturn Views.Windows.Window The window instance, for method chaining
    ]]
    function Window:setPersistStateByPlayer(value)
        self.persistStateByPlayer = value
        return self
    end

    --[[--
    Sets a window property using the library configuration instance.

    This method is used internally by the library to persist the window's
    state. It's not meant to be called by addons.

    @local
    
    @tparam string key The property key
    @param any value The property value
    ]]
    function Window:setProperty(key, value)
        self:config({
            [self:getPropertyKey(key)] = value
        })
    end

    --[[--
    Sets the window title.

    The window title will be displayed in the title bar, the same one that
    users can click and drag to move the window.

    @param string title The window title
    @treturn Views.Windows.Window The window instance, for method chaining

    @usage
        window:setTitle('My Window Title')
    ]]
    function Window:setTitle(title)
        self.title = title
        return self
    end

    --[[--
    Sets the window visibility.

    This is the method to be called by addons to show or hide the window,
    instead of the local show() and hide(), considering that it not only
    controls the window visibility but also persists the state if the window
    is persisting its state.

    @tparam boolean visible The visibility state

    @treturn Views.Windows.Window The window instance, for method chaining
    --]]
    function Window:setVisibility(visible)
        if visible then self:show() else self:hide() end

        if self:isPersistingState() then self:setProperty('visibility', visible) end

        return self
    end

    --[[--
    Sets the window position on creation.

    This method is called when the window is created, and it sets the window
    position to the first position set by the developer or the persisted
    position if it's found.

    This method shouldn't be called directly. It's considered a complement
    to the create() method.

    @local
    ]]
    function Window:setWindowPositionOnCreation()
        local point = self.firstPosition.point
        local relativeTo = self.firstPosition.relativeTo
        local relativePoint = self.firstPosition.relativePoint
        local xOfs = self.firstPosition.xOfs
        local yOfs = self.firstPosition.yOfs

        if self:isPersistingState() then
            point = self:getProperty('position.point') or point
            relativeTo = self:getProperty('position.relativeTo') or relativeTo
            relativePoint = self:getProperty('position.relativePoint') or relativePoint
            xOfs = self:getProperty('position.xOfs') or xOfs
            yOfs = self:getProperty('position.yOfs') or yOfs
        end

        self.window:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
    end

    --[[--
    Sets the window size on creation.

    This method is called when the window is created, and it sets the window
    size to the first size set by the developer or the persisted size if it's
    found.

    This method shouldn't be called directly. It's considered a complement
    to the create() method.

    @local
    ]]
    function Window:setWindowSizeOnCreation()
        local w = self.firstSize.width
        local h = self.firstSize.height

        if self:isPersistingState() then
            h = self:getProperty('size.height') or h
            w = self:getProperty('size.width')  or w
        end

        self.window:SetSize(w, h)
    end

    --[[--
    Sets the window visibility on creation.

    This method is called when the window is created, and it sets the window
    visibility to the first state set by the developer or the persisted
    state if it's found.

    This method shouldn't be called directly. It's considered a complement
    to the create() method.

    @local
    ]]
    function Window:setWindowVisibilityOnCreation()
        local visibility = self.firstVisibility

        if self:isPersistingState() then
            local storedVisibility = self:getProperty('visibility')

            -- these conditionals are necessary so Lua doesn't consider falsy values
            -- as false, but as nil
            if storedVisibility ~= nil then
                visibility = self.__.bool:isTrue(storedVisibility)
            else
                visibility = self.firstVisibility
            end
        end

        self:setVisibility(visibility)
    end

    --[[--
    Shows the window.

    This is just a facade method to call the Show method on the window frame.
    However, it shouldn't be used by addons as an internal method. Use
    setVisibility(true) instead.

    @local
    @see Views.Windows.Window.setVisibility
    ]]
    function Window:show()
        self.window:Show()
    end

    --[[--
    Stores the window's point in the configuration instance if the window is
    persisting its state.

    This method is used internally by the library to persist the window's
    state. It's not meant to be called by addons.

    @local
    ]]
    function Window:storeWindowPoint()
        if not self:isPersistingState() then return end

        local point, relativeTo, relativePoint, xOfs, yOfs = self.window:GetPoint()

        self:setProperty('position.point', point)
        self:setProperty('position.relativeTo', relativeTo)
        self:setProperty('position.relativePoint', relativePoint)
        self:setProperty('position.xOfs', xOfs)
        self:setProperty('position.yOfs', yOfs)
    end

    --[[--
    Stores the window's size in the configuration instance if the window is
    persisting its state.

    This method is used internally by the library to persist the window's
    state. It's not meant to be called by addons.

    @local
    ]]
    function Window:storeWindowSize()
        if not self:isPersistingState() then return end

        local width, height = self.window:GetWidth(), self.window:GetHeight()

        self:setProperty('size.height', height)
        self:setProperty('size.width', width)
    end
-- end of Window

    return self
end