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
    
    -- 显示怪物力量和戒备
    local yPos = 140
    if monster:getBlock() > 0 then
        yPos = 160
    end
    
    if monster:getStrength() > 0 then
        love.graphics.setColor(0.8, 0.2, 0.2) -- 红色表示力量
        love.graphics.print("Strength: " .. monster:getStrength(), 260, yPos)
        yPos = yPos + 20
    end
    
    if monster:getDexterity() > 0 then
        love.graphics.setColor(0.2, 0.6, 0.8) -- 蓝色表示戒备
        love.graphics.print("Dexterity: " .. monster:getDexterity(), 260, yPos)
        yPos = yPos + 20
    end
    
    -- 显示怪物当前意图
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.print("Intent: " .. monster:getIntentDescription(), 260, yPos)
    yPos = yPos + 20
    
    -- 显示怪物buff
    battle_ui.drawBuffs(monster, 260, yPos)
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
    local yPos = 320
    if player:getBlock() > 0 then
        love.graphics.setColor(0, 0.8, 1)
        love.graphics.print(string.format("Block: %d", player:getBlock()), 50, yPos, 0, 1.2)
        yPos = yPos + 20
    end
    
    -- Draw strength and dexterity
    if player:getStrength() > 0 then
        love.graphics.setColor(0.8, 0.2, 0.2) -- 红色表示力量
        love.graphics.print(string.format("Strength: %d", player:getStrength()), 50, yPos, 0, 1.2)
        yPos = yPos + 20
    end
    
    if player:getDexterity() > 0 then
        love.graphics.setColor(0.2, 0.6, 0.8) -- 蓝色表示戒备
        love.graphics.print(string.format("Dexterity: %d", player:getDexterity()), 50, yPos, 0, 1.2)
        yPos = yPos + 20
    end
    
    -- Draw player buffs
    battle_ui.drawBuffs(player, 50, yPos)
end

-- 绘制角色的buff
function battle_ui.drawBuffs(character, x, y)
    local buffs = character:getActiveBuffs()
    if #buffs == 0 then return end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Buffs:", x, y)
    
    local buffSpacing = 20
    local buffY = y + 20
    
    for i, buff in ipairs(buffs) do
        -- 选择buff颜色
        if buff.buff_type == "positive" then
            love.graphics.setColor(0, 0.8, 0.2) -- 绿色表示增益
        else
            love.graphics.setColor(0.8, 0.2, 0.2) -- 红色表示减益
        end
        
        -- 显示buff名称和持续时间
        local buffText = buff.name
        
        -- 如果buff可叠加且层数大于1，显示层数
        if buff.stackable and buff.stacks and buff.stacks > 1 then
            buffText = buffText .. " x" .. buff.stacks
        end
        
        -- 显示持续时间（如果不是永久buff）
        if buff.duration and buff.duration > 0 then
            buffText = buffText .. " (" .. buff.duration .. ")"
        elseif buff.duration and buff.duration == -1 then
            buffText = buffText .. " (∞)"
        end
        
        love.graphics.print(buffText, x, buffY + (i-1) * buffSpacing, 0, 0.8)
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

-- 绘制高亮卡牌组
function battle_ui.drawHighlightedGroups(highlightedGroups)
    local cardWidth = 100
    local cardHeight = 140
    local cardSpacing = 15
    local startX = 30
    local startY = 400

    for _, highlight in ipairs(highlightedGroups) do
        local group = highlight.group
        local alpha = 1 - (highlight.timer / highlight.duration)
        
        -- 计算高亮框的位置和大小
        local x = startX + (group.startIndex - 1) * (cardWidth + cardSpacing) - 5
        local y = startY - 5
        local width = (group.endIndex - group.startIndex + 1) * (cardWidth + cardSpacing) - cardSpacing + 10
        local height = cardHeight + 10
        
        -- 绘制高亮框
        love.graphics.setColor(1, 1, 0, alpha * 0.7)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", x, y, width, height)
        love.graphics.setLineWidth(1)
        
        -- 绘制组合效果提示
        if group.count > 1 then
            love.graphics.setColor(1, 1, 0, alpha)
            love.graphics.print("x" .. group.count, x + width - 25, y - 20, 0, 1.2)
        end
    end
end

-- 绘制飘字效果
function battle_ui.drawFloatingTexts(floatingTexts)
    for _, text in ipairs(floatingTexts) do
        local alpha = 1 - (text.timer / text.duration)
        local yOffset = -30 * (text.timer / text.duration)
        
        love.graphics.setColor(text.color[1], text.color[2], text.color[3], alpha)
        love.graphics.print(text.text, text.x, text.y + yOffset, 0, 1.5)
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