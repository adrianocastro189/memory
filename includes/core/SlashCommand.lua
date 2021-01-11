--[[
The main slash command for the Memory Addon.

The slash command structure for /memoryaddon is: command key value, where command
is the command to be executed by Memory Addon, key is the first argument and value
is the second argument that will get the command tail, regardless of spaces in it.

Example: /memoryaddon set myname My name is Squareone
  Command: set
  Key: myname
  Value: My name is Squareone

@since 1.0.0
]]
SLASH_MEMORYADDON1 = '/memoryaddon'
SlashCmdList['MEMORYADDON'] = function( arg )

  -- sanity check
  if nil == arg then MemoryCore:print( 'Invalid command' ); end

  -- helps parsing the slash command arguments
  local argumentIndex = 1;

  local argumentCommand = nil;
  local argumentKey     = nil;
  local argumentValue   = nil;

  for argument in arg:gmatch( '%w+' ) do

    -- parses each command part
        if 1 == argumentIndex then argumentCommand = argument;
    elseif 2 == argumentIndex then argumentKey     = argument;
    elseif 3 == argumentIndex then argumentValue   = argument;
    else                           argumentValue   = argumentValue .. ' ' .. argument;
    end

    -- increments the argument index
    argumentIndex = argumentIndex + 1;
  end
end
