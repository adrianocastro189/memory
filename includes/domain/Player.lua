--[[
Adds the player prototype and creation method to core.

@since 0.4.0-alpha

@param MemoryCore core the memory core instance
]]
function MemoryAddon_addPlayerPrototype( core )

  -- prevents this method to be called again
  MemoryAddon_addPlayerPrototype = nil;
end
