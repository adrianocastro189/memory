TestMemory = BaseTestClass:new()

TestCase.new()
    :setName('construct')
    :setTestClass(TestMemory)
    :setExecution(function(self)
        local instance = MemoryCore:new('Memory/Memory')

        lu.assertNotNil(instance)
        lu.assertEquals('', instance.category)
        lu.assertEquals(-1, instance.first)
        lu.assertEquals('', instance.interactionType)
        lu.assertEquals(-1, instance.last)
        lu.assertEquals({}, instance.path)
        lu.assertEquals(0, instance.x)

        lu.assertEquals('undefined', instance.DATA_PLACEHOLDER)
    end)
    :register()

TestCase.new()
    :setName('getDaysSince... methods')
    :setTestClass(TestMemory)
    :setExecution(function(data)
        local memory = MemoryCore:new('Memory/Memory')

        memory[data.hasMethod]  = function() return data.has end

        memory.getFirst = function () return { getDate = function () return 'test-first' end } end
        memory.getLast  = function () return { getDate = function () return 'test-last' end } end

        MemoryCore.getDateHelper = function () return {
            getDaysDiff = function (self, d1, d2) return 'test-diff-'..d1..'-'..d2 end,
            getToday = function () return 'test-today' end
        } end

        local result = memory[data.getMethod](memory)

        lu.assertEquals(data.expectedOutput, result)
    end)
    :setScenarios({
        ['getDaysSinceFirstDay when has first'] = {
            getMethod = 'getDaysSinceFirstDay',
            hasMethod = 'hasFirst',
            has = true,
            expectedOutput = 'test-diff-test-first-test-today'
        },
        ['getDaysSinceFirstDay when has no first'] = {
            getMethod = 'getDaysSinceFirstDay',
            hasMethod = 'hasFirst',
            has = false,
            expectedOutput = -1
        },
        ['getDaysSinceLastDay when has last'] = {
            getMethod = 'getDaysSinceLastDay',
            hasMethod = 'hasLast',
            has = true,
            expectedOutput = 'test-diff-test-last-test-today'},
        ['getDaysSinceLastDay when has no last'] = {
            getMethod = 'getDaysSinceLastDay',
            hasMethod = 'hasLast',
            has = false,
            expectedOutput = -1
        },
    })
    :register()

TestCase.new()
    :setName('get...FormattedDate methods')
    :setTestClass(TestMemory)
    :setExecution(function(data)
        local memory = MemoryCore:new('Memory/Memory')

        memory[data.hasMethod]  = function() return data.has end
        memory[data.getMethod] = function () return {
            getDate = function () return data.date end,
            hasDate = function () return data.hasDate end
        } end

        MemoryCore.getDateHelper = function () return {
            getFormattedDate = function (self, date) return
                'test-formatted-' .. date
            end
        } end

        lu.assertEquals(data.expectedOutput, memory[data.getFormattedDateMethod](memory))
    end)
    :setScenarios({
        ['first with no first'] = {
            hasMethod = 'hasFirst',
            has = false,
            getFormattedDateMethod = 'getFirstFormattedDate',
            getMethod = 'getFirst',
            date = 'test-date',
            hasDate = true,
            expectedOutput = 'undefined',
        },
        ['first with no date'] = {
            hasMethod = 'hasFirst',
            has = true,
            getFormattedDateMethod = 'getFirstFormattedDate',
            getMethod = 'getFirst',
            date = 'test-date',
            hasDate = false,
            expectedOutput = 'undefined',
        },
        ['first with date'] = {
            hasMethod = 'hasFirst',
            has = true,
            getFormattedDateMethod = 'getFirstFormattedDate',
            getMethod = 'getFirst',
            date = 'test-date',
            hasDate = true,
            expectedOutput = 'test-formatted-test-date',
        },
        ['last with no last'] = {
            hasMethod = 'hasLast',
            has = false,
            getFormattedDateMethod = 'getLastFormattedDate',
            getMethod = 'getLast',
            date = 'test-date',
            hasDate = true,
            expectedOutput = 'undefined',
        },
        ['last with no date'] = {
            hasMethod = 'hasLast',
            has = true,
            getFormattedDateMethod = 'getLastFormattedDate',
            getMethod = 'getLast',
            date = 'test-date',
            hasDate = false,
            expectedOutput = 'undefined',
        },
        ['last with date'] = {
            hasMethod = 'hasLast',
            has = true,
            getFormattedDateMethod = 'getLastFormattedDate',
            getMethod = 'getLast',
            date = 'test-date',
            hasDate = true,
            expectedOutput = 'test-formatted-test-date',
        },
    })
    :register()

