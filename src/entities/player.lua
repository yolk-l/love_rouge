local player = {}

function player.new()
    local self = setmetatable({}, { __index = player })
    self.health = 100
    self.maxHealth = 100
    self.deck = {}
    return self
end

function player:draw()
    -- Draw player here
end

return player