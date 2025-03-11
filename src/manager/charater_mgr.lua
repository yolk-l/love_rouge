local player = require "src.entities.player"
local global = require "src.global"
local mt = {}
mt.__index = mt

function mt:getCharacter(camp)
    return self.characters[camp]
end

function mt:addCharacter(camp, character)
    table.insert(self.characters[camp], character)
    -- 添加到ID映射表
    self.characterIdMap[character:getId()] = character
end

function mt:removeCharacter(camp, character)
    if not character then
        -- 移除所有角色并清除ID映射
        for _, char in ipairs(self.characters[camp]) do
            self.characterIdMap[char:getId()] = nil
        end
        self.characters[camp] = {}
        return
    end
    
    -- 从ID映射表中移除
    self.characterIdMap[character:getId()] = nil
    
    -- 从阵营列表中移除
    for i, char in ipairs(self.characters[camp]) do
        if char == character then
            table.remove(self.characters[camp], i)
            break
        end
    end
end

-- 通过ID获取角色
function mt:getCharacterById(id)
    return self.characterIdMap[id]
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

local charaterMgr = {}

function charaterMgr.new()
    local self = setmetatable({}, mt)
    self.characters = {}
    self.characters[global.camp.player] = {}
    self.characters[global.camp.monster] = {}
    self.characterIdMap = {} -- ID到角色的映射
    return self
end

return charaterMgr

