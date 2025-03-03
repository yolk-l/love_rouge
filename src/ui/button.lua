local button = {}

function button.new(text, x, y, width, height, onClick)
    local self = setmetatable({}, { __index = button })
    self.text = text
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.onClick = onClick
    return self
end

function button:update(dt)
    -- Update logic here
end

function button:draw()
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.print(self.text, self.x + 10, self.y + 10)
end

function button:mousepressed(x, y, button)
    if x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height then
        self.onClick()
    end
end

return button