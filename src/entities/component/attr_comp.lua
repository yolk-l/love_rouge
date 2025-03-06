local global = require "src.global"
local eventMgr = require "src.manager.event_mgr"

local mt = {}

function mt:applyDamage(caster, damage)
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

function mt:applyBlock(caster, block)
    local originalBlock = self.block
    self.block = self.block + block
    
    -- 触发格挡事件
    eventMgr.emit(global.events.CHARACTER_BLOCKED, {
        target = self,
        source = caster,
        blockAmount = block,
        totalBlock = self.block
    })
end

function mt:applyHeal(caster, heal)
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

function mt:is_defeated()
    return self.health <= 0
end

function mt:getEnemy()
    if self.camp == global.camp.player then
        return global.charaterMgr:getCharacter(global.camp.monster)[1]
    else
        return global.charaterMgr:getCharacter(global.camp.player)[1]
    end
end

return mt