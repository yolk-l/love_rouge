local cards = {
    -- Attack cards
    Strike = {
        name = "Strike",
        type = "attack",
        args = { arg1 = 6 },
        effect_list = {
            {effect_type ="damage", effect_target = "enemy", effect_args = {"arg1"} },
        },
        description = "Deal [arg1] damage",
        comboEffect = {
            [2] = {arg1 = 12},
            [3] = {arg1 = 18},
            [4] = {arg1 = 24},
            [5] = {arg1 = 30}
        }
    },
    HeavyStrike = {
        name = "Heavy Strike",
        type = "attack",
        args = { arg1 = 8 },
        effect_list = {
            {effect_type ="damage", effect_target = "enemy", effect_args = {"arg1"} },
        },
        description = "Deal [arg1] damage",
        comboEffect = {
            [2] = {arg1 = 16},
            [3] = {arg1 = 24},
            [4] = {arg1 = 32},
            [5] = {arg1 = 40}
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
        description = "Gain [arg1] block",
        comboEffect = {
            [2] = {arg1 = 10},
            [3] = {arg1 = 15},
            [4] = {arg1 = 20},
            [5] = {arg1 = 25}
        }
    },
    IronArmor = {
        name = "Iron Armor",
        type = "defense",
        args = { arg1 = 8 },
        effect_list = {
            {effect_type ="block", effect_target = "self", effect_args = {"arg1"} },
        },
        description = "Gain [arg1] block",
        comboEffect = {
            [2] = {arg1 = 16},
            [3] = {arg1 = 24},
            [4] = {arg1 = 32},
            [5] = {arg1 = 40}
        }
    },
    -- Special cards
    Rage = {
        name = "Rage",
        type = "special",
        args = { arg1 = 4, arg2 = 4 },
        effect_list = {
            {effect_type ="damage", effect_target = "enemy", effect_args = {"arg1"} },
            {effect_type ="block", effect_target = "self", effect_args = {"arg2"} },
        },
        description = "Deal [arg1] damage, gain [arg2] block",
        comboEffect = {
            [2] = {arg1 = 8, arg2 = 8},
            [3] = {arg1 = 12, arg2 = 12},
            [4] = {arg1 = 16, arg2 = 16},
            [5] = {arg1 = 20, arg2 = 20}
        }
    },
    BattleCry = {
        name = "Battle Cry",
        type = "special",
        args = { arg1 = 3, arg2 = 3 },
        effect_list = {
            {effect_type ="damage", effect_target = "enemy", effect_args = {"arg1"} },
            {effect_type ="block", effect_target = "self", effect_args = {"arg2"} },
        },
        description = "Deal [arg1] damage, gain [arg2] block",
        comboEffect = {
            [2] = {arg1 = 6, arg2 = 6},
            [3] = {arg1 = 9, arg2 = 9},
            [4] = {arg1 = 12, arg2 = 12},
            [5] = {arg1 = 15, arg2 = 15}
        }
    }
}

return cards