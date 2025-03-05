local global = require "src.global"
local button = require "src.ui.button"

local mt = {}
mt.__index = mt
-- 状态变量

function mt:onRestartClick()
    global.stateMgr:changeState("map", { restart = true })
end

function mt:onQuitClick()
    love.event.quit()
end

function mt:load()
    -- 创建重新开始按钮
    self.restartButton = button.new("重新开始", 300, 300, 200, 50, self.onRestartClick)
    -- 创建退出按钮
    self.quitButton = button.new("退出游戏", 300, 400, 200, 50, self.onQuitClick)
end

function mt:update(dt)
    self.restartButton:update(dt)
    self.quitButton:update(dt)
end

function mt:draw()
    -- 绘制黑色背景
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    -- 绘制游戏结束文字
    love.graphics.setColor(1, 0, 0) -- 红色
    love.graphics.printf("游戏结束", 0, 150, love.graphics.getWidth(), "center")
    -- 绘制按钮
    love.graphics.setColor(1, 1, 1)
    self.restartButton:draw()
    self.quitButton:draw()
end

function mt:mousepressed(x, y, button)
    self.restartButton:mousepressed(x, y, button)
    self.quitButton:mousepressed(x, y, button)
end

local GameOver = {}

function GameOver.new()
    return setmetatable({
        restartButton = nil,
        quitButton = nil,
    }, mt)
end

return GameOver 