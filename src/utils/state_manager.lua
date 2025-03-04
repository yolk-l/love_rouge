local stateManager = {}

local states = {}
local currentState

function stateManager.register(name, state)
    states[name] = state
end

function stateManager.changeState(newState, params)
    print("Changing state to: " .. newState) -- 调试输出
    
    -- 懒加载状态
    if not states[newState] then
        if newState == "battle" then
            states.battle = require "src.states.battle.battle"
        elseif newState == "map" then
            states.map = require "src.states.map"
        elseif newState == "game_over" then
            states.game_over = require "src.states.game_over"
        elseif newState == "start" then
            states.start = require "src.states.start"
        end
    end
    
    if currentState and states[currentState].exit then
        states[currentState].exit()
    end
    currentState = newState
    if states[currentState].load then
        states[currentState].load(params)
    end
end

function stateManager.update(dt)
    if currentState and states[currentState].update then
        states[currentState].update(dt)
    end
end

function stateManager.draw()
    if currentState and states[currentState].draw then
        states[currentState].draw()
    end
end

function stateManager.mousepressed(x, y, button)
    if currentState and states[currentState].mousepressed then
        states[currentState].mousepressed(x, y, button)
    end
end

function stateManager.mousemoved(x, y, dx, dy)
    if currentState and states[currentState].mousemoved then
        states[currentState].mousemoved(x, y, dx, dy)
    end
end

function stateManager.mousereleased(x, y, button)
    if currentState and states[currentState].mousereleased then
        states[currentState].mousereleased(x, y, button)
    end
end

return stateManager