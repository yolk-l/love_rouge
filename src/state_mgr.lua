local battle = require "src.states.battle.battle"
local map = require "src.states.map"
local gameOver = require "src.states.game_over"
local start = require "src.states.start"

local mt = {}
mt.__index = mt


function mt:register(name, state)
    self.states[name] = state
end

function mt:changeState(newState, params)
    print("Changing state to: " .. newState) -- 调试输出
    -- 懒加载状态
    if not self.states[newState] then
        if newState == "battle" then
            self.states.battle = battle.new()
        elseif newState == "map" then
            self.states.map = map.new()
        elseif newState == "game_over" then
            self.states.game_over = gameOver.new()
        elseif newState == "start" then
            self.states.start = start.new()
        end
    end
    if self.currentState and self.states[self.currentState].exit then
        self.states[self.currentState]:exit()
    end
    self.currentState = newState
    if self.states[self.currentState].load then
        self.states[self.currentState]:load(params)
    end
end

function mt:update(dt)
    if self.currentState and self.states[self.currentState].update then
        self.states[self.currentState]:update(dt)
    end
end

function mt:draw()
    if self.currentState and self.states[self.currentState].draw then
        self.states[self.currentState]:draw()
    end
end

function mt:mousepressed(x, y, button)
    if self.currentState and self.states[self.currentState].mousepressed then
        self.states[self.currentState]:mousepressed(x, y, button)
    end
end

function mt:mousemoved(x, y, dx, dy)
    if self.currentState and self.states[self.currentState].mousemoved then
        self.states[self.currentState]:mousemoved(x, y, dx, dy)
    end
end

function mt:mousereleased(x, y, button)
    if self.currentState and self.states[self.currentState].mousereleased then
        self.states[self.currentState]:mousereleased(x, y, button)
    end
end

local stateMgr = {}

function stateMgr.new()
    return setmetatable({
        states = {},
        currentState = nil
    }, mt)
end

return stateMgr