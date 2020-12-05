--[[
Adds the memory text formatter prototype and creation method to core.

@since 0.6.0-beta

@param MemoryRepository repository the memory repository instance
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


    --[[
    Builds and return a sentence about the first experience of the player with a memory.

    @since 0.6.0-beta

    @param MemoryAddon_Memory memory
    @return string
    ]]
    function instance:getFirstWithDate( memory )

      if nil == memory or ( not memory:hasFirst() ) then

        return "I don't remember the first time I " .. self:getPastActionSentence() .. self:getPastActionSentenceConnector( 'view' ) .. self:getSubject();
      end

      return 'The first time I ' .. self:getPastActionSentence() .. self:getPastActionSentenceConnector( 'view' ) .. self:getActionSubject() .. ' was on ' .. memory:getFirstFormattedDate();
    end


    --[[
    Builds and return a sentence about the first experience of the player with a memory with a day difference from today.

    @since 0.6.0-beta

    @param MemoryAddon_Memory memory
    @return string
    ]]
    function instance:getFirstWithDays( memory )

      if nil == memory or ( not memory:hasFirst() ) then

        return "I don't remember the first time I " .. self:getPastActionSentence() .. self:getPastActionSentenceConnector( 'view' ) .. self:getSubject();
      end

      return 'The first time I ' .. self:getPastActionSentence() .. self:getPastActionSentenceConnector( 'view' ) .. self:getActionSubject() .. ' was ' .. memory:getDaysSinceFirstDay() .. 'ago';
    end


    --[[
    Builds and return a sentence about the last experience of the player with a memory.

    @since 0.6.0-beta

    @param MemoryAddon_Memory memory
    @return string
    ]]
    function instance:getLastWithDate( memory )

      if nil == memory or ( not memory:hasLast() ) then

        return "I don't remember the last time I " .. self:getPastActionSentence() .. self:getPastActionSentenceConnector( 'view' ) .. self:getSubject();
      end

      return 'The last time I ' .. self:getPastActionSentence() .. self:getPastActionSentenceConnector( 'view' ) .. self:getActionSubject() .. ' was on ' .. memory:getLastFormattedDate();
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

    @return string
    ]]
    function instance:getPastActionSentenceConnector( context )

      if 'view' == context then

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

    @return string
    ]]
    function instance:getPresentActionSentenceConnector()

      return self.presentActionSentenceConnector or instance.UNDEFINED_PROPERTY;
    end


    --[[
    Gets the memory subject that can be a zone, npc, player, etc.

    @since 0.6.0-beta

    @return string
    ]]
    function instance:getSubject()

      return self.subject or instance.UNDEFINED_PROPERTY;
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
