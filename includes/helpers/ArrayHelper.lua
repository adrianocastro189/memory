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

@returns MemoryAddon_ArrayHelper
]]
function MemoryAddon_ArrayHelper:new()

  local instance = {};
  setmetatable( instance, MemoryAddon_ArrayHelper );


  --[[
  Checks if a haystack array has a needle string.

  @since 0.4.0-alpha

  @return bool
  ]]
  function instance:inArray( needle, haystack )

  end


  -- destroys the prototype, so instance will be unique
  MemoryAddon_ArrayHelper = nil;

  return instance;
end
