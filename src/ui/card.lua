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
    local yOffset = 50
    
    -- 检查卡牌效果类型并显示相应信息
    for _, effect in ipairs(cardData.effect_list) do
        if effect.effect_type == "damage" then
            love.graphics.setColor(0.8, 0, 0) -- 红色表示伤害
            love.graphics.print("Damage: " .. cardData.args[effect.effect_args[1]], x + 10, y + yOffset)
            yOffset = yOffset + 20
        elseif effect.effect_type == "block" then
            love.graphics.setColor(0, 0, 0.8) -- 蓝色表示格挡
            love.graphics.print("Block: " .. cardData.args[effect.effect_args[1]], x + 10, y + yOffset)
            yOffset = yOffset + 20
        elseif effect.effect_type == "add_strength" then
            love.graphics.setColor(0.8, 0, 0) -- 红色表示力量
            love.graphics.print("Strength: +" .. cardData.args[effect.effect_args[1]], x + 10, y + yOffset)
            yOffset = yOffset + 20
        elseif effect.effect_type == "add_dexterity" then
            love.graphics.setColor(0, 0, 0.8) -- 蓝色表示敏捷
            love.graphics.print("Dexterity: +" .. cardData.args[effect.effect_args[1]], x + 10, y + yOffset)
            yOffset = yOffset + 20
        end
    end

    -- 显示卡牌描述
    love.graphics.setColor(0, 0, 0)
    if cardData.description then
        -- 替换描述中的参数
        local desc = cardData.description
        for argName, argValue in pairs(cardData.args) do
            desc = desc:gsub("%[" .. argName .. "%]", tostring(argValue))
        end
        love.graphics.printf(desc, x + 5, y + yOffset, 90, "left")
    end
end

return card