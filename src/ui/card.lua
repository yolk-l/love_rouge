local card = {}

function card.draw(cardData, x, y)
    -- 绘制卡牌背景
    love.graphics.setColor(0.8, 0.8, 0.8) -- 灰色背景
    love.graphics.rectangle("fill", x, y, 100, 150) -- 卡牌大小
    love.graphics.setColor(0, 0, 0) -- 黑色边框
    love.graphics.rectangle("line", x, y, 100, 150)

    -- 显示卡牌名称
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(cardData.name, x + 10, y + 10)

    -- 显示卡牌类型
    love.graphics.print("Type: " .. cardData.type, x + 10, y + 30)

    -- 显示卡牌效果
    if cardData.baseDamage then
        love.graphics.print("Damage: " .. cardData.baseDamage, x + 10, y + 50)
    end
    if cardData.baseBlock then
        love.graphics.print("Block: " .. cardData.baseBlock, x + 10, y + 70)
    end

    -- 显示卡牌描述
    if cardData.description then
        love.graphics.print(cardData.description, x + 10, y + 90)
    end
end

return card