TestMemoryString = BaseTestClass:new()

-- @covers MemoryString.__construct()
TestCase.new()
    :setName('__construct')
    :setTestClass(TestMemoryString)
    :setExecution(function(data)
        -- can't use spies here
        local instanceBuildCall = nil
        local classMock = MemoryCore:getClass('Memory/MemoryString')
        function classMock:build() instanceBuildCall = 'build' end

        function classMock:parse() instanceBuildCall = 'parse' end

        MemoryCore:addClass('Memory/MemoryString', classMock)

        local instance = MemoryCore:new('Memory/MemoryString', data.memoryStringArg)

        lu.assertNotIsNil(instance)
        lu.assertEquals('|', instance.DATA_SEPARATOR)
        lu.assertEquals('-', instance.DATA_DEFAULT_CHAR)
        lu.assertEquals('-', instance.date)
        lu.assertEquals('-', instance.moment)
        lu.assertEquals('-', instance.playerLevel)
        lu.assertEquals('-', instance.subZone)
        lu.assertEquals('-', instance.zone)

        lu.assertEquals(data.expectedBuildCall, instanceBuildCall)
    end)
    :setScenarios({
        ['with no memory string'] = {
            memoryStringArg = nil,
            expectedBuildCall = 'build'
        },
        ['with a memory string'] = {
            memoryStringArg = '2020-01-01|1|60|Durotar|Valley of Trials',
            expectedBuildCall = 'parse'
        }
    })
    :register()

-- @covers MemoryString:build()
TestCase.new()
    :setName('build')
    :setTestClass(TestMemoryString)
    :setExecution(function(data)
        MemoryCore = Spy
            .new(MemoryCore)
            :mockMethod('getDateHelper', function()
                return {
                    getToday = function() return data.date end
                }
            end)
            :mockMethod('getMomentRepository', function()
                return {
                    getCurrentMomentIndex = function() return data.moment end
                }
            end)
        
        _G['UnitLevel'] = function() return data.playerLevel end
        _G['GetZoneText'] = function() return data.zone end
        _G['GetSubZoneText'] = function() return data.subZone end

        local instance = MemoryCore:new('Memory/MemoryString')
        
        instance:build()

        lu.assertEquals(data.expectedDate, instance.date)
        lu.assertEquals(data.expectedMoment, instance.moment)
        lu.assertEquals(data.expectedPlayerLevel, instance.playerLevel)
        lu.assertEquals(data.expectedZone, instance.zone)
        lu.assertEquals(data.expectedSubZone, instance.subZone)
    end)
    :setScenarios({
        ['with no data values'] = {
            date = nil,
            moment = nil,
            playerLevel = nil,
            zone = nil,
            subZone = nil,
            expectedDate = '-',
            expectedMoment = '-',
            expectedPlayerLevel = '-',
            expectedZone = '-',
            expectedSubZone = '-'
        },
        ['with data values'] = {
            date = '2020-01-01',
            moment = 1,
            playerLevel = 60,
            zone = 'Durotar',
            subZone = 'Valley of Trials',
            expectedDate = '2020-01-01',
            expectedMoment = 1,
            expectedPlayerLevel = 60,
            expectedZone = 'Durotar',
            expectedSubZone = 'Valley of Trials'
        },
    })
    :register()

-- @covers MemoryString:getLocation()
TestCase.new()
    :setName('getLocation')
    :setTestClass(TestMemoryString)
    :setExecution(function(data)
        local instance = MemoryCore:new('Memory/MemoryString')

        instance.zone = data.zone
        instance.subZone = data.subZone

        lu.assertEquals(data.expectedLocation, instance:getLocation())
    end)
    :setScenarios({
        ['no zone and subzone'] = {
            zone = '-',
            subZone = '-',
            expectedLocation = ''
        },
        ['no zone'] = {
            zone = '-',
            subZone = 'Valley of Trials',
            expectedLocation = 'Valley of Trials'
        },
        ['no subzone'] = {
            zone = 'Durotar',
            subZone = '-',
            expectedLocation = 'Durotar'
        },
        ['zone and subzone'] = {
            zone = 'Durotar',
            subZone = 'Valley of Trials',
            expectedLocation = 'Valley of Trials, Durotar'
        },
    })
    :register()

-- @covers MemoryString:getMoment()
TestCase.new()
    :setName('getMoment')
    :setTestClass(TestMemoryString)
    :setExecution(function(data)
        local instance = MemoryCore:new('Memory/MemoryString')

        instance.moment = data.moment

        MemoryCore = Spy
            .new(MemoryCore)
            :mockMethod('getMomentRepository', function()
                return {
                    getMoment = function() return 'moment' end
                }
            end)

        lu.assertEquals(data.expectedMoment, instance:getMoment(data.context))
    end)
    :setScenarios({
        ['view with no moment'] = {
            moment = '-',
            context = 'view',
            expectedMoment = '-'
        },
        ['view with moment'] = {
            moment = 1,
            context = 'view',
            expectedMoment = 'moment'
        },
        ['no view with moment'] = {
            moment = 1,
            context = 'no view',
            expectedMoment = 1
        },
    })
    :register()

