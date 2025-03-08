local base_util = require "src.utils.base_util"

local battle_ui = {}

-- 绘制怪物
function battle_ui.drawMonster(monster)
    -- 绘制怪物展示框
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 250, 50, 300, 200)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 250, 50, 300, 200)

    -- 绘制怪物名称
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Monster: " .. monster.name, 260, 60)

    -- 绘制怪物血条
    local healthBarWidth = 280
    local healthBarHeight = 20
    local healthRatio = monster:getHealthRatio()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 260, 90, healthBarWidth, healthBarHeight)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 260, 90, healthBarWidth * healthRatio, healthBarHeight)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", 260, 90, healthBarWidth, healthBarHeight)

    -- 显示怪物当前血量
    love.graphics.print("Health: " .. monster:getHealth() .. " / " .. monster:getMaxHealth(), 260, 120)
    
    -- 显示怪物格挡值
    if monster:getBlock() > 0 then
        love.graphics.setColor(0, 0.8, 1)
        love.graphics.print("Block: " .. monster:getBlock(), 260, 140)
    end
    
    -- 显示怪物当前意图
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.print("Intent: " .. monster:getIntentDescription(), 260, 160)
end

-- 绘制玩家状态
function battle_ui.drawPlayerHealth(player)
    local healthBarWidth = 200
    local healthBarHeight = 20
    local healthPercentage = player:getHealthRatio()
    
    -- Draw health bar background
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", 50, 300, healthBarWidth, healthBarHeight)
    
    -- Draw health bar
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 50, 300, healthBarWidth * healthPercentage, healthBarHeight)
    
    -- Draw health text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("HP: %d/%d", player:getHealth(), player:getMaxHealth()), 50, 280, 0, 1.2)
    -- Draw block value
    if player:getBlock() > 0 then
        love.graphics.setColor(0, 0.8, 1)
        love.graphics.print(string.format("Block: %d", player:getBlock()), 50, 320, 0, 1.2)
    end
end

-- 获取卡牌类型对应的颜色
local function getCardTypeColor(cardType)
    if cardType == "attack" then
        return {0.8, 0.2, 0.2} -- 红色
    elseif cardType == "defense" then
        return {0.2, 0.6, 0.8} -- 蓝色
    elseif cardType == "skill" then
        return {0.2, 0.8, 0.2} -- 绿色
    elseif cardType == "power" then
        return {0.8, 0.2, 0.8} -- 紫色
    else
        return {0.6, 0.6, 0.6} -- 灰色（默认）
    end
end

-- 自适应文本换行
local function drawWrappedText(text, x, y, width, scale)
    scale = scale or 1
    local font = love.graphics.getFont()
    local words = {}
    for word in text:gmatch("%S+") do
        table.insert(words, word)
    end
    
    local lines = {}
    local currentLine = ""
    
    for _, word in ipairs(words) do
        local testLine = currentLine
        if testLine ~= "" then
            testLine = testLine .. " "
        end
        testLine = testLine .. word
        
        if font:getWidth(testLine) * scale <= width then
            currentLine = testLine
        else
            table.insert(lines, currentLine)
            currentLine = word
        end
    end
    
    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end
    
    for i, line in ipairs(lines) do
        love.graphics.print(line, x, y + (i-1) * font:getHeight() * scale, 0, scale)
    end
    
    return #lines * font:getHeight() * scale
end

-- 绘制卡牌
function battle_ui.drawCards(cards)
    local cardWidth = 100
    local cardHeight = 140
    local cardSpacing = 15
    local startX = 30
    local startY = 400

    for i, card in ipairs(cards) do
        local x = startX + (i - 1) * (cardWidth + cardSpacing)
        local y = startY
        
        -- 获取卡牌类型颜色
        local typeColor = getCardTypeColor(card.type)
        
        -- Draw card background
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", x, y, cardWidth, cardHeight)

        -- Draw card border with type color
        love.graphics.setColor(typeColor)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, cardWidth, cardHeight)
        love.graphics.setLineWidth(1)

        -- Draw card name
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(card.name, x + 8, y + 8, 0, 1.1)

        -- Draw card description with replaced parameters and text wrapping
        love.graphics.setColor(0.8, 0.8, 0.8)
        local description = base_util.replaceParams(card.description, card.args)
        local descHeight = drawWrappedText(description, x + 8, y + 35, cardWidth - 16, 0.9)
        
        -- Draw card type (centered and lower)
        love.graphics.setColor(typeColor)
        local font = love.graphics.getFont()
        local typeText = card.type:gsub("^%l", string.upper) -- Capitalize first letter
        local typeWidth = font:getWidth(typeText) * 0.9
        love.graphics.print(typeText, x + (cardWidth - typeWidth) / 2, y + 110, 0, 0.9)
    end
end

-- 绘制飞行中的卡牌
function battle_ui.drawFlyingCards(flyingCards)
    local cardWidth = 100
    local cardHeight = 140

    for _, flyingCard in ipairs(flyingCards) do
        local x = flyingCard.startX + (flyingCard.targetX - flyingCard.startX) * flyingCard.progress
        local y = flyingCard.startY + (flyingCard.targetY - flyingCard.startY) * flyingCard.progress
        
        -- 获取卡牌类型颜色
        local typeColor = getCardTypeColor(flyingCard.card.type)

        -- Draw card background
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", x, y, cardWidth, cardHeight)

        -- Draw card border with type color
        love.graphics.setColor(typeColor)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, cardWidth, cardHeight)
        love.graphics.setLineWidth(1)

        -- Draw card name
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(flyingCard.card.name, x + 8, y + 8, 0, 1.1)

        -- Draw card description with replaced parameters and text wrapping
        love.graphics.setColor(0.8, 0.8, 0.8)
        local description = base_util.replaceParams(flyingCard.card.description, flyingCard.card.args)
        local descHeight = drawWrappedText(description, x + 8, y + 35, cardWidth - 16, 0.9)

        -- Draw card type (centered and lower)
        love.graphics.setColor(typeColor)
        local font = love.graphics.getFont()
        local typeText = flyingCard.card.type:gsub("^%l", string.upper) -- Capitalize first letter
        local typeWidth = font:getWidth(typeText) * 0.9
        love.graphics.print(typeText, x + (cardWidth - typeWidth) / 2, y + 110, 0, 0.9)
    end
end

-- 绘制按钮
function battle_ui.drawButtons(generateCardButton, executeCardButton, isReleasingCards)
    if isReleasingCards then
        love.graphics.setColor(0.5, 0.5, 0.5)
    else
        love.graphics.setColor(1, 1, 1)
    end
    generateCardButton:draw()
    executeCardButton:draw()
end

return battle_ui 