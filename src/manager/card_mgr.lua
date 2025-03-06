local global = require "src.global"
local cards = require "conf.cards"
local effectMgr = require "src.manager.effect_mgr"
local mt = {}
mt.__index = mt

-- 生成卡牌
function mt:generateCards()
    self.playerCards = {}
    self.cardCounts = {}
    if not self.cardNameList then
        self.cardNameList = {}
        for name, _ in pairs(cards) do
            table.insert(self.cardNameList, name)
        end
    end

    for _ = 1, 5 do
        local randomCardName = self.cardNameList[math.random(1, #self.cardNameList)]
        local cardData = table.clone(cards[randomCardName])
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

-- 封装卡牌效果
function mt:executeCard(cardData)
    local count = self.cardCounts[cardData.name]
    local caster = global.player
    -- 应用基础效果，根据相同卡牌数量提升效果数值
    for _, effect in ipairs(cardData.effect_list) do
        local effectType = effect.effect_type
        local effect_target = effect.effect_target
        -- 如果有相同卡牌，根据comboEffect提升效果数值
        local comboArgs = nil
        if count > 1 and cardData.comboEffect and cardData.comboEffect[count] and cardData.comboEffect[count][effectType] then
            comboArgs = cardData.comboEffect[count][effectType]
        end
        local effectArgs = {}
        for _, arg_name in ipairs(effect.effect_args) do
            local argValue = cardData.args[arg_name]
            if comboArgs then
                argValue = comboArgs[arg_name] or argValue
            end
            table.insert(effectArgs, argValue)
        end
        local msg = string.format("Card %s effect: %s", cardData.name, effectType)
        for i, argValue in ipairs(effectArgs) do
            msg = msg .. "arg" .. i .. "=" .. argValue
        end
        print(msg)
        effectMgr.excuteEffect(caster, effectType, effect_target, effectArgs)
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