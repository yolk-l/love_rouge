local intents = require "conf.intents"

local monsters = {
    -- Normal monsters
    normal = {
        {
            name = "Small Slime",
            health = 30,
            maxHealth = 30,
            strength = 1,
            intent_refs = {
                { intent_type = "attack", intent_id = "basic_attack" },
                { intent_type = "healing", intent_id = "slime_split" }
            }
        },
        {
            name = "Goblin Warrior",
            health = 40,
            maxHealth = 40,
            strength = 2,
            intent_refs = {
                { intent_type = "attack", intent_id = "basic_attack", args_override = { arg1 = 7, arg2 = 2 } },
                { intent_type = "defense", intent_id = "defensive_stance" }
            }
        },
        {
            name = "Counter Guardian",
            health = 35,
            maxHealth = 35,
            dexterity = 2,
            intent_refs = {
                { intent_type = "attack", intent_id = "basic_attack", args_override = { arg1 = 4, arg2 = 3 } },
                { intent_type = "buff", intent_id = "counter_attack", args_override = { arg1 = 5 } }
            }
        },
        {
            name = "Buff Master",
            health = 45,
            maxHealth = 45,
            strength = 1,
            dexterity = 1,
            intent_refs = {
                { intent_type = "attack", intent_id = "basic_attack", args_override = { arg1 = 5, arg2 = 3 } },
                { intent_type = "buff", intent_id = "apply_strength" },
                { intent_type = "buff", intent_id = "apply_weakness" }
            }
        }
    },
    -- Elite monsters
    elite = {
        {
            name = "Elite Slime King",
            health = 60,
            maxHealth = 60,
            strength = 3,
            intent_refs = {
                { intent_type = "attack", intent_id = "strong_attack" },
                { intent_type = "healing", intent_id = "elite_split" },
                { intent_type = "defense", intent_id = "basic_shield", args_override = { arg1 = 8 } }
            }
        },
        {
            name = "Elite Goblin King",
            health = 70,
            maxHealth = 70,
            strength = 4,
            dexterity = 2,
            intent_refs = {
                { intent_type = "attack", intent_id = "strong_attack", args_override = { arg1 = 10, arg2 = 3 } },
                { intent_type = "defense", intent_id = "strong_shield" },
                { intent_type = "buff", intent_id = "rage" }
            }
        },
        {
            name = "Elite Counter Guardian",
            health = 65,
            maxHealth = 65,
            intent_refs = {
                { intent_type = "attack", intent_id = "strong_attack", args_override = { arg1 = 8, arg2 = 4 } },
                { intent_type = "buff", intent_id = "counter_attack", args_override = { arg1 = 8 } },
                { intent_type = "defense", intent_id = "strong_shield" }
            }
        },
        {
            name = "Elite Buff Master",
            health = 75,
            maxHealth = 75,
            intent_refs = {
                { intent_type = "attack", intent_id = "strong_attack", args_override = { arg1 = 9, arg2 = 3 } },
                { intent_type = "buff", intent_id = "apply_strength", args_override = { arg1 = 3 } },
                { intent_type = "buff", intent_id = "apply_weakness", args_override = { arg1 = 3 } }
            }
        }
    },
    -- Boss monsters
    boss = {
        {
            name = "Slime Emperor",
            health = 100,
            maxHealth = 100,
            intent_refs = {
                { intent_type = "attack", intent_id = "very_strong_attack" },
                { intent_type = "healing", intent_id = "boss_split" },
                { intent_type = "defense", intent_id = "strong_shield", args_override = { arg1 = 15 } },
                { intent_type = "buff", intent_id = "boss_rage" }
            }
        },
        {
            name = "Master of Counters",
            health = 90,
            maxHealth = 90,
            intent_refs = {
                { intent_type = "attack", intent_id = "strong_attack", args_override = { arg1 = 10, arg2 = 4 } },
                { intent_type = "buff", intent_id = "counter_attack", args_override = { arg1 = 12 } },
                { intent_type = "defense", intent_id = "strong_shield", args_override = { arg1 = 12 } },
                { intent_type = "buff", intent_id = "rage", args_override = { arg1 = 6, arg2 = 15 } }
            }
        }
    }
}

return monsters