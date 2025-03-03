local stateManager = require "src.utils.state_manager"
local button = require "src.ui.button"
local card = require "src.ui.card"
local monsters = require "conf.monsters"
local cards = require "conf.cards"

local currentMonster
local playerCards = {}
local generateCardButton
local currentCardIndex = 0 -- 当前释放的卡牌索引
local isReleasingCards = false -- 是否正在释放卡牌
local cardReleaseTimer = 0 -- 卡牌释放计时器
local flyingCards = {} -- 正在飞行的卡牌

local function onGenerateCardClick()
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

local function load()
    -- 初始化战斗
    currentMonster = monsters.normal[math.random(1, #monsters.normal)] -- 随机选择一个普通怪物
    generateCardButton = button.new("Generate Cards", 300, 500, 200, 50, onGenerateCardClick)
end

local function update(dt)
    generateCardButton:update(dt)

    -- 更新卡牌释放逻辑
    if isReleasingCards then
        cardReleaseTimer = cardReleaseTimer + dt
        if cardReleaseTimer >= 0.5 then -- 每 0.5 秒释放一张卡牌
            cardReleaseTimer = 0
            if currentCardIndex <= #playerCards then
                local cardData = playerCards[currentCardIndex]
                -- 将卡牌添加到飞行卡牌列表中
                table.insert(flyingCards, {
                    card = cardData,
                    startX = 100 + (currentCardIndex - 1) * 120,
                    startY = 400,
                    targetX = 400, -- 怪物框的中心位置
                    targetY = 150, -- 怪物框的中心位置
                    progress = 0 -- 飞行进度
                })
                currentCardIndex = currentCardIndex + 1
            else
                isReleasingCards = false -- 所有卡牌释放完毕
            end
        end
    end

    -- 更新飞行卡牌
    for i = #flyingCards, 1, -1 do
        local flyingCard = flyingCards[i]
        flyingCard.progress = flyingCard.progress + dt * 2 -- 控制飞行速度
        if flyingCard.progress >= 1 then
            -- 卡牌到达目标位置，应用效果
            if flyingCard.card.damage then
                currentMonster.health = currentMonster.health - flyingCard.card.damage
                print("Card " .. currentCardIndex - 1 .. " dealt " .. flyingCard.card.damage .. " damage!")
            end
            if currentMonster.health <= 0 then
                print("Monster defeated!")
                stateManager.changeState("map") -- 返回地图界面
                currentCardIndex = 0 -- 重置卡牌释放索引
                isReleasingCards = false -- 重置释放状态
                flyingCards = {} -- 清空飞行卡牌
                playerCards = {}
                return
            end
            table.remove(flyingCards, i) -- 移除已到达的卡牌
            table.remove(playerCards, currentCardIndex - 1) -- 移除已生效的卡牌
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
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Monster: " .. currentMonster.name, 260, 60)

    -- 绘制怪物血条
    local healthBarWidth = 280
    local healthBarHeight = 20
    local healthRatio = currentMonster.health / 100 -- 假设怪物最大血量为100
    love.graphics.setColor(1, 0, 0) -- 红色血条背景
    love.graphics.rectangle("fill", 260, 90, healthBarWidth, healthBarHeight)
    love.graphics.setColor(0, 1, 0) -- 绿色血条
    love.graphics.rectangle("fill", 260, 90, healthBarWidth * healthRatio, healthBarHeight)
    love.graphics.setColor(1, 1, 1) -- 白色边框
    love.graphics.rectangle("line", 260, 90, healthBarWidth, healthBarHeight)

    -- 显示怪物当前血量
    love.graphics.print("Health: " .. currentMonster.health, 260, 120)
end

local function drawCards()
    -- 绘制卡牌
    for i, cardData in ipairs(playerCards) do
        card.draw(cardData, 100 + (i - 1) * 120, 400)
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
    -- 绘制怪物展示框和血条
    drawMonster()

    -- 绘制卡牌
    drawCards()

    -- 绘制飞行中的卡牌
    drawFlyingCards()

    -- 绘制按钮
    generateCardButton:draw()
end

local function mousepressed(x, y, button)
    generateCardButton:mousepressed(x, y, button)

    -- 检查是否点击了卡牌
    for i, cardData in ipairs(playerCards) do
        local cardX = 100 + (i - 1) * 120
        local cardY = 400
        if x >= cardX and x <= cardX + 100 and y >= cardY and y <= cardY + 150 then
            print("Clicked card: " .. cardData.name)
            if not isReleasingCards then
                currentCardIndex = 1 -- 开始释放卡牌
                isReleasingCards = true
            end
        end
    end
end

return {
    load = load,
    update = update,
    draw = draw,
    mousepressed = mousepressed
}