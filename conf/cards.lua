local cards = {
    -- Attack cards
    Strike = {
        name = "Strike",
        type = "attack",
        args = { arg1 = 6 },
        effect_list = {
            {effect_type ="damage", effect_target = "enemy", effect_args = {"arg1"} },
        },
        description = "Deal [arg1] 伤害",
        comboEffect = {
            [2] = {damage = {arg1 = 12}},
            [3] = {damage = {arg1 = 18}},
            [4] = {damage = {arg1 = 24}},
            [5] = {damage = {arg1 = 30}}
        }
    },
    HeavyStrike = {
        name = "Heavy Strike",
        type = "attack",
        args = { arg1 = 8 },
        effect_list = {
            {effect_type ="damage", effect_target = "enemy", effect_args = {"arg1"} },
        },
        description = "造成 [arg1] 伤害",
        comboEffect = {
            [2] = {damage = {arg1 = 16}},
            [3] = {damage = {arg1 = 24}},
            [4] = {damage = {arg1 = 32}},
            [5] = {damage = {arg1 = 40}}
        }
    },
    -- Defense cards
    Defend = {
        name = "Defend",
        type = "defense",
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
        args = { arg1 = 8 },
        effect_list = {
            {effect_type ="block", effect_target = "self", effect_args = {"arg1"} },
        },
        description = "获得 [arg1] 点格挡",
        comboEffect = {
            [2] = {block = {arg1 = 16}},
            [3] = {block = {arg1 = 24}},
            [4] = {block = {arg1 = 32}},
            [5] = {block = {arg1 = 40}}
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
            [2] = {add_strength = {arg1 = 3}},
            [3] = {add_strength = {arg1 = 4}},
            [4] = {add_strength = {arg1 = 5}},
            [5] = {add_strength = {arg1 = 6}}
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
            [2] = {add_dexterity = {arg1 = 3}},
            [3] = {add_dexterity = {arg1 = 4}},
            [4] = {add_dexterity = {arg1 = 5}},
            [5] = {add_dexterity = {arg1 = 6}}
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
            [2] = {add_strength = {arg1 = 3}},
            [3] = {add_strength = {arg1 = 4}},
            [4] = {add_strength = {arg1 = 5}},
            [5] = {add_strength = {arg1 = 6}}
        }
    },
    Expose = {
        name = "Expose",
        type = "skill",
        args = { arg1 = 50 },
        effect_list = {
            {
                effect_type = "add_buff", 
                effect_target = "enemy", 
                effect_args = {
                    {
                        buff_type = "negative",
                        buff_id = "vulnerable",
                        args_override = { arg1 = 50 }
                    }
                }
            },
        },
        description = "敌人在2回合内受到的伤害增加 [arg1]%",
        comboEffect = {
            [2] = {arg1 = 75},
            [3] = {arg1 = 100},
            [4] = {arg1 = 125},
            [5] = {arg1 = 150}
        }
    },
    Poison = {
        name = "Poison",
        type = "skill",
        args = { arg1 = 3 },
        effect_list = {
            {
                effect_type = "add_buff", 
                effect_target = "enemy", 
                effect_args = {
                    {
                        buff_type = "negative",
                        buff_id = "poison",
                        args_override = { arg1 = 3 }
                    }
                }
            },
        },
        description = "给予中毒效果，3回合内每回合结束时造成 [arg1] 点伤害",
        comboEffect = {
            [2] = {arg1 = 5},
            [3] = {arg1 = 7},
            [4] = {arg1 = 9},
            [5] = {arg1 = 12}
        }
    }
}

return cards