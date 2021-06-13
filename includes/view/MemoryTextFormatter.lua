--[[
Adds the memory text formatter prototype and creation method to core.

@since 0.6.0-beta

@param MemoryAddon_MemoryRepository repository the memory repository instance
]]
function MemoryAddon_addMemoryTextFormatterPrototype( core )

  --[[
  The memory text formatter prototype.

  @since 0.6.0-beta
  ]]
  local MemoryAddon_MemorTextFormatter = {};
  MemoryAddon_MemorTextFormatter.__index = MemoryAddon_MemorTextFormatter;

  --[[
  Builds a new instance of a memory text formatter.

  @since 0.6.0-beta

  @return MemoryAddon_MemorTextFormatter
  ]]
  function MemoryAddon_MemorTextFormatter:new()

    local instance = {};

    setmetatable( instance, MemoryAddon_MemorTextFormatter );

    instance.MESSAGE_TYPE_FIRST_WITH_DATE = 1;
    instance.MESSAGE_TYPE_FIRST_WITH_DAYS = 2;
    instance.MESSAGE_TYPE_LAST_WITH_DATE  = 3;
    instance.MESSAGE_TYPE_LAST_WITH_DAYS  = 4;
    instance.MESSAGE_TYPE_COUNT           = 5;
    instance.UNDEFINED_PROPERTY           = '(undefined property)';
    instance.UNDEFINED_MESSAGE_TYPE       = '(undefined message type)';

    instance.pastActionSentence             = instance.UNDEFINED_PROPERTY;
    instance.pastActionSentenceConnector    = instance.UNDEFINED_PROPERTY;
    instance.presentActionSentence          = instance.UNDEFINED_PROPERTY;
    instance.presentActionSentenceConnector = instance.UNDEFINED_PROPERTY;
    instance.subject                        = instance.UNDEFINED_PROPERTY;


    --[[
    Gets a sentence defined by type.

    @since 0.6.0-beta

    @param MemoryAddon_Memory memory
    @param int type
    @param int x may increase or decrease the x value for MESSAGE_TYPE_COUNT (optional)
    @return string
    ]]
    function instance:getChatMessage( memory, type, --[[optional]] x )

      if self.MESSAGE_TYPE_FIRST_WITH_DATE == type then return self:getFirstWithDate( memory );   end
      if self.MESSAGE_TYPE_FIRST_WITH_DAYS == type then return self:getFirstWithDays( memory );   end
      if self.MESSAGE_TYPE_LAST_WITH_DATE  == type then return self:getLastWithDate( memory );    end
      if self.MESSAGE_TYPE_LAST_WITH_DAYS  == type then return self:getLastWithDays( memory );    end
      if self.MESSAGE_TYPE_COUNT           == type then return self:getPresentCount( memory, x ); end

      return self.UNDEFINED_MESSAGE_TYPE;
    end


    --[[
    Builds and return a sentence about the first experience of the player with a memory.

    @since 0.6.0-beta

    @param MemoryAddon_Memory memory
    @return string
    ]]
    function instance:getFirstWithDate( memory )

      if nil == memory or ( not memory:hasFirst() ) then

        return 'I don\'t remember the first time I ' .. self:getPastActionSentence() .. self:getPastActionSentenceConnector( 'view' ) .. self:getSubject( 'view' );
      end

      return 'The first time I '
        .. self:getPastActionSentence()
        .. self:getPastActionSentenceConnector( 'view' )
        .. self:getSubject( 'view' )
        .. ' was on '
        .. memory:getFirstFormattedDate()
        .. self:maybeAppendLocation( memory:getInteractionType(), memory:getFirst() )
        .. self:maybeAppendLevel( memory:getFirst() )
        .. self:maybeAppendMoment( memory:getFirst() );
    end


    --[[
    Builds and return a sentence about the first experience of the player with a memory with a day difference from today.

    @since 0.6.0-beta

    @param MemoryAddon_Memory memory
    @return string
    ]]
    function instance:getFirstWithDays( memory )

      if nil == memory or ( not memory:hasFirst() ) then

        return 'I don\'t remember the first time I ' .. self:getPastActionSentence() .. self:getPastActionSentenceConnector( 'view' ) .. self:getSubject( 'view' );
      end

      local days = memory:getDaysSinceFirstDay();
      local was  = '';

      -- generates a was fragment that makes sense
      if 0 == days then was = 'today'; else was = days .. ' day(s) ago'; end

      return 'The first time I '
        .. self:getPastActionSentence()
        .. self:getPastActionSentenceConnector( 'view' )
        .. self:getSubject( 'view' )
        .. ' was '
        .. was
        .. self:maybeAppendLocation( memory:getInteractionType(), memory:getFirst() )
        .. self:maybeAppendLevel( memory:getFirst() )
        .. self:maybeAppendMoment( memory:getFirst() );
    end


    --[[
    Builds and return a sentence about the last experience of the player with a memory.

    @since 0.6.0-beta

    @param MemoryAddon_Memory memory
    @return string
    ]]
    function instance:getLastWithDate( memory )

      if nil == memory or ( not memory:hasLast() ) then

        return 'I don\'t remember the last time I ' .. self:getPastActionSentence() .. self:getPastActionSentenceConnector( 'view' ) .. self:getSubject( 'view' );
      end

      return 'The last time I '
        .. self:getPastActionSentence()
        .. self:getPastActionSentenceConnector( 'view' )
        .. self:getSubject( 'view' )
        .. ' was on '
        .. memory:getLastFormattedDate()
        .. self:maybeAppendLocation( memory:getInteractionType(), memory:getLast() )
        .. self:maybeAppendLevel( memory:getLast() )
        .. self:maybeAppendMoment( memory:getLast() );
    end


    --[[
    Builds and return a sentence about the last experience of the player with a memory with a day difference from today.

    @since 0.6.0-beta

    @param MemoryAddon_Memory memory
    @return string
    ]]
    function instance:getLastWithDays( memory )

      if nil == memory or ( not memory:hasLast() ) then

        return 'I don\'t remember the last time I ' .. self:getPastActionSentence() .. self:getPastActionSentenceConnector( 'view' ) .. self:getSubject( 'view' );
      end

      local days = memory:getDaysSinceLastDay();
      local was  = '';

      -- generates a was fragment that makes sense
      if 0 == days then was = 'today'; else was = days .. ' day(s) ago'; end

      return 'The last time I '
        .. self:getPastActionSentence()
        .. self:getPastActionSentenceConnector( 'view' )
        .. self:getSubject( 'view' )
        .. ' was '
        .. was
        .. self:maybeAppendLocation( memory:getInteractionType(), memory:getLast() )
        .. self:maybeAppendLevel( memory:getLast() )
        .. self:maybeAppendMoment( memory:getLast() );
    end


    --[[
    Gets the memory past action sentence that can be visited, talked, etc.

    @since 0.6.0-beta

    @return string
    ]]
    function instance:getPastActionSentence()

      return self.pastActionSentence or instance.UNDEFINED_PROPERTY;
    end


    --[[
    Gets the memory past action sentence connector that can be with, to, etc.

    @since 0.6.0-beta

    @param string context may wrap stuff around the returned string
    @return string
    ]]
    function instance:getPastActionSentenceConnector( context )

      if 'view' == context then

        -- may return a single space if there's no sentence connector
        if '' == self.pastActionSentenceConnector then return ' '; end

        return ' ' .. self.pastActionSentenceConnector .. ' ';
      end

      return self.pastActionSentenceConnector or instance.UNDEFINED_PROPERTY;
    end


    --[[
    Gets the memory present action sentence that can be visit, talk, etc.

    @since 0.6.0-beta

    @return string
    ]]
    function instance:getPresentActionSentence()

      return self.presentActionSentence or instance.UNDEFINED_PROPERTY;
    end


    --[[
    Gets the memory present action sentence connector that can be with, to, etc.

    @since 0.6.0-beta

    @param string context may wrap stuff around the returned string
    @return string
    ]]
    function instance:getPresentActionSentenceConnector( context )

      if 'view' == context then

        -- may return a single space if there's no sentence connector
        if '' == self.presentActionSentenceConnector then return ' '; end

        return ' ' .. self.presentActionSentenceConnector .. ' ';
      end

      return self.presentActionSentenceConnector or instance.UNDEFINED_PROPERTY;
    end


    --[[
    Gets a present tense sentence about how many times the player had experienced this memory.

    @since 0.6.0-beta

    @param MemoryAddon_Memory memory
    @param int x count to add
    @return string
    ]]
    function instance:getPresentCount( memory, --[[optional]] x, --[[optional]] printFirst )

      printFirst = printFirst or false;

      if ( nil == memory or 0 == memory:getX() ) and not printFirst then

        return 'I don\'t remember how many times I ' .. self:getPastActionSentence() .. self:getPastActionSentenceConnector( 'view' ) .. self:getSubject( 'view' );
      end

      -- may change x value with the optional param
      x = memory:getX() + ( x or 0 );

      return 'This is the ' .. x .. MemoryCore:getStringHelper():getOrdinalSuffix( x ) .. ' time I ' .. self:getPresentActionSentence() .. self:getPresentActionSentenceConnector( 'view' ) .. self:getSubject( 'view' );
    end


    --[[
    Gets a random memory chat message.

    @since 0.6.0-beta

    @param MemoryAddon_Memory memory
    @param int x may increase or decrease the x value for MESSAGE_TYPE_COUNT (optional)
    @return string
    ]]
    function instance:getRandomChatMessage( memory, --[[optional]] x )

      local messageTypes = {
        self.MESSAGE_TYPE_FIRST_WITH_DATE,
        self.MESSAGE_TYPE_FIRST_WITH_DAYS,
        self.MESSAGE_TYPE_LAST_WITH_DATE,
        self.MESSAGE_TYPE_LAST_WITH_DAYS,
        self.MESSAGE_TYPE_COUNT
      }

      local randomType = math.ceil( math.random() * #messageTypes );

      if 0 == randomType then

        MemoryCore:getLogger():warn( 'Unexpected random number' );
        return self.UNDEFINED_MESSAGE_TYPE;
      end

      return self:getChatMessage( memory, randomType, x );
    end


    --[[
    Gets the memory subject that can be a zone, npc, player, etc.

    @since 0.6.0-beta

    @param string context may wrap stuff around the returned string
    @return string
    ]]
    function instance:getSubject( context )

      local subject = self.subject or instance.UNDEFINED_PROPERTY;

      if 'view' == context then

        subject = MemoryCore:highlight( subject );
      end

      return subject;
    end


    --[[
    May return a level string to be appended to the memory sentence.

    @since 1.1.1

    @return string
    ]]
    function instance:maybeAppendLevel( memoryString )

      -- sanity check
      if not memoryString:hasLevel() then return ''; end

      -- we don't want to show the level if the player is at the same level
      if tonumber( UnitLevel( 'player' ) ) == tonumber( memoryString:getPlayerLevel() ) then return ''; end

      return ' when my level was ' .. MemoryCore:highlight( memoryString:getPlayerLevel() );
    end


    --[[
    May return a location to be appended to the memory sentence.

    @since 1.1.1

    @return string
    ]]
    function instance:maybeAppendLocation( interactionType, memoryString )

      local location = memoryString:getLocation();

      -- sanity check
      if nil == location or '' == location or 'visit' == interactionType then return ''; end

      return ' at ' .. MemoryCore:highlight( location );
    end


    --[[
    May return a moment to be appended to the memory.

    @since 1.1.0

    @param MemoryAddon_MemoryString memoryString
    @return string
    ]]
    function instance:maybeAppendMoment( memoryString )

      -- sanity check
      if not memoryString:hasMoment() then return ''; end

      -- gets the current moment
      local currentMoment = MemoryCore:getMomentRepository():getCurrentMomentIndex();

      -- we don't want to show the moment if it's the current moment
      if ( tonumber( currentMoment ) or 0 ) == ( tonumber( memoryString:getMoment() ) or 0 ) then return ''; end

      -- gets the moment description
      local moment = memoryString:getMoment( 'view' );

      -- returns the highlighted memory moment
      return MemoryCore:highlight( ' ~' .. moment .. '~', '34c0eb' );
    end


    --[[
    Sets the memory past action sentence that can be visited, talked, etc.

    @since 0.6.0-beta

    @param string pastActionSentence
    @return MemoryAddon_MemorTextFormatter
    ]]
    function instance:setPastActionSentence( pastActionSentence )

      self.pastActionSentence = pastActionSentence or instance.UNDEFINED_PROPERTY;

      return self;
    end


    --[[
    Sets the memory past action sentence connector that can be with, to, etc.

    @since 0.6.0-beta

    @param string pastActionSentenceConnector
    @return MemoryAddon_MemorTextFormatter
    ]]
    function instance:setPastActionSentenceConnector( pastActionSentenceConnector )

      self.pastActionSentenceConnector = pastActionSentenceConnector or instance.UNDEFINED_PROPERTY;

      return self;
    end


    --[[
    Sets the memory present action sentence that can be visit, talk, etc.

    @since 0.6.0-beta

    @param string presentActionSentence
    @return MemoryAddon_MemorTextFormatter
    ]]
    function instance:setPresentActionSentence( presentActionSentence )

      self.presentActionSentence = presentActionSentence or instance.UNDEFINED_PROPERTY;

      return self;
    end


    --[[
    Sets the memory present action sentence connector that can be with, to, etc.

    @since 0.6.0-beta

    @param string presentActionSentenceConnector
    @return MemoryAddon_MemorTextFormatter
    ]]
    function instance:setPresentActionSentenceConnector( presentActionSentenceConnector )

      self.presentActionSentenceConnector = presentActionSentenceConnector or instance.UNDEFINED_PROPERTY;

      return self;
    end


    --[[
    Sets the memory subject that can be a zone, npc, player, etc.

    @since 0.6.0-beta

    @param string subject
    @return MemoryAddon_MemorTextFormatter
    ]]
    function instance:setSubject( subject )

      self.subject = subject or instance.UNDEFINED_PROPERTY;

      return self;
    end


    return instance;
  end


  --[[
  Builds a new instance of a memory text formatter from core.

  @since 0.6.0-beta

  @return MemoryAddon_MemorTextFormatter
  ]]
  function core:newMemoryTextFormatter()

    return MemoryAddon_MemorTextFormatter:new();
  end


  -- prevents this method to be called again
  MemoryAddon_addMemoryTextFormatterPrototype = nil;
end
