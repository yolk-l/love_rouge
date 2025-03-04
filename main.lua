local stateManager = require "src.utils.state_manager"

function love.load()
    -- 使用懒加载方式加载初始状态
    stateManager.changeState("start")
end

function love.update(dt)
    stateManager.update(dt)
end

function love.draw()
    stateManager.draw()
end

function love.mousepressed(x, y, button)
    stateManager.mousepressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    stateManager.mousemoved(x, y, dx, dy)
end

function love.mousereleased(x, y, button)
    stateManager.mousereleased(x, y, button)
end