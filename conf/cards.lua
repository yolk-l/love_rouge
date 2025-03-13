local cards = {
    -- Attack cards
    Strike = {
        name = "Strike",
        type = "attack",
        -- 乘法增长
        args = { arg1 = 6 },
        effect_list = {
            {effect_type ="damage", effect_target = "enemy", effect_args = {"arg1"} },
        },
        description = "[arg1] 伤害",
        comboEffect = {
            [2] = {damage = {arg1 = 12}},
            [3] = {damage = {arg1 = 18}},
            [4] = {damage = {arg1 = 24}},
            [5] = {damage = {arg1 = 30}}
        }
    },
    ComboStrike = {
        name = "ComboStrike",
        type = "attack",
        -- 指数增长
        args = { arg1 = 4 },
        effect_list = {
            {effect_type ="damage", effect_target = "enemy", effect_args = {"arg1"} },
        },
        description = "[arg1] 伤害",
        comboEffect = {
            [2] = {damage = {arg1 = 8}},
            [3] = {damage = {arg1 = 16}},
            [4] = {damage = {arg1 = 32}},
            [5] = {damage = {arg1 = 64}}
        }
    },
    -- Defense cards
    Defend = {
        name = "Defend",
        type = "defense",
        -- 乘法增长
        args = { arg1 = 5 },
        effect_list = {
            {effect_type ="block", effect_target = "self", effect_args = {"arg1"} },
        },
        description = "获得 [arg1] 点格挡",
        comboEffect = {
            [2] = {block = {arg1 = 10}},
            [3] = {block = {arg1 = 15}},
            [4] = {block = {arg1 = 20}},
            [5] = {block = {arg1 = 25}}
        }
    },
    IronArmor = {
        name = "Iron Armor",
        type = "defense",
        -- 指数增长
        args = { arg1 = 4 },
        effect_list = {
            {effect_type ="block", effect_target = "self", effect_args = {"arg1"} },
        },
        description = "获得 [arg1] 点格挡",
        comboEffect = {
            [2] = {block = {arg1 = 8}},
            [3] = {block = {arg1 = 16}},
            [4] = {block = {arg1 = 32}},
            [5] = {block = {arg1 = 64}}
        }
    },
    -- Buff cards
    Strengthen = {
        name = "Strengthen",
        type = "skill",
        args = { arg1 = 2 },
        effect_list = {
            {
                effect_type = "add_strength",
                effect_target = "self",
                effect_args = {"arg1"}
            },
        },
        description = "获得 [arg1] 点力量",
        comboEffect = {
            [2] = {add_strength = {arg1 = 5}},
            [3] = {add_strength = {arg1 = 8}},
            [4] = {add_strength = {arg1 = 11}},
            [5] = {add_strength = {arg1 = 14}}
        }
    },
    Agility = {
        name = "Agility",
        type = "skill",
        args = { arg1 = 2 },
        effect_list = {
            {
                effect_type = "add_dexterity",
                effect_target = "self",
                effect_args = {"arg1"}
            },
        },
        description = "获得 [arg1] 点敏捷",
        comboEffect = {
            [2] = {add_dexterity = {arg1 = 5}},
            [3] = {add_dexterity = {arg1 = 8}},
            [4] = {add_dexterity = {arg1 = 11}},
            [5] = {add_dexterity = {arg1 = 14}}
        }
    },
    Weaken = {
        name = "Weaken",
        type = "skill",
        args = { arg1 = 2 },
        effect_list = {
            {
                effect_type = "add_strength",
                effect_target = "enemy",
                effect_args = {"-arg1"}
            },
        },
        description = "降低敌人 [arg1] 点力量",
        comboEffect = {
            [2] = {add_strength = {arg1 = -4}},
            [3] = {add_strength = {arg1 = -6}},
            [4] = {add_strength = {arg1 = -8}},
            [5] = {add_strength = {arg1 = -10}}
        }
    },
}

return cards