TestCase.new()
    :setName('get...PlayerLevel methods')
    :setTestClass(TestMemory)
    :setExecution(function (data)
        local memory = MemoryCore:new('Memory/Memory')

        memory[data.hasMethod]  = function() return data.has end
        memory[data.getMethod] = function () return {
            getPlayerLevel = function () return data.level end,
            hasLevel = function () return data.hasLevel end
        } end

        lu.assertEquals(data.expectedOutput, memory[data.getLevelMethod](memory))
    end)
    :setScenarios({
        ['first with no first'] = {
            hasMethod = 'hasFirst',
            has = false,
            getLevelMethod = 'getFirstPlayerLevel',
            getMethod = 'getFirst',
            level = 1,
            hasLevel = true,
            expectedOutput = '',
        },
        ['first with no level'] = {
            hasMethod = 'hasFirst',
            has = true,
            getLevelMethod = 'getFirstPlayerLevel',
            getMethod = 'getFirst',
            level = 1,
            hasLevel = false,
            expectedOutput = '',
        },
        ['first with level'] = {
            hasMethod = 'hasFirst',
            has = true,
            getLevelMethod = 'getFirstPlayerLevel',
            getMethod = 'getFirst',
            level = 1,
            hasLevel = true,
            expectedOutput = 1,
        },
        ['last with no last'] = {
            hasMethod = 'hasLast',
            has = false,
            getLevelMethod = 'getLastPlayerLevel',
            getMethod = 'getLast',
            level = 2,
            hasLevel = true,
            expectedOutput = '',
        },
        ['last with no level'] = {
            hasMethod = 'hasLast',
            has = true,
            getLevelMethod = 'getLastPlayerLevel',
            getMethod = 'getLast',
            level = 2,
            hasLevel = false,
            expectedOutput = '',
        },
        ['last with level'] = {
            hasMethod = 'hasLast',
            has = true,
            getLevelMethod = 'getLastPlayerLevel',
            getMethod = 'getLast',
            level = 2,
            hasLevel = true,
            expectedOutput = 2,
        },
    })
    :register()

TestCase.new()
    :setName('hasCategory')
    :setTestClass(TestMemory)
    :setExecution(function(data)
        local memory = MemoryCore:new('Memory/Memory')

        memory.getCategory = function () return data.category end

        lu.assertEquals(data.expectedOutput, memory:hasCategory())
    end)
    :setScenarios({
        ['has category'] = {category = 'test-category', expectedOutput = true},
        ['has no category'] = {category = '', expectedOutput = false},
    })
    :register()

TestCase.new()
    :setName('hasFirst')
    :setTestClass(TestMemory)
    :setExecution(function(data)
        local memory = MemoryCore:new('Memory/Memory')

        memory.first = data.first
        memory.getFirst = data.getFirst

        lu.assertEquals(data.expectedOutput, memory:hasFirst())
    end)
    :setScenarios({
        ['first is null'] = {
            first = nil,
            getFirst = function () return nil end,
            expectedOutput = false
        },
        ['first is -1'] = {
            first = -1,
            getFirst = function () return -1 end,
            expectedOutput = false
        },
        ['first has no date'] = {
            first = -1,
            getFirst = function () return { hasDate = function () return false end } end,
            expectedOutput = false
        },
        ['first has date'] = {
            first = -1,
            getFirst = function () return { hasDate = function () return true end } end,
            expectedOutput = true
        },
    })
    :register()

TestCase.new()
    :setName('hasFirstMoment')
    :setTestClass(TestMemory)
    :setExecution(function(data)
        local memory = MemoryCore:new('Memory/Memory')

        memory.hasFirst = function () return data.hasFirst end
        memory.getFirst = function () return { hasMoment = function () return data.hasMoment end } end

        lu.assertEquals(data.expectedOutput, memory:hasFirstMoment())
    end)
    :setScenarios({
        ['has no first'] = {hasFirst = false, hasMoment = true, expectedOutput = false},
        ['has no first moment'] = {hasFirst = true, hasMoment = false, expectedOutput = false},
        ['has first moment'] = {hasFirst = true, hasMoment = true, expectedOutput = true},
    })
    :register()

TestCase.new()
    :setName('hasInteractionType')
    :setTestClass(TestMemory)
    :setExecution(function(data)
        local memory = MemoryCore:new('Memory/Memory')

        memory.getInteractionType = function () return data.interactionType end

        lu.assertEquals(data.expectedOutput, memory:hasInteractionType())
    end)
    :setScenarios({
        ['has interaction type'] = {interactionType = 'test-interactionType', expectedOutput = true},
        ['has no interaction type'] = {interactionType = '', expectedOutput = false},
    })
    :register()

