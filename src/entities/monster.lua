local base_util = require "src.utils.base_util"
local attrComp = require "src.entities.component.attr_comp"
local effectMgr = require "src.manager.effect_mgr"
local eventMgr = require "src.manager.event_mgr"
local global = require "src.global"
local intentComp = require "src.entities.component.intent_comp"
local targetComp = require "src.entities.component.target_comp"
local intents = require "conf.intents"
local buffMgr = require "src.manager.buff_mgr"
local idGenerator = require "src.utils.id_generator"

local mt = {}
mt.__index = mt

-- 解析意图引用，返回完整的意图配置
function mt:resolveIntentRefs(intentRefs)
    if not intentRefs then return {} end

    local resolvedIntents = {}
    for _, intentId in ipairs(intentRefs) do
        local intent_cfg = intents[intentId]
        if not intent_cfg then
            print("Warning: Intent not found - ID: " .. intentId)
            goto continue
        end
        -- 获取原始意图配置
        -- 创建意图的深拷贝
        local resolvedIntent = table.clone(intent_cfg)
        -- 应用参数覆盖
        table.insert(resolvedIntents, resolvedIntent)
        ::continue::
    end
    return resolvedIntents
end

-- 获取怪物ID
function mt:getId()
    return self.id
end

-- 获取怪物数据（用于事件传递）
function mt:getData()
    return {
        id = self.id,
        type = "monster",
        name = self.name,
        health = self:getHealth(),
        maxHealth = self:getMaxHealth(),
        block = self:getBlock(),
        strength = self:getStrength(),
        dexterity = self:getDexterity(),
        camp = self.camp,
        monsterType = self.monsterType
    }
end

-- 检查自定义触发条件
function mt:checkCustomCondition(intent, eventData)
    -- 如果没有自定义检查条件，默认通过
    if not intent.trigger.check_condition then
        return true
    end

    -- 如果事件数据为空，默认不通过
    if not eventData then
        print("Warning: Event data is nil in checkCustomCondition")
        return false
    end

    local condition = intent.trigger.check_condition

    -- 检查是否是自身受到伤害的条件
    if condition == "self_damaged" then
        -- 检查事件数据中是否有targetId字段
        if not eventData.targetId then
            print("Warning: No targetId in event data for self_damaged condition")
            return false
        end
        -- 检查受到伤害的目标是否是自己
        return eventData.targetId == self.id

    -- 检查是否是敌人受到伤害的条件
    elseif condition == "enemy_damaged" then
        -- 检查事件数据中是否有targetId字段
        if not eventData.targetId then
            print("Warning: No targetId in event data for enemy_damaged condition")
            return false
        end
        -- 检查受到伤害的目标是否是敌人(玩家)
        local target = global.charaterMgr:getCharacterById(eventData.targetId)
        return target and target:getCamp() == global.camp.player

    -- 可以根据需要添加更多自定义条件
    elseif condition == "player_low_health" then
        -- 检查玩家生命值是否低于30%
        local player = global.charaterMgr:getCharacter(global.camp.player)[1]
        if not player then
            print("Warning: Player not found for player_low_health condition")
            return false
        end
        return player:getHealthRatio() < 0.3

    elseif condition == "self_low_health" then
        -- 检查自身生命值是否低于30%
        return self:getHealthRatio() < 0.3

    -- 默认情况
    else
        print("Warning: Unknown check condition: " .. condition)
        return true
    end
end

function mt:executeIntent(intent)
    if not intent then
        print("Warning: Attempted to execute nil intent")
        return
    end

    if not intent.effect_list then
        print("Warning: Intent has no effect_list: " .. (intent.name or "unknown"))
        return
    end

    -- 触发意图执行前事件
    eventMgr.emit(global.events.INTENT_BEFORE_EXECUTE, {
        sourceId = self.id,
        sourceType = "monster",
        intentName = intent.name,
        intentType = intent.type
    })

    for _, effect in ipairs(intent.effect_list) do
        local effectType = effect.effect_type
        local effectTarget = effect.effect_target

        if not effectType then
            print("Warning: Effect has no type")
            goto continue
        end

        if not effectTarget then
            print("Warning: Effect has no target")
            goto continue
        end

        local effectArgs = {}

        -- 特殊处理add_buff效果类型
        if effectType == "add_buff" then
            -- 对于add_buff效果，直接使用effect_args中的buff引用
            effectArgs = effect.effect_args

            local msg = string.format("Monster %s intent: %s, adding buff: %s", 
                self.name, intent.name, effectArgs[1].buff_id)
            print(msg)
        else
            -- 对于其他效果类型，正常处理参数
            if not effect.effect_args then
                print("Warning: Effect has no effect_args")
                goto continue
            end
            if not intent.args then
                print("Warning: Intent has no args")
                goto continue
            end
            for _, argName in ipairs(effect.effect_args) do
                local argValue = intent.args[argName]
                if not argValue then
                    print("Warning: Arg not found in intent: " .. argName)
                    goto continue
                end
                table.insert(effectArgs, argValue)
            end
            local msg = string.format("Monster %s intent: %s, effect: %s", self.name, intent.name, effectType)
            for i, argValue in ipairs(effectArgs) do
                msg = msg .. " arg" .. i .. "=" .. argValue
            end
            print(msg)
        end
        effectMgr.excuteEffect(self, effectType, effectTarget, effectArgs)
        ::continue::
    end
    -- 触发意图执行后事件
    eventMgr.emit(global.events.INTENT_AFTER_EXECUTE, {
        sourceId = self.id,
        sourceType = "monster",
        intentName = intent.name,
        intentType = intent.type
    })
