local global = require "src.global"
local eventMgr = require "src.manager.event_mgr"

local mt = {}

function mt:applyBlock(caster, block)
    print("applyBlock", self:getCamp(), caster:getCamp(), block)
    local originalBlock = self.block
    
    -- 触发获得格挡前事件，允许戒备属性修改格挡值
    local eventData = {
        source = caster,
        target = self,
        blockAmount = block
    }
    
    -- 应用戒备属性加成
    if self.dexterity and self.dexterity > 0 then
        eventData.blockAmount = eventData.blockAmount + self.dexterity
        print(string.format("%s's block increased by %d from Dexterity", self.name, self.dexterity))
    end
    
    eventMgr.emit(global.events.BEFORE_BLOCK_GAINED, eventData)
    
    -- 应用可能被修改的格挡值
    self.block = self.block + eventData.blockAmount
    
    -- 触发格挡事件
    eventMgr.emit(global.events.CHARACTER_BLOCKED, {
        target = self,
        source = caster,
        blockAmount = eventData.blockAmount,
        totalBlock = self.block
    })
end

function mt:applyHeal(caster, heal)
    print("applyHeal", self:getCamp(), caster:getCamp(), heal)
    local originalHealth = self.health
    self.health = math.min(self.maxHealth, self.health + heal)
    local actualHeal = self.health - originalHealth
    
    -- 触发治疗事件
    eventMgr.emit(global.events.CHARACTER_HEALED, {
        target = self,
        source = caster,
        healAmount = heal,
        actualHeal = actualHeal
    })
end

-- 增加力量
function mt:addStrength(amount)
    self.strength = (self.strength or 0) + amount
    print(string.format("%s's strength changed by %+d to %d", self.name, amount, self.strength))
    
    -- 触发力量变化事件
    eventMgr.emit(global.events.CHARACTER_STRENGTH_CHANGED, {
        target = self,
        amount = amount,
        totalStrength = self.strength
    })
    
    return self.strength
end

-- 增加戒备
function mt:addDexterity(amount)
    self.dexterity = (self.dexterity or 0) + amount
    print(string.format("%s's dexterity changed by %+d to %d", self.name, amount, self.dexterity))
    
    -- 触发戒备变化事件
    eventMgr.emit(global.events.CHARACTER_DEXTERITY_CHANGED, {
        target = self,
        amount = amount,
        totalDexterity = self.dexterity
    })
    
    return self.dexterity
end

-- 获取力量值
function mt:getStrength()
    return self.strength or 0
end

-- 获取戒备值
function mt:getDexterity()
    return self.dexterity or 0
end

function mt:is_defeated()
    return self.health <= 0
end

function mt:getHealthRatio()
    return self.health / self.maxHealth
end

function mt:getHealth()
    return self.health
end

function mt:setHealth(health)
    self.health = health
end


function mt:getMaxHealth()
    return self.maxHealth
end

function mt:setMaxHealth(maxHealth)
    self.maxHealth = maxHealth
end
function mt:getBlock()
    return self.block
end

function mt:setBlock(block)
    self.block = block
end

function mt:getCamp()
    return self.camp
end

return mt