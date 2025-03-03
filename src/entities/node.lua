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
    elseif self.type == "boss" then
        color = {1, 0, 0} -- Boss节点为红色
    elseif self.type == 1 then
        color = {0, 1, 0} -- 战斗节点为绿色
    elseif self.type == 2 then
        color = {0, 0, 1} -- 商店节点为蓝色
    elseif self.type == 3 then
        color = {1, 1, 0} -- 事件节点为黄色
    end

    -- 绘制节点
    love.graphics.setColor(color)
    love.graphics.circle("fill", self.x + offsetX, self.y + offsetY, 30) -- 节点半径固定为30
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("line", self.x + offsetX, self.y + offsetY, 30)

    -- 显示节点名称
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.name, self.x + offsetX - 30, self.y + offsetY + 35) -- 名称显示在节点下方
end

function node:isClicked(mouseX, mouseY, offsetX, offsetY)
    local dist = math.sqrt((mouseX - (self.x + offsetX))^2 + (mouseY - (self.y + offsetY))^2)
    return dist <= 30 -- 节点半径固定为30
end

return node