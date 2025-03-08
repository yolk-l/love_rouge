-- 全局变量管理

-- 状态变量
local global = {}

global.cardMgr = nil
global.stateMgr = nil
global.battle = nil
global.charaterMgr = nil
global.player = nil
global.eventMgr = require "src.manager.event_mgr"

global.camp = {
    player = 1,
    monster = 2,
}

global.battle_result = {
    player_win = 1,
    monster_win = 2,
}

-- 游戏事件常量
global.events = {
    -- 战斗相关事件
    BATTLE_START = "battle_start",
    BATTLE_VICTORY = "battle_victory",
    BATTLE_DEFEAT = "battle_defeat",
    
    -- 卡牌相关事件
    CARDS_GENERATED = "cards_generated",
    CARDS_EXECUTED = "cards_executed",
    CARDS_FINISHED = "cards_finished",
    PLAYER_CARDS_GENERATED_COUNT = "player_cards_generated_count",
    
    -- 角色相关事件
    CHARACTER_DAMAGED = "character_damaged",
    CHARACTER_HEALED = "character_healed",
    CHARACTER_BLOCKED = "character_blocked",
    CHARACTER_DEFEATED = "character_defeated"
}

return global