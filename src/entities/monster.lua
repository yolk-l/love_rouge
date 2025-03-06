local base_util = require "src.utils.base_util"
local attrComp = require "src.entities.component.attr_comp"
local effectMgr = require "src.manager.effect_mgr"
local eventMgr = require "src.manager.event_mgr"
local global = require "src.global"

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
        local msg = string.format("Monster %s intent: %s, effect: %s", self.name, intent.name, effectType)
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

    -- 为每个意图注册监听器
    for _, intent in ipairs(self.intents) do
        local listenerId = eventMgr.on(intent.trigger, function(eventData)
            local value = eventData.value
            if not intent.triggerValue or (value and value >= intent.triggerValue) then
                self:executeIntent(intent)
            end
        end, self)

        table.insert(self.intentListenerIds, {
            event = intent.trigger,
            id = listenerId
        })
    end
end

-- 移除怪物的意图监听器
function mt:removeIntentListeners()
    if not self.intentListenerIds then return end

    for _, listenerId in ipairs(self.intentListenerIds) do
        eventMgr.off(listenerId.event, listenerId.id)
    end

    self.intentListenerIds = {}
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

    base_util.inject_comp(monster, attrComp)
    
    -- 注册意图监听器
    monster:registerIntentListeners()
    
    return monster
end

return Monster