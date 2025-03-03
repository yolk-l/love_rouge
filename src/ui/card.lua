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

    -- 显示卡牌效果
    if cardData.damage then
        love.graphics.print("Damage: " .. cardData.damage, x + 10, y + 30)
    end
    if cardData.block then
        love.graphics.print("Block: " .. cardData.block, x + 10, y + 50)
    end
    love.graphics.print("Cost: " .. cardData.cost, x + 10, y + 70)
end

return card