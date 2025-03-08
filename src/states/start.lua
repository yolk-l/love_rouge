local button = require "src.ui.button"
local global = require "src.global"
local player = require "src.entities.player"

local mt = {}
mt.__index = mt

function mt:onStartClick()
    global.stateMgr:changeState("map") -- 使用状态管理器切换状态
    global.player = player.new()
    global.charaterMgr:addCharacter(global.camp.player, global.player)
end

function mt:load()
    self.startButton = button.new("Start Game", 300, 200, 200, 50, self.onStartClick)
end

function mt:update(dt)
    self.startButton:update(dt)
end

function mt:draw()
    self.startButton:draw()
end

function mt:mousepressed(x, y, button)
    self.startButton:mousepressed(x, y, button)
end

local Start = {}

function Start.new()
    return setmetatable({
        startButton = nil,
    }, mt)
end

return Start