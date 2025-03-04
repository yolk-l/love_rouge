local stateManager = require "src.utils.state_manager"
local button = require "src.ui.button"

local m = {}

-- 状态变量
local restartButton
local quitButton

function m.onRestartClick()
    stateManager.changeState("map", { restart = true })
end

function m.onQuitClick()
    love.event.quit()
end

function m.load()
    -- 创建重新开始按钮
    restartButton = button.new("重新开始", 300, 300, 200, 50, m.onRestartClick)
    -- 创建退出按钮
    quitButton = button.new("退出游戏", 300, 400, 200, 50, m.onQuitClick)
end

function m.update(dt)
    restartButton:update(dt)
    quitButton:update(dt)
end

function m.draw()
    -- 绘制黑色背景
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- 绘制游戏结束文字
    love.graphics.setColor(1, 0, 0) -- 红色
    love.graphics.printf("游戏结束", 0, 150, love.graphics.getWidth(), "center")
    
    -- 绘制按钮
    love.graphics.setColor(1, 1, 1)
    restartButton:draw()
    quitButton:draw()
end

function m.mousepressed(x, y, button)
    restartButton:mousepressed(x, y, button)
    quitButton:mousepressed(x, y, button)
end

return m 