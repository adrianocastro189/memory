--[[
The date helper prototype.

Provides helper methods to work with dates.

@since 0.6.0-beta
]]
MemoryAddon_DateHelper = {};
MemoryAddon_DateHelper.__index = MemoryAddon_DateHelper;

--[[
Constructs a new instance of an date helper.

@since 0.6.0-beta

@return MemoryAddon_DateHelper
]]
function MemoryAddon_DateHelper:new()

  local instance = {};
  setmetatable( instance, MemoryAddon_DateHelper );


  --[[
  Gets a readable date with the format "Month day, year".

  @since 0.6.0-beta

  @param string date a string date with format %y-%m-%d
  @return string
  ]]
  function instance:getFormattedDate( date )

    -- explodes the date
    local year, month, day = strsplit( '-', date );

    -- sanity check
    if nil == year or nil == month or nil == day then

      return 'Invalid date';
    end

    return self:getMonthName( month ) .. ' ' .. tonumber( day ) .. ', ' .. year;
  end
  end


  -- destroys the prototype, so instance will be unique
  MemoryAddon_DateHelper = nil;

  return instance;
end
