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

local monster_entity = {}

local currentMonster

-- 初始化怪物
function monster_entity.initialize(monsterData, battleType)
    currentMonster = Entity:new(monsterData.health, monsterData.health)
    currentMonster.name = monsterData.name
    currentMonster.attack = monsterData.attack
    currentMonster.type = battleType
    currentMonster.intents = monsterData.intents
    currentMonster.turnCount = 0
    return currentMonster
end

-- 执行怪物意图
function monster_entity.executeIntent(intent, player)
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
function monster_entity.checkIntents(trigger, value, player)
    if not currentMonster or not currentMonster.intents then return end
    
    for _, intent in ipairs(currentMonster.intents) do
        if intent.trigger == trigger then
            if not intent.triggerValue or (value and value >= intent.triggerValue) then
                monster_entity.executeIntent(intent, player)
            end
        end
    end
end

-- 应用卡牌效果到怪物
function monster_entity.applyCardEffect(cardData)
    if cardData.baseDamage then
        currentMonster:applyDamage(cardData.baseDamage)
        print(string.format("Card %s dealt %d damage!", cardData.name, cardData.baseDamage))
    end
end

-- 获取怪物状态
function monster_entity.getState()
    return currentMonster
end

-- 检查怪物是否被击败
function monster_entity.isDefeated()
    return currentMonster and currentMonster.health <= 0
end

-- 增加回合计数
function monster_entity.incrementTurnCount()
    if currentMonster then
        currentMonster.turnCount = currentMonster.turnCount + 1
        return currentMonster.turnCount
    end
    return 0
end

return monster_entity 