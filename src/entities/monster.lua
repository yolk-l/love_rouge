
local mt = {}
mt.__index = mt

function mt:applyDamage(damage)
    if self.block > 0 then
        if self.block >= damage then
            self.block = self.block - damage
            damage = 0
        else
            damage = damage - self.block
            self.block = 0
        end
    end
    self.health = self.health - damage
end

function mt:applyBlock(block)
    self.block = self.block + block
end

function mt:executeIntent(intent, player)
    if intent.type == "attack" then
        local damage = intent.value
        if player.block > 0 then
            if player.block >= damage then
                player.block = player.block - damage
                damage = 0
                print(string.format("Blocked all damage! Remaining block: %d", player.block))
            else
                damage = damage - player.block
                print(string.format("Blocked %d damage! Remaining block: %d", player.block, 0))
                player.block = 0
            end
        end
        player.health = player.health - damage
        player.damageTaken = player.damageTaken + damage
        print(string.format("Monster %s used %s for %d damage!", 
            self.name, intent.name, damage))
    elseif intent.type == "heal" then
        self.health = math.min(self.maxHealth, self.health + intent.value)
        print(string.format("Monster %s used %s to heal for %d!", 
            self.name, intent.name, intent.value))
    elseif intent.type == "shield" then
        self.block = (self.block or 0) + intent.value
        print(string.format("Monster %s used %s to gain %d block!", 
            self.name, intent.name, intent.value))
    elseif intent.type == "buff_attack" then
        self.attack = self.attack + intent.value
        print(string.format("Monster %s used %s to increase attack by %d!", 
            self.name, intent.name, intent.value))
    end
end

function mt:checkIntents(trigger, value, player)
    if not self.intents then return end
    
    for _, intent in ipairs(self.intents) do
        if intent.trigger == trigger then
            if not intent.triggerValue or (value and value >= intent.triggerValue) then
                self:executeIntent(intent, player)
            end
        end
    end
end

function mt:incrementTurnCount()
    self.turnCount = self.turnCount + 1
    return self.turnCount
end

function mt:isDefeated()
    return self.health <= 0
end

function mt:draw()
    love.graphics.print(self.name, 300, 100)
    love.graphics.print("Health: " .. self.health, 300, 120)
end

local Monster = {}

function Monster.new(monsterData, battleType)
    return setmetatable({
        name = monsterData.name,
        health = monsterData.health,
        maxHealth = monsterData.health,
        attack = monsterData.attack,
        type = battleType,
        intents = monsterData.intents,
        block = 0,
        turnCount = 0,
    }, mt)
end

return Monster