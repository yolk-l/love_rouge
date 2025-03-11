local idGenerator = {}

-- 用于生成唯一ID的计数器
local idCounters = {
    entity = 0,
    player = 0,
    monster = 0,
    card = 0
}

-- 生成唯一ID
function idGenerator.generateId(prefix)
    prefix = prefix or "entity"
    
    if not idCounters[prefix] then
        idCounters[prefix] = 0
    end
    
    idCounters[prefix] = idCounters[prefix] + 1
    return prefix .. "_" .. os.time() .. "_" .. idCounters[prefix]
end

-- 重置特定类型的ID计数器
function idGenerator.resetCounter(prefix)
    if prefix then
        idCounters[prefix] = 0
    else
        for k, _ in pairs(idCounters) do
            idCounters[k] = 0
        end
    end
end

return idGenerator 