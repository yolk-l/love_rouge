local stateManager = require "src.utils.state_manager"
local button = require "src.ui.button"
local card = require "src.ui.card"
local monsters = require "conf.monsters"
local cards = require "conf.cards"

local currentMonster
local playerCards = {}
local generateCardButton
local executeCardButton
local currentCardIndex = 0 -- 当前释放的卡牌索引
local isReleasingCards = false -- 是否正在释放卡牌
local cardReleaseTimer = 0 -- 卡牌释放计时器
local flyingCards = {} -- 正在飞行的卡牌
local battleType = "normal" -- 默认战斗类型

-- 禁用按钮
local function disableButtons()
    generateCardButton.enabled = false
    executeCardButton.enabled = false
end

-- 启用按钮
local function enableButtons()
    generateCardButton.enabled = true
    executeCardButton.enabled = true
end

local function onGenerateCardClick()
    if not generateCardButton.enabled or isReleasingCards then return end
    
    -- 生成 5 张随机卡牌
    playerCards = {}
    for i = 1, 5 do
        local randomCard = cards[math.random(1, #cards)]
        table.insert(playerCards, randomCard)
    end
    currentCardIndex = 0 -- 重置卡牌释放索引
    isReleasingCards = false -- 重置释放状态
    flyingCards = {} -- 清空飞行卡牌
end

local function onExecuteCardClick()
    if not executeCardButton.enabled or isReleasingCards then return end
    
    if #playerCards > 0 then
        isReleasingCards = true -- 开始释放卡牌
        disableButtons() -- 禁用所有按钮
    else
        print("No cards to execute! Generate cards first.")
    end
end

local function load(params)
    if not params then
        error("Battle state requires parameters")
        return
    end
    
    if params.nodeType ~= "battle" then
        error("Invalid node type for battle state: " .. tostring(params.nodeType))
        return
    end
    
    -- 获取战斗类型（normal/elite/boss）
    battleType = params.battleType or "normal"
    
    -- 根据战斗类型选择怪物池
    local monsterPool = monsters[battleType]
    if not monsterPool then
        print("Warning: Invalid battle type '" .. battleType .. "', falling back to normal")
        monsterPool = monsters.normal
    end
    
    -- 初始化战斗
    local monsterData = monsterPool[math.random(1, #monsterPool)]
    currentMonster = {
        name = monsterData.name,
        health = monsterData.health,
        maxHealth = monsterData.health,
        attack = monsterData.attack,
        type = battleType -- 记录怪物类型
    }
    
    generateCardButton = button.new("Generate Cards", 200, 500, 150, 50, onGenerateCardClick)
    executeCardButton = button.new("Execute Cards", 400, 500, 150, 50, onExecuteCardClick)
    enableButtons() -- 确保按钮初始状态为启用
end

local function update(dt)
    if not isReleasingCards then
        generateCardButton:update(dt)
        executeCardButton:update(dt)
    end

    -- 更新卡牌释放逻辑
    if isReleasingCards then
        cardReleaseTimer = cardReleaseTimer + dt
        if cardReleaseTimer >= 0.5 then -- 每 0.5 秒释放一张卡牌
            cardReleaseTimer = 0
            if currentCardIndex < #playerCards then
                currentCardIndex = currentCardIndex + 1
                local cardData = playerCards[currentCardIndex]
                -- 将卡牌添加到飞行卡牌列表中
                table.insert(flyingCards, {
                    card = cardData,
                    startX = 100 + (currentCardIndex - 1) * 120,
                    startY = 300,
                    targetX = 400,
                    targetY = 150,
                    progress = 0
                })
            else
                isReleasingCards = false -- 所有卡牌释放完毕
                enableButtons() -- 重新启用按钮
            end
        end
    end

    -- 更新飞行卡牌
    for i = #flyingCards, 1, -1 do
        local flyingCard = flyingCards[i]
        flyingCard.progress = flyingCard.progress + dt * 2
        if flyingCard.progress >= 1 then
            -- 卡牌到达目标位置，应用效果
            if flyingCard.card.damage then
                currentMonster.health = currentMonster.health - flyingCard.card.damage
                print(string.format("Card %d dealt %d damage to %s %s!", 
                    currentCardIndex, 
                    flyingCard.card.damage,
                    currentMonster.type,
                    currentMonster.name))
            end
            if currentMonster.health <= 0 then
                print("Monster defeated!")
                -- 战斗结束后，清空卡牌队列
                playerCards = {}
                flyingCards = {}
                currentCardIndex = 0
                isReleasingCards = false
                enableButtons()
                -- 更新地图中当前战斗节点的状态
                stateManager.changeState("map", { 
                    completeBattleNode = true,
                    battleType = battleType -- 传递战斗类型回地图
                })
                return
            end
            table.remove(flyingCards, i)
        end
    end
end

local function drawMonster()
    -- 绘制怪物展示框
    love.graphics.setColor(0.2, 0.2, 0.2) -- 灰色背景
    love.graphics.rectangle("fill", 250, 50, 300, 200) -- 展示框大小
    love.graphics.setColor(1, 1, 1) -- 白色边框
    love.graphics.rectangle("line", 250, 50, 300, 200)

    -- 绘制怪物名称
    love.graphics.setColor(1, 1, 1) -- 白色文字
    love.graphics.print("Monster: " .. currentMonster.name, 260, 60)

    -- 绘制怪物血条
    local healthBarWidth = 280
    local healthBarHeight = 20
    local healthRatio = currentMonster.health / currentMonster.maxHealth -- 计算血量比例
    love.graphics.setColor(1, 0, 0) -- 红色血条背景
    love.graphics.rectangle("fill", 260, 90, healthBarWidth, healthBarHeight)
    love.graphics.setColor(0, 1, 0) -- 绿色血条
    love.graphics.rectangle("fill", 260, 90, healthBarWidth * healthRatio, healthBarHeight)
    love.graphics.setColor(0, 0, 0) -- 黑色边框
    love.graphics.rectangle("line", 260, 90, healthBarWidth, healthBarHeight)

    -- 显示怪物当前血量
    love.graphics.print("Health: " .. currentMonster.health .. " / " .. currentMonster.maxHealth, 260, 120)
end

local function drawCards()
    -- 绘制卡牌
    for i, cardData in ipairs(playerCards) do
        if i > currentCardIndex then -- 只绘制未释放的卡牌
            card.draw(cardData, 100 + (i - 1) * 120, 300) -- 卡牌位置上移
        end
    end
end

local function drawFlyingCards()
    -- 绘制飞行中的卡牌
    for _, flyingCard in ipairs(flyingCards) do
        local x = flyingCard.startX + (flyingCard.targetX - flyingCard.startX) * flyingCard.progress
        local y = flyingCard.startY + (flyingCard.targetY - flyingCard.startY) * flyingCard.progress
        card.draw(flyingCard.card, x, y)
    end
end

local function draw()
    -- 绘制背景
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- 绘制怪物展示框和血条
    drawMonster()

    -- 绘制卡牌
    drawCards()

    -- 绘制飞行中的卡牌
    drawFlyingCards()

    -- 绘制按钮（根据状态显示不同的外观）
    if isReleasingCards then
        love.graphics.setColor(0.5, 0.5, 0.5) -- 禁用状态显示灰色
    else
        love.graphics.setColor(1, 1, 1)
    end
    generateCardButton:draw()
    executeCardButton:draw()
end

local function mousepressed(x, y, button)
    if isReleasingCards then return end -- 如果正在释放卡牌，禁用所有鼠标操作
    
    generateCardButton:mousepressed(x, y, button)
    executeCardButton:mousepressed(x, y, button)

    -- 检查是否点击了卡牌
    for i, cardData in ipairs(playerCards) do
        local cardX = 100 + (i - 1) * 120
        local cardY = 300
        if x >= cardX and x <= cardX + 100 and y >= cardY and y <= cardY + 150 then
            print(string.format("Clicked card: %s", cardData.name))
        end
    end
end

return {
    load = load,
    update = update,
    draw = draw,
    mousepressed = mousepressed
}