TestCase.new()
    :setName('hasLast')
    :setTestClass(TestMemory)
    :setExecution(function(data)
        local memory = MemoryCore:new('Memory/Memory')

        memory.last = data.last
        memory.getLast = data.getLast

        lu.assertEquals(data.expectedOutput, memory:hasLast())
    end)
    :setScenarios({
        ['last is null'] = {
            last = nil,
            getLast = function () return nil end,
            expectedOutput = false
        },
        ['last is -1'] = {
            last = -1,
            getLast = function () return -1 end,
            expectedOutput = false
        },
        ['last has no date'] = {
            last = -1,
            getLast = function () return { hasDate = function () return false end } end,
            expectedOutput = false
        },
        ['last has date'] = {
            last = -1,
            getLast = function () return { hasDate = function () return true end } end,
            expectedOutput = true
        },
    })
    :register()

TestCase.new()
    :setName('hasLastMoment')
    :setTestClass(TestMemory)
    :setExecution(function(data)
        local memory = MemoryCore:new('Memory/Memory')

        memory.hasLast = function () return data.hasLast end
        memory.getLast = function () return { hasMoment = function () return data.hasMoment end } end

        lu.assertEquals(data.expectedOutput, memory:hasLastMoment())
    end)
    :setScenarios({
        ['has no last'] = {hasLast = false, hasMoment = true, expectedOutput = false},
        ['has no last moment'] = {hasLast = true, hasMoment = false, expectedOutput = false},
        ['has last moment'] = {hasLast = true, hasMoment = true, expectedOutput = true},
    })
    :register()

TestCase.new()
    :setName('hasPath')
    :setTestClass(TestMemory)
    :setExecution(function(data)
        local memory = MemoryCore:new('Memory/Memory')

        memory.getPath = function () return data.path end

        lu.assertEquals(data.expectedOutput, memory:hasPath())
    end)
    :setScenarios({
        ['path is nil'] = {path = nil, expectedOutput = false},
        ['path is empty'] = {path = {}, expectedOutput = false},
        ['path is not empty'] = {path = {'a', 'b', 'c'}, expectedOutput = true},
    })
    :register()

TestCase.new()
    :setName('isValid')
    :setTestClass(TestMemory)
    :setExecution(function(data)
        local memory = MemoryCore:new('Memory/Memory')

        memory.hasCategory = function () return data.hasCategory end
        memory.hasInteractionType = function () return data.hasInteractionType end
        memory.hasPath = function () return data.hasPath end

        lu.assertEquals(data.expectedOutput, memory:isValid())
    end)
    :setScenarios({
        ['has no category'] = {hasCategory = false, hasInteractionType = true, hasPath = true, expectedOutput = false},
        ['has no interaction type'] = {hasCategory = true, hasInteractionType = false, hasPath = true, expectedOutput = false},
        ['has no path'] = {hasCategory = true, hasInteractionType = true, hasPath = false, expectedOutput = false},
        ['has category, interaction type, and path'] = {hasCategory = true, hasInteractionType = true, hasPath = true, expectedOutput = true},
    })
    :register()

TestCase.new()
    :setName('randomNumber')
    :setTestClass(TestMemory)
    :setExecution(function(data)
        local memory = MemoryCore:new('Memory/Memory')

        lu.assertNotIsNil(memory:randomNumber())
    end)
    :register()

TestCase.new()
    :setName('maybePrint')
    :setTestClass(TestMemory)
    :setExecution(function (data)
        local memory = MemoryCore:new('Memory/Memory')

        memory.randomNumber = function () return data.randomNumber end
        memory.print = function (instance, textFormatter)
            memory.textFormatterArg = textFormatter
        end

        MemoryCore.setting = function (instance, key, defaultValue)
            if key == 'memory.printChance' and defaultValue == '0.2' then
                return '0.2'
            end
            return nil
        end

        memory:maybePrint('test-text-formatter')

        lu.assertEquals(data.expectedOutput, memory.textFormatterArg)
    end)
    :setScenarios({
        ['randomNumber is less than setting'] = {
            randomNumber = 0.1,
            expectedOutput = 'test-text-formatter'
        },
        ['randomNumber is equal to setting'] = {
            randomNumber = 0.2,
            expectedOutput = 'test-text-formatter'
        },
        ['randomNumber is greater than setting'] = {
            randomNumber = 0.3,
            expectedOutput = nil
        },
    })
    :register()

