local player = {}

function player.new()
    local self = setmetatable({}, { __index = player })
    self.health = 100
    self.maxHealth = 100
    self.block = 0
    self.deck = {}
    self.damageTaken = 0
    self.cardsGenerated = 0
    return self
end

function player:applyDamage(damage)
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

function player:applyBlock(block)
    self.block = self.block + block
end

function player:applyCardEffect(cardData)
    if cardData.baseBlock then
        self:applyBlock(cardData.baseBlock)
        print(string.format("Card %s gained %d block!", cardData.name, cardData.baseBlock))
    end
end

function player:applyComboEffect(combo)
    if combo.effect.block then
        self:applyBlock(combo.effect.block)
        print(string.format("Combo effect: %d %s gained %d block!", 
            combo.count, combo.card.name, combo.effect.block))
    end
end

function player:incrementCardsGenerated()
    self.cardsGenerated = self.cardsGenerated + 1
    return self.cardsGenerated
end

function player:isDefeated()
    return self.health <= 0
end

function player:draw()
    -- Draw player here
end

return player