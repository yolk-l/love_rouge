
local global = require "src.global"

local mt = {}
mt.__index = mt

-- 生成卡牌
function mt:generateCards(cards)
    self.playerCards = {}
    self.cardCounts = {}
    for _ = 1, 5 do
        local randomCard = cards[math.random(1, #cards)]
        local cardData = {
            name = randomCard.name,
            type = randomCard.type,
            baseEffect = randomCard.baseEffect,
            description = randomCard.description,
            comboEffect = randomCard.comboEffect
        }
        table.insert(self.playerCards, cardData)
        self.cardCounts[cardData.name] = (self.cardCounts[cardData.name] or 0) + 1
    end
end

-- 开始释放卡牌
function mt:startReleasingCards()
    if #self.playerCards > 0 then
        self.isReleasingCards = true
        return true
    end
    return false
end

function mt:excuteEffect(effectType, effectValue, target)
    if effectType == "damage" then
        target:applyDamage(effectValue)
    elseif effectType == "block" then
        target:applyBlock(effectValue)
    end
end

-- 封装卡牌效果
function mt:executeCard(cardData, target)
    local count = self.cardCounts[cardData.name]
    -- 先应用基础效果
    for _, effect in ipairs(cardData.baseEffect) do
        local effectType = effect[1]
        local effectValue = effect[2]
        local comboEffect = cardData.comboEffect[count]
        if comboEffect and comboEffect[effectType] then
            effectValue = comboEffect[effectType]
        end
        self:excuteEffect(effectType, effectValue, target)
    end
end

-- 更新卡牌释放逻辑
function mt:update(dt, onCardEffect)
    if not self.isReleasingCards then return false end
    self.cardReleaseTimer = self.cardReleaseTimer + dt
    if self.cardReleaseTimer >= 0.5 then
        self.cardReleaseTimer = 0
        if self.currentCardIndex < #self.playerCards then
            self.currentCardIndex = self.currentCardIndex + 1
            local cardData = self.playerCards[self.currentCardIndex]
            table.insert(self.flyingCards, {
                card = cardData,
                startX = 30 + (self.currentCardIndex - 1) * 115,
                startY = 400,
                targetX = 400,
                targetY = 150,
                progress = 0,
                cardIndex = self.currentCardIndex  -- 记录卡牌在playerCards中的索引
            })
        else
            self.isReleasingCards = false
            self.currentCardIndex = 0  -- 重置索引
            return true -- 所有卡牌释放完成
        end
    end
    -- 更新飞行中的卡牌
    for i = #self.flyingCards, 1, -1 do
        local flyingCard = self.flyingCards[i]
        flyingCard.progress = flyingCard.progress + dt * 2
        if flyingCard.progress >= 1 then
            -- 应用卡牌效果
            onCardEffect(flyingCard.card)
            table.remove(self.flyingCards, i)
            -- 检查玩家血量
            if global.currentPlayer:isDefeated() then
                print("Player defeated!")
                global.stateMgr:changeState("game_over")
                return true
            end
        end
    end
    return false
end

-- 获取卡牌状态
function mt:getState()
    return {
        playerCards = self.playerCards,
        currentCardIndex = self.currentCardIndex,
        isReleasingCards = self.isReleasingCards,
        flyingCards = self.flyingCards
    }
end

-- 重置卡牌状态
function mt:reset()
    self.playerCards = {}
    self.cardCounts = {}
    self.currentCardIndex = 0
    self.isReleasingCards = false
    self.cardReleaseTimer = 0
    self.flyingCards = {}
end

local CardMgr = {}

function CardMgr.new()
    return setmetatable({
        playerCards = {},
        currentCardIndex = 0,
        isReleasingCards = false,
        cardReleaseTimer = 0,
        flyingCards = {},
        cardCounts = {}
    }, mt)
end

return CardMgr