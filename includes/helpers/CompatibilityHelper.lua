--[[
The compatibility helper prototype.

Provides helper methods to work with compatibility between Classic and Retail versions.

@since 0.4.0-alpha
]]
MemoryAddon_CompatibilityHelper = {};
MemoryAddon_CompatibilityHelper.__index = MemoryAddon_CompatibilityHelper;

--[[
Constructs a new instance of a compatibility helper.

@since 0.4.0-alpha

@return MemoryAddon_CompatibilityHelper
]]
function MemoryAddon_CompatibilityHelper:new()

  local instance = {};
  setmetatable( instance, MemoryAddon_CompatibilityHelper );


  --[[
  Gets the dialog gossip title, which will be the npc name for almost all cases.

  @since 0.4.0-alpha

  @return string
  ]]
  function instance:getDialogGossipTitle()

    -- just a pointer to improve readability
    local gossipFrame = GossipFrameNpcNameText;

    if nil ~= gossipFrame and nil ~= gossipFrame:GetText() and gossipFrame:IsVisible() then

      return gossipFrame:GetText();
    end

    return '';

  end


  --[[
  Gets the quest gossip title, which will be the npc name for almost all cases.

  @since 0.4.0-alpha

  @return string
  ]]
  function instance:getQuestGossipTitle()

    -- just a pointer to improve readability
    local questFrame = QuestFrameNpcNameText;

    if nil ~= questFrame and nil ~= questFrame:GetText() and questFrame:IsVisible() then

      return questFrame:GetText();
    end

    return '';
  end


  --[[
  Checks whether the player is flying.

  For Classic it will always return false.

  @since 0.4.0-alpha

  @return bool
  ]]
  function instance:isFlying()

    return not ( IsFlying == nil ) and IsFlying();
  end


  -- destroys the prototype, so instance will be unique
  MemoryAddon_CompatibilityHelper = nil;

  return instance;
end
