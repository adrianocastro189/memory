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

  -- pattern for a single 'You receive loot: %s.' chat msg loot
  instance.PATTERN_LOOT_ITEM_SELF = LOOT_ITEM_SELF:gsub( '%%s', '(.+)' );

  -- pattern for multiple 'You receive loot: %sx%d.' chat msg loot
  instance.PATTERN_LOOT_ITEM_SELF_MULTIPLE = LOOT_ITEM_SELF_MULTIPLE:gsub( '%%s', '(.+)' ):gsub( '%%d', '(%%d+)' );

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
  Gets all the member full names in a party or raid group.

  A full name is composed by the player's name, a dash and it's realm name without spaces.

  @since 0.4.0-alpha

  @return array list of group member full names
  ]]
  function instance:getGroupFullNames()

    -- gets the number of group members
    local groupSize = GetNumGroupMembers();

    -- array to be returned
    local groupFullNames = {};

    -- helper var to iterate over group members
    local counter = 1;

    -- pointer to the current member
    local currentMemberFullName = nil;

    while counter <= groupSize do

      -- attempts to get a raid or party member
      currentMemberFullName = self:getNameAndRealm( 'raid' .. counter ) or self:getNameAndRealm( 'party' .. counter );

      if nil ~= currentMemberFullName then

        table.insert( groupFullNames, currentMemberFullName );
      end

      counter = counter + 1;
    end

    return groupFullNames;
  end


  --[[
  Gets the unit's name with the realm.

  This method is equivalent to UnitFullName and adds compatibility with Classic.

  @since 1.0.0

  @return string the unit's full name
  ]]
  function instance:getNameAndRealm( unit )

    -- attempts to get the name and realm name
    local name, realm = UnitName( unit );

    -- sanity check
    if nil == name then return nil; end

    -- it means this method was called for a player in the same realm
    if nil == realm then

      realm = GetRealmName();

      -- removes the spaces in the realm name like Blizzard does for UnitFullName
      realm = string.gsub(realm, ' ', '');
    end

    return name .. '-' .. realm;
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


  --[[
  Gets an item loot information from a loot string got from CHAT_MSG_LOOT payload.

  @since 0.4.0-alpha

  @return mixed item loot information with string name, bool valid and int quantity
  ]]
  function instance:parseChatMsgLoot( msg )

    -- sanity check
    msg = msg or '';

    -- return object with item loot information
    local item = {};

    -- default quantity (may be replaced only if multiple loot is found)
    item.quantity = 1;

    -- determines whether the looted item is valid
    item.valid = true;

    if msg:match( self.PATTERN_LOOT_ITEM_SELF_MULTIPLE ) then

      -- when the player loots more than 1 of the same item
      itemLink, quantity = string.match( msg, self.PATTERN_LOOT_ITEM_SELF_MULTIPLE );

      item.quantity = quantity;

    elseif msg:match( self.PATTERN_LOOT_ITEM_SELF ) then

      -- when the player loots only 1 item
      itemLink = string.match( msg, self.PATTERN_LOOT_ITEM_SELF );

    else

      MemoryCore:getLogger():debug( 'Invalid loot item msg' );

      item.valid = false;
    end

    if item.valid then

      -- gets the item name from the extracted item link
      local itemName = GetItemInfo( itemLink );

      -- considering that the item link can be invalid, do a sanity check
      item.valid = itemName ~= nil and itemName ~= '';
      item.name  = itemName;
    end

    return item;
  end


  -- destroys the prototype, so instance will be unique
  MemoryAddon_CompatibilityHelper = nil;

  return instance;
end
