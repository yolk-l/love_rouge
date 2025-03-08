local global = require "src.global"
local eventMgr = require "src.manager.event_mgr"

local mt = {}

function mt.applyDamage(self, caster, damage)
    print("applyDamage", self:getCamp(), caster:getCamp(), damage)
    local originalDamage = damage
    
    if self.block > 0 then
        if self.block >= damage then
            self.block = self.block - damage
            damage = 0
        else
            damage = damage - self.block
            self.block = 0
        end
    end
    
    self.health = self.health - damage
    
    -- 触发受伤事件
    eventMgr.emit(global.events.CHARACTER_DAMAGED, {
        target = self,
        source = caster,
        damage = originalDamage,
        damageTaken = damage,
        blocked = originalDamage - damage
    })
    
    -- 如果生命值降至0或以下，触发击败事件
    if self.health <= 0 then
        eventMgr.emit(global.events.CHARACTER_DEFEATED, {
            target = self,
            source = caster
        })
    end
end

function mt.applyBlock(self, caster, block)
    local originalBlock = self.block
    self.block = self.block + block
    print("applyBlock", self:getCamp(), caster:getCamp(), block, self.block, self:getBlock())
    
    -- 触发格挡事件
    eventMgr.emit(global.events.CHARACTER_BLOCKED, {
        target = self,
        source = caster,
        blockAmount = block,
        totalBlock = self.block
    })
end

function mt.applyHeal(self, caster, heal)
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

function mt.is_defeated(self)
    return self.health <= 0
end

function mt.getHealthRatio(self)
    return self.health / self.maxHealth
end

function mt.getHealth(self)
    return self.health
end

function mt.getMaxHealth(self)
    return self.maxHealth
end

function mt.getBlock(self)
    return self.block
end

function mt.getCamp(self)
    return self.camp
end

return mt