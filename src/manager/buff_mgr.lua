local global = require "src.global"
local eventMgr = require "src.manager.event_mgr"
local effectMgr = require "src.manager.effect_mgr"
local base_util = require "src.utils.base_util"
local buffs = require "conf.buffs"

local mt = {}
mt.__index = mt

-- 初始化buff管理器
function mt:init(owner)
    self.owner = owner
    self.activeBuffs = {} -- 当前激活的buff列表
    self.buffListenerIds = {} -- buff事件监听器ID列表
    
    -- 注册全局事件监听器
    self:registerGlobalListeners()
end

-- 注册全局事件监听器
function mt:registerGlobalListeners()
    -- 注册事件监听器，用于处理触发式buff
    local events = {
        "character_damaged",
        "cards_finished",
        "before_damage_dealt",
        "before_damage_taken",
        "before_block_gained"
    }
    
    for _, event in ipairs(events) do
        local listenerId = eventMgr.on(event, function(eventData)
            self:checkBuffTriggers(event, eventData)
        end, self)
        
        table.insert(self.buffListenerIds, {
            event = event,
            id = listenerId
        })
    end
end

-- 解析buff引用，返回完整的buff配置
function mt:resolveBuffRef(buffRef)
    if not buffRef then return nil end
    
    local buffType = buffRef.buff_type
    local buffId = buffRef.buff_id
    local argsOverride = buffRef.args_override
    
    -- 获取原始buff配置
    local originalBuff = buffs[buffType] and buffs[buffType][buffId]
    if not originalBuff then
        print("Warning: Buff not found - Type: " .. tostring(buffType) .. ", ID: " .. tostring(buffId))
        return nil
    end
    
    -- 创建buff的深拷贝
    local resolvedBuff = table.clone(originalBuff)
    
    -- 应用参数覆盖
    if argsOverride then
        for k, v in pairs(argsOverride) do
            resolvedBuff.args[k] = v
        end
    end
    
    return resolvedBuff
end

-- 添加buff到目标
function mt:addBuff(buffRef, source)
    local buff = self:resolveBuffRef(buffRef)
    if not buff then
        print("Warning: Failed to resolve buff reference")
        return false
    end
    
    -- 添加新buff
    local newBuff = table.clone(buff)
    newBuff.source = source
    newBuff.trigger_count = 0
    
    -- 添加到激活buff列表
    table.insert(self.activeBuffs, newBuff)
    
    print(string.format("%s gained %s buff", self.owner.name, buff.name))
    
    -- 触发buff添加事件
    eventMgr.emit("buff_added", {
        target = self.owner,
        source = source,
        buff = newBuff
    })
    
    return true
end

-- 检查buff触发器
function mt:checkBuffTriggers(event, eventData)
    for i = #self.activeBuffs, 1, -1 do
        local buff = self.activeBuffs[i]
        
        -- 检查buff是否有触发器，且触发事件匹配
        if buff.trigger and buff.trigger.event == event then
            -- 检查自定义条件
            if self:checkBuffCondition(buff, eventData) then
                -- 执行buff效果
                self:executeBuffEffects(buff, eventData)
                
                -- 增加触发次数
                buff.trigger_count = (buff.trigger_count or 0) + 1
                
                -- 检查是否需要移除buff
                if buff.remove_after_trigger then
                    -- 如果设置了触发次数限制，检查是否达到限制
                    if not buff.trigger_limit or buff.trigger_count >= buff.trigger_limit then
                        -- 移除buff
                        table.remove(self.activeBuffs, i)
                        
                        print(string.format("%s's %s buff removed after triggering", self.owner.name, buff.name))
                        
                        -- 触发buff移除事件
                        eventMgr.emit("buff_removed", {
                            target = self.owner,
                            buff = buff
                        })
                    end
                end
            end
        end
    end
end

-- 检查buff的触发条件
function mt:checkBuffCondition(buff, eventData)
    -- 如果没有自定义检查条件，默认通过
    if not buff.trigger.check_condition then
        return true
    end
    
    -- 如果事件数据为空，默认不通过
    if not eventData then
        print("Warning: Event data is nil in checkBuffCondition")
        return false
    end
    
    local condition = buff.trigger.check_condition
    
    -- 检查是否是自身受到伤害的条件
    if condition == "self_damaged" then
        -- 检查事件数据中是否有target字段
        if not eventData.target then
            return false
        end
        -- 检查受到伤害的目标是否是自己
        return eventData.target == self.owner
    
    -- 检查是否是自身攻击的条件
    elseif condition == "self_attacking" then
        -- 检查事件数据中是否有source字段
        if not eventData.source then
            return false
        end
        -- 检查攻击来源是否是自己
        return eventData.source == self.owner
    
    -- 检查是否是自身获得格挡的条件
    elseif condition == "self_blocking" then
        -- 检查事件数据中是否有target字段
        if not eventData.target then
            return false
        end
        -- 检查获得格挡的目标是否是自己
        return eventData.target == self.owner
    
    -- 总是触发的条件
    elseif condition == "always" then
        return true
    
    -- 默认情况
    else
        print("Warning: Unknown buff check condition: " .. condition)
        return true
    end
end

-- 执行buff效果
function mt:executeBuffEffects(buff, eventData)
    if not buff.effect_list then
        print("Warning: Buff has no effect_list: " .. buff.name)
        return
    end
    
    for _, effect in ipairs(buff.effect_list) do
        local effectType = effect.effect_type
        
        if not effectType then
            print("Warning: Buff effect has no type")
            goto continue
        end
        
        local effectArgs = {}
        
        if not effect.effect_args then
            print("Warning: Buff effect has no effect_args")
            goto continue
        end
        
        if not buff.args then
            print("Warning: Buff has no args")
            goto continue
        end
        
        -- 处理效果参数
        for _, argName in ipairs(effect.effect_args) do
            local argValue = buff.args[argName]
            table.insert(effectArgs, argValue)
        end
        
        -- 执行效果
        effectMgr.excuteEffect(buff.source or self.owner, effectType, effect.effect_target, effectArgs)
        
        ::continue::
    end
end

-- 获取所有激活的buff
function mt:getActiveBuffs()
    return self.activeBuffs
end

-- 移除所有buff
function mt:removeAllBuffs()
    for i = #self.activeBuffs, 1, -1 do
        local buff = self.activeBuffs[i]
        
        -- 触发buff移除事件
        eventMgr.emit("buff_removed", {
            target = self.owner,
            buff = buff
        })
    end
    
    self.activeBuffs = {}
end

-- 清理buff管理器
function mt:cleanup()
    -- 移除所有buff
    self:removeAllBuffs()
    
    -- 移除所有事件监听器
    for _, listener in ipairs(self.buffListenerIds) do
        eventMgr.off(listener.event, listener.id)
    end
    
    self.buffListenerIds = {}
end

local BuffMgr = {}

function BuffMgr.new(owner)
    local instance = setmetatable({}, mt)
    instance:init(owner)
    return instance
end

return BuffMgr 