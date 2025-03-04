local monster_manager = {}

local currentMonster = nil

-- 初始化怪物
function monster_manager.initialize(monsterData, battleType)
    currentMonster = {
        name = monsterData.name,
        health = monsterData.health,
        maxHealth = monsterData.health,
        attack = monsterData.attack,
        type = battleType,
        intents = monsterData.intents,
        block = 0,
        turnCount = 0
    }
    return currentMonster
end

-- 执行怪物意图
function monster_manager.executeIntent(intent, player)
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
            currentMonster.name, intent.name, damage))
    elseif intent.type == "heal" then
        currentMonster.health = math.min(currentMonster.maxHealth, 
            currentMonster.health + intent.value)
        print(string.format("Monster %s used %s to heal for %d!", 
            currentMonster.name, intent.name, intent.value))
    elseif intent.type == "shield" then
        currentMonster.block = (currentMonster.block or 0) + intent.value
        print(string.format("Monster %s used %s to gain %d block!", 
            currentMonster.name, intent.name, intent.value))
    elseif intent.type == "buff_attack" then
        currentMonster.attack = currentMonster.attack + intent.value
        print(string.format("Monster %s used %s to increase attack by %d!", 
            currentMonster.name, intent.name, intent.value))
    end
end

-- 检查怪物意图
function monster_manager.checkIntents(trigger, value, player)
    if not currentMonster or not currentMonster.intents then return end
    
    for _, intent in ipairs(currentMonster.intents) do
        if intent.trigger == trigger then
            if not intent.triggerValue or (value and value >= intent.triggerValue) then
                monster_manager.executeIntent(intent, player)
            end
        end
    end
end

-- 应用卡牌效果到怪物
function monster_manager.applyCardEffect(cardData)
    if cardData.baseDamage then
        local damage = cardData.baseDamage
        if currentMonster.block > 0 then
            if currentMonster.block >= damage then
                currentMonster.block = currentMonster.block - damage
                damage = 0
            else
                damage = damage - currentMonster.block
                currentMonster.block = 0
            end
        end
        currentMonster.health = currentMonster.health - damage
        print(string.format("Card %s dealt %d damage!", cardData.name, damage))
        return damage
    end
    return 0
end

-- 获取怪物状态
function monster_manager.getState()
    return currentMonster
end

-- 检查怪物是否被击败
function monster_manager.isDefeated()
    return currentMonster and currentMonster.health <= 0
end

-- 增加回合计数
function monster_manager.incrementTurnCount()
    if currentMonster then
        currentMonster.turnCount = currentMonster.turnCount + 1
        return currentMonster.turnCount
    end
    return 0
end

return monster_manager 