local global = require "src.global"
local cards = require "conf.cards"
local effectMgr = require "src.manager.effect_mgr"
local eventMgr = require "src.manager.event_mgr"
local idGenerator = require "src.utils.id_generator"

local mt = {}
mt.__index = mt

-- 为卡牌添加唯一ID
function mt:assignCardId(cardData)
    if not cardData.id then
        cardData.id = idGenerator.generateId("card")
    end
    return cardData
end

-- 获取卡牌数据（用于事件传递）
function mt:getCardData(cardData)
    return {
        id = cardData.id,
        type = "card",
        name = cardData.name,
        cardType = cardData.type,
        description = cardData.description,
        args = cardData.args
    }
end

-- 生成卡牌
function mt:generateCards()
    self.playerCards = {}
    self.cardCounts = {}
    
    -- 使用玩家卡组而不是随机生成
    if #self.deck == 0 then
        -- 如果卡组为空，使用旧的随机生成逻辑作为备选
        if not self.cardNameList then
            self.cardNameList = {}
            for name, _ in pairs(cards) do
                table.insert(self.cardNameList, name)
            end
        end

        -- 随机生成5张卡牌
        local randomCards = {}
        for _ = 1, 5 do
            local randomCardName = self.cardNameList[math.random(1, #self.cardNameList)]
            local cardData = table.clone(cards[randomCardName])
            self:assignCardId(cardData)
            table.insert(randomCards, cardData)
            self.cardCounts[cardData.name] = (self.cardCounts[cardData.name] or 0) + 1
        end
        
        -- 按卡牌名称排序，使相同卡牌放在一起
        table.sort(randomCards, function(a, b) return a.name < b.name end)
        self.playerCards = randomCards
        
        print("Warning: Using random cards because deck is empty")
    else
        -- 从玩家卡组中随机选择5张卡牌
        local deckCopy = {}
        for i, card in ipairs(self.deck) do
            table.insert(deckCopy, {index = i, card = table.clone(card)})
        end
        
        -- 随机选择5张卡牌，或者全部卡牌如果卡组少于5张
        local cardCount = math.min(5, #deckCopy)
        local randomCards = {}
        for _ = 1, cardCount do
            if #deckCopy > 0 then
                local randomIndex = math.random(1, #deckCopy)
                local selectedCard = deckCopy[randomIndex].card
                self:assignCardId(selectedCard)
                table.insert(randomCards, selectedCard)
                self.cardCounts[selectedCard.name] = (self.cardCounts[selectedCard.name] or 0) + 1
                table.remove(deckCopy, randomIndex)
            end
        end
        
        -- 按卡牌名称排序，使相同卡牌放在一起
        table.sort(randomCards, function(a, b) return a.name < b.name end)
        self.playerCards = randomCards
        
        print("Generated " .. cardCount .. " cards from player's deck")
    end
    
    -- 生成卡牌组信息，用于显示相同卡牌的组合效果
    self.cardGroups = {}
    local currentGroup = nil
    
    for i, card in ipairs(self.playerCards) do
        if currentGroup == nil or currentGroup.name ~= card.name then
            -- 创建新组
            currentGroup = {
                name = card.name,
                type = card.type,
                cards = {card},
                count = 1,
                startIndex = i,
                endIndex = i
            }
            table.insert(self.cardGroups, currentGroup)
        else
            -- 添加到当前组
            table.insert(currentGroup.cards, card)
            currentGroup.count = currentGroup.count + 1
            currentGroup.endIndex = i
        end
    end
end

-- 开始释放卡牌
function mt:startReleasingCards()
    if #self.playerCards > 0 then
        self.isReleasingCards = true
        self.cardGroups = self.cardGroups or {}
        self.currentGroupIndex = 0
        self.highlightedGroups = {}
        return true
    end
    return false
end

-- 封装卡牌效果
function mt:executeCardGroup(cardGroup)
    if not cardGroup or #cardGroup.cards == 0 then
        print("Warning: Attempted to execute nil or empty card group")
        return
    end
    
    local cardData = cardGroup.cards[1]  -- 使用组中第一张卡牌的数据
    local count = #cardGroup.cards
    local caster = global.player
    
    -- 应用基础效果，根据相同卡牌数量提升效果数值
    for _, effect in ipairs(cardData.effect_list) do
        local effectType = effect.effect_type
        local effect_target = effect.effect_target
        
        -- 如果有相同卡牌，根据comboEffect提升效果数值
        local comboArgs = nil
        if count > 1 and cardData.comboEffect and cardData.comboEffect[count] then
            -- 新的combo效果格式，按效果类型分类
            if cardData.comboEffect[count][effectType] then
                comboArgs = cardData.comboEffect[count][effectType]
            end
        end
        
        local effectArgs = {}
        
        -- 特殊处理add_buff效果类型
        if effectType == "add_buff" then
            -- 对于add_buff效果，直接使用effect_args中的buff引用
            effectArgs = effect.effect_args
            
            -- 如果有combo效果，应用到buff参数上
            if comboArgs and effectArgs[1] and effectArgs[1].args_override then
                for k, v in pairs(comboArgs) do
                    effectArgs[1].args_override[k] = v
                end
            end
        else
            -- 对于其他效果类型，正常处理参数
            for _, arg_name in ipairs(effect.effect_args) do
                -- 处理负值参数，如"-arg1"
                local isNegative = false
                local processedArgName = arg_name
                
                if type(arg_name) == "string" and arg_name:sub(1, 1) == "-" then
                    isNegative = true
                    processedArgName = arg_name:sub(2)
                end
                
                local argValue = cardData.args[processedArgName]
                
                -- 应用combo效果
                if comboArgs and comboArgs[processedArgName] then
                    argValue = comboArgs[processedArgName]
                end
                
                -- 如果是负值参数，取反
                if isNegative then
                    argValue = -argValue
                end
                
                table.insert(effectArgs, argValue)
            end
        end
        
        local msg = string.format("Card Group %s (x%d) effect: %s", cardData.name, count, effectType)
        for i, argValue in ipairs(effectArgs) do
            -- 添加类型检查，确保argValue是可以连接的类型
            local argValueStr = ""
            if type(argValue) == "table" then
                argValueStr = "table:" .. tostring(argValue)
            else
                argValueStr = tostring(argValue)
            end
            msg = msg .. " arg" .. i .. "=" .. argValueStr
        end
        print(msg)
        
        -- 添加飘字效果
        local target = effect_target == "enemy" and global.charaterMgr:getCharacter(global.camp.monster)[1] or global.player
        table.insert(self.floatingTexts, {
            text = self:getEffectText(effectType, effectArgs),
            target = target,
            x = target.x or 400,
            y = target.y or 150,
            color = self:getEffectColor(effectType),
            timer = 0,
            duration = 1.5
        })
        
        -- 使用ID而不是对象引用
        local targetId = target:getId()
        
        -- 触发卡牌效果事件
        eventMgr.emit(global.events.CARD_EFFECT_APPLIED, {
            effectType = effectType,
            effectArgs = effectArgs,
            cardData = self:getCardData(cardData),
            cardCount = count,
            sourceId = global.player:getId(),
            targetId = targetId,
        })
        
        effectMgr.excuteEffect(caster, effectType, effect_target, effectArgs)
    end
end

-- 获取效果文本
function mt:getEffectText(effectType, effectArgs)
    if effectType == "damage" then
        return "-" .. effectArgs[1] .. " HP"
    elseif effectType == "block" then
        return "+" .. effectArgs[1] .. " Block"
    elseif effectType == "add_strength" then
        if effectArgs[1] > 0 then
            return "+" .. effectArgs[1] .. " STR"
        else
            return effectArgs[1] .. " STR"
        end
    elseif effectType == "add_dexterity" then
        if effectArgs[1] > 0 then
            return "+" .. effectArgs[1] .. " DEX"
        else
            return effectArgs[1] .. " DEX"
        end
    elseif effectType == "add_buff" then
        local buffData = effectArgs[1]
        if not buffData then
            return "Add Buff"
        elseif buffData.buff_id == "vulnerable" then
            return "Vulnerable"
        elseif buffData.buff_id == "poison" then
            return "Poison " .. (buffData.args_override and buffData.args_override.arg1 or "")
        else
            return buffData.buff_id
        end
    else
        return effectType
    end
end

-- 获取效果颜色
function mt:getEffectColor(effectType)
    if effectType == "damage" then
        return {1, 0.2, 0.2}  -- 红色
    elseif effectType == "block" then
        return {0.2, 0.6, 1}  -- 蓝色
    elseif effectType == "add_strength" then
        return {1, 0.5, 0.2}  -- 橙色
    elseif effectType == "add_dexterity" then
        return {0.2, 0.8, 0.2}  -- 绿色
    elseif effectType == "add_buff" then
        return {0.8, 0.2, 0.8}  -- 紫色
    else
        return {1, 1, 1}  -- 白色
    end
end

-- 更新卡牌释放逻辑
function mt:update(dt, onCardEffect)
    if not self.isReleasingCards then return false end
    
    -- 初始化飘字效果数组
    self.floatingTexts = self.floatingTexts or {}
    
    -- 更新飘字效果
    for i = #self.floatingTexts, 1, -1 do
        local text = self.floatingTexts[i]
        text.timer = text.timer + dt
        if text.timer >= text.duration then
            table.remove(self.floatingTexts, i)
        end
    end
    
    self.cardReleaseTimer = self.cardReleaseTimer + dt
    if self.cardReleaseTimer >= 0.5 then
        self.cardReleaseTimer = 0
        if self.currentGroupIndex < #self.cardGroups then
            self.currentGroupIndex = self.currentGroupIndex + 1
            local cardGroup = self.cardGroups[self.currentGroupIndex]
            
            -- 添加高亮组
            table.insert(self.highlightedGroups, {
                group = cardGroup,
                timer = 0,
                duration = 1.0
            })
            
            -- 执行卡牌组效果
            onCardEffect(cardGroup)
        else
            self.isReleasingCards = false
            self.currentGroupIndex = 0
            self.highlightedGroups = {}
            return true -- 所有卡牌释放完成
        end
    end
    
    -- 更新高亮组
    for i = #self.highlightedGroups, 1, -1 do
        local highlight = self.highlightedGroups[i]
        highlight.timer = highlight.timer + dt
        if highlight.timer >= highlight.duration then
            table.remove(self.highlightedGroups, i)
        end
    end
    
    -- 检查玩家血量
    local battleResult = global.charaterMgr:is_battle_over()
    if battleResult == "player_win" then
        print("Player win!")
        global.stateMgr:changeState("game_over")
        return true
    elseif battleResult == "monster_win" then
        print("Monster win!")
        global.stateMgr:changeState("game_over")
        return true
    end
    
    return false
end

-- 获取卡牌状态
function mt:getState()
    return {
        playerCards = self.playerCards,
        cardGroups = self.cardGroups,
        currentGroupIndex = self.currentGroupIndex,
        isReleasingCards = self.isReleasingCards,
        highlightedGroups = self.highlightedGroups or {},
        floatingTexts = self.floatingTexts or {}
    }
end

-- 重置卡牌状态
function mt:reset()
    self.playerCards = {}
    self.cardCounts = {}
    self.cardGroups = {}
    self.currentGroupIndex = 0
    self.isReleasingCards = false
    self.cardReleaseTimer = 0
    self.highlightedGroups = {}
    self.floatingTexts = {}
    -- 注意：不重置self.deck，保留玩家的卡组
end

-- 卡组管理功能
-- 添加卡牌到玩家卡组
function mt:addCardToDeck(cardName)
    -- 尝试直接查找卡牌
    if not cards[cardName] then
        -- 如果找不到，尝试查找不带空格的版本
        local noSpaceName = cardName:gsub(" ", "")
        if cards[noSpaceName] then
            print("找到卡牌的无空格版本: " .. noSpaceName)
            cardName = noSpaceName
        else
            -- 打印所有可用的卡牌名称，帮助调试
            print("警告: 尝试添加无效卡牌: " .. cardName)
            print("可用的卡牌名称:")
            for name, _ in pairs(cards) do
                print("  - " .. name .. " (" .. cards[name].name .. ")")
            end
            return false
        end
    end
    
    local cardData = table.clone(cards[cardName])
    self:assignCardId(cardData)
    
    -- 确保卡牌具有必要的字段
    if not cardData.args then
        cardData.args = {}
    end
    
    if cardData.comboEffect and type(cardData.comboEffect) ~= "table" then
        cardData.comboEffect = {}
    end
    
    table.insert(self.deck, cardData)
    
    -- 触发卡牌添加事件
    eventMgr.emit(global.events.CARD_ADDED_TO_DECK, {
        card = self:getCardData(cardData),
        sourceId = global.player:getId(),
        sourceType = "player"
    })
    
    print("成功添加卡牌到卡组: " .. cardName .. " (" .. cardData.name .. ")，当前卡组大小: " .. #self.deck)
    return true
end

-- 从卡组中移除卡牌
function mt:removeCardFromDeck(index)
    -- 检查索引是否有效
    if index <= 0 or index > #self.deck then
        print("警告: 尝试移除无效卡牌索引: " .. index .. "，当前卡组大小: " .. #self.deck)
        return false
    end
    
    -- 获取要移除的卡牌
    local removedCard = self.deck[index]
    if not removedCard then
        print("警告: 索引 " .. index .. " 处没有卡牌，当前卡组大小: " .. #self.deck)
        return false
    end
    
    local cardName = removedCard.name
    
    -- 从卡组中移除卡牌
    table.remove(self.deck, index)
    
    -- 触发卡牌移除事件
    eventMgr.emit(global.events.CARD_REMOVED_FROM_DECK, {
        card = self:getCardData(removedCard),
        sourceId = global.player:getId(),
        sourceType = "player"
    })
    
    print("成功从卡组移除卡牌: " .. cardName .. "，当前卡组大小: " .. #self.deck)
    return removedCard
end

-- 获取玩家卡组
function mt:getDeck()
    return self.deck
end

-- 获取随机卡牌（用于商店和事件）
function mt:getRandomCard(cardType)
    local availableCards = {}
    
    -- 收集所有符合类型的卡牌
    for name, cardData in pairs(cards) do
        if not cardType or cardData.type == cardType then
            table.insert(availableCards, name)
        end
    end
    
    if #availableCards == 0 then
        print("警告: 没有找到可用的卡牌类型: " .. (cardType or "任意"))
        return nil
    end
    
    -- 随机选择一张卡牌
    local randomCardName = availableCards[math.random(1, #availableCards)]
    local randomCard = table.clone(cards[randomCardName])
    
    -- 确保卡牌具有必要的字段
    if not randomCard.args then
        randomCard.args = {}
    end
    
    if randomCard.comboEffect and type(randomCard.comboEffect) ~= "table" then
        randomCard.comboEffect = {}
    end
    
    -- 确保卡牌的name属性与键名一致
    if randomCard.name ~= randomCardName and not randomCard.name:find(randomCardName) and not randomCardName:find(randomCard.name:gsub(" ", "")) then
        print("警告: 卡牌名称不一致: 键名=" .. randomCardName .. ", 显示名称=" .. randomCard.name)
        -- 不修改name属性，因为它是用于显示的
    end
    
    print("获取随机卡牌: " .. randomCard.name .. " (键名: " .. randomCardName .. "), 类型: " .. randomCard.type)
    return randomCard
end

local CardMgr = {}

function CardMgr.new()
    return setmetatable({
        playerCards = {},
        currentCardIndex = 0,
        isReleasingCards = false,
        cardReleaseTimer = 0,
        flyingCards = {},
        cardCounts = {},
        deck = {} -- 玩家卡组
    }, mt)
end

return CardMgr