local mt = {}
mt.__index = mt

-- 意图计数器

-- 初始化怪物的意图计数器
function mt:initIntent()
    self.intentCounters = {}
    for _, intent in ipairs(self.intents) do
        if intent.trigger then
            self.intentCounters[intent.name] = 0
        end
    end
end

-- 清理怪物的意图计数器
function mt:cleanupIntent()
    self.intentCounters = {}
end

-- 增加意图计数
function mt:incrementIntentCount(intentName)
    if self.intentCounters[intentName] then
        self.intentCounters[intentName] = self.intentCounters[intentName] + 1
        return self.intentCounters[intentName]
    end
    return 0
end

-- 获取意图计数
function mt:getIntentCount(intentName)
    if self.intentCounters[intentName] then
        return self.intentCounters[intentName]
    end
    return 0
end

-- 重置意图计数
function mt:resetIntentCount(intentName)
    if self.intentCounters[intentName] then
        self.intentCounters[intentName] = 0
    end
end

-- 检查意图是否满足触发条件
function mt:checkIntentTrigger(intent)
    if not intent.trigger then return false end
    
    local currentCount = self:getIntentCount(intent.name)
    local requiredCount = intent.trigger.required_count or 1
    
    return currentCount >= requiredCount
end

return mt
