local mt = {}
mt.__index = mt

function mt:draw(offsetX, offsetY)
    -- Set node color
    local color = {1, 1, 1} -- Default white
    local nodeSymbol = "?"
    
    if self.completed then
        color = {0.5, 0.5, 0.5} -- Gray for completed nodes
    else
        if self.type == "battle" then
            if self.battleType == "boss" then
                color = {1, 0, 0} -- Red for Boss battles
                nodeSymbol = "B"
            elseif self.battleType == "elite" then
                color = {1, 0.5, 0} -- Orange for Elite battles
                nodeSymbol = "E"
            else
                color = {0, 1, 0} -- Green for normal battles
                nodeSymbol = "M"
            end
        elseif self.type == "shop" then
            color = {0, 0, 1} -- Blue for shops
            nodeSymbol = "$"
        elseif self.type == "event" then
            color = {1, 1, 0} -- Yellow for events
            nodeSymbol = "?"
        end
    end

    -- Draw node
    love.graphics.setColor(color)
    love.graphics.circle("fill", self.x + offsetX, self.y + offsetY, 30)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("line", self.x + offsetX, self.y + offsetY, 30)

    -- Display node symbol
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(nodeSymbol, self.x + offsetX - 8, self.y + offsetY - 12, 0, 2, 2)
    
    -- Display node name
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.name, self.x + offsetX - 30, self.y + offsetY + 35)
    
    -- Display node type (only in debug mode)
    if self.debug then
        local typeText = self.type
        if self.type == "battle" then
            typeText = self.battleType .. " " .. self.type
        end
        love.graphics.print(typeText, self.x + offsetX - 30, self.y + offsetY - 45)
    end
end

function mt:isClicked(mouseX, mouseY, offsetX, offsetY)
    local dist = math.sqrt((mouseX - (self.x + offsetX))^2 + (mouseY - (self.y + offsetY))^2)
    return dist <= 30
end

local NodeEntity = {}

function NodeEntity.new(x, y, type, name)
    return setmetatable({
        x = x,
        y = y,
        type = type,
        name = name,
        completed = false,
        debug = false, -- Debug mode, set to true to display more information
    }, mt)
end

return NodeEntity