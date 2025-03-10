local base_util = require "src.utils.base_util"
local attrComp = require "src.entities.component.attr_comp"
local targetComp = require "src.entities.component.target_comp"
local eventMgr = require "src.manager.event_mgr"
local global = require "src.global"
local buffMgr = require "src.manager.buff_mgr"

local mt = {}
mt.__index = mt

function mt:incrementCardsGenerated()
    self.cardsGenerated = self.cardsGenerated + 1
    -- 触发卡牌生成计数事件
    eventMgr.emit("player_cards_generated_count", {
        value = self.cardsGenerated,
        source = self
    })
    return self.cardsGenerated
end

function mt:draw()
    -- Draw player here
end

-- 获取所有激活的buff
function mt:getActiveBuffs()
    if self.buffMgr then
        return self.buffMgr:getActiveBuffs()
    end
    return {}
end

-- 添加金币
function mt:addGold(amount)
    self.gold = self.gold + amount
    -- 触发金币变化事件
    eventMgr.emit("player_gold_changed", {
        value = amount,
        total = self.gold,
        source = self
    })
    return self.gold
end

-- 消费金币
function mt:spendGold(amount)
    if self.gold >= amount then
        self.gold = self.gold - amount
        -- 触发金币变化事件
        eventMgr.emit("player_gold_changed", {
            value = -amount,
            total = self.gold,
            source = self
        })
        return true
    end
    return false
end

-- 初始化玩家卡组
function mt:initDeck()
    -- 添加初始卡牌
    print("初始化玩家卡组...")
    global.cardMgr:addCardToDeck("Strike")
    global.cardMgr:addCardToDeck("Strike")
    global.cardMgr:addCardToDeck("Strike")
    global.cardMgr:addCardToDeck("Defend")
    global.cardMgr:addCardToDeck("Defend")
    global.cardMgr:addCardToDeck("Defend")
    print("玩家卡组初始化完成，卡组大小: " .. #global.cardMgr:getDeck())
end

local Player = {}

function Player.new()
    local player = setmetatable({
        name = "Player",
        health = 100,
        maxHealth = 100,
        block = 0,
        strength = 0,
        dexterity = 0,
        deck = {},
        damageTaken = 0,
        cardsGenerated = 0,
        gold = 100, -- 初始金币
        camp = global.camp.player
    }, mt)

    base_util.inject_comp(player, attrComp)
    base_util.inject_comp(player, targetComp)
    
    -- 创建buff管理器
    player.buffMgr = buffMgr.new(player)

    global.player = player
    
    -- 初始化卡组
    player:initDeck()
    
    return player
end

return Player