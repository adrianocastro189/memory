
if (StormwindLibrary_v0_0_3) then return end
        
StormwindLibrary_v0_0_3 = {}
StormwindLibrary_v0_0_3.__index = StormwindLibrary_v0_0_3

function StormwindLibrary_v0_0_3.new()
    local self = setmetatable({}, StormwindLibrary_v0_0_3)
    -- Library version = '0.0.3'

local Item = {}
Item.__index = Item

function Item.new(name)
    local self = setmetatable({}, Item)
    self.name = name
    return self
end

function Item:getName()
    return self.name
end

function self:createItem()
    return Item.new('test')
end
    return self
end