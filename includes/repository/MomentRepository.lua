--[[
The moment repository prototype.

Provides all read and write methods to manipulate the player moments.

@since 1.1.0
]]
MemoryAddon_MomentRepository = {};
MemoryAddon_MomentRepository.__index = MemoryAddon_MomentRepository;

--[[
Constructs a new instance of a moment repository.

@since 1.1.0

@return MemoryAddon_MomentRepository
]]
function MemoryAddon_MomentRepository:new()

  local instance = {};
  setmetatable( instance, MemoryAddon_MomentRepository );

  -- the name of the moments saved in the settings array
  instance.MOMENT_SETTINGS_NAME = 'moments';


  --[[
  Gets the current moment index, i.e. the most recent one.

  @since 1.1.0

  @return int
  ]]
  function instance:getCurrentMomentIndex()

    return #self:getMoments();
  end


  --[[
  Gets a moment by its index.

  @since 1.1.0

  @param int index the moment index
  @return string|nil the moment
  ]]
  function instance:getMoment( index )

    return self:getMoments()[ index ];
  end


  --[[
  Gets all the stored moments.

  @since 1.1.0

  @return string[] moments
  ]]
  function instance:getMoments()

    return MemoryCore:setting( self.MOMENT_SETTINGS_NAME, {} );
  end


  --[[
  Determines whether there's a current moment stored or not.

  @since 1.1.0

  @return bool
  ]]
  function instance:hasCurrentMoment()

    return self:getCurrentMomentIndex() > 0;
  end


  -- destroys the prototype, so instance will be unique
  MemoryAddon_MomentRepository = nil;

  return instance;
end
