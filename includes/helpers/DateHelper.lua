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
  Gets the difference of two dates in days.

  This method won't return negative values but the absolute difference.

  @since 0.6.0-beta

  @param string dateFrom
  @param string dateTo
  @return int
  ]]
  function instance:getDaysDiff( dateFrom, dateTo )

    -- gets the time representation for each date
    dateFrom = self:toTime( dateFrom );
    dateTo   = self:toTime( dateTo );

    -- sanity checks
    if nil == dateFrom or nil == dateTo then

      return 'Invalid date(s)';
    end

    -- returns the absolute difference between them
    return math.abs( difftime( dateTo, dateFrom ) / ( 24 * 60 * 60 ) );
  end


  --[[
  Gets a readable date with the format 'Month day, year'.

  @since 0.6.0-beta

  @param string date a string date with format %y-%m-%d
  @return string
  ]]
  function instance:getFormattedDate( date )

    -- explodes the date
    local year, month, day = strsplit( '-', date );

    -- fixes a two digit year
    if 2 == #year then year = '20' .. year; end

    -- sanity check
    if nil == year or nil == month or nil == day then

      return '(invalid date = ' .. date .. ')';
    end

    return self:getMonthName( month ) .. ' ' .. tonumber( day ) .. ', ' .. year;
  end


  --[[
  Gets the month name from its index.

  @since 0.6.0-beta

  @param string|int month index from 1 to 12
  @return string
  ]]
  function instance:getMonthName( month )

    month = tonumber( month );

    if 1  == month then return 'January';   end
    if 2  == month then return 'February';  end
    if 3  == month then return 'March';     end
    if 4  == month then return 'April';     end
    if 5  == month then return 'May';       end
    if 6  == month then return 'June';      end
    if 7  == month then return 'July';      end
    if 8  == month then return 'August';    end
    if 9  == month then return 'September'; end
    if 10 == month then return 'October';   end
    if 11 == month then return 'November';  end
    if 12 == month then return 'December';  end

    return 'Invalid month';
  end


  --[[
  Gets a time representation from World of Warcraft from a date string.

  @since 0.6.0-beta

  @param string date a string date with format %y-%m-%d
  @return time|nil
  ]]
  function instance:toTime( date )

    -- explodes the date
    local year, month, day = strsplit( '-', date );

    -- fixes a two digit year
    if 2 == #year then year = '20' .. year; end

    -- sanity check
    if nil == year or nil == month or nil == day then

      return nil;
    end

    -- returns the World of Warcraft time representation
    return time( { day = tonumber( day ), month = tonumber( month ), year = tonumber( year ) } );
  end


  -- destroys the prototype, so instance will be unique
  MemoryAddon_DateHelper = nil;

  return instance;
end