TestCase.new()
    :setName('maybeTakeScreenshot')
    :setTestClass(TestMemory)
    :setExecution(function (data)
        local memory = MemoryCore:new('Memory/Memory')

        memory.randomNumber = function () return data.randomNumber end
        memory.takeScreenshot = function (instance, textFormatter)
            memory.textFormatterArg = textFormatter
        end

        MemoryCore.setting = function (instance, key, defaultValue)
            if key == 'memory.screenshotChance' and defaultValue == '-1' then
                -- emulates the screenshot chance setting being enabled
                return 0.2
            end
            return nil
        end

        memory:maybeTakeScreenshot('test-text-formatter')

        lu.assertEquals(data.expectedOutput, memory.textFormatterArg)
    end)
    :setScenarios({
        ['randomNumber is less than setting'] = {
            randomNumber = 0.1,
            expectedOutput = 'test-text-formatter'
        },
        ['randomNumber is equal to setting'] = {
            randomNumber = 0.2,
            expectedOutput = 'test-text-formatter'
        },
        ['randomNumber is greater than setting'] = {
            randomNumber = 0.3,
            expectedOutput = nil
        },
    })
    :register()

TestCase.new()
    :setName('print')
    :setTestClass(TestMemory)
    :setExecution(function ()
        local textFormatter = {
            getRandomChatMessage = function (self, memory, x)
                self.memoryArg = memory
                self.xArg = x
                return 'test-random-chat-message'
            end
        }

        local memory = MemoryCore:new('Memory/Memory')

        MemoryCore.print = function (self, sentence)
            self.sentenceArg = sentence
        end

        memory:print(textFormatter)

        lu.assertEquals(memory, textFormatter.memoryArg)
        lu.assertEquals(1, textFormatter.xArg)
        lu.assertEquals('test-random-chat-message', MemoryCore.sentenceArg)
    end)
    :register()

TestCase.new()
    :setName('save')
    :setTestClass(TestMemory)
    :setExecution(function ()
        local repository = {
            storeMemory = function (self, memory)
                self.memoryArg = memory
            end
        }

        MemoryCore.getRepository = function () return repository end

        local memory = MemoryCore:new('Memory/Memory')

        memory:save()

        lu.assertEquals(memory, repository.memoryArg)
    end)
    :register()

TestCase.new()
    :setName('setters and getters')
    :setTestClass(TestMemory)
    :setExecution(function (data)
        local instance = MemoryCore:new('Memory/Memory')

        local setterResult = instance[data.setter](instance, data.value)
        local getterResult = instance[data.getter](instance)

        lu.assertEquals(instance, setterResult)
        lu.assertEquals(data.value, getterResult)
    end)
    :setScenarios({
        ['category'] = {setter = 'setCategory', getter = 'getCategory', value = 'test-category'},
        ['first'] = {setter = 'setFirst', getter = 'getFirst', value = 'test-first-memory-string'},
        ['interactionType'] = {setter = 'setInteractionType', getter = 'getInteractionType', value = 'test-interactionType'},
        ['last'] = {setter = 'setLast', getter = 'getLast', value = 'test-last-memory-string'},
        ['path'] = {setter = 'setPath', getter = 'getPath', value = {'a', 'b', 'c'}},
        ['x'] = {setter = 'setX', getter = 'getX', value = 1},
    })
    :register()

TestCase.new()
    :setName('takeScreenshot')
    :setTestClass(TestMemory)
    :setExecution(function (data)
        local memory = MemoryCore:new('Memory/Memory')

        local textFormatter = {
            getPresentCount = function (self, memory, x, printFirst)
                self.memoryArg = memory
                self.xArg = x
                self.printFirstArg = printFirst
                return data.sentece
            end
        }

        local screenshotController = {
            prepareScreenshot = function (self, sentence)
                self.sentenceArg = sentence
            end,
            takeScreenshot = function () end
        }
        MemoryCore.getScreenshotController = function () return screenshotController end

        local compatibilityHelper = {
            wait = function (self, seconds, callback)
                self.secondsArg = seconds
                self.callbackArg = callback
            end
        }
        MemoryCore.getCompatibilityHelper = function () return compatibilityHelper end

        memory:takeScreenshot(textFormatter)

        lu.assertEquals(memory, textFormatter.memoryArg)
        lu.assertEquals(1, textFormatter.xArg)
        lu.assertEquals(true, textFormatter.printFirstArg)
        lu.assertEquals(data.sentece, screenshotController.sentenceArg)
        lu.assertEquals(data.secondsArg, compatibilityHelper.secondsArg)
        
        lu.assertEquals(data.shouldTakeScreenshot, compatibilityHelper.callbackArg == screenshotController.takeScreenshot)
    end)
    :setScenarios({
        ['sentence is nil'] = {
            sentece = nil,
            secondsArg = nil,
            shouldTakeScreenshot = false,
        },
        ['sentence is not nil'] = {
            sentece = 'test-sentence',
            secondsArg = 2,
            shouldTakeScreenshot = true,
        },
    })
    :register()