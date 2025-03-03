local stateManager = require "src.utils.state_manager"
local startState = require "src.states.start"
local mapState = require "src.states.map"
local battleState = require "src.states.battle"

function love.load()
    stateManager.register("start", startState)
    stateManager.register("map", mapState)
    stateManager.register("battle", battleState)
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