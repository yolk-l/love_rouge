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
    local healthRatio = monster.health / monster.maxHealth
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 260, 90, healthBarWidth, healthBarHeight)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 260, 90, healthBarWidth * healthRatio, healthBarHeight)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", 260, 90, healthBarWidth, healthBarHeight)

    -- 显示怪物当前血量
    love.graphics.print("Health: " .. monster.health .. " / " .. monster.maxHealth, 260, 120)
    
    -- 显示怪物格挡值
    if monster.block > 0 then
        love.graphics.setColor(0, 0.8, 1)
        love.graphics.print("Block: " .. monster.block, 260, 140)
    end
    
    -- 显示怪物攻击力
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.print("Attack: " .. monster.attack, 260, 160)
end

-- 绘制玩家状态
function battle_ui.drawPlayerHealth(player)
    local healthBarWidth = 200
    local healthBarHeight = 20
    local healthPercentage = player.health / player.maxHealth
    
    -- Draw health bar background
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", 50, 300, healthBarWidth, healthBarHeight)
    
    -- Draw health bar
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 50, 300, healthBarWidth * healthPercentage, healthBarHeight)
    
    -- Draw health text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("HP: %d/%d", player.health, player.maxHealth), 50, 280, 0, 1.2)
    
    -- Draw block value
    if player.block > 0 then
        love.graphics.setColor(0, 0.8, 1)
        love.graphics.print(string.format("Block: %d", player.block), 50, 320, 0, 1.2)
    end
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
        -- Draw card background
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", x, y, cardWidth, cardHeight)

        -- Draw card border
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", x, y, cardWidth, cardHeight)

        -- Draw card name
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(card.name, x + 8, y + 8, 0, 1.1)

        -- Draw card description
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.print(card.description, x + 8, y + 35, 0, 0.9)
        -- Draw card type
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.print(card.type, x + 8, y + 100, 0, 0.9)
        -- Draw card damage
        if card.baseDamage then
            love.graphics.setColor(1, 0, 0)
            love.graphics.print(string.format("Damage: %d", card.baseDamage), x + 8, y + 120, 0, 0.9)
        end
    end
end

-- 绘制飞行中的卡牌
function battle_ui.drawFlyingCards(flyingCards)
    local cardWidth = 100
    local cardHeight = 140

    for _, flyingCard in ipairs(flyingCards) do
        local x = flyingCard.startX + (flyingCard.targetX - flyingCard.startX) * flyingCard.progress
        local y = flyingCard.startY + (flyingCard.targetY - flyingCard.startY) * flyingCard.progress

        -- Draw card background
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", x, y, cardWidth, cardHeight)

        -- Draw card border
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", x, y, cardWidth, cardHeight)

        -- Draw card name
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(flyingCard.card.name, x + 8, y + 8, 0, 1.1)

        -- Draw card description
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.print(flyingCard.card.description, x + 8, y + 35, 0, 0.9)

        -- Draw card type
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.print(flyingCard.card.type, x + 8, y + 100, 0, 0.9)

        -- Draw card damage
        if flyingCard.card.baseDamage then
            love.graphics.setColor(1, 0, 0)
            love.graphics.print(string.format("Damage: %d", flyingCard.card.baseDamage), x + 8, y + 120, 0, 0.9)
        end
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