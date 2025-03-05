local global = require "src.global"
local stateMgr = require "src.state_mgr"
local cardMgr = require "src.states.battle.card_mgr"
local battle = require "src.states.battle.battle"

function love.load()
    global.stateMgr = stateMgr.new()
    global.cardMgr = cardMgr.new()
    global.battle = battle.new()
    -- 使用懒加载方式加载初始状态
    for k,v in pairs(global.stateMgr.states) do
        print("Loading state", k, v)
    end
    global.stateMgr:changeState("start")
end

function love.update(dt)
    global.stateMgr:update(dt)
end

function love.draw()
    global.stateMgr:draw()
end

function love.mousepressed(x, y, button)
    global.stateMgr:mousepressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    global.stateMgr:mousemoved(x, y, dx, dy)
end

function love.mousereleased(x, y, button)
    global.stateMgr:mousereleased(x, y, button)
end