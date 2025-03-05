local global = require "src.global"
local button = require "src.ui.button"
local monsters = require "conf.monsters"
local cards = require "conf.cards"

-- 导入新模块
local battle_ui = require "src.ui.battle_ui"

local monster = require "src.entities.monster"
local player = require "src.entities.player"

local mt = {}
mt.__index = mt
function mt:disableButtons()
    self.generateCardButton.enabled = false
    self.executeCardButton.enabled = false
end

function mt:enableButtons()
    self.generateCardButton.enabled = true
    self.executeCardButton.enabled = true
end

function mt:onGenerateCardClick()
    if not self.generateCardButton.enabled or global.cardMgr:getState().isReleasingCards then return end
    -- 生成卡牌
    global.cardMgr:generateCards(cards)
    -- 更新玩家状态
    local cardsGenerated = global.currentPlayer:incrementCardsGenerated()
    -- 检查怪物意图
    self.currentMonster:checkIntents("cards_generated", cardsGenerated, global.currentPlayer)
    -- 增加回合计数并检查回合意图
    local turnCount = self.currentMonster:incrementTurnCount()
    self.currentMonster:checkIntents("turn_start", turnCount, global.currentPlayer)

    -- 检查玩家血量
    if global.currentPlayer:isDefeated() then
        print("Player defeated!")
        global.stateMgr:changeState("game_over")
        return
    end
end

function mt:onExecuteCardClick()
    if not self.executeCardButton.enabled or global.cardMgr:getState().isReleasingCards then return end
    if global.cardMgr:startReleasingCards() then
        self:disableButtons()
    else
        print("No cards to execute! Generate cards first.")
    end
end

function mt:load(params)
    if not params then
        error("Battle state requires parameters")
        return
    end
    if params.nodeType ~= "battle" then
        error("Invalid node type for battle state: " .. tostring(params.nodeType))
        return
    end
    -- 获取战斗类型
    self.battleType = params.battleType or "normal"
    -- 选择怪物池
    local monsterPool = monsters[self.battleType]
    if not monsterPool then
        print("Warning: Invalid battle type '" .. self.battleType .. "', falling back to normal")
        monsterPool = monsters.normal
    end
    -- 初始化战斗
    local monsterData = monsterPool[math.random(1, #monsterPool)]
    self.currentMonster = monster.new(monsterData, self.battleType)
    global.cardMgr:reset()
    -- 初始化按钮
    self.generateCardButton = button.new("Generate Cards", 300, 550, 150, 50, self.onGenerateCardClick, self)
    self.executeCardButton = button.new("Execute Cards", 500, 550, 150, 50, self.onExecuteCardClick, self)
    self:enableButtons()
end

function mt:update(dt)
    local cardState = global.cardMgr:getState()
    if not cardState.isReleasingCards then
        self.generateCardButton:update(dt)
        self.executeCardButton:update(dt)
    end

    -- 更新卡牌释放逻辑
    local cardsFinished = global.cardMgr:update(dt, function(cardData)
        global.cardMgr:executeCard(cardData, self.currentMonster)
    end)

    -- 如果卡牌释放完成，重新启用按钮
    if cardsFinished then
        self:enableButtons()
        -- 清空 playerCards
        global.cardMgr:reset()
    end

    if cardsFinished then
        -- 检查战斗结果
        if self.currentMonster:isDefeated() then
            print("Monster defeated!")
            global.stateMgr:changeState("map", {
                completeBattleNode = true,
                battleType = self.battleType
            })
            return
        end
        if global.currentPlayer:isDefeated() then
            print("Player defeated!")
            global.stateMgr:changeState("game_over")
            return
        end
        -- 检查回合结束时的怪物意图
        self.currentMonster:checkIntents("turn_end", self.currentMonster:incrementTurnCount(), global.currentPlayer)
    end
end

function mt:draw()
    -- 绘制背景
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- 绘制UI
    battle_ui.drawMonster(self.currentMonster)
    battle_ui.drawPlayerHealth(global.currentPlayer)

    local cardState = global.cardMgr:getState()
    -- 先绘制飞行中的卡牌，再绘制静止的卡牌
    battle_ui.drawFlyingCards(cardState.flyingCards)
    battle_ui.drawCards(cardState.playerCards, cardState.flyingCards)
    battle_ui.drawButtons(self.generateCardButton, self.executeCardButton, cardState.isReleasingCards)
end

function mt:mousepressed(x, y, button)
    local cardState = global.cardMgr:getState()
    if cardState.isReleasingCards or #cardState.flyingCards > 0 then return end

    self.generateCardButton:mousepressed(x, y, button)
    self.executeCardButton:mousepressed(x, y, button)

    -- 检查是否点击了卡牌
    for i, cardData in ipairs(cardState.playerCards) do
        local cardX = 30 + (i - 1) * 115
        local cardY = 400
        if x >= cardX and x <= cardX + 100 and y >= cardY and y <= cardY + 140 then
            print(string.format("Clicked card: %s", cardData.name))
        end
    end
end

local Battle = {}

function Battle.new()
    return setmetatable({
        generateCardButton = nil,
        executeCardButton = nil,
        currentMonster = nil,
        battleType = "normal",
    }, mt)
end

return Battle
