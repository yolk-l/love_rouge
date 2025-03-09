-- 小史莱姆的意图
small_slime = {
    -- 攻击意图
    attack = {
        weight = 70,
        intent_id = "attack",
        args = { arg1 = 5 }
    },
    -- 防御意图
    defend = {
        weight = 20,
        intent_id = "defend",
        args = { arg1 = 5 }
    },
    -- 增加力量意图
    buff = {
        weight = 10,
        intent_id = "apply_strength",
        args = { arg1 = 1 }
    }
},

-- 哥布林战士的意图
goblin_warrior = {
    -- 攻击意图
    attack = {
        weight = 60,
        intent_id = "attack",
        args = { arg1 = 7 }
    },
    -- 防御意图
    defend = {
        weight = 20,
        intent_id = "defend",
        args = { arg1 = 6 }
    },
    -- 增加力量意图
    buff = {
        weight = 20,
        intent_id = "apply_strength",
        args = { arg1 = 2 }
    }
},

-- 反击守卫的意图
counter_guardian = {
    -- 攻击意图
    attack = {
        weight = 40,
        intent_id = "attack",
        args = { arg1 = 6 }
    },
    -- 防御意图
    defend = {
        weight = 30,
        intent_id = "defend",
        args = { arg1 = 8 }
    },
    -- 增加敏捷意图
    buff = {
        weight = 30,
        intent_id = "apply_dexterity",
        args = { arg1 = 2 }
    }
},

-- Buff大师的意图
buff_master = {
    -- 攻击意图
    attack = {
        weight = 30,
        intent_id = "attack",
        args = { arg1 = 4 }
    },
    -- 防御意图
    defend = {
        weight = 20,
        intent_id = "defend",
        args = { arg1 = 5 }
    },
    -- 增加力量意图
    buff_strength = {
        weight = 25,
        intent_id = "apply_strength",
        args = { arg1 = 1 }
    },
    -- 增加敏捷意图
    buff_dexterity = {
        weight = 25,
        intent_id = "apply_dexterity",
        args = { arg1 = 1 }
    }
},

-- 精英史莱姆王的意图
elite_slime_king = {
    -- 攻击意图
    attack = {
        weight = 50,
        intent_id = "attack",
        args = { arg1 = 10 }
    },
    -- 防御意图
    defend = {
        weight = 20,
        intent_id = "defend",
        args = { arg1 = 8 }
    },
    -- 增加力量意图
    buff = {
        weight = 30,
        intent_id = "apply_strength",
        args = { arg1 = 3 }
    }
},

-- 精英哥布林王的意图
elite_goblin_king = {
    -- 攻击意图
    attack = {
        weight = 40,
        intent_id = "attack",
        args = { arg1 = 12 }
    },
    -- 防御意图
    defend = {
        weight = 20,
        intent_id = "defend",
        args = { arg1 = 10 }
    },
    -- 增加力量意图
    buff_strength = {
        weight = 20,
        intent_id = "apply_strength",
        args = { arg1 = 2 }
    },
    -- 增加敏捷意图
    buff_dexterity = {
        weight = 20,
        intent_id = "apply_dexterity",
        args = { arg1 = 2 }
    }
} 