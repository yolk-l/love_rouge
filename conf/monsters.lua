local monsters = {
    -- Normal monsters
    normal = {
        {
            name = "Small Slime",
            health = 30,
            maxHealth = 30,
            strength = 1,
            intent_refs = {
                "basic_attack",
                "slime_split",
            }
        },
        {
            name = "Goblin Warrior",
            health = 40,
            maxHealth = 40,
            strength = 2,
            intent_refs = {
                "basic_attack",
                "defensive_stance",
            }
        },
        {
            name = "Counter Guardian",
            health = 35,
            maxHealth = 35,
            dexterity = 2,
            intent_refs = {
                "basic_attack",
                "apply_strength",
            }
        },
        {
            name = "Buff Master",
            health = 45,
            maxHealth = 45,
            strength = 1,
            dexterity = 1,
            intent_refs = {
                "basic_attack",
                "apply_strength",
                "weaken_enemy",
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
                "strong_attack",
                "elite_split",
                "basic_shield",
            }
        },
        {
            name = "Elite Goblin King",
            health = 70,
            maxHealth = 70,
            strength = 4,
            dexterity = 2,
            intent_refs = {
                "strong_attack",
                "strong_shield",
                "apply_dexterity",
            }
        },
        {
            name = "Elite Counter Guardian",
            health = 65,
            maxHealth = 65,
            intent_refs = {
                "strong_attack",
                "apply_strength",
                "strong_shield",
            }
        },
        {
            name = "Elite Buff Master",
            health = 75,
            maxHealth = 75,
            intent_refs = {
                "strong_attack",
                "apply_strength",
                "apply_weakness",
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
                "very_strong_attack",
                "boss_split",
                "strong_shield",
                "apply_dexterity",
            }
        },
        {
            name = "Master of Counters",
            health = 90,
            maxHealth = 90,
            intent_refs = {
                "strong_attack",
                "counter_attack",
                "strong_shield",
                "rage",
            }
        }
    }
}

return monsters