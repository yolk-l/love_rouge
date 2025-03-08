local mt = {}

-- 意图计数器

-- 初始化怪物的意图计数器
function mt.initIntent(self)
    self.intentCounters = {}
    for _, intent in ipairs(self.intents) do
        if intent.trigger then
            self.intentCounters[intent.name] = 0
        end
    end
end

-- 清理怪物的意图计数器
function mt.cleanupIntent(self)
    self.intentCounters = {}
end

-- 增加意图计数
function mt.incrementIntentCount(self, intentName)
    if self.intentCounters[intentName] then
        self.intentCounters[intentName] = self.intentCounters[intentName] + 1
        return self.intentCounters[intentName]
    end
    return 0
end

-- 获取意图计数
function mt.getIntentCount(self, intentName)
    if self.intentCounters[intentName] then
        return self.intentCounters[intentName]
    end
    return 0
end

-- 重置意图计数
function mt.resetIntentCount(self, intentName)
    if self.intentCounters[intentName] then
        self.intentCounters[intentName] = 0
    end
end

-- 检查意图是否满足触发条件
function mt.checkIntentTrigger(self, intent)
    if not intent.trigger then return false end
    
    local currentCount = self:getIntentCount(intent.name) or 0
    
    local requiredCount = intent.trigger.required_count or 1
    if type(requiredCount) == "string" then
        requiredCount = intent.args[requiredCount] or 1
    end
    
    return currentCount >= requiredCount
end

return mt