-- @covers MemoryString:hasDate()
-- @covers MemoryString:hasLevel()
-- @covers MemoryString:hasMoment()
TestCase.new()
    :setName('has methods')
    :setTestClass(TestMemoryString)
    :setExecution(function(data)
        local instance = MemoryCore:new('Memory/MemoryString')

        instance[data.property] = data.value

        lu.assertEquals(data.expectedResult, instance[data.method](instance))
    end)
    :setScenarios({
        ['date with nil'] = {
            property = 'date',
            value = nil,
            method = 'hasDate',
            expectedResult = false,
        },
        ['date with -1'] = {
            property = 'date',
            value = '-1',
            method = 'hasDate',
            expectedResult = false,
        },
        ['database with value'] = {
            property = 'date',
            value = '2020-01-01',
            method = 'hasDate',
            expectedResult = true,
        },
        ['level with nil'] = {
            property = 'playerLevel',
            value = nil,
            method = 'hasLevel',
            expectedResult = false,
        },
        ['level with -'] = {
            property = 'playerLevel',
            value = '-',
            method = 'hasLevel',
            expectedResult = false,
        },
        ['level with value'] = {
            property = 'playerLevel',
            value = 60,
            method = 'hasLevel',
            expectedResult = true,
        },
        ['moment with nil'] = {
            property = 'moment',
            value = nil,
            method = 'hasMoment',
            expectedResult = false,
        },
        ['moment with -'] = {
            property = 'moment',
            value = '-',
            method = 'hasMoment',
            expectedResult = false,
        },
        ['moment with zero'] = {
            property = 'moment',
            value = 0,
            method = 'hasMoment',
            expectedResult = false,
        },
        ['moment with negative number'] = {
            property = 'moment',
            value = -1,
            method = 'hasMoment',
            expectedResult = false,
        },
        ['moment with value'] = {
            property = 'moment',
            value = 1,
            method = 'hasMoment',
            expectedResult = true,
        },
        ['subzone with nil'] = {
            property = 'subZone',
            value = nil,
            method = 'hasSubZone',
            expectedResult = false,
        },
        ['subzone with -'] = {
            property = 'subZone',
            value = '-',
            method = 'hasSubZone',
            expectedResult = false,
        },
        ['subzone with value'] = {
            property = 'subZone',
            value = 'Valley of Trials',
            method = 'hasSubZone',
            expectedResult = true,
        },
        ['zone with nil'] = {
            property = 'zone',
            value = nil,
            method = 'hasZone',
            expectedResult = false,
        },
        ['zone with -'] = {
            property = 'zone',
            value = '-',
            method = 'hasZone',
            expectedResult = false,
        },
        ['zone with value'] = {
            property = 'zone',
            value = 'Durotar',
            method = 'hasZone',
            expectedResult = true,
        },
    })
    :register()

-- @covers MemoryString:parse()
TestCase.new()
    :setName('parse')
    :setTestClass(TestMemoryString)
    :setExecution(function(data)
        local instance = MemoryCore:new('Memory/MemoryString')

        instance:parse(data.memoryString)

        lu.assertEquals(data.expectedDate, instance.date)
        lu.assertEquals(data.expectedMoment, instance.moment)
        lu.assertEquals(data.expectedPlayerLevel, instance.playerLevel)
        lu.assertEquals(data.expectedZone, instance.zone)
        lu.assertEquals(data.expectedSubZone, instance.subZone)
    end)
    :setScenarios({
        ['no memory string'] = {
            memoryString = nil,
            expectedDate = nil,
            expectedMoment = '-',
            expectedPlayerLevel = nil,
            expectedZone = nil,
            expectedSubZone = nil,
        },
        ['with memory string'] = {
            memoryString = '2020-01-01|60|Durotar|Valley of Trials|1',
            expectedDate = '2020-01-01',
            expectedMoment = '1',
            expectedPlayerLevel = '60',
            expectedZone = 'Durotar',
            expectedSubZone = 'Valley of Trials',
        },
        ['no moment'] = {
            memoryString = '2020-01-01|60|Durotar|Valley of Trials',
            expectedDate = '2020-01-01',
            expectedMoment = '-',
            expectedPlayerLevel = '60',
            expectedZone = 'Durotar',
            expectedSubZone = 'Valley of Trials',
        },
    })
    :register()

-- @covers MemoryString:getDate()
-- @covers MemoryString:getMoment()
-- @covers MemoryString:getPlayerLevel()
-- @covers MemoryString:getSubZone()
-- @covers MemoryString:getZone()
-- @covers MemoryString:setDate()
-- @covers MemoryString:setMoment()
-- @covers MemoryString:setPlayerLevel()
-- @covers MemoryString:setSubZone()
-- @covers MemoryString:setZone()
TestCase.new()
    :setName('setters and getters')
    :setTestClass(TestMemoryString)
    :setExecution(function(data)
        local instance = MemoryCore:new('Memory/MemoryString')

        local result = instance[data.setter](instance, 'value')

        lu.assertEquals(instance, result)
        lu.assertEquals('value', instance[data.getter](instance))
    end)
    :setScenarios({
        ['date'] = {
            setter = 'setDate',
            getter = 'getDate'
        },
        ['moment'] = {
            setter = 'setMoment',
            getter = 'getMoment'
        },
        ['playerLevel'] = {
            setter = 'setPlayerLevel',
            getter = 'getPlayerLevel'
        },
        ['zone'] = {
            setter = 'setZone',
            getter = 'getZone'
        },
        ['subZone'] = {
            setter = 'setSubZone',
            getter = 'getSubZone'
        }
    })
    :register()

-- @covers MemoryString:tostring()
TestCase.new()
    :setName('tostring')
    :setTestClass(TestMemoryString)
    :setExecution(function()
        local instance = MemoryCore:new('Memory/MemoryString')

        instance.date = '2020-01-01'
        instance.moment = 1
        instance.playerLevel = 60
        instance.zone = 'Durotar'
        instance.subZone = 'Valley of Trials'

        lu.assertEquals('2020-01-01|60|Durotar|Valley of Trials|1', instance:toString())
    end)
    :register()
-- End of TestMemoryString