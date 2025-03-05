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

local m = {}

-- 状态变量
local generateCardButton
local executeCardButton
local battleType = "normal"

-- 使用新的 monster 和 player 对象
local currentMonster
local currentPlayer

function m.disableButtons()
    generateCardButton.enabled = false
    executeCardButton.enabled = false
end

function m.enableButtons()
    generateCardButton.enabled = true
    executeCardButton.enabled = true
end

function m.onGenerateCardClick()
    if not generateCardButton.enabled or card_logic.getState().isReleasingCards then return end
    
    -- 生成卡牌
    card_logic.generateCards(cards)
    
    -- 更新玩家状态
    local cardsGenerated = currentPlayer:incrementCardsGenerated()
    
    -- 检查怪物意图
    currentMonster:checkIntents("cards_generated", cardsGenerated, currentPlayer)
    
    -- 增加回合计数并检查回合意图
    local turnCount = currentMonster:incrementTurnCount()
    currentMonster:checkIntents("turn_start", turnCount, currentPlayer)
end

function m.onExecuteCardClick()
    if not executeCardButton.enabled or card_logic.getState().isReleasingCards then return end
    
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
    currentMonster = monster.new(monsterData, battleType)
    currentPlayer = player.new()
    card_logic.reset()
    
    -- 初始化按钮
    generateCardButton = button.new("Generate Cards", 300, 550, 150, 50, m.onGenerateCardClick)
    executeCardButton = button.new("Execute Cards", 500, 550, 150, 50, m.onExecuteCardClick)
    m.enableButtons()
end

function m.update(dt)
    local cardState = card_logic.getState()
    
    if not cardState.isReleasingCards then
        generateCardButton:update(dt)
        executeCardButton:update(dt)
    end

    -- 更新卡牌释放逻辑
    local cardsFinished = card_logic.update(dt, function(cardData)
        -- 应用卡牌效果
        local damage = currentMonster:applyDamage(cardData.baseDamage or 0)
        currentPlayer:applyCardEffect(cardData)
        
        -- 应用组合效果
        local comboEffects = card_logic.calculateCardCombo({cardData})
        for _, combo in ipairs(comboEffects) do
            currentMonster:applyCardEffect(combo.card)
            currentPlayer:applyComboEffect(combo)
        end
        
        -- 检查怪物意图
        currentMonster:checkIntents("damage_taken", damage, currentPlayer)
    end)
    
    -- 如果卡牌释放完成，重新启用按钮
    if cardsFinished then
        m.enableButtons()
        -- 清空 playerCards
        card_logic.reset()
    end
    
    if cardsFinished then
        -- 检查战斗结果
        if currentMonster:isDefeated() then
            print("Monster defeated!")
            stateManager.changeState("map", { 
                completeBattleNode = true,
                battleType = battleType
            })
            return
        end
        
        if currentPlayer:isDefeated() then
            print("Player defeated!")
            stateManager.changeState("game_over")
            return
        end
        
        -- 检查回合结束时的怪物意图
        currentMonster:checkIntents("turn_end", currentMonster:incrementTurnCount(), currentPlayer)
    end
end

function m.draw()
    -- 绘制背景
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- 绘制UI
    battle_ui.drawMonster(currentMonster)
    battle_ui.drawPlayerHealth(currentPlayer)
    
    local cardState = card_logic.getState()
    -- 先绘制飞行中的卡牌，再绘制静止的卡牌
    battle_ui.drawFlyingCards(cardState.flyingCards)
    battle_ui.drawCards(cardState.playerCards, cardState.flyingCards)
    battle_ui.drawButtons(generateCardButton, executeCardButton, cardState.isReleasingCards)
end

function m.mousepressed(x, y, button)
    local cardState = card_logic.getState()
    if cardState.isReleasingCards or #cardState.flyingCards > 0 then return end
    
    generateCardButton:mousepressed(x, y, button)
    executeCardButton:mousepressed(x, y, button)

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