end

-- 注册怪物的意图监听器
function mt:registerIntentListeners()
    if not self.intents then return end

    -- 清除之前的监听器
    if self.intentListenerIds then
        for _, listenerId in ipairs(self.intentListenerIds) do
            eventMgr.off(listenerId.event, listenerId.id)
        end
    end

    self.intentListenerIds = {}
    self:initIntent()

    -- 为每个意图注册监听器
    for _, intent in ipairs(self.intents) do
        if intent.trigger then
            local listenerId = eventMgr.on(intent.trigger.event, function(eventData)
                -- 确保事件数据有效
                if not eventData then
                    print("Warning: Received nil event data for event: " .. intent.trigger.event)
                    return
                end
                -- 打印调试信息
                print("Event received: " .. intent.trigger.event .. ", Intent: " .. intent.name)
                if eventData.targetId then
                    local target = global.charaterMgr:getCharacterById(eventData.targetId)
                    print("  Target: " .. (target and target.name or "unknown") .. " (ID: " .. eventData.targetId .. ")")
                end
                if eventData.sourceId then
                    local source = global.charaterMgr:getCharacterById(eventData.sourceId)
                    print("  Source: " .. (source and source.name or "unknown") .. " (ID: " .. eventData.sourceId .. ")")
                end
                -- 首先检查自定义条件
                if not self:checkCustomCondition(intent, eventData) then
                    print("  Custom condition check failed")
                    return -- 如果条件不满足，直接返回
                end
                -- 增加计数
                self:incrementIntentCount(intent.name)
                print("  Intent count increased: " .. self:getIntentCount(intent.name))
                -- 检查是否满足触发条件
                if self:checkIntentTrigger(intent) then
                    print("  Intent triggered: " .. intent.name)
                    self:executeIntent(intent)
                    -- 如果是一次性意图，重置计数
                    if intent.trigger.one_time then
                        self:resetIntentCount(intent.name)
                        print("  Intent count reset")
                    end
                else
                    print("  Intent not triggered yet, count: " .. self:getIntentCount(intent.name))
                end
            end, self)

            table.insert(self.intentListenerIds, {
                event = intent.trigger.event,
                id = listenerId
            })
        end
    end
end

-- 移除怪物的意图监听器
function mt:removeIntentListeners()
    if not self.intentListenerIds then return end

    for _, listenerId in ipairs(self.intentListenerIds) do
        eventMgr.off(listenerId.event, listenerId.id)
    end

    self.intentListenerIds = {}
    self:cleanupIntent()
end

-- 获取当前意图
function mt:getCurrentIntent()
    if not self.intents then return nil end

    -- 按优先级排序意图
    local sortedIntents = {}
    for _, intent in ipairs(self.intents) do
        table.insert(sortedIntents, intent)
    end

    table.sort(sortedIntents, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)

    -- 返回第一个满足触发条件的意图
    for _, intent in ipairs(sortedIntents) do
        if self:checkIntentTrigger(intent) then
            return intent
        end
    end

    -- 如果没有满足条件的意图，返回第一个意图
    return sortedIntents[1]
end

function mt:getIntentDescription()
    local intent = self:getCurrentIntent()
    if intent then
        -- 替换描述中的参数
        local description = base_util.replaceParams(intent.description, intent.args)
        return intent.name .. ": " .. description
    end
    return "No intent"
end

-- 获取所有激活的buff
function mt:getActiveBuffs()
    if self.buffMgr then
        return self.buffMgr:getActiveBuffs()
    end
    return {}
end

function mt:draw()
    love.graphics.print(self.name, 300, 100)
    love.graphics.print("Health: " .. self.health, 300, 120)
end

local Monster = {}

function Monster.new(monsterData, monsterType)
    if not monsterData then
        error("Monster data is required")
        return nil
    end

    local monster = setmetatable({
        id = idGenerator.generateId("monster"),
        name = monsterData.name,
        health = monsterData.health or 50,
        maxHealth = monsterData.health or 50,
        block = 0,
        strength = monsterData.strength or 0,
        dexterity = monsterData.dexterity or 0,
        monsterType = monsterType or "normal",
        camp = global.camp.monster,
        intentListenerIds = {},
        x = 400, -- 默认位置
        y = 150  -- 默认位置
    }, mt)

    -- 注入组件
    base_util.inject_comp(monster, attrComp)
    base_util.inject_comp(monster, intentComp)
    base_util.inject_comp(monster, targetComp)

    -- 创建buff管理器
    monster.buffMgr = buffMgr.new(monster)

    -- 解析怪物意图
    if monsterData.intent_refs then
        monster.intents = monster:resolveIntentRefs(monsterData.intent_refs)
    end

    -- 注册意图监听器
    monster:registerIntentListeners()

    return monster
end

return Monster