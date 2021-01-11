--[[
The main slash command for the Memory Addon.

@since 1.0.0
]]
SLASH_MEMORYADDON1 = '/memoryaddon'
SlashCmdList['MEMORYADDON'] = function( arg )

  -- sanity check
  if nil == arg then MemoryCore:print( 'Invalid command' ); end
end
