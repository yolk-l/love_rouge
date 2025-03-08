local eventMgr = {}

-- 事件监听器列表
local listeners = {}
-- 用于生成唯一ID的计数器
local idCounter = 0

-- 生成唯一的监听器ID
local function generateUniqueId()
    idCounter = idCounter + 1
    return tostring(os.time()) .. "_" .. tostring(idCounter)
end

-- 注册事件监听器
-- @param eventName 事件名称
-- @param listener 监听器函数，接收事件数据作为参数
-- @param context 监听器上下文（可选）
-- @return 监听器ID，用于后续移除
function eventMgr.on(eventName, listener, context)
    if not listeners[eventName] then
        listeners[eventName] = {}
    end

    local listenerId = generateUniqueId()

    table.insert(listeners[eventName], {
        id = listenerId,
        fn = listener,
        context = context
    })

    return listenerId
end

-- 移除事件监听器
-- @param eventName 事件名称
-- @param listenerId 监听器ID
function eventMgr.off(eventName, listenerId)
    if not listeners[eventName] then return end

    for i, listener in ipairs(listeners[eventName]) do
        if listener.id == listenerId then
            table.remove(listeners[eventName], i)
            break
        end
    end

    if #listeners[eventName] == 0 then
        listeners[eventName] = nil
    end
end

-- 触发事件
-- @param eventName 事件名称
-- @param ... 传递给监听器的参数
function eventMgr.emit(eventName, ...)
    if not listeners[eventName] then return end

    -- 创建监听器列表的副本，避免在遍历过程中移除监听器导致的问题
    local listenersCopy = {}
    for _, listener in ipairs(listeners[eventName]) do
        table.insert(listenersCopy, {
            id = listener.id,
            fn = listener.fn,
            context = listener.context
        })
    end

    for _, listener in ipairs(listenersCopy) do
        if listener.context then
            listener.fn(listener.context, ...)
        else
            listener.fn(...)
        end
    end
end

-- 一次性事件监听器，触发后自动移除
-- @param eventName 事件名称
-- @param listener 监听器函数
-- @param context 监听器上下文（可选）
function eventMgr.once(eventName, listener, context)
    local listenerId

    local onceListener = function(...)
        eventMgr.off(eventName, listenerId)
        if context then
            listener(context, ...)
        else
            listener(...)
        end
    end

    listenerId = eventMgr.on(eventName, onceListener)
    return listenerId
end

-- 清除所有事件监听器
function eventMgr.clear()
    listeners = {}
    idCounter = 0
end

-- 获取事件列表
function eventMgr.getEventNames()
    local names = {}
    for name, _ in pairs(listeners) do
        table.insert(names, name)
    end
    return names
end

-- 获取特定事件的监听器数量
function eventMgr.getListenerCount(eventName)
    if not listeners[eventName] then
        return 0
    end
    return #listeners[eventName]
end

return eventMgr 