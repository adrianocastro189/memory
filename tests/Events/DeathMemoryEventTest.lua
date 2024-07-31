TestDeathMemoryEvent = BaseTestClass:new()

TestCase.new()
    :setName('eventDeath is set')
    :setTestClass(TestDeathMemoryEvent)
    :setExecution(function ()
        local eventDeathListener = nil
        MemoryCore.arr:each(MemoryCore.eventListeners, function (listener)
            if MemoryCore.arr:inArray(listener.events, 'PLAYER_DEAD') then
                eventDeathListener = listener
            end
        end)

        local textFormatter = eventDeathListener:buildMemoryTextFormatter()

        local memory = MemoryCore:new('Memory/Memory')

        local sentence = textFormatter:getChatMessage(memory, textFormatter.MESSAGE_TYPE_FIRST_WITH_DATE)

        lu.assertEquals("I don't remember the first time I died", sentence)
    end)
    :register()