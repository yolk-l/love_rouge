-- 检查意图是否满足触发条件
function intentMgr.checkIntentTrigger(monster, intent)
    if not intent.trigger then return false end
    
    local currentCount = intentMgr.getIntentCount(monster, intent.name)
    -- 获取所需计数，支持从args中读取参数
    local requiredCount = intent.trigger.required_count
    if type(requiredCount) == "string" and intent.args[requiredCount] then
        requiredCount = intent.args[requiredCount]
    end
    requiredCount = requiredCount or 1
    
    return currentCount >= requiredCount
end 