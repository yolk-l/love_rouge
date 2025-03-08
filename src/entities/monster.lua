local base_util = require "src.utils.base_util"
local attrComp = require "src.entities.component.attr_comp"
local effectMgr = require "src.manager.effect_mgr"
local eventMgr = require "src.manager.event_mgr"
local global = require "src.global"
local intentComp = require "src.entities.component.intent_comp"
local targetComp = require "src.entities.component.target_comp"
local intents = require "conf.intents"

local mt = {}
mt.__index = mt

-- 解析意图引用，返回完整的意图配置
function mt:resolveIntentRefs(intentRefs)
    if not intentRefs then return {} end
    
    local resolvedIntents = {}
    for _, ref in ipairs(intentRefs) do
        local intentType = ref.intent_type
        local intentId = ref.intent_id
        local argsOverride = ref.args_override
        
        -- 获取原始意图配置
        local originalIntent = intents[intentType] and intents[intentType][intentId]
        if originalIntent then
            -- 创建意图的深拷贝
            local resolvedIntent = table.clone(originalIntent)
            
            -- 应用参数覆盖
            if argsOverride then
                for k, v in pairs(argsOverride) do
                    resolvedIntent.args[k] = v
                end
            end
            
            table.insert(resolvedIntents, resolvedIntent)
        else
            print("Warning: Intent not found - Type: " .. intentType .. ", ID: " .. intentId)
        end
    end
    
    return resolvedIntents
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
        -- 检查事件数据中是否有target字段
        if not eventData.target then
            print("Warning: No target in event data for self_damaged condition")
            return false
        end
        -- 检查受到伤害的目标是否是自己
        return eventData.target == self
    
    -- 检查是否是敌人受到伤害的条件
    elseif condition == "enemy_damaged" then
        -- 检查事件数据中是否有target字段
        if not eventData.target then
            print("Warning: No target in event data for enemy_damaged condition")
            return false
        end
        -- 检查受到伤害的目标是否是敌人(玩家)
        return eventData.target:getCamp() == global.camp.player
    
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
        
        local msg = string.format("Monster %s intent: %s, effect: %s\n", self.name, intent.name, effectType)
        for i, argValue in ipairs(effectArgs) do
            msg = msg .. "arg" .. i .. "=" .. argValue
        end
        print(msg)
        
        effectMgr.excuteEffect(self, effectType, effectTarget, effectArgs)
        
        ::continue::
    end
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
                if eventData.target then
                    print("  Target: " .. (eventData.target.name or "unknown"))
                end
                if eventData.source then
                    print("  Source: " .. (eventData.source.name or "unknown"))
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

function mt:draw()
    love.graphics.print(self.name, 300, 100)
    love.graphics.print("Health: " .. self.health, 300, 120)
end

local Monster = {}

function Monster.new(monsterData, battleType)
    local monster = setmetatable({
        name = monsterData.name,
        health = monsterData.health,
        maxHealth = monsterData.health,
        type = battleType,
        block = 0,
        camp = global.camp.monster,
        intentListenerIds = {}
    }, mt)

    -- 解析意图引用
    monster.intents = monster:resolveIntentRefs(monsterData.intent_refs)

    print("monster: " , monster.name, #monster.intents, monster.health)
    base_util.inject_comp(monster, attrComp)
    base_util.inject_comp(monster, intentComp)
    base_util.inject_comp(monster, targetComp)
    
    -- 注册意图监听器
    monster:registerIntentListeners()
    
    return monster
end

return Monster