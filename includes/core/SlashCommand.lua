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
end
