local player_manager = {}

local player = {
    health = 80,
    maxHealth = 80,
    block = 0,
    damageTaken = 0,
    cardsGenerated = 0
}

-- 初始化玩家状态
function player_manager.initialize()
    player.health = 80
    player.maxHealth = 80
    player.block = 0
    player.damageTaken = 0
    player.cardsGenerated = 0
    return player
end

-- 应用卡牌效果到玩家
function player_manager.applyCardEffect(cardData)
    if cardData.baseBlock then
        player.block = player.block + cardData.baseBlock
        print(string.format("Card %s gained %d block!", cardData.name, cardData.baseBlock))
    end
end

-- 应用组合效果到玩家
function player_manager.applyComboEffect(combo)
    if combo.effect.block then
        player.block = player.block + combo.effect.block
        print(string.format("Combo effect: %d %s gained %d block!", 
            combo.count, combo.card.name, combo.effect.block))
    end
end

-- 增加生成的卡牌计数
function player_manager.incrementCardsGenerated()
    player.cardsGenerated = player.cardsGenerated + 1
    return player.cardsGenerated
end

-- 获取玩家状态
function player_manager.getState()
    return player
end

-- 检查玩家是否被击败
function player_manager.isDefeated()
    return player.health <= 0
end

return player_manager 