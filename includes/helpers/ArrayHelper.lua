--[[
The array helper prototype.

Provides helper methods to work with arrays.

@since 0.4.0-alpha
]]
MemoryAddon_ArrayHelper = {};
MemoryAddon_ArrayHelper.__index = MemoryAddon_ArrayHelper;

--[[
Constructs a new instance of an array helper.

@since 0.4.0-alpha

@return MemoryAddon_ArrayHelper
]]
function MemoryAddon_ArrayHelper:new()

  local instance = {};
  setmetatable( instance, MemoryAddon_ArrayHelper );


  --[[
  Returns the values in needles that are not present in haystack.

  @since 0.4.0-alpha

  @param array needles values to check...
  @param array haystack ...agains this array
  @return array the values in needles that are not present in haystack
  ]]
  function instance:arrayDiff( needles, haystack )

    local difference = {};

    for key, needle in pairs( needles ) do

      if not self:inArray( needle, haystack ) then

        table.insert( difference, needle );
      end
    end

    return difference;
  end


  --[[
  Checks if a haystack array has a needle string.

  @since 0.4.0-alpha

  @return bool
  ]]
  function instance:inArray( needle, haystack )

    for i, value in ipairs( haystack ) do

      if value == needle then

        return true;
      end
    end

    return false;
  end


  -- destroys the prototype, so instance will be unique
  MemoryAddon_ArrayHelper = nil;

  return instance;
end
