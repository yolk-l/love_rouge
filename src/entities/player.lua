local base_util = require "src.utils.base_util"
local attrComp = require "src.entities.component.attr_comp"
local targetComp = require "src.entities.component.target_comp"
local eventMgr = require "src.manager.event_mgr"
local global = require "src.global"
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

function mt:on_turn_start()
    -- 触发玩家回合开始事件
    eventMgr.emit("player_turn_start", {
        source = self
    })
end

function mt:on_turn_end()
    -- 触发玩家回合结束事件
    eventMgr.emit("player_turn_end", {
        source = self
    })
end

function mt:draw()
    -- Draw player here
end

local Player = {}

function Player.new()
    local player = setmetatable({
        health = 100,
        maxHealth = 100,
        block = 0,
        deck = {},
        damageTaken = 0,
        cardsGenerated = 0,
        camp = global.camp.player,
    }, mt)

    base_util.inject_comp(player, attrComp)
    base_util.inject_comp(player, targetComp)
    
    -- 设置全局玩家引用
    global.player = player
    
    return player
end

return Player