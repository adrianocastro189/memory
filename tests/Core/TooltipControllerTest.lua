-- @TODO: Move this test class to the new TestCase structure <2024.07.30>

TestTooltipController = BaseTestClass:new()
    -- @covers MemoryAddon_TooltipController
    function TestTooltipController:testIsListeningToTooltipEvents()
        local function execution(handlerName, event)
            local isListening = false

            MemoryCore:getTooltipController()[handlerName] = function() isListening = true end

            MemoryCore.events:notify(event, { name = 'test-name' })

            lu.assertTrue(isListening)
        end

        execution('handleTooltipItem', 'TOOLTIP_ITEM_SHOWN')
        execution('handleTooltipUnit', 'TOOLTIP_UNIT_SHOWN')
    end

    -- @covers MemoryAddon_TooltipController:shouldAddMemoriesToTooltip()
    function TestTooltipController:testShouldAddMemoriesToTooltip()
        local function execution(settingValue, expected)
            -- mocks
            function MemoryCore:setting() return settingValue end

            local result = MemoryCore:getTooltipController():shouldAddMemoriesToTooltip()

            lu.assertEquals(expected, result)
        end

        -- true values
        execution(true, true)
        execution(1, true)
        execution('1', true)
        execution('true', true)
        execution('yes', true)

        -- false values
        execution(0, false)
        execution('0', false)
        execution('false', false)
        execution('no', false)
        execution(false, false)
    end
-- end of TestTooltipController