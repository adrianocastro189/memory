--[[
The screenshot controller.

Provides methods to prepare and take game screenshots.

@since 1.2.0
]]
MemoryAddon_ScreenshotController = {};
MemoryAddon_ScreenshotController.__index = MemoryAddon_ScreenshotController;

--[[
Constructs a new instance of the screenshot controller.

@since 1.2.0

@return MemoryAddon_ScreenshotController
]]
function MemoryAddon_ScreenshotController:new()

  local instance = {};
  setmetatable( instance, MemoryAddon_ScreenshotController );


  --[[
  Takes a game screenshot.

  @since 1.2.0
  ]]
  function instance:takeScreenshot()

    if nil ~= Screenshot then

      Screenshot();
    end
  end


  --[[
  Prepares a screenshot to be taken.

  @since 1.2.0
  ]]
  function instance:prepareScreenshot( message )

    if nil ~= message and nil ~= RaidNotice_AddMessage and nil ~= RaidWarningFrame then

      RaidNotice_AddMessage( RaidWarningFrame, message, { r = 255, g = 255, b = 255 } );
    end
  end


  -- destroys the prototype, so instance will be unique
  MemoryAddon_ScreenshotController = nil;

  return instance;
end
