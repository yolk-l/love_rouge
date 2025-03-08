local global = require "src.global"
local eventMgr = require "src.manager.event_mgr"

local effectMgr = {}

function effectMgr.get_target(caster, effect_target)
    if effect_target == "self" then
        return caster
    elseif effect_target == "enemy" then
        return caster:getEnemy()
    end
end

function effectMgr.excuteEffect(caster, effectType, effect_target, effectArgs)
    local target = effectMgr.get_target(caster, effect_target)
    
    -- 触发效果执行前事件
    eventMgr.emit("effect_before_" .. effectType, {
        caster = caster,
        target = target,
        effectType = effectType,
        effectArgs = effectArgs
    })
    
    -- 执行效果
    if effectType == "damage" then
        effectMgr.damage(caster, target, effectArgs)
    elseif effectType == "block" then
        effectMgr.block(caster, target, effectArgs)
    elseif effectType == "heal" then
        effectMgr.heal(caster, target, effectArgs)
    end
    
    -- 触发效果执行后事件
    eventMgr.emit("effect_after_" .. effectType, {
        caster = caster,
        target = target,
        effectType = effectType,
        effectArgs = effectArgs
    })
end

function effectMgr.damage(caster, target, effectArgs)
    target:applyDamage(caster, effectArgs[1])
end

function effectMgr.block(caster, target, effectArgs)
    local blockAmount = effectArgs[1]
    if type(blockAmount) == "number" then
        target:applyBlock(caster, blockAmount)
    else
        print("Warning: Invalid block amount:", blockAmount)
    end
end

function effectMgr.heal(caster, target, effectArgs)
    target:applyHeal(caster, effectArgs[1])
end

return effectMgr
