local card_manager = {}

-- 状态变量
local playerCards = {}
local currentCardIndex = 0
local isReleasingCards = false
local cardReleaseTimer = 0
local flyingCards = {}

-- 计算卡牌组合效果
function card_manager.calculateCardCombo(cards)
    local cardCounts = {}
    local comboEffects = {}
    
    -- 统计每种卡牌的数量
    for _, card in ipairs(cards) do
        cardCounts[card.name] = (cardCounts[card.name] or 0) + 1
    end
    
    -- 计算每种卡牌的组合效果
    for cardName, count in pairs(cardCounts) do
        if count >= 2 then
            -- 找到对应的卡牌定义
            for _, cardDef in ipairs(cards) do
                if cardDef.name == cardName and cardDef.comboEffect[count] then
                    table.insert(comboEffects, {
                        card = cardDef,
                        count = count,
                        effect = cardDef.comboEffect[count]
                    })
                    break
                end
            end
        end
    end
    
    return comboEffects
end

-- 生成卡牌
function card_manager.generateCards(cards)
    playerCards = {}
    for i = 1, 5 do
        local randomCard = cards[math.random(1, #cards)]
        table.insert(playerCards, randomCard)
    end
    currentCardIndex = 0
    isReleasingCards = false
    flyingCards = {}
    return playerCards
end

-- 开始释放卡牌
function card_manager.startReleasingCards()
    if #playerCards > 0 then
        isReleasingCards = true
        return true
    end
    return false
end

-- 更新卡牌释放逻辑
function card_manager.update(dt, onCardEffect)
    if not isReleasingCards then return false end
    
    cardReleaseTimer = cardReleaseTimer + dt
    if cardReleaseTimer >= 0.5 then
        cardReleaseTimer = 0
        if currentCardIndex < #playerCards then
            currentCardIndex = currentCardIndex + 1
            local cardData = playerCards[currentCardIndex]
            table.insert(flyingCards, {
                card = cardData,
                startX = 30 + (currentCardIndex - 1) * 115,
                startY = 400,
                targetX = 400,
                targetY = 150,
                progress = 0,
                cardIndex = currentCardIndex  -- 记录卡牌在playerCards中的索引
            })
        else
            isReleasingCards = false
            return true -- 所有卡牌释放完成
        end
    end
    
    -- 更新飞行中的卡牌
    for i = #flyingCards, 1, -1 do
        local flyingCard = flyingCards[i]
        flyingCard.progress = flyingCard.progress + dt * 2
        if flyingCard.progress >= 1 then
            -- 应用卡牌效果
            onCardEffect(flyingCard.card)
            
            -- 从玩家卡组中移除已使用的卡牌
            table.remove(playerCards, flyingCard.cardIndex)
            
            -- 更新剩余飞行卡牌的索引
            for j = i + 1, #flyingCards do
                flyingCards[j].cardIndex = flyingCards[j].cardIndex - 1
            end
            
            table.remove(flyingCards, i)
        end
    end
    
    return false
end

-- 获取卡牌状态
function card_manager.getState()
    return {
        playerCards = playerCards,
        currentCardIndex = currentCardIndex,
        isReleasingCards = isReleasingCards,
        flyingCards = flyingCards
    }
end

-- 重置卡牌状态
function card_manager.reset()
    playerCards = {}
    currentCardIndex = 0
    isReleasingCards = false
    cardReleaseTimer = 0
    flyingCards = {}
end

return card_manager 