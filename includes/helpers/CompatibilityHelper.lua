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

    return self:getGossipTitle( GossipFrameNpcNameText );
  end


  --[[
  Gets the gossip title, which will be the npc name for almost all cases.

  @since 0.4.0-alpha

  @param gossipFrame the gossip frame
  @return string the gossip frame title
  ]]
  function instance:getGossipTitle( gossipFrame )

    if nil ~= gossipFrame and nil ~= gossipFrame:GetText() and gossipFrame:IsVisible() then

      return gossipFrame:GetText();
    end

    return '';
  end


  --[[
  Gets all the member guids in a party or raid group.

  @since 0.4.0-alpha

  @return array list of group member guids
  ]]
  function instance:getGroupGuids()

    -- gets the number of group members
    local groupSize = GetNumGroupMembers();

    -- array to be returned
    local groupGuids = {};

    -- helper var to iterate over group members
    local counter = 1;

    -- pointer to the current member
    local currentMemberGuid = nil;

    while counter <= groupSize do

      -- attempts to get a raid or party member
      currentMemberGuid = UnitGUID( 'raid' .. counter ) or UnitGUID( 'party' .. counter );

      if nil ~= currentMemberGuid then

        table.insert( groupGuids, currentMemberGuid );
      end

      counter = counter + 1;
    end

    return groupGuids;
  end


  --[[
  Gets the quest gossip title, which will be the npc name for almost all cases.

  @since 0.4.0-alpha

  @return string
  ]]
  function instance:getQuestGossipTitle()

    return self:getGossipTitle( QuestFrameNpcNameText );
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
