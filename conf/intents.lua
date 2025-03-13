-- 怪物意图配置文件
local intents = {
    -- 攻击类意图
    basic_attack = {
        name = "Attack",
        description = "Deal [arg1] damage after taking [arg2] damage",
        type = "attack",
        args = { arg1 = 6, arg2 = 1 },
        effect_list = {
            {effect_type ="damage", effect_target = "enemy", effect_args = {"arg1"} },
        },
        trigger = {
            event = "cards_generated",
            required_count = "arg2",
            one_time = true,
        },
        priority = 1
    },
    strong_attack = {
        name = "Strong Attack",
        description = "Deal [arg1] damage after taking [arg2] damage",
        type = "attack",
        args = { arg1 = 12, arg2 = 1 },
        effect_list = {
            {effect_type ="damage", effect_target = "enemy", effect_args = {"arg1"} },
        },
        trigger = {
            event = "cards_generated",
            required_count = "arg2",
            one_time = true,
        },
        priority = 1
    },
    very_strong_attack = {
        name = "Very Strong Attack",
        description = "Deal [arg1] damage after taking [arg2] damage",
        type = "attack",
        args = { arg1 = 18, arg2 = 1 },
        effect_list = {
            {effect_type ="damage", effect_target = "enemy", effect_args = {"arg1"} },
        },
        trigger = {
            event = "cards_generated",
            required_count = "arg2",
            one_time = true,
        },
        priority = 1
    },

-- 防御类意图
    basic_shield = {
        name = "Shield",
        description = "Gain [arg1] block",
        type = "shield",
        args = { arg1 = 5 },
        effect_list = {
            {effect_type ="block", effect_target = "self", effect_args = {"arg1"} },
        },
        trigger = {
            event = "cards_finished",
            required_count = 1,
            one_time = true
        },
        priority = 2
    },
    strong_shield = {
        name = "Strong Shield",
        description = "Gain [arg1] block",
        type = "shield",
        args = { arg1 = 10 },
        effect_list = {
            {effect_type ="block", effect_target = "self", effect_args = {"arg1"} },
        },
        trigger = {
            event = "cards_finished",
            required_count = 1,
            one_time = true
        },
        priority = 2
    },
    defensive_stance = {
        name = "Defensive Stance",
        description = "Gain [arg1] block",
        type = "shield",
        args = { arg1 = 18 },
        effect_list = {
            {effect_type ="block", effect_target = "self", effect_args = {"arg1"} },
        },
        trigger = {
            event = "cards_finished",
            required_count = 1,
            one_time = true
        },
        priority = 2
    },

-- 治疗类意图
    slime_split = {
        name = "Split",
        description = "Heal [arg1] HP after taking [arg2] damage",
        type = "heal",
        args = { arg1 = 5, arg2 = 3 },
        effect_list = {
            {effect_type ="heal", effect_target = "self", effect_args = {"arg1"} },
        },
        trigger = {
            event = "character_damaged",
            required_count = "arg2",
            one_time = true,
            check_condition = "self_damaged" -- 只有怪物自身受到伤害时才触发
        },
        priority = 2
    },
    elite_split = {
        name = "Elite Split",
        description = "Heal [arg1] HP after taking [arg2] damage",
        type = "heal",
        args = { arg1 = 10, arg2 = 3 },
        effect_list = {
            {effect_type ="heal", effect_target = "self", effect_args = {"arg1"} },
        },
        trigger = {
            event = "character_damaged",
            required_count = "arg2",
            one_time = true,
            check_condition = "self_damaged" -- 只有怪物自身受到伤害时才触发
        },
        priority = 2
    },
    boss_split = {
        name = "Boss Split",
        description = "Heal [arg1] HP after taking [arg2] damage",
        type = "heal",
        args = { arg1 = 15, arg2 = 3 },
        effect_list = {
            {effect_type ="heal", effect_target = "self", effect_args = {"arg1"} },
        },
        trigger = {
            event = "character_damaged",
            required_count = "arg2",
            one_time = true,
            check_condition = "self_damaged" -- 只有怪物自身受到伤害时才触发
        },
        priority = 2
    },
    -- 添加buff的意图
    apply_strength = {
        name = "Empower",
        description = "Gain [arg1] Strength",
        type = "buff",
        args = { arg1 = 2 },
        effect_list = {
            {
                effect_type = "add_strength",
                effect_target = "self",
                effect_args = {"arg1"}
            }
        },
        trigger = {
            event = "character_damaged",
            required_count = 3,
            one_time = true,
            check_condition = "self_damaged" -- 只有怪物自身受到伤害时才触发
        },
        priority = 2
    },
    apply_dexterity = {
        name = "Defensive Stance",
        description = "Gain [arg1] Dexterity",
        type = "buff",
        args = { arg1 = 2 },
        effect_list = {
            {
                effect_type = "add_dexterity",
                effect_target = "self",
                effect_args = {"arg1"}
            }
        },
        trigger = {
            event = "cards_finished",
            required_count = 1,
            one_time = true
        },
        priority = 2
    },

    weaken_enemy = {
        name = "Weaken",
        description = "Reduce enemy's Strength by [arg1]",
        type = "debuff",
        args = { arg1 = 2 },
        effect_list = {
            {
                effect_type = "add_strength",
                effect_target = "enemy",
                effect_args = {"-arg1"}
            }
        },
        trigger = {
            event = "cards_finished",
            required_count = 1,
            one_time = true
        },
        priority = 2
    }
}

return intents