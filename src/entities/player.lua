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

function mt:incrementCardsGenerated()
    self.cardsGenerated = self.cardsGenerated + 1
    return self.cardsGenerated
end

function mt:isDefeated()
    return self.health <= 0
end

function mt:draw()
    -- Draw player here
end

local Player = {}

function Player.new()
    return setmetatable({
        health = 100,
        maxHealth = 100,
        block = 0,
        deck = {},
        damageTaken = 0,
        cardsGenerated = 0,
    }, mt)
end

return Player