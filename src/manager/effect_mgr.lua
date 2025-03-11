local global = require "src.global"
local eventMgr = require "src.manager.event_mgr"

local effectMgr = {}

function effectMgr.get_target(caster, effect_target)
    print("Get target:", effect_target, "caster:", caster.name)
    if effect_target == "self" then
        local self_target = caster
        print("Self target:", self_target.name)
        return self_target
    elseif effect_target == "enemy" then
        local enemy_target = caster:getEnemy()
        print("Enemy target:", enemy_target and enemy_target.name or "nil")
        return enemy_target
    end
end

function effectMgr.excuteEffect(caster, effectType, effect_target, effectArgs)
    local target = effectMgr.get_target(caster, effect_target)
    
    -- 触发效果执行前事件
    eventMgr.emit("effect_before_" .. effectType, {
        casterId = caster:getId(),
        casterType = caster:getCamp() == global.camp.player and "player" or "monster",
        targetId = target:getId(),
        targetType = target:getCamp() == global.camp.player and "player" or "monster",
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
        casterId = caster:getId(),
        casterType = caster:getCamp() == global.camp.player and "player" or "monster",
        targetId = target:getId(),
        targetType = target:getCamp() == global.camp.player and "player" or "monster",
        effectType = effectType,
        effectArgs = effectArgs
    })
end

function effectMgr.damage(caster, target, effectArgs)
    local damage = effectArgs[1]
    
    -- 触发伤害前事件，允许修改伤害值
    local eventData = {
        sourceId = caster:getId(),
        sourceType = caster:getCamp() == global.camp.player and "player" or "monster",
        targetId = target:getId(),
        targetType = target:getCamp() == global.camp.player and "player" or "monster",
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
    
    -- 触发伤害后事件
    eventMgr.emit(global.events.AFTER_DAMAGE_DEALT, {
        sourceId = caster:getId(),
        sourceType = caster:getCamp() == global.camp.player and "player" or "monster",
        targetId = target:getId(),
        targetType = target:getCamp() == global.camp.player and "player" or "monster",
        damage = eventData.damage
    })
end

function effectMgr.block(caster, target, effectArgs)
    local blockAmount = effectArgs[1]
    print("Block effect:", blockAmount, "target:", target.name, "caster:", caster.name)
    
    if type(blockAmount) == "number" then
        -- 触发获得格挡前事件，允许buff修改格挡值
        local eventData = {
            sourceId = caster:getId(),
            sourceType = caster:getCamp() == global.camp.player and "player" or "monster",
            targetId = target:getId(),
            targetType = target:getCamp() == global.camp.player and "player" or "monster",
            blockAmount = blockAmount
        }
        
        eventMgr.emit(global.events.BEFORE_BLOCK_GAINED, eventData)
        
        -- 应用可能被修改的格挡值
        target:applyBlock(caster, eventData.blockAmount)
        
        -- 触发获得格挡后事件
        eventMgr.emit(global.events.AFTER_BLOCK_GAINED, {
            sourceId = caster:getId(),
            sourceType = caster:getCamp() == global.camp.player and "player" or "monster",
            targetId = target:getId(),
            targetType = target:getCamp() == global.camp.player and "player" or "monster",
            blockAmount = eventData.blockAmount
        })
    else
        print("Warning: Invalid block amount:", blockAmount)
    end
end

function effectMgr.heal(caster, target, effectArgs)
    local healAmount = effectArgs[1]
    
    -- 触发治疗前事件
    local eventData = {
        sourceId = caster:getId(),
        sourceType = caster:getCamp() == global.camp.player and "player" or "monster",
        targetId = target:getId(),
        targetType = target:getCamp() == global.camp.player and "player" or "monster",
        healAmount = healAmount
    }
    
    eventMgr.emit(global.events.BEFORE_HEAL, eventData)
    
    -- 应用治疗
    target:applyHeal(caster, eventData.healAmount)
    
    -- 触发治疗后事件
    eventMgr.emit(global.events.AFTER_HEAL, {
        sourceId = caster:getId(),
        sourceType = caster:getCamp() == global.camp.player and "player" or "monster",
        targetId = target:getId(),
        targetType = target:getCamp() == global.camp.player and "player" or "monster",
        healAmount = eventData.healAmount
    })
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
    
    -- 触发添加buff前事件
    local eventData = {
        sourceId = caster:getId(),
        sourceType = caster:getCamp() == global.camp.player and "player" or "monster",
        targetId = target:getId(),
        targetType = target:getCamp() == global.camp.player and "player" or "monster",
        buffRef = buffRef
    }
    
    eventMgr.emit(global.events.BEFORE_BUFF_ADDED, eventData)
    
    -- 添加buff
    local addedBuff = target.buffMgr:addBuff(buffRef, caster)
    
    -- 触发添加buff后事件
    if addedBuff then
        eventMgr.emit(global.events.AFTER_BUFF_ADDED, {
            sourceId = caster:getId(),
            sourceType = caster:getCamp() == global.camp.player and "player" or "monster",
            targetId = target:getId(),
            targetType = target:getCamp() == global.camp.player and "player" or "monster",
            buffId = addedBuff.id,
            buffType = addedBuff.buff_type,
            buffName = addedBuff.name
        })
    end
end

-- 增加力量效果
function effectMgr.add_strength(caster, target, effectArgs)
    local amount = effectArgs[1]
    
    if not amount or type(amount) ~= "number" then
        print("Warning: Invalid strength amount:", amount)
        return
    end
    
    -- 触发增加力量前事件
    local eventData = {
        sourceId = caster:getId(),
        sourceType = caster:getCamp() == global.camp.player and "player" or "monster",
        targetId = target:getId(),
        targetType = target:getCamp() == global.camp.player and "player" or "monster",
        amount = amount
    }
    
    eventMgr.emit(global.events.BEFORE_STRENGTH_CHANGED, eventData)
    
    -- 添加力量
    target:addStrength(eventData.amount)
    
    -- 触发增加力量后事件
    eventMgr.emit(global.events.AFTER_STRENGTH_CHANGED, {
        sourceId = caster:getId(),
        sourceType = caster:getCamp() == global.camp.player and "player" or "monster",
        targetId = target:getId(),
        targetType = target:getCamp() == global.camp.player and "player" or "monster",
        amount = eventData.amount,
        newValue = target:getStrength()
    })
end

-- 增加戒备效果
function effectMgr.add_dexterity(caster, target, effectArgs)
    local amount = effectArgs[1]
    
    if not amount or type(amount) ~= "number" then
        print("Warning: Invalid dexterity amount:", amount)
        return
    end
    
    -- 触发增加戒备前事件
    local eventData = {
        sourceId = caster:getId(),
        sourceType = caster:getCamp() == global.camp.player and "player" or "monster",
        targetId = target:getId(),
        targetType = target:getCamp() == global.camp.player and "player" or "monster",
        amount = amount
    }
    
    eventMgr.emit(global.events.BEFORE_DEXTERITY_CHANGED, eventData)
    
    -- 添加戒备
    target:addDexterity(eventData.amount)
    
    -- 触发增加戒备后事件
    eventMgr.emit(global.events.AFTER_DEXTERITY_CHANGED, {
        sourceId = caster:getId(),
        sourceType = caster:getCamp() == global.camp.player and "player" or "monster",
        targetId = target:getId(),
        targetType = target:getCamp() == global.camp.player and "player" or "monster",
        amount = eventData.amount,
        newValue = target:getDexterity()
    })
end

return effectMgr
