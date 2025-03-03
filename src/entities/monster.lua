local monster = {}

function monster.new(monsterData)
    local self = setmetatable({}, { __index = monster })
    self.name = monsterData.name
    self.health = monsterData.health
    self.attack = monsterData.attack
    return self
end

function monster:draw()
    love.graphics.print(self.name, 300, 100)
    love.graphics.print("Health: " .. self.health, 300, 120)
end

return monster