local button = {}

function button.new(text, x, y, width, height, onClick, ...)
    local self = setmetatable({}, { __index = button })
    self.text = text
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.onClick = onClick
    self.clickArgs = {...}
    return self
end

function button:update(dt)
    -- 更新逻辑
end

function button:draw()
    -- 绘制按钮背景
    love.graphics.setColor(0.4, 0.4, 0.4) -- 灰色背景
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1) -- 白色边框
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    -- 绘制按钮文字
    love.graphics.setColor(1, 1, 1) -- 白色文字
    love.graphics.print(self.text, self.x + 10, self.y + 15)
end

function button:mousepressed(x, y, button)
    if x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height then
        self.onClick(unpack(self.clickArgs))
    end
end

return button