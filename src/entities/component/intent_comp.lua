local mt = {}

-- 意图计数器

-- 初始化怪物的意图计数器
function mt:initIntent()
    self.intentCounters = {}
    if not self.intents then
        print("Warning: No intents found during initIntent")
        return
    end
    
    for _, intent in ipairs(self.intents) do
        if intent and intent.name and intent.trigger then
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
    if not self.intentCounters then
        self.intentCounters = {}
    end
    
    if not intentName then
        print("Warning: Attempted to increment count for nil intent name")
        return 0
    end
    
    if self.intentCounters[intentName] then
        self.intentCounters[intentName] = self.intentCounters[intentName] + 1
    else
        self.intentCounters[intentName] = 1
    end
    
    return self.intentCounters[intentName]
end

-- 获取意图计数
function mt:getIntentCount(intentName)
    if not self.intentCounters then
        return 0
    end
    
    if not intentName then
        print("Warning: Attempted to get count for nil intent name")
        return 0
    end
    
    return self.intentCounters[intentName] or 0
end

-- 重置意图计数
function mt:resetIntentCount(intentName)
    if not self.intentCounters then
        self.intentCounters = {}
        return
    end
    
    if not intentName then
        print("Warning: Attempted to reset count for nil intent name")
        return
    end
    
    self.intentCounters[intentName] = 0
end

-- 检查意图是否满足触发条件
function mt:checkIntentTrigger(intent)
    if not intent or not intent.trigger then 
        return false 
    end
    
    if not intent.name then
        print("Warning: Intent has no name in checkIntentTrigger")
        return false
    end
    
    local currentCount = self:getIntentCount(intent.name)
    
    local requiredCount = intent.trigger.required_count or 1
    if type(requiredCount) == "string" then
        if not intent.args then
            print("Warning: Intent has no args but required_count is a string: " .. requiredCount)
            requiredCount = 1
        else
            requiredCount = intent.args[requiredCount] or 1
        end
    end
    
    return currentCount >= requiredCount
end

return mt
