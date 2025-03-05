local Entity = {}
Entity.__index = Entity

function Entity:new(health, maxHealth)
    local entity = setmetatable({}, self)
    entity.health = health
    entity.maxHealth = maxHealth
    entity.block = 0
    return entity
end

function Entity:applyDamage(damage)
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

function Entity:applyBlock(block)
    self.block = self.block + block
end

local player_entity = {}

-- 初始化玩家状态
local player = Entity:new(80, 80)

function player_entity.initialize()
    player.health = 80
    player.maxHealth = 80
    player.block = 0
    player.damageTaken = 0
    player.cardsGenerated = 0
    return player
end

-- 应用卡牌效果到玩家
function player_entity.applyCardEffect(cardData)
    if cardData.baseBlock then
        player:applyBlock(cardData.baseBlock)
        print(string.format("Card %s gained %d block!", cardData.name, cardData.baseBlock))
    end
end

-- 应用组合效果到玩家
function player_entity.applyComboEffect(combo)
    if combo.effect.block then
        player:applyBlock(combo.effect.block)
        print(string.format("Combo effect: %d %s gained %d block!", 
            combo.count, combo.card.name, combo.effect.block))
    end
end

-- 增加生成的卡牌计数
function player_entity.incrementCardsGenerated()
    player.cardsGenerated = player.cardsGenerated + 1
    return player.cardsGenerated
end

-- 获取玩家状态
function player_entity.getState()
    return player
end

-- 检查玩家是否被击败
function player_entity.isDefeated()
    return player.health <= 0
end

return player_entity 