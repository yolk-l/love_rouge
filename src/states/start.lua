local button = require "src.ui.button"
local stateManager = require "src.utils.state_manager"

local startButton

local M = {}

function M.onStartClick()
    stateManager.changeState("map") -- 使用状态管理器切换状态
end

function M.load()
    startButton = button.new("Start Game", 300, 200, 200, 50, M.onStartClick)
end

function M.update(dt)
    startButton:update(dt)
end

function M.draw()
    startButton:draw()
end

function M.mousepressed(x, y, button)
    startButton:mousepressed(x, y, button)
end

return M