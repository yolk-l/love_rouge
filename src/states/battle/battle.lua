local stateManager = require "src.utils.state_manager"
local button = require "src.ui.button"
local card = require "src.ui.card"
local monsters = require "conf.monsters"
local cards = require "conf.cards"

-- 导入新模块
local card_logic = require "src.states.battle.card_logic"
local battle_ui = require "src.states.battle.ui.battle_ui"

local monster = require "src.entities.monster"
local player = require "src.entities.player"

local global = require "src.global"

local m = {}

-- 使用全局变量
local generateCardButton = global.generateCardButton
local executeCardButton = global.executeCardButton

local currentMonster = global.currentMonster
local currentPlayer = global.currentPlayer

-- 定义局部变量
local battleType = "normal"

function m.disableButtons()
    global.generateCardButton.enabled = false
    global.executeCardButton.enabled = false
end

function m.enableButtons()
    global.generateCardButton.enabled = true
    global.executeCardButton.enabled = true
end

function m.onGenerateCardClick()
    if not global.generateCardButton.enabled or card_logic.getState().isReleasingCards then return end
    
    -- 生成卡牌
    card_logic.generateCards(cards)
    
    -- 更新玩家状态
    local cardsGenerated = global.currentPlayer:incrementCardsGenerated()
    
    -- 检查怪物意图
    global.currentMonster:checkIntents("cards_generated", cardsGenerated, global.currentPlayer)
    
    -- 增加回合计数并检查回合意图
    local turnCount = global.currentMonster:incrementTurnCount()
    global.currentMonster:checkIntents("turn_start", turnCount, global.currentPlayer)
end

function m.onExecuteCardClick()
    if not global.executeCardButton.enabled or card_logic.getState().isReleasingCards then return end
    
    if card_logic.startReleasingCards() then
        m.disableButtons()
    else
        print("No cards to execute! Generate cards first.")
    end
end

function m.load(params)
    if not params then
        error("Battle state requires parameters")
        return
    end
    
    if params.nodeType ~= "battle" then
        error("Invalid node type for battle state: " .. tostring(params.nodeType))
        return
    end
    
    -- 获取战斗类型
    battleType = params.battleType or "normal"
    
    -- 选择怪物池
    local monsterPool = monsters[battleType]
    if not monsterPool then
        print("Warning: Invalid battle type '" .. battleType .. "', falling back to normal")
        monsterPool = monsters.normal
    end
    
    -- 初始化战斗
    local monsterData = monsterPool[math.random(1, #monsterPool)]
    global.currentMonster = monster.new(monsterData, battleType)
    global.currentPlayer = player.new()
    card_logic.reset()
    
    -- 初始化按钮
    global.generateCardButton = button.new("Generate Cards", 300, 550, 150, 50, m.onGenerateCardClick)
    global.executeCardButton = button.new("Execute Cards", 500, 550, 150, 50, m.onExecuteCardClick)
    m.enableButtons()
end

function m.update(dt)
    local cardState = card_logic.getState()
    
    if not cardState.isReleasingCards then
        global.generateCardButton:update(dt)
        global.executeCardButton:update(dt)
    end

    -- 更新卡牌释放逻辑
    local cardsFinished = card_logic.update(dt, function(cardData)
        -- 应用卡牌效果
        local damage = global.currentMonster:applyDamage(cardData.baseDamage or 0)
        global.currentPlayer:applyCardEffect(cardData)
        
        -- 应用组合效果
        local comboEffects = card_logic.calculateCardCombo({cardData})
        for _, combo in ipairs(comboEffects) do
            global.currentMonster:applyCardEffect(combo.card)
            global.currentPlayer:applyComboEffect(combo)
        end
        
        -- 检查怪物意图
        global.currentMonster:checkIntents("damage_taken", damage, global.currentPlayer)
        
        card_logic.executeCardEffects(cardData, global.currentMonster)
    end)
    
    -- 如果卡牌释放完成，重新启用按钮
    if cardsFinished then
        m.enableButtons()
        -- 清空 playerCards
        card_logic.reset()
    end
    
    if cardsFinished then
        -- 检查战斗结果
        if global.currentMonster:isDefeated() then
            print("Monster defeated!")
            stateManager.changeState("map", { 
                completeBattleNode = true,
                battleType = battleType
            })
            return
        end
        
        if global.currentPlayer:isDefeated() then
            print("Player defeated!")
            stateManager.changeState("game_over")
            return
        end
        
        -- 检查回合结束时的怪物意图
        global.currentMonster:checkIntents("turn_end", global.currentMonster:incrementTurnCount(), global.currentPlayer)
    end
end

function m.draw()
    -- 绘制背景
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- 绘制UI
    battle_ui.drawMonster(global.currentMonster)
    battle_ui.drawPlayerHealth(global.currentPlayer)
    
    local cardState = card_logic.getState()
    -- 先绘制飞行中的卡牌，再绘制静止的卡牌
    battle_ui.drawFlyingCards(cardState.flyingCards)
    battle_ui.drawCards(cardState.playerCards, cardState.flyingCards)
    battle_ui.drawButtons(global.generateCardButton, global.executeCardButton, cardState.isReleasingCards)
end

function m.mousepressed(x, y, button)
    local cardState = card_logic.getState()
    if cardState.isReleasingCards or #cardState.flyingCards > 0 then return end
    
    global.generateCardButton:mousepressed(x, y, button)
    global.executeCardButton:mousepressed(x, y, button)

    -- 检查是否点击了卡牌
    for i, cardData in ipairs(cardState.playerCards) do
        local cardX = 30 + (i - 1) * 115
        local cardY = 400
        if x >= cardX and x <= cardX + 100 and y >= cardY and y <= cardY + 140 then
            print(string.format("Clicked card: %s", cardData.name))
        end
    end
end

return m 