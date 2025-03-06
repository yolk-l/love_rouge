local eventMgr = {}

-- 事件监听器列表
local listeners = {}

-- 注册事件监听器
-- @param eventName 事件名称
-- @param listener 监听器函数，接收事件数据作为参数
-- @param context 监听器上下文（可选）
-- @return 监听器ID，用于后续移除
function eventMgr.on(eventName, listener, context)
    if not listeners[eventName] then
        listeners[eventName] = {}
    end

    local listenerId = tostring(listener) .. tostring(math.random(1, 10000))

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

    for _, listener in ipairs(listeners[eventName]) do
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