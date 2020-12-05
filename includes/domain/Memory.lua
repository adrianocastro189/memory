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
    instance.category        = '';
    instance.first           = -1;
    instance.interactionType = '';
    instance.last            = -1;
    instance.path            = {};
    instance.x               =  0;


    --[[
    Gets the memory category.

    @since 0.5.0-beta

    @return string the memory category
    ]]
    function instance:getCategory()

      return self.category;
    end


    --[[
    Gets the first time player had this memory.

    @since 0.5.0-beta

    @return MemoryAddon_MemoryString
    ]]
    function instance:getFirst()

      return self.first;
    end


    --[[
    Gets the memory interaction type.

    @since 0.5.0-beta

    @return string the memory interaction type.
    ]]
    function instance:getInteractionType()

      return self.interactionType;
    end


    --[[
    Gets the last time player had this memory.

    @since 0.5.0-beta

    @return MemoryAddon_MemoryString
    ]]
    function instance:getLast()

      return self.last;
    end


    --[[
    Gets the memory path.

    @since 0.5.0-beta

    @return string[] the memory path
    ]]
    function instance:getPath()

      return self.path;
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
    Determines whether the memory has a category.

    @since 0.5.0-beta

    @return bool
    ]]
    function instance:hasCategory()

      return self:getCategory() ~= nil and self:getCategory() ~= '';
    end


    --[[
    Determines whether the player had already experienced this memory before.

    @since 0.5.0-beta

    @return bool
    ]]
    function instance:hasFirst()

      return self:getFirst() ~= nil and self:getFirst() ~= -1;
    end


    --[[
    Determines whether the memory has an interaction type.

    @since 0.5.0-beta

    @return bool
    ]]
    function instance:hasInteractionType()

      return self:getInteractionType() ~= nil and self:getInteractionType() ~= '';
    end


    --[[
    Determines whether the memory has a path

    @since 0.5.0-beta

    @return bool
    ]]
    function instance:hasPath()

      return self:getPath() ~= nil and #self:getPath() > 0;
    end


    --[[
    Determines whether the memory is a valid memory based on its primary properties.

    @since 0.5.0-beta

    @return bool
    ]]
    function instance:isValid()

      return self:hasCategory() and self:hasInteractionType() and self:hasPath();
    end


    --[[
    May print the memory in the chat frame based on a random chance.

    @since 0.5.0-beta
    ]]
    function instance:maybePrint()

      if math.random() <= 1.1 then

        self:print();
      end
    end


    --[[
    Prints the memory in the chat frame.

    @since 0.5.0-beta
    ]]
    function instance:print()

      -- TODO: Replace this for a better formatted string on future epics {AC 2020-11-22}
      local tempMemoryString = 'First[' .. self:getFirst() .. '], Last[' .. self:getLast() .. '], x[' .. self:getX() .. ']';
            tempMemoryString = string.gsub( '\124cff6ac4ff{0}\124r', "{0}", tempMemoryString );

      MemoryCore:print( tempMemoryString );
    end


    --[[
    Saves this memory in the repository.

    @see MemoryRepository:storeMemory()

    @since 0.5.0-beta
    ]]
    function instance:save()

      MemoryCore:getRepository():storeMemory( self );
    end


    --[[
    Sets the memory category.

    @since 0.5.0-beta

    @param string memory category
    @return self MemoryAddon_Memory
    ]]
    function instance:setCategory( category )

      self.category = category or '';

      return self;
    end


    --[[
    Sets the first time player had this memory.

    @since 0.5.0-beta

    @param MemoryAddon_MemoryString a memory string instance
    @return self MemoryAddon_Memory
    ]]
    function instance:setFirst( first )

      self.first = first or -1;

      return self;
    end


    --[[
    Sets the memory interaction type.

    @since 0.5.0-beta

    @param string memory interaction type
    @return self MemoryAddon_Memory
    ]]
    function instance:setInteractionType( interactionType )

      self.interactionType = interactionType or '';

      return self;
    end


    --[[
    Sets the last time player had this memory.

    @since 0.5.0-beta

    @param MemoryAddon_MemoryString a memory string instance
    @return self MemoryAddon_Memory
    ]]
    function instance:setLast( last )

      self.last = last or -1;

      return self;
    end


    --[[
    Sets the memory path.

    @since 0.5.0-beta

    @param string[] memory path
    @return self MemoryAddon_Memory
    ]]
    function instance:setPath( path )

      self.path = path or {};

      return self;
    end


    --[[
    Sets the number of times player had this memory.

    @since 0.5.0-beta

    @param int x
    @return self MemoryAddon_Memory
    ]]
    function instance:setX( x )

      self.x = x or 0;

      return self;
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


  -- prevents this method to be called again
  MemoryAddon_addMemoryPrototype = nil;
end
