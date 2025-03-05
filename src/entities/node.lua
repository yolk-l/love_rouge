local node = {}

function node.new(x, y, type, name)
    local self = setmetatable({}, { __index = node })
    self.x = x
    self.y = y
    self.type = type
    self.name = name
    self.completed = false
    return self
end

function node:draw(offsetX, offsetY)
    -- 设置节点颜色
    local color = {1, 1, 1} -- 默认白色
    if self.completed then
        color = {0.5, 0.5, 0.5} -- 已完成节点为灰色
    else
        if self.type == "battle" then
            if self.battleType == "boss" then
                color = {1, 0, 0} -- Boss战斗为红色
            elseif self.battleType == "elite" then
                color = {1, 0.5, 0} -- 精英战斗为橙色
            else
                color = {0, 1, 0} -- 普通战斗为绿色
            end
        elseif self.type == "shop" then
            color = {0, 0, 1} -- 商店为蓝色
        elseif self.type == "event" then
            color = {1, 1, 0} -- 事件为黄色
        end
    end

    -- 绘制节点
    love.graphics.setColor(color)
    love.graphics.circle("fill", self.x + offsetX, self.y + offsetY, 30)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("line", self.x + offsetX, self.y + offsetY, 30)

    -- 显示节点名称
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.name, self.x + offsetX - 30, self.y + offsetY + 35)
    
    -- 显示节点类型
    local typeText = self.type
    if self.type == "battle" then
        typeText = self.battleType .. " " .. self.type
    end
    love.graphics.print(typeText, self.x + offsetX - 30, self.y + offsetY - 45)
end

function node:isClicked(mouseX, mouseY, offsetX, offsetY)
    local dist = math.sqrt((mouseX - (self.x + offsetX))^2 + (mouseY - (self.y + offsetY))^2)
    return dist <= 30
end

return node