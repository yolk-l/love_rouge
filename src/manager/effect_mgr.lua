local global = require "src.global"
local eventMgr = require "src.manager.event_mgr"

local effectMgr = {}

function effectMgr.get_target(caster, effect_target)
    print("Get target:", effect_target, "caster:", caster)
    if effect_target == "self" then
        local self_target = caster
        print("Self target:", self_target)
        return self_target
    elseif effect_target == "enemy" then
        local enemy_target = caster:getEnemy()
        print("Enemy target:", enemy_target)
        return enemy_target
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
    elseif effectType == "add_buff" then
        effectMgr.add_buff(caster, target, effectArgs)
    elseif effectType == "add_strength" then
        effectMgr.add_strength(caster, target, effectArgs)
    elseif effectType == "add_dexterity" then
        effectMgr.add_dexterity(caster, target, effectArgs)
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
    local damage = effectArgs[1]
    
    -- 触发伤害前事件，允许修改伤害值
    local eventData = {
        source = caster,
        target = target,
        damage = damage
    }
    
    eventMgr.emit(global.events.BEFORE_DAMAGE_DEALT, eventData)
    
    -- 如果目标是玩家，触发受到伤害前事件
    if target:getCamp() == global.camp.player then
        eventMgr.emit(global.events.BEFORE_DAMAGE_TAKEN, eventData)
    end
    
    -- 应用可能被修改的伤害值
    -- 注意：力量属性的加成现在在applyDamage方法中处理
    target:applyDamage(eventData.damage, caster)
end

function effectMgr.block(caster, target, effectArgs)
    local blockAmount = effectArgs[1]
    print("Block effect:", blockAmount, "target:", target, "caster:", caster)
    
    if type(blockAmount) == "number" then
        -- 触发获得格挡前事件，允许buff修改格挡值
        local eventData = {
            source = caster,
            target = target,
            blockAmount = blockAmount
        }
        
        eventMgr.emit(global.events.BEFORE_BLOCK_GAINED, eventData)
        
        -- 应用可能被修改的格挡值
        target:applyBlock(caster, eventData.blockAmount)
    else
        print("Warning: Invalid block amount:", blockAmount)
    end
end

function effectMgr.heal(caster, target, effectArgs)
    target:applyHeal(caster, effectArgs[1])
end

function effectMgr.add_buff(caster, target, effectArgs)
    local buffRef = effectArgs[1]
    
    if not buffRef then
        print("Warning: No buff reference provided in effectArgs")
        return
    end
    
    -- 打印调试信息
    print("Adding buff reference:", tostring(buffRef))
    print("Effect args type:", type(effectArgs), "length:", #effectArgs)
    
    -- 检查目标是否有buff管理器
    if not target.buffMgr then
        print("Warning: Target has no buff manager")
        return
    end
    
    -- 添加buff
    target.buffMgr:addBuff(buffRef, caster)
end

-- 增加力量效果
function effectMgr.add_strength(caster, target, effectArgs)
    local amount = effectArgs[1]
    
    if not amount or type(amount) ~= "number" then
        print("Warning: Invalid strength amount:", amount)
        return
    end
    
    -- 添加力量
    target:addStrength(amount)
end

-- 增加戒备效果
function effectMgr.add_dexterity(caster, target, effectArgs)
    local amount = effectArgs[1]
    
    if not amount or type(amount) ~= "number" then
        print("Warning: Invalid dexterity amount:", amount)
        return
    end
    
    -- 添加戒备
    target:addDexterity(amount)
end

return effectMgr
