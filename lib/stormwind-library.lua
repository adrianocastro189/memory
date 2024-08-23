
--- Stormwind Library
-- @module stormwind-library
if (StormwindLibrary_v1_12_2) then return end
        
StormwindLibrary_v1_12_2 = {}
StormwindLibrary_v1_12_2.__index = StormwindLibrary_v1_12_2

function StormwindLibrary_v1_12_2.new(props)
    local self = setmetatable({}, StormwindLibrary_v1_12_2)
    -- Library version = '1.12.2'

-- list of callbacks to be invoked when the library is loaded
self.loadCallbacks = {}

--[[
Removes the callback loader and its properties.
]]
function self:destroyCallbackLoader()
    self.destroyCallbackLoader = nil
    self.invokeLoadCallbacks = nil
    self.loadCallbacks = nil
    self.onLoad = nil
end

--[[
Invokes all the callbacks that have been enqueued.
]]
function self:invokeLoadCallbacks()
    self.arr:each(self.loadCallbacks, function(callback)
        callback()
    end)

    self:destroyCallbackLoader()
end

--[[
Enqueues a callback function to be invoked when the library is loaded.

@tparam function callback The callback function to be invoked when the library is loaded
]]
function self:onLoad(callback)
    table.insert(self.loadCallbacks, callback)
end

-- invokes a local callback that won't be invoked in game
-- for testing purposes only
self:onLoad(function()
    if not self.environment:inGame() then
        self.callbacksInvoked = true
    end
end)


--[[
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
function self:dd(...)
    local inGame = self.environment and self.environment:inGame() or false
    
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
The Arr class contains helper functions to manipulate arrays.

@classmod Support.Arr

@usage
    -- library is an instance of the Stormwind Library
    library.arr
]]
local Arr = {}
    Arr.__index = Arr
    Arr.__ = self

    --[[
    Iterates over the list values and calls a callback function for each of
    them, returning true if at least one of the calls returns true.

    Once the callback returns true, the method stops the iteration and
    returns, which means that the callback won't be called for the remaining
    items in the list.

    The callback function must be a function that accepts (val) or (val, i)
    where val is the object in the interaction and i it's index. It also must
    return a boolean value.

    @tparam table list The list to be iterated
    @tparam function callback The function to be called for each item in the list
    
    @treturn boolean Whether the callback returned true for at least one item
    ]]
    function Arr:any(list, callback)
        for i, val in pairs(list or {}) do
            if callback(val, i) then
                return true
            end
        end

        return false
    end

    --[[--
    Concatenates the values of the arrays passed as arguments into a single
    array.

    This method should be called only for arrays, as it won't consider table
    keys and will only concatenate their values.

    @tparam table ... The arrays to be concatenated

    @treturn table The concatenated array

    @usage
        local list1 = {1, 2}
        local list2 = {3, 4}
        local results = library.arr:concat(list1, list2)
        -- results = {1, 2, 3, 4}
    ]]
    function Arr:concat(...)
        local results = {}
        self:each({...}, function(list)
            self:each(list, function(value)
                table.insert(results, value)
            end)
        end)
        return results
    end

    --[[--
    Counts the number of items in a list.

    This method solves the problem of counting the number of items in a list
    that's not an array, so it can't be counted using the # operator.

    @tparam table list The list to be counted

    @treturn integer The number of items in the list

    @usage
        local list = {a = 'a', b = 'b', c = 'c'}
        local count = library.arr:count(list)
        -- count = 3
    ]]
    function Arr:count(list)
        local count = 0
        self:each(list, function()
            count = count + 1
        end)
        return count
    end

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
            current = self:safeGet(current, keys[i])
            if current == nil then
                return default
            end
        end
    
        return current
    end

    --[[--
    Determines whether a table has a key or not.

    This method is a simple wrapper around the get() method, checking if the
    value returned is not nil. It also accepts a dot notation key.

    @tparam table list the table to be checked
    @tparam string key a dot notation key to be used in the search

    @treturn boolean whether the key is in the table or not

    @usage
        local list = {a = {b = {c = 1}}}
        local hasKey = library.arr:hasKey(list, 'a.b.c')
        -- hasKey = true
    ]]
    function Arr:hasKey(list, key)
        return self:get(list, key) ~= nil
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
        if not self:hasKey(list, key) then self:set(list, key, initialValue) end
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
    Safe get is an internal method, not meant to be used by other classes
    that will return a value from a list given a key that can be a string
    or a number.

    This method is a helper to allow dot notation keys to contain numbers,
    which was a limitation of the get() method until version 1.10.0.

    @internal

    @tparam table list the table to have the value retrieved
    @tparam string|number key the key to be used in the search

    @treturn any|nil the value found in the list
    ]]
    function Arr:safeGet(list, key)
        if list == nil then
            return nil
        end

        local value = list[key]

        if value ~= nil then
            return value
        end

        return list[tonumber(key)]
    end

    --[[--
    Sets a value using arrays dot notation.

    It will basically iterate over the keys separated by "." and create
    the missing indexes, finally setting the last key with the value in
    the args list.

    @NOTE: Although dot notation keys are supported and when retrieving
           values they can contain numbers or strings, when setting values with
           numbers as keys, nested or not, they will be converted to strings.
           That's a convention to avoid questions about the type of the keys,
           considering that when retrieving, the library can check both types
           and return the value, but when setting, it's not possible to
           imagine what's the intention of the developer.

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
    colors: table, optional
        primary: string, optional
        secondary: string, optional
    command: string, optional
    data: table, optional
    inventory: table, optional
        track: boolean, optional
    name: string, optional
    version: string, optional
}
]]
self.addon = {}

self.addon.colors = self.arr:get(props or {}, 'colors', {})
self.addon.command = self.arr:get(props or {}, 'command')
self.addon.data = self.arr:get(props or {}, 'data')
self.addon.inventory = self.arr:get(props or {}, 'inventory', {
    track = false,
})
self.addon.name = self.arr:get(props or {}, 'name')
self.addon.version = self.arr:get(props or {}, 'version')

local requiredProperties = {
    'name'
}

for _, property in ipairs(requiredProperties) do
    if not self.addon[property] then
        error(string.format('The addon property "%s" is required to initialize Stormwind Library.', property))
    end
end

--[[
Contains a list of class structures that Stormwind Library can handle to allow
instantiation, protection in case of abstractions, and inheritance.
]]
self.classes = {}

--[[
Maps all the possible class types Stormwind Library can handle.
]]
self.classTypes = self.arr:freeze({
    CLASS_TYPE_ABSTRACT = 1,
    CLASS_TYPE_CONCRETE = 2,
})

--[[
Registers an abstract class.

@tparam string classname The name of the abstract class to be registered
@tparam table classStructure The abstract class structure to be registered
@tparam nil|string|table clientFlavors The client flavors the class is supported by
--]]
function self:addAbstractClass(classname, classStructure, clientFlavors)
    self:addClass(classname, classStructure, clientFlavors, self.classTypes.CLASS_TYPE_ABSTRACT)
end

--[[
Helper method that extends a class structure with another by a parent class name
and also adds the class.

Calling this method is the same of calling extend() and addClass() in sequence.

@tparam string classname The name of the class to be registered
@tparam table classStructure The class structure to be registered
@tparam string parentClassname The name of the parent class to be extended with
@tparam nil|string|table clientFlavors The client flavors the class is supported by
@tparam integer|nil classType The class type, represented by the classTypes constants
]]
function self:addChildClass(classname, classStructure, parentClassname, clientFlavors, classType)
    self:extend(classStructure, parentClassname)
    self:addClass(classname, classStructure, clientFlavors, classType)
end

--[[
Registers a class so the library is able to instantiate it later.

This method just updates the library classes table by registering a class
for the client flavors it's supported.

@tparam string classname The name of the class to be registered
@tparam table classStructure The class structure to be registered
@tparam nil|string|table clientFlavors The client flavors the class is supported by
@tparam integer|nil classType The class type, represented by the classTypes constants
]]
function self:addClass(classname, classStructure, clientFlavors, classType)
    local arr = self.arr

    -- defaults to concrete class if not specified
    classType = classType or self.classTypes.CLASS_TYPE_CONCRETE

    clientFlavors = arr:wrap(clientFlavors or {
        self.environment.constants.CLIENT_CLASSIC,
        self.environment.constants.CLIENT_CLASSIC_ERA,
        self.environment.constants.CLIENT_RETAIL,
        self.environment.constants.TEST_SUITE,
    })

    arr:each(clientFlavors, function(clientFlavor)
        arr:set(self.classes, clientFlavor .. '.' .. classname, {
            structure = classStructure,
            type = classType,
        })
    end)
end

--[[
Provides class inheritance by extending a class structure with another by its
name.

Calling this method is the same of getting the parent class structure with
getClass() and setting the child class structure metatable. Consider this as
a helper method to improve code readability.

It's important to note that this method respects the client flavors strategy 
just like getClass(), which means it will only work properly if the parent
class is registered for the same client flavors as where this method is called.

@tparam table classStructure The class structure to be extended
@tparam string parentClassname The name of the parent class to be extended with
]]
function self:extend(classStructure, parentClassname)
    local parentStructure = self:getClass(parentClassname)
    setmetatable(classStructure, parentStructure)
end

--[[
Returns a class structure by its name.

This method's the same as accessing self.classes[classname].

@tparam string classname The name of the class to be returned
@tparam string output The output format, either 'structure' (default) or 'type'

@treturn integer|table The class structure or type, depending on the output parameter
]]
function self:getClass(classname, output)
    local clientFlavor = self.environment:getClientFlavor()

    return self.classes[clientFlavor][classname][output or 'structure']
end

--[[
This method emulates the new keyword in OOP languages by instantiating a
class by its name as long as the class has a __construct() method with or
without parameters.

@tparam string classname The name of the class to be instantiated
@param ... The parameters to be passed to the class constructor

@treturn table The class instance
]]
function self:new(classname, ...)
    local classType = self:getClass(classname, 'type')

    if classType == self.classTypes.CLASS_TYPE_ABSTRACT then
        error(classname .. ' is an abstract class and cannot be instantiated')
    end

    return self:getClass(classname).__construct(...)
end


--[[--
The Interval class is a utility class that is capable of executing a given
function at a specified interval.

It uses the World of Warcraft API ticker in the background to mimic the
setInterval() function in JavaScript. And different from other support
classes, Interval is an instance based class, which means it requires one
instance per interval, allowing multiple intervals to be run at the same time.

@classmod Support.Interval
]]
local Interval = {}
    Interval.__index = Interval
    Interval.__ = self
    self:addClass('Interval', Interval)

    --[[--
    Interval constructor.
    ]]
    function Interval.__construct()
        return setmetatable({}, Interval)
    end

    --[[--
    Sets the callback to be executed at each interval.

    @tparam function value the callback to be executed at each interval

    @treturn Support.Interval self
    ]]
    function Interval:setCallback(value)
        self.callback = value
        return self
    end

    --[[--
    Sets the number of seconds between each interval.

    @tparam integer value the number of seconds between each interval

    @treturn Support.Interval self
    ]]
    function Interval:setSeconds(value)
        self.seconds = value
        return self
    end

    --[[--
    Starts the interval.

    @treturn Support.Interval self
    ]]
    function Interval:start()
        self.ticker = C_Timer.NewTicker(self.seconds, self.callback)
        return self
    end

    --[[--
    Executes the callback immediately and starts the interval.

    @see Support.Interval.start

    @treturn Support.Interval self
    ]]
    function Interval:startImmediately()
        self.callback()
        self:start()
        return self
    end

    --[[--
    Stops the interval if it's running.

    @treturn Support.Interval self
    ]]
    function Interval:stop()
        if self.ticker then
            self.ticker:Cancel()
        end
        
        return self
    end
-- end of Interval


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
    self:maybeInitializeConfiguration()

    return self.configuration ~= nil
end

--[[
May initialize the addon configuration if it's not set yet.
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
    Outputs an error message using the game's error frame.

    The error frame by default is a red message that appears in the
    middle of the screen, usually used for errors that need the user's
    attention like attempting to use an ability that is on cooldown or
    trying to mount in a place where it's not allowed.

    If, for some reason, the error frame is not available, it will fall back
    to the default output method.

    @tparam string message The error message to be printed
    ]]
    function Output:error(message)
        if self.__.arr:hasKey(_G, 'UIErrorsFrame.AddMessage') then
            UIErrorsFrame:AddMessage(message, 1.0, 0.1, 0.1)
            return
        end

        self:out('Error: '..message)
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

-- allows Output to be instantiated, very useful for testing
self:addClass('Output', Output)

--[[
Gets a formatted versioned name label for the addon.

This method is similar to getVersionLabel(), but it also includes the addon
name in the label.

When the version is not set, it will return the addon name only.

@treturn string The addon name and version label
]]
function self:getVersionedNameLabel()
    local versionLabel = self:getVersionLabel()

    return self.addon.name .. (versionLabel and ' ' .. versionLabel or '')
end

--[[
Gets a formatted version label for the addon.

By default, a version label is simply the version number prefixed with a 'v'.

For this method to work, the addon property 'version' must be set during
initialization, otherwise it will return nil.

@treturn string The version addon property prefixed with a 'v'
]]
function self:getVersionLabel()
    if self.addon.version then
        return 'v' .. self.addon.version
    end

    return nil
end


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
    Sets the command arguments validator.

    A command arguments validator is a function that will be executed before
    the command callback. It must return 'valid' if the arguments are valid
    or any other value if the arguments are invalid.

    @tparam function value the command arguments validator

    @return self

    @usage
        command:setArgsValidator(function(...)
            -- validate the arguments
            return 'valid'
        end)
    ]]
    function Command:setArgsValidator(value)
        self.argsValidator = value
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
    Validates the command arguments if the command has an arguments validator.

    If no arguments validator is set, the method will return 'valid' as by the
    default, the command must consider the user input as valid to execute. This
    also allows that addons can validate the arguments internally.

    @param ... The arguments to be validated

    @treturn string 'valid' if the arguments are valid or any other value otherwise
    ]]
    function Command:validateArgs(...)
        if self.argsValidator then
            return self.argsValidator(...)
        end

        return 'valid'
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
    Gets a command instance by its operation or the default help command.

    To avoid any confusions, although loaded by an operation, the return
    command is an instance of the Command class, so that's why this method is
    prefixed with getCommand.

    @tparam string operation The operation associated with the command

    @treturn Command The command instance or the default help command
    ]]
    function CommandsHandler:getCommandOrDefault(operation)
        local command = operation and self.operations[operation] or nil

        if command and command.callback then
            return command
        end

        return self.operations['help']
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
    for the operation, if it exists, or the default one otherwise.

    But before invoking the callback, it validates the arguments that were
    passed to the operation in case the command has an arguments validator.
    
    @local

    @tparam string operation The operation that was triggered
    @tparam table args The arguments that were passed to the operation
    ]]
    function CommandsHandler:maybeInvokeCallback(operation, args)
        local command = self:getCommandOrDefault(operation)

        local validationResult = command:validateArgs(self.__.arr:unpack(args))

        if validationResult ~= 'valid' then
            self.__.output:out(validationResult)
            return
        end

        command.callback(self.__.arr:unpack(args))
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


--[[--
The Events class is a layer between World of Warcraft events and events
triggered by the Stormwind Library.

When using this library in an addon, it should focus on listening to the
library events, which are more detailed and have more mapped parameters.

@classmod Facades.Events
]]
local Events = {}
    Events.__index = Events
    Events.__ = self
    self:addClass('Events', Events)

    --[[--
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

    --[[--
    Creates the events frame, which will be responsible for capturing
    all World of Warcraft events and forwarding them to the library
    handlers.

    @local
    ]]
    function Events:createFrame()
        self.eventsFrame = CreateFrame('Frame')
        self.eventsFrame:SetScript('OnEvent', function (source, event, ...)
            self:handleOriginal(source, event, ...)
        end)
    end

    --[[--
    This is the main event handler method, which will capture all
    subscribed World of Warcraft events and forwards them to the library
    handlers that will later notify other subscribers.

    It's important to mention that addons shouldn't care about this
    method, which is an internal method to the Events class.

    @tparam table source The Events instance, used when calling Events.handleOriginal
    @tparam string event The World of Warcraft event to be handled
    @param ... The parameters passed by the World of Warcraft event
    ]]
    function Events:handleOriginal(source, event, ...)
        local callback = self.originalListeners[event]

        if callback then
            callback(...)
        end
    end

    --[[--
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

    --[[--
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

    --[[--
    Notifies all listeners of a specific event.

    This method should be called by event handlers to notify all listeners
    of a specific Stormwind Library event.

    @tparam string event The Stormwind Library event to notify
    @param ... The parameters to be passed to the event listeners
    ]]
    function Events:notify(event, ...)
        local params = {...}

        local listeners = self.__.arr:get(self.listeners, event, {})

        self.__.arr:map(listeners, function (listener)
            listener(self.__.arr:unpack(params))
        end)
    end
-- end of Events

self.events = self:new('Events')

local events = self.events

-- the Stormwind Library event triggered when a player engages in combat
events.EVENT_NAME_PLAYER_ENTERED_COMBAT = 'PLAYER_ENTERED_COMBAT'

-- the Stormwind Library event triggered when a player leaves combat
events.EVENT_NAME_PLAYER_LEFT_COMBAT = 'PLAYER_LEFT_COMBAT'

-- handles the World of Warcraft PLAYER_REGEN_DISABLED event
events:listenOriginal('PLAYER_REGEN_DISABLED', function ()
    self.currentPlayer:setInCombat(true)

    events:notify(events.EVENT_NAME_PLAYER_ENTERED_COMBAT)
end)

-- handles the World of Warcraft PLAYER_REGEN_ENABLED event
events:listenOriginal('PLAYER_REGEN_ENABLED', function ()
    self.currentPlayer:setInCombat(false)

    events:notify(events.EVENT_NAME_PLAYER_LEFT_COMBAT)
end)

local events = self.events

-- the Stormwind Library event triggered when a player levels up
events.EVENT_NAME_PLAYER_LEVEL_UP = 'PLAYER_LEVEL_UP'

-- handles the World of Warcraft PLAYER_LEVEL_UP event
events:listenOriginal('PLAYER_LEVEL_UP', function (newLevel)
    self.currentPlayer:setLevel(newLevel)

    events:notify(events.EVENT_NAME_PLAYER_LEVEL_UP, newLevel)
end)

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

--[[--
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

@local
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

--[[--
Facade for the PetJournal API.

Although C_PetJournal is available in the classic clients, this facade is
not instantiable there considering that its functions are not entirely
functional. For that reason, StormwindLibrary won't hold a default instance
of this class like it does for other facades. Instead, addons must create
their own instances of this class when needed.

@classmod Facades.PetJournal
]]
local PetJournal = {}
    PetJournal.__index = PetJournal
    PetJournal.__ = self
    self:addClass('PetJournal', PetJournal, {
        self.environment.constants.TEST_SUITE,
        self.environment.constants.CLIENT_RETAIL,
    })

    --[[--
    PetJournal constructor.
    ]]
    function PetJournal.__construct()
        return setmetatable({}, PetJournal)
    end

    --[[--
    Gets the species id of the pet currently summoned by the player.

    If the player has no pet summoned, this method returns nil.

    Note that this method doesn't return the pet identifier, or GUID, which
    means the returned id is the species id of the pet, not the pet itself.

    @treturn integer|nil The currently summoned pet species id, or nil if no pet is summoned
    ]]
    function PetJournal:getSummonedPetSpeciesId()
        local petGuid = C_PetJournal.GetSummonedPetGUID()

        if petGuid then
            -- this sanity check is necessary to avoid Lua errors in case no
            -- pet is summoned
            local speciesId = C_PetJournal.GetPetInfoByPetID(petGuid)

            -- don't return C_PetJournal.GetPetInfoByPetID(petGuid) directly
            -- as it will return all the pet info, not just the species id
            return speciesId
        end

        return nil
    end

    --[[--
    Determines whether the player has at least one pet from a given species.

    The C_PetJournal.GetOwnedBattlePetString() API method returns a colored
    string containing the number of pets owned by the player for a given
    species. Example: "|cFFFFD200Collected (1/3)"

    This method just checks if the string is not nil, which means the player
    has at least one pet from the given species.

    @tparam integer speciesId The species ID of the pet to check

    @treturn boolean Whether the player owns at least one pet from the given species
    ]]
    function PetJournal:playerOwnsPet(speciesId)
        return C_PetJournal.GetOwnedBattlePetString(speciesId) ~= nil
    end
-- end of PetJournal

--[[--
The target facade maps all the information that can be retrieved by the
World of Warcraft API target related methods.

This class can also be used to access the target with many other purposes,
like setting the target marker.

@classmod Facades.Target
]]
local Target = {}
    Target.__index = Target
    Target.__ = self
    self:addClass('Target', Target)

    --[[--
    Target constructor.
    ]]
    function Target.__construct()
        return setmetatable({}, Target)
    end

    --[[--
    Gets the target GUID.

    @treturn string|nil The target GUID, or nil if the player has no target
    ]]
    function Target:getGuid()
        return UnitGUID('target')
    end

    --[[--
    Gets the target health.

    In the World of Warcraft API, the UnitHealth('target') function behaves
    differently for NPCs and other players. For NPCs, it returns the absolute
    value of their health, whereas for players, it returns a value between
    0 and 100 representing the percentage of their current health compared
    to their total health.

    @treturn number|nil The target health, or nil if the player has no target
    ]]
    function Target:getHealth()
        return self:hasTarget() and UnitHealth('target') or nil
    end

    --[[--
    Gets the target health in percentage.

    This method returns a value between 0 and 1, representing the target's
    health percentage.

    @treturn number|nil The target health percentage, or nil if the player has no target
    ]]
    function Target:getHealthPercentage()
        return self:hasTarget() and (self:getHealth() / self:getMaxHealth()) or nil
    end

    --[[--
    Gets the target raid marker in the target, if any.

    @treturn Models.RaidMarker|nil The target raid marker, or nil if the player has no target
    ]]
    function Target:getMark()
        local mark = GetRaidTargetIndex('target')

        return mark and self.__.raidMarkers[mark] or nil
    end

    --[[--
    Gets the maximum health of the specified unit.

    In the World of Warcraft API, the UnitHealthMax function is used to
    retrieve the maximum health of a specified unit. When you call
    UnitHealthMax('target'), it returns the maximum amount of health points
    that the targeted unit can have at full health. This function is commonly
    used by addon developers and players to track and display health-related
    information, such as health bars and percentages.

    @treturn number|nil The maximum health of the target, or nil if the player has no target
    ]]
    function Target:getMaxHealth()
        return self:hasTarget() and UnitHealthMax('target') or nil
    end

    --[[--
    Gets the target name.

    @treturn string|nil The target name, or nil if the player has no target
    ]]
    function Target:getName()
        return UnitName('target')
    end

    --[[--
    Determines whether the player has a target or not.

    @treturn boolean Whether the player has a target or not
    ]]
    function Target:hasTarget()
        return nil ~= self:getName()
    end

    --[[--
    Determines whether the target is alive.

    @treturn boolean|nil Whether the target is alive or not, or nil if the player has no target
    ]]
    function Target:isAlive()
        if self:hasTarget() then
            return not self:isDead()
        end
        
        return nil
    end

    --[[--
    Determines whether the target is dead.

    @treturn boolean|nil Whether the target is dead or not, or nil if the player has no target
    ]]
    function Target:isDead()
        return self:hasTarget() and UnitIsDeadOrGhost('target') or nil
    end

    --[[--
    Determines whether the target is marked or not.

    A marked target is a target that has a raid marker on it.

    @treturn boolean Whether the target is marked or not
    ]]
    function Target:isMarked()
        return nil ~= self:getMark()
    end

    --[[--
    Determines whether the target is taggable or not.

    In Classic World of Warcraft, a taggable enemy is an enemy is an enemy that
    can grant experience, reputation, honor, loot, etc. Of course, that would
    depend on the enemy level, faction, etc. But this method checks if another
    player hasn't tagged the enemy before the current player.

    As an example, if the player targets an enemy with a gray health bar, it
    means it's not taggable, then this method will return false.

    @treturn boolean|nil Whether the target is taggable or not, or nil if the player has no target
    ]]
    function Target:isTaggable()
        if not self:hasTarget() then
            return nil
        end

        return not self:isNotTaggable()
    end

    --[[--
    Determines whether the target is already tagged by other player.

    @see Core.Target.isTaggable
    
    @treturn boolean|nil Whether the target is not taggable or not, or nil if the player has no target
    ]]
    function Target:isNotTaggable()
        return UnitIsTapDenied('target')
    end

    --[[--
    Adds or removes a raid marker on the target.

    @see ./src/Models/RaidTarget.lua
    @see https://wowwiki-archive.fandom.com/wiki/API_SetRaidTarget

    @tparam Models.RaidMarker raidMarker The raid marker to be added or removed from the target
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
    self:addAbstractClass('AbstractTooltip', AbstractTooltip)

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
    Handles the event fired from the game when a  unit tooltip is shown.

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

self:onLoad(function()
    self.tooltip = self:new('Tooltip')
    self.tooltip:registerTooltipHandlers()
end)

--[[--
The default implementation of the AbstractTooltip class for the Classic
clients.

@classmod Facades.ClassicTooltip
]]
local ClassicTooltip = {}
    ClassicTooltip.__index = ClassicTooltip
    self:addChildClass('Tooltip', ClassicTooltip, 'AbstractTooltip', {
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
    self:addChildClass('Tooltip', RetailTooltip, 'AbstractTooltip', {
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


--[[--
Creates item instances from multiple sources.

This factory is responsible for being able to instantiate item objects from
different sources, such as item links, item ids, item names, complex strings
containing item information and any other source that's available in the game
that can be used to identify an item.

@classmod Factories.ItemFactory
]]
local ItemFactory = {}
    ItemFactory.__index = ItemFactory
    ItemFactory.__ = self

    --[[--
    ItemFactory constructor.
    ]]
    function ItemFactory.__construct()
        return setmetatable({}, ItemFactory)
    end

    --[[--
    Creates an item instance from container item information, which is a table
    with lots of item properties that usually comes from the game API
    functions like C_Container.GetContainerItemInfo().

    Of course, this method extracts only the properties mapped in the Item
    model, and it will be improved to cover more of them in the future in
    case they are needed.

    The properties accepted in this method can be dumped from the game using
    a slash command like "/dump C_Container.GetContainerItemInfo(0, 1)" and
    making sure there's an item in the first slot of the backpack.

    @tparam table[string] containerItemInfo A table containing item information

    @treturn Models.Item The item instance created from the container item
    ]]
    function ItemFactory:createFromContainerItemInfo(containerItemInfo)
        if not containerItemInfo then
            return nil
        end

        local arr = self.__.arr

        return self.__:new('Item')
            :setName(arr:get(containerItemInfo, 'itemName'))
            :setId(arr:get(containerItemInfo, 'itemID'))
    end
-- end of ItemFactory

self.itemFactory = ItemFactory.__construct()


--[[--
This model represents bags, bank bags, the player's self backpack, and any
other container capable of holding items.

@classmod Models.Container
]]
local Container = {}
    Container.__index = Container
    Container.__ = self
    self:addClass('Container', Container)

    --[[--
    Container constructor.
    ]]
    function Container.__construct()
        local instance = setmetatable({}, Container)

        instance.outdated = true

        return instance
    end

    --[[--
    Marks the container as outdated, meaning that the container's items need
    to be refreshed, mapped again, to reflect the current state of the player
    items in the container.

    It's important to mention that this flag is named "outdated" instead of
    "updated" because as a layer above the game's API, the library will do the
    best it can to keep the container's items updated, but it's not guaranteed
    considering the fact that it can miss some specific events. One thing it
    can be sure is when the container is outdated when the BAG_UPDATE event
    is triggered.

    @treturn Models.Container self
    ]]
    function Container:flagOutdated()
        self.outdated = true
        return self
    end

    --[[--
    Gets the item information for a specific slot in the container using the
    game's C_Container.GetContainerItemInfo API method.

    @local

    @tparam int slot The internal container slot to get the item information from

    @treturn table[string]|nil The item information (if any) in a specific slot
    ]]
    function Container:getContainerItemInfo(slot)
        return C_Container.GetContainerItemInfo(self.slot, slot)
    end

    --[[--
    Gets the container's items.

    Important note: this method may scan the container for items only once.
    After that, it will return the cached list of items. It's necessary to
    call self:refresh() to update the list of items in case the caller needs
    the most up-to-date list, unless there's an event listener updating them
    automatically.

    @treturn table[Models.Item] the container's items
    ]]
    function Container:getItems()
        if self.items == nil or self.outdated then
            self:mapItems()
        end

        return self.items
    end

    --[[--
    Gets the number of slots in the container.

    @treturn int the number of slots in the container
    ]]
    function Container:getNumSlots()
        return C_Container.GetContainerNumSlots(self.slot)
    end

    --[[--
    Determines whether the container has a specific item.

    @tparam int|Models.Item The item ID or item instance to search for

    @treturn boolean
    ]]
    function Container:hasItem(item)
        local arr = self.__.arr

        return arr:any(self:getItems(), function (itemInContainer)
            return itemInContainer.id == arr:get(arr:wrap(item), 'id', item)
        end)
    end

    --[[--
    Scans the container represented by self.slot and updates its internal
    list of items.

    @NOTE: This method was designed to be updated in the future when the
    container class implements a map with slot = item positions. For now,
    it's a simple item mapping that updated the internal items cache.

    @treturn Models.Container self
    ]]
    function Container:mapItems()
        self.items = {}

        for slot = 1, self:getNumSlots() do
            local itemInformation = self:getContainerItemInfo(slot)
            local item = self.__.itemFactory:createFromContainerItemInfo(itemInformation)
            table.insert(self.items, item)
        end

        self.outdated = false

        return self
    end

    --[[--
    This is just a facade for the mapItems() method to improve readability.

    The refresh method just updates the container's internal list of items
    to reflect the current state of the player's container.

    @see Models.Container.mapItems

    @treturn Models.Container self
    ]]
    function Container:refresh()
        return self:mapItems()
    end

    --[[--
    Sets the container slot.

    The slot represents the container's position in the player's inventory.
    
    A list of slots can be found with "/dump Enum.BagIndex" in game.

    @tparam int value the container's slot

    @treturn Models.Container self
    ]]
    function Container:setSlot(value)
        self.slot = value
        return self
    end
-- end of Container

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
    Sets the item id.

    @tparam int value the item's id

    @treturn Models.Item self
    ]]
    function Item:setId(value)
        self.id = value
        return self
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

--[[--
This model represents the group of all player containers condensed as a
single concept.

It's a concept because the game doesn't have a visual inventory, but it
shows the items inside bags, bank slots, keyring, etc, that are mapped as
containers, while the inventory is the "sum" of all these containers.

@classmod Models.Inventory
]]
local Inventory = {}
    Inventory.__index = Inventory
    Inventory.__ = self
    self:addClass('Inventory', Inventory)

    --[[--
    Inventory constructor.
    ]]
    function Inventory.__construct()
        local instance = setmetatable({}, Inventory)

        instance.containers = {}
        instance.outdated = true

        return instance
    end

    --[[--
    Marks the inventory as outdated, meaning that the container's items need
    to be refreshed, mapped again, in which container inside this inventory
    instance to reflect the current state of the player items in all
    containers.

    It's important to mention that this flag is named "outdated" instead of
    "updated" because as a layer above the game's API, the library will do the
    best it can to keep the container's items updated, but it's not guaranteed
    considering the fact that it can miss some specific events. One thing it
    can be sure is when the container is outdated when the BAG_UPDATE event
    is triggered.

    @see Models.Container.flagOutdated

    @treturn Models.Inventory self
    ]]
    function Inventory:flagOutdated()
        self.outdated = true

        self.__.arr:each(self.containers, function (container)
            container:flagOutdated()
        end)

        return self
    end

    --[[--
    Gets all items from the inventory.

    This method will return all items from all containers mapped in the
    inventory.

    Make sure to call this method after any actions that trigger the
    inventory mapping (refresh), to get the most updated items.
    ]]
    function Inventory:getItems()
        self:maybeMapContainers()

        local items = {}

        self.__.arr:each(self.containers, function (container)
            items = self.__.arr:concat(items, container:getItems())
        end)

        return items
    end

    --[[--
    Determines whether the inventory has a specific item.

    @tparam int|Models.Item The item ID or item instance to search for

    @treturn boolean
    ]]
    function Inventory:hasItem(item)
        self:maybeMapContainers()

        return self.__.arr:any(self.containers, function (container)
            return container:hasItem(item)
        end)
    end

    --[[--
    Maps all player containers in the inventory internal list.

    This method will also trigger the mapping of the containers slot, so
    it's expected to have the player items synchronized after this method
    is called.

    @treturn Models.Inventory self
    ]]
    function Inventory:mapContainers()
        if not self.__.arr:get(_G, 'Enum.BagIndex') then
            return
        end

        self.containers = {}

        self.__.arr:each(Enum.BagIndex, function (bagId, bagName)
            local container = self.__:new('Container')
                :setSlot(bagId)
                :mapItems()

            table.insert(self.containers, container)
        end)

        self.outdated = false

        return self
    end

    --[[--
    May map the containers if the inventory is outdated.

    @local
    
    @treturn Models.Inventory self
    ]]
    function Inventory:maybeMapContainers()
        if self.outdated then
            self:mapContainers()
        end

        return self
    end

    --[[--
    Iterates over all containers in the inventory and refreshes their items.

    @treturn Models.Inventory self
    ]]
    function Inventory:refresh()
        self:maybeMapContainers()

        self.__.arr:each(self.containers, function (container)
            container:refresh()
        end)

        return self
    end
-- end of Inventory

if self.addon.inventory.track then
    self.playerInventory = self:new('Inventory')

    self.events:listenOriginal('BAG_UPDATE', function ()
        self.playerInventory:flagOutdated()
    end)
end

--[[--
The macro class maps macro information and allow in game macro updates.

@classmod Models.Macro
]]
local Macro = {}
    Macro.__index = Macro
    Macro.__ = self
    self:addClass('Macro', Macro)

    --[[--
    Macro constructor.

    @tparam string name The macro's name
    ]]
    function Macro.__construct(name)
        local self = setmetatable({}, Macro)

        self.name = name

        -- defaults
        self:setIcon("INV_Misc_QuestionMark")

        return self
    end

    --[[--
    Determines whether this macro exists.

    @treturn boolean Whether the macro exists
    ]]
    function Macro:exists()
        return GetMacroIndexByName(self.name) > 0
    end

    --[[--
    Saves the macro, returning the macro id.

    If the macro, identified by its name, doesn't exist yet, it will be created.

    It's important to mention that this whole Macro class can have weird
    behavior if it tries to save() a macro with dupicated names. Make sure this
    method is called for unique names.

    Future implementations may fix this issue, but as long as it uses unique
    names, this model will work as expected.

    @treturn integer The macro id
    ]]
    function Macro:save()
        if self:exists() then
            return EditMacro(self.name, self.name, self.icon, self.body)
        end

        return CreateMacro(self.name, self.icon, self.body)
    end

    --[[--
    Sets the macro body.

    The macro's body is the code that will be executed when the macro's
    triggered.

    If the value is an array, it's considered a multiline body, and lines will
    be separated by a line break.

    @tparam array[string]|string value The macro's body

    @treturn Models.Macro self The current instance for method chaining
    ]]
    function Macro:setBody(value)
        self.body = self.__.arr:implode('\n', value)
        return self
    end

    --[[--
    Sets the macro icon.

    @tparam integer|string value The macro's icon texture id

    @treturn Models.Macro self The current instance for method chaining
    ]]
    function Macro:setIcon(value)
        self.icon = value
        return self
    end

    --[[--
    Sets the macro name.

    This is the macro's identifier, which means the one World of Warcraft API
    will use when accessing the game's macro.

    @tparam string value The macro's name

    @treturn Models.Macro self The current instance for method chaining
    ]]
    function Macro:setName(value)
        self.name = value
        return self
    end
-- end of Macro

--[[--
The raid marker model represents those icon markers that can
be placed on targets, mostly used in raids and dungeons, especially
skull and cross (x).

This model is used to represent the raid markers in the game, but
not only conceptually, but it maps markers and their indexes to
be represented by objects in the addon environment.

@classmod Models.RaidMarker
]]
local RaidMarker = {}
    RaidMarker.__index = RaidMarker
    RaidMarker.__ = self

    --[[
    The raid marker constructor.

    @tparam integer id The raid marker id
    @tparam string name The raid marker name
    ]]
    function RaidMarker.__construct(id, name)
        local self = setmetatable({}, RaidMarker)

        self.id = id
        self.name = name

        return self
    end

    --[[--
    Returns a string representation of the raid marker that can
    be used to print it in the chat output in game.

    @treturn string Printable string representing the raid marker
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

    @usage
        local realm = library:getClass('Realm').getCurrentRealm()
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
            :setGuid(UnitGUID('player'))
            :setInCombat(UnitAffectingCombat('player'))
            :setLevel(UnitLevel('player'))
            :setName(UnitName('player'))
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
    Sets the Player in combat status.

    @tparam boolean value the Player's in combat status

    @treturn Models.Player self
    ]]
    function Player:setInCombat(value)
        self.inCombat = value
        return self
    end

    --[[--
    Sets the Player level.

    @TODO: Move this method to Unit when the Unit model is implemented <2024.06.13>

    @tparam integer value the Player's level

    @treturn Models.Player self
    ]]
    function Player:setLevel(value)
        self.level = value
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
Constants for centralizing values that are widely used in view classes.

@table viewConstants

@field DEFAULT_BACKGROUND_TEXTURE The default background texture for windows
                                  and frames in general
]]
self.viewConstants = self.arr:freeze({
    DEFAULT_BACKGROUND_TEXTURE = 'Interface/Tooltips/UI-Tooltip-Background',
})

--[[--
MinimapIcon is responsible for handling all visual components of this kind of icon
that's one of the most important parts of any addon.

It aims to provide a simple way to create and manage the icon that will be displayed
on the minimap, allowing players to interact with it and providing callbacks for
clicks.

@classmod Views.MinimapIcon
]]
local MinimapIcon = {}
    MinimapIcon.__index = MinimapIcon
    MinimapIcon.__ = self
    self:addClass('MinimapIcon', MinimapIcon)

    --[[--
    MinimapIcon constructor.

    @tparam string id The unique identifier for this icon, or 'default' if none is provided
    ]]
    function MinimapIcon.__construct(id)
        local self = setmetatable({}, MinimapIcon)

        self.id = id or 'default'
        self.isDragging = false
        self.persistStateByPlayer = false

        return self
    end

    --[[--
    Decides whether this instance should proxy to the player's or the global
    configuration instance.

    By default, the minimap icon will proxy to the global configuration instance.

    @local
    ]]
    function MinimapIcon:config(...)
        if self.persistStateByPlayer then
            return self.__:playerConfig(...)
        end
        
        return self.__:config(...)
    end

    --[[--
    Creates the minimap icon visual components.
    ]]
    function MinimapIcon:create()
        if self.minimapIcon then
            return self
        end

        self.minimapIcon = self:createIconFrame()

        self:createIconTexture()
        self:createIconOverlay()
        self:setAnglePositionOnCreation()
        self:setVisibilityOnCreation()

        return self
    end

    --[[--
    Creates and sets up a minimap icon frame.

    @local

    @treturn table The minimap icon frame created by CreateFrame
    ]]
    function MinimapIcon:createIconFrame()
        local minimapIcon = CreateFrame('Button', 'Minimap' .. self.id, Minimap)
        minimapIcon:RegisterForClicks('AnyUp')
        minimapIcon:SetFrameLevel(8)
        minimapIcon:SetFrameStrata('MEDIUM')
        minimapIcon:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')
        minimapIcon:SetScript('OnEnter', function() self:onEnter() end)
        minimapIcon:SetScript('OnLeave', function() self:onLeave() end)
        minimapIcon:SetScript('OnMouseDown', function (component, button) self:onMouseDown(button) end)
        minimapIcon:SetScript('OnMouseUp', function (component, button) self:onMouseUp(button) end)
        minimapIcon:SetScript('OnUpdate', function() self:onUpdate() end)
        minimapIcon:SetSize(31, 31)
        return minimapIcon
    end

    --[[--
    Creates an icon overlay for the minimap icon.

    @local

    @treturn table The minimap icon overlay texture created by CreateTexture
    ]]
    function MinimapIcon:createIconOverlay()
        local overlay = self.minimapIcon:CreateTexture(nil, 'OVERLAY')
        overlay:SetTexture('Interface\\Minimap\\MiniMap-TrackingBorder')
        overlay:SetSize(53, 53)
        overlay:SetPoint('TOPLEFT')
        return overlay
    end

    --[[--
    Creates and sets up the minimap icon texture, which is equivalent to saying that
    it creates the minimap icon itself.

    @local

    @treturn table The minimap icon texture created by CreateTexture
    ]]
    function MinimapIcon:createIconTexture()
        local iconTexture = self.minimapIcon:CreateTexture(nil, 'BACKGROUND')
        iconTexture:SetTexture(self.icon)
        iconTexture:SetSize(20, 20)
        iconTexture:SetPoint('CENTER', self.minimapIcon, 'CENTER')
        return iconTexture
    end

    --[[--
    Gets the minimap icon radius based on the minimap width.

    @local

    @treturn number The minimap icon radius
    ]]
    function MinimapIcon:getMinimapRadius()
        return Minimap:GetWidth() / 2
    end

    --[[--
    Gets a minimap icon property using the library configuration instance.

    This method is used internally by the library to persist state. It's not meant
    to be called by addons.

    @local

    @tparam string key The property key

    @treturn any The property value
    ]]
    function MinimapIcon:getProperty(key)
        return self:config(self:getPropertyKey(key))
    end

    --[[--
    Gets the property key used by the minimap icon instance to persist its state
    using the library configuration instance.

    A property key is a result of the concatenation of a static prefix, this
    instance's id, and the key parameter.

    This method is used internally by the library to persist state. It's not meant
    to be called by addons.

    @local

    @tparam string key The property key

    @treturn string The property key used by the minimap icon instance to persist
                    its state using the library configuration instance
    ]]
    function MinimapIcon:getPropertyKey(key)
        return 'minimapIcon.' .. self.id .. '.' .. key
    end

    --[[--
    Gets the minimap icon tooltip lines set on creation or by the developer or a
    list of default lines if none is provided.

    @local
    ]]
    function MinimapIcon:getTooltipLines()
        return self.tooltipLines or {
            self.__:getVersionedNameLabel(),
            'Hold SHIFT and drag to move this icon',
        }
    end

    --[[--
    Hides the minimap icon.

    This is just a facade method to call Hide() on the minimap icon frame. However,
    it shouldn't be used by addons as an internal method. Use setVisibility(false)
    instead.

    @local
    @see Views.MinimapIcon.setVisibility
    ]]
    function MinimapIcon:hide()
        self.minimapIcon:Hide()
    end

    --[[
    Determines whether the cursor is over the minimap icon.

    @local

    @treturn boolean Whether the cursor is over the minimap icon
    ]]
    function MinimapIcon:isCursorOver()
        -- gets the minimap icon effective scale
        local scale = self.minimapIcon:GetEffectiveScale()

        -- gets the minimap icon width and height based on the scale
        local width, height = self.minimapIcon:GetWidth() * scale, self.minimapIcon:GetHeight() * scale
        
        -- gets the cursor position using the World of Warcraft API
        local cx, cy = GetCursorPosition()

        -- gets the minimap icon position based on the scale
        local lx, ly = self.minimapIcon:GetLeft() * scale, self.minimapIcon:GetBottom() * scale
    
        -- checks if the cursor is over the minimap icon based on the boundaries
        return cx >= lx and cx <= lx + width and cy >= ly and cy <= ly + height
    end

    --[[--
    Determines if the minimap icon is persisting its state.

    A minimap icon is considered to be persisting its state if the library is
    created with a configuration set.

    @local

    @treturn boolean true if the minimap icon is persisting its state, false otherwise
    ]]
    function MinimapIcon:isPersistingState()
        return self.__:isConfigEnabled()
    end

    --[[--
    May invoke the minimap icon callbacks if the cursor is over the icon.

    @local
    ]]
    function MinimapIcon:maybeInvokeCallbacks(button)
        if self:isCursorOver() then
            if button == 'LeftButton' and self.callbackOnLeftClick then
                self.callbackOnLeftClick()
            elseif button == 'RightButton' and self.callbackOnRightClick then
                self.callbackOnRightClick()
            end
        end
    end

    --[[--
    Executes when the minimap icon is being dragged for repositioning.

    @local

    @NOTE: It appears that math.atan2() is deprecated in environments with Lua 5.4,
           however, it's kept here considering that World of Warcraft doesn't use
           the latest Lua version. However, it's important to keep an eye on this
           method in the future.
    ]]
    function MinimapIcon:onDrag()
        local xpos, ypos = GetCursorPosition()
        local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
        local scale = UIParent:GetScale()

        local radius = self:getMinimapRadius()

        xpos = xpos / scale - xmin - radius
        ypos = ypos / scale - ymin - radius

        local angle = math.atan2(ypos, xpos)

        self:updatePosition(math.deg(angle))
    end

    --[[--
    Executes when the mouse enters the minimap icon.

    @local
    ]]
    function MinimapIcon:onEnter()
        if not self.isDragging then
            GameTooltip:SetOwner(self.minimapIcon, 'ANCHOR_RIGHT')

            self.__.arr:each(self:getTooltipLines(), function(line)
                GameTooltip:AddLine(line)
            end)

            GameTooltip:Show()
        end
    end

    --[[--
    Executes when the mouse leaves the minimap icon.

    @local
    ]]
    function MinimapIcon:onLeave()
        GameTooltip:Hide()
    end

    --[[--
    Executes when the mouse is pressed down on the minimap icon.

    @local
    ]]
    function MinimapIcon:onMouseDown(button)
        if button == 'LeftButton' and self:shouldMove() then
            self.isDragging = true
            GameTooltip:Hide()
        end
    end

    --[[--
    Executes when the mouse is released on the minimap icon.

    @local
    ]]
    function MinimapIcon:onMouseUp(button)
        if self.isDragging then
            self.isDragging = false
            return
        end

        self:maybeInvokeCallbacks(button)
    end

    --[[--
    Executes when the minimap icon frame is updated.

    @local
    ]]
    function MinimapIcon:onUpdate()
        if self.isDragging and self:shouldMove() then
            self:onDrag()
        end
    end

    --[[--
    Sets the minimap icon angle position on creation.

    This method is called when the minimap icon is created, and it sets the angle
    position to the first position set by the developer or the persisted
    position if it's found.

    This method shouldn't be called directly. It's considered a complement
    to the create() method.

    @local
    ]]
    function MinimapIcon:setAnglePositionOnCreation()
        local angle = self.firstAnglePosition or 225

        if self:isPersistingState() then
            angle = self:getProperty('anglePosition') or angle
        end

        self:updatePosition(angle)
    end

    --[[--
    Sets the minimap icon callback for left clicks.

    @tparam function value The callback function
    
    @treturn Views.MinimapIcon The minimap icon instance, for method chaining

    @usage
        icon:setCallbackOnLeftClick(function()
            print('Left click!')
        end)
    ]]
    function MinimapIcon:setCallbackOnLeftClick(value)
        self.callbackOnLeftClick = value
        return self
    end

    --[[--
    Sets the minimap icon callback for right clicks.

    @tparam function value The callback function
    
    @treturn Views.MinimapIcon The minimap icon instance, for method chaining

    @usage
        icon:setCallbackOnRightClick(function()
            print('Right click!')
        end)
    ]]
    function MinimapIcon:setCallbackOnRightClick(value)
        self.callbackOnRightClick = value
        return self
    end

    --[[--
    Sets the minimap icon first angle position in degrees.

    The first angle position is the position that the minimap icon will have when
    it's first created. If the player moves the icon and this instance is persisting
    its state, this property will be ignored.

    It's important to mention that the angle represented by 0.0 is the right side
    (or 3 o'clock, east) of the minimap, and the angle increases counterclockwise,
    which means that 90.0 is the top side (or 12 o'clock, north), 180.0 is the left
    side (or 9 o'clock, west), and 270.0 is the bottom side (or 6 o'clock, south).

    @tparam number value The first angle position in degrees

    @treturn Views.MinimapIcon The minimap icon instance, for method chaining

    @usage
        icon:setFirstAnglePosition(225.0)
    ]]
    function MinimapIcon:setFirstAnglePosition(value)
        self.firstAnglePosition = value
        return self
    end

    --[[--
    Sets the minimap icon image, which will be passed to the icon texture.

    @tparam string value The image path

    @treturn Views.MinimapIcon The minimap icon instance, for method chaining

    @usage
        icon:setImage('Interface\\Icons\\INV_Misc_QuestionMark')
    ]]
    function MinimapIcon:setIcon(value)
        self.icon = value
        return self
    end

    --[[--
    Sets the minimap icon instance to have its stated persisted in the player's
    configuration instead of the global one.

    @tparam boolean value Whether the minimap icon should persist its state by player

    @treturn Views.MinimapIcon The minimap icon instance, for method chaining

    @usage
        icon:setPersistStateByPlayer(true)
    ]]
    function MinimapIcon:setPersistStateByPlayer(value)
        self.persistStateByPlayer = value
        return self
    end

    --[[--
    Sets a minimap icon property using the library configuration instance.

    This method is used internally by the library to persist  state. It's not meant
    to be called by addons.

    @local
    
    @tparam string key The property key
    @param any value The property value
    ]]
    function MinimapIcon:setProperty(key, value)
        self:config({
            [self:getPropertyKey(key)] = value
        })
    end

    --[[--
    Sets a minimap icon state property if it's persisting its state.

    This method is used internally by the library to persist  state. It's not meant
    to be called by addons.

    @local
    
    @tparam string key The property key
    @param any value The property value
    ]]
    function MinimapIcon:setPropertyIfPersistingState(key, value)
        if self:isPersistingState() then
            self:setProperty(key, value)
        end
    end

    --[[--
    Sets the minimap tooltip lines.

    If no lines are provided, the tooltip will be displayed with default information.

    @tparam string[] value The tooltip lines

    @treturn Views.MinimapIcon The minimap icon instance, for method chaining

    @usage
        icon:setTooltipLines({
            'Click to open settings',
            'Right click to show a panel',
            'Drag this icon to move',
        })
    ]]
    function MinimapIcon:setTooltipLines(value)
        self.tooltipLines = value
        return self
    end

    --[[--
    Sets the minimap icon visibility.

    This is the method to be called by addons to show or hide the minimap icon,
    instead of the local show() and hide(), considering that it not only controls
    the minimap icon visibility but also persists the state if persistence is
    enabled.

    @tparam boolean visible The visibility state

    @treturn Views.MinimapIcon The minimap icon instance, for method chaining
    --]]
    function MinimapIcon:setVisibility(visible)
        self.visible = visible

        if visible then self:show() else self:hide() end

        if self:isPersistingState() then self:setProperty('visibility', visible) end

        return self
    end

    --[[--
    Sets the minimap icon visibility on creation.

    This method is called when the minimap icon is created, and it sets the
    visibility to true (default) or the persisted state if it's found.

    This method shouldn't be called directly. It's considered a complement
    to the create() method.

    @local
    ]]
    function MinimapIcon:setVisibilityOnCreation()
        local visibility = true

        if self:isPersistingState() then
            local storedVisibility = self:getProperty('visibility')

            -- these conditionals are necessary so Lua doesn't consider falsy values
            -- as false, but as nil
            if storedVisibility ~= nil then
                visibility = self.__.bool:isTrue(storedVisibility)
            end
        end

        self:setVisibility(visibility)
    end

    --[[--
    Determines whether the minimap icon should move instead of being clicked.

    @local

    @treturn boolean Whether the minimap icon should move
    ]]
    function MinimapIcon:shouldMove()
        return IsShiftKeyDown()
    end

    --[[--
    Shows the minimap icon.

    This is just a facade method to call Show() on the minimap icon frame. However,
    it shouldn't be used by addons as an internal method. Use setVisibility(true)
    instead.

    @local
    @see Views.MinimapIcon.setVisibility
    ]]
    function MinimapIcon:show()
        self.minimapIcon:Show()
    end

    --[[--
    Calculates the minimap icon position based on the angle in degrees.

    When updating the position, the angle position will also be persisted if this
    instance is persisting its state. That guarantees that the icon will be in the
    same position when the player logs in again.

    @local

    @tparam number angleInDegrees The angle in degrees

    @treturn Views.MinimapIcon The minimap icon instance, for method chaining
    ]]
    function MinimapIcon:updatePosition(angleInDegrees)
        local angleInRadians = math.rad(angleInDegrees)

        -- distance from the center of the minimap
        local radius = self:getMinimapRadius()
        local x = math.cos(angleInRadians) * radius
        local y = math.sin(angleInRadians) * radius

        self.minimapIcon:SetPoint('CENTER', Minimap, 'CENTER', x, y)

        self:setPropertyIfPersistingState('anglePosition', angleInDegrees)

        return self
    end
-- end of MinimapIcon

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

        self.pages = {}

        return self
    end

    --[[--
    Adds a page to the window.

    @tparam Views.Windows.WindowPage windowPage The window page to be added

    @treturn Views.Windows.Window The window instance, for method chaining
    ]]
    function Window:addPage(windowPage)
        self.pages[windowPage.pageId] = windowPage
        windowPage:hide()
        self:positionPages()

        if self.__.arr:count(self.pages) == 1 then
            self:setActivePage(windowPage.pageId)
        end

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

        self:positionPages()

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
            bgFile = self.__.viewConstants.DEFAULT_BACKGROUND_TEXTURE,
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
            bgFile = self.__.viewConstants.DEFAULT_BACKGROUND_TEXTURE,
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
            bgFile = self.__.viewConstants.DEFAULT_BACKGROUND_TEXTURE,
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

    This is just a facade method to call Hide() on the window frame. However, it
    shouldn't be used by addons as an internal method. Use setVisibility(false)
    instead.

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
    Positions the pages inside the content frame.

    This is an internal method and it shouldn't be called by addons.

    @local
    --]]
    function Window:positionPages()
        for _, windowPage in pairs(self.pages) do
            local child = windowPage.contentFrame

            child:SetParent(self.contentFrame)
            child:SetPoint('TOPLEFT', self.contentFrame, 'TOPLEFT', 0, 0)
            child:SetPoint('TOPRIGHT', self.contentFrame, 'TOPRIGHT', 0, 0)
        end
    end

    --[[--
    Sets the active page in the Window.

    This method basically hides all pages and shows the one with the given
    page id and adjusts the content frame height to the current page height.
    ]]
    function Window:setActivePage(pageId)
        self.__.arr:each(self.pages, function(windowPage)
            if windowPage.pageId == pageId then
                windowPage:show()
                self.contentFrame:SetHeight(windowPage:getHeight())
                return
            end

            windowPage:hide()
        end)
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
        self.visible = visible

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

    This is just a facade method to call Show() on the window frame. However, it
    shouldn't be used by addons as an internal method. Use setVisibility(true)
    instead.

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

    --[[--
    Toggles the window visibility.

    If the window is visible, it will be hidden. If it's hidden, it will be
    shown.

    @treturn Views.Windows.Window The window instance, for method chaining
    ]]
    function Window:toggleVisibility()
        return self:setVisibility(not self.visible)
    end
-- end of Window

--[[--
WindowPage represents a page in a window content area.

With the concept of pages, it's possible to have a single window handling
multiple content areas, each one with its own set of frames and change pages
to switch between them.

@classmod Views.Windows.WindowPage
]]
local WindowPage = {}
    WindowPage.__index = WindowPage
    WindowPage.__ = self

    self:addClass('WindowPage', WindowPage)

    --[[--
    WindowPage constructor.
    ]]
    function WindowPage.__construct(pageId)
        local self = setmetatable({}, WindowPage)

        self.pageId = pageId

        return self
    end

    --[[--
    Creates the page frame if it doesn't exist yet.

    @treturn Views.Windows.WindowPage The window page instance, for method chaining
    ]]
    function WindowPage:create()
        if self.contentFrame then return self end

        self.contentFrame = self:createFrame()

        return self
    end

    --[[--
    This is just a facade method to call World of Warcraft's CreateFrame.

    @local

    @see Views.Windows.WindowPage.create

    @treturn table The frame created by CreateFrame
    ]]
    function WindowPage:createFrame()
        return CreateFrame('Frame', nil, UIParent, 'BackdropTemplate')
    end

    --[[--
    Gets the page's height.
    ]]
    function WindowPage:getHeight()
        return self.contentFrame:GetHeight()
    end

    --[[--
    Hides the page frame.
    ]]
    function WindowPage:hide()
        self.contentFrame:Hide()
    end

    --[[--
    Positions the children frames inside the page.

    This is an internal method and it shouldn't be called by addons.

    @local
    --]]
    function WindowPage:positionContentChildFrames()
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
    Sets the page's content, which is a table of frames.

    The Stormwind Library Window Page was designed to accept a list of frames
    to compose its content.

    This method is used to populate the content frame with the frames passed
    in the frames parameter. The frames then will be positioned sequentially
    from top to bottom, with the first frame being positioned at the top and
    the last frame at the bottom. Their width will be the same as the content
    frame's width and will grow horizontally to the right if the whole
    page is resized.

    Please, read the library documentation for more information on how to
    work with the frames inside the page's content.

    @tparam table frames The list of frames to be placed inside the page

    @treturn Views.Windows.WindowPage The window page instance, for method chaining

    @usage
        local frameA = CreateFrame(...)
        local frameB = CreateFrame(...)
        local frameC = CreateFrame(...)

        page:setContent({frameA, frameB, frameC})
    ]]
    function WindowPage:setContent(frames)
        self.contentChildren = frames

        if self.contentFrame then self:positionContentChildFrames() end

        return self
    end

    --[[--
    Shows the page frame.
    ]]
    function WindowPage:show()
        self.contentFrame:Show()
    end
-- end of WindowPage


self:invokeLoadCallbacks()
    return self
end