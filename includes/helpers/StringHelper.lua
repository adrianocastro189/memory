--[[
The string helper prototype.

Provides helper methods to work with strings.

@since 0.6.0-alpha
]]
MemoryAddon_StringHelper = {};
MemoryAddon_StringHelper.__index = MemoryAddon_StringHelper;

--[[
Constructs a new instance of a string helper.

@since 0.6.0-alpha

@return MemoryAddon_StringHelper
]]
function MemoryAddon_StringHelper:new()

  local instance = {};
  setmetatable( instance, MemoryAddon_StringHelper );


  --[[
  Gets the orginal suffix for a number.

  For 1, this method will return st, for 2, nd, and so on.

  @since 0.6.0-alpha

  @param number
  @return string
  ]]
  function instance:getOrdinalSuffix( number )

      local j = number % 10;
      local k = number % 100;

      if ( j == 1 and k ~= 11 ) then return 'st'; end
      if ( j == 2 and k ~= 12 ) then return 'nd'; end
      if ( j == 3 and k ~= 13 ) then return 'rd'; end

      return 'th';
  end


  -- destroys the prototype, so instance will be unique
  MemoryAddon_StringHelper = nil;

  return instance;
end
