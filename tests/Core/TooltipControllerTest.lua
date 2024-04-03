---@diagnostic disable: duplicate-set-field

TestTooltipController = BaseTestClass:new()
    -- @covers MemoryAddon_TooltipController:shouldAddMemoriesToTooltip()
    function TestTooltipController:testShouldAddMemoriesToTooltip()
        local function execution(settingValue, expected)
            -- mocks
            function MemoryCore:setting() return settingValue end

            local result = MemoryCore:getTooltipController():shouldAddMemoriesToTooltip()

            lu.assertEquals(expected, result)
        end

        -- default behavior
        execution(nil, true)

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