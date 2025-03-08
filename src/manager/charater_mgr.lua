local player = require "src.entities.player"
local global = require "src.global"
local mt = {}
mt.__index = mt

function mt:getCharacter(camp)
    return self.characters[camp]
end

function mt:addCharacter(camp, character)
    table.insert(self.characters[camp], character)
end

function mt:removeCharacter(camp, character)
    table.remove(self.characters[camp], character)
end

function mt:getEnemiesByCamp(camp)
    if camp == global.camp.player then
        return self.characters[global.camp.monster]
    else
        return self.characters[global.camp.player]
    end
end

function mt:is_battle_over()
    for _, character in ipairs(self.characters[global.camp.player]) do
        if character:is_defeated() then
            return global.battle_result.monster_win
        end
    end

    local all_monster_dead = true
    for _, character in ipairs(self.characters[global.camp.monster]) do
        if not character:is_defeated() then
            all_monster_dead = false
        end
    end
    if all_monster_dead then
        return global.battle_result.player_win
    end
    return false
end

function mt:on_turn_end()
    -- 处理怪物回合结束
    for _, character in ipairs(self.characters[global.camp.monster]) do
        character:on_turn_end()
    end
    
    -- 处理玩家回合结束
    for _, character in ipairs(self.characters[global.camp.player]) do
        character:on_turn_end()
    end
end

function mt:on_turn_start()
    for _, character in ipairs(self.characters[global.camp.player]) do
        character:on_turn_start()
    end
end

local charaterMgr = {}

function charaterMgr.new()
    local self = setmetatable({}, mt)
    self.characters = {}
    self.characters[global.camp.player] = {}
    self.characters[global.camp.monster] = {}
    return self
end

return charaterMgr

