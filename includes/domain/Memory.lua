--[[
Adds the memory prototype and creation method to repository.

@since 0.5.0-beta

@param MemoryRepository repository the memory repository instance
]]
function MemoryAddon_addMemoryPrototype( repository )

  --[[
  The memory prototype.

  @since 0.5.0-beta
  ]]
  local MemoryAddon_Memory = {};
  MemoryAddon_Memory.__index = MemoryAddon_Memory;

  --[[
  Builds a new instance of a memory.

  @since 0.5.0-beta

  @return MemoryAddon_Memory
  ]]
  function MemoryAddon_Memory:new()

    local instance = {};

    setmetatable( instance, MemoryAddon_Memory );
    instance.first = -1;
    instance.last  = -1;
    instance.x     =  0;


    --[[
    Gets the first time player had this memory.

    @since 0.5.0-beta

    @return string a memory string
    ]]
    function instance:getFirst()

      return self.first;
    end


    --[[
    Gets the last time player had this memory.

    @since 0.5.0-beta

    @return string a memory string
    ]]
    function instance:getLast()

      return self.last;
    end


    --[[
    Gets the number of times player had this memory.

    @since 0.5.0-beta

    @return int
    ]]
    function instance:getX()

      return self.x;
    end


    --[[
    Sets the first time player had this memory.

    @since 0.5.0-beta

    @param string first a memory string
    ]]
    function instance:setFirst( first )

      self.first = first or -1;
    end


    --[[
    Sets the last time player had this memory.

    @since 0.5.0-beta

    @param string last a memory string
    ]]
    function instance:setLast( last )

      self.last = last or -1;
    end


    --[[
    Sets the number of times player had this memory.

    @since 0.5.0-beta

    @param int x
    ]]
    function instance:setX( x )

      self.x = x or 0;
    end


    return instance;
  end

  --[[
  Builds a new instance of a memory from repository.

  @since 0.5.0-beta

  @return MemoryAddon_Memory
  ]]
  function repository:newMemory()

    return MemoryAddon_Memory:new();
  end
end
