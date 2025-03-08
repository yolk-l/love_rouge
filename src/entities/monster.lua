local base_util = require "src.utils.base_util"
local attrComp = require "src.entities.component.attr_comp"
local effectMgr = require "src.manager.effect_mgr"
local eventMgr = require "src.manager.event_mgr"
local global = require "src.global"
local intentComp = require "src.entities.component.intent_comp"
local targetComp = require "src.entities.component.target_comp"

local mt = {}
mt.__index = mt

function mt:executeIntent(intent)
    for _, effect in ipairs(intent.effect_list) do
        local effectType = effect.effect_type
        local effectTarget = effect.effect_target
        local effectArgs = {}
        for _, argName in ipairs(effect.effect_args) do
            local argValue = intent.args[argName]
            table.insert(effectArgs, argValue)
        end
        local msg = string.format("Monster %s intent: %s, effect: %s\n", self.name, intent.name, effectType)
        for i, argValue in ipairs(effectArgs) do
            msg = msg .. "arg" .. i .. "=" .. argValue
        end
        print(msg)
        effectMgr.excuteEffect(self, effectType, effectTarget, effectArgs)
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
                -- 增加计数
                self:incrementIntentCount(intent.name)
                
                -- 检查是否满足触发条件
                if self:checkIntentTrigger(intent) then
                    self:executeIntent(intent)
                    -- 如果是一次性意图，重置计数
                    if intent.trigger.one_time then
                        self:resetIntentCount(intent.name)
                    end
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

function mt:incrementTurnCount()
    self.turnCount = self.turnCount + 1
    -- 触发回合开始事件
    eventMgr.emit("turn_start", {
        value = self.turnCount,
        source = self
    })
    return self.turnCount
end

function mt:on_turn_end()
    -- 触发回合结束事件
    eventMgr.emit("turn_end", {
        source = self
    })
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
        local description = intent.description
        for argName, argValue in pairs(intent.args or {}) do
            description = description:gsub("%[" .. argName .. "%]", tostring(argValue))
        end
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
        attack = monsterData.attack,
        type = battleType,
        intents = monsterData.intents,
        block = 0,
        turnCount = 0,
        camp = global.camp.monster,
        intentListenerIds = {}
    }, mt)

    print("monster: " , monster.name, monster.intents, monster.health)
    base_util.inject_comp(monster, attrComp)
    base_util.inject_comp(monster, intentComp)
    base_util.inject_comp(monster, targetComp)
    
    -- 注册意图监听器
    monster:registerIntentListeners()
    
    return monster
end

return Monster