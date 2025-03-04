local monsters = {
    -- Normal monsters
    normal = {
        {
            name = "Small Slime",
            health = 30,
            maxHealth = 30,
            attack = 5,
            intents = {
                {
                    name = "Attack",
                    description = "Deal 5 damage",
                    type = "attack",
                    value = 5,
                    trigger = "turn_start",
                    priority = 1
                },
                {
                    name = "Split",
                    description = "Heal 5 HP",
                    type = "heal",
                    value = 5,
                    trigger = "damage_taken",
                    triggerValue = 15,
                    priority = 2
                }
            }
        },
        {
            name = "Goblin Warrior",
            health = 40,
            maxHealth = 40,
            attack = 7,
            intents = {
                {
                    name = "Attack",
                    description = "Deal 7 damage",
                    type = "attack",
                    value = 7,
                    trigger = "turn_start",
                    priority = 1
                },
                {
                    name = "Defensive Stance",
                    description = "Gain 5 block",
                    type = "shield",
                    value = 5,
                    trigger = "cards_generated",
                    triggerValue = 3,
                    priority = 2
                }
            }
        }
    },
    -- Elite monsters
    elite = {
        {
            name = "Elite Slime King",
            health = 60,
            maxHealth = 60,
            attack = 8,
            intents = {
                {
                    name = "Strong Attack",
                    description = "Deal 8 damage",
                    type = "attack",
                    value = 8,
                    trigger = "turn_start",
                    priority = 1
                },
                {
                    name = "Split",
                    description = "Heal 10 HP",
                    type = "heal",
                    value = 10,
                    trigger = "damage_taken",
                    triggerValue = 20,
                    priority = 2
                },
                {
                    name = "Shield",
                    description = "Gain 8 block",
                    type = "shield",
                    value = 8,
                    trigger = "cards_generated",
                    triggerValue = 4,
                    priority = 3
                }
            }
        },
        {
            name = "Elite Goblin King",
            health = 70,
            maxHealth = 70,
            attack = 10,
            intents = {
                {
                    name = "Strong Attack",
                    description = "Deal 10 damage",
                    type = "attack",
                    value = 10,
                    trigger = "turn_start",
                    priority = 1
                },
                {
                    name = "Defensive Stance",
                    description = "Gain 10 block",
                    type = "shield",
                    value = 10,
                    trigger = "cards_generated",
                    triggerValue = 3,
                    priority = 2
                },
                {
                    name = "Rage",
                    description = "Increase attack by 5",
                    type = "buff_attack",
                    value = 5,
                    trigger = "damage_taken",
                    triggerValue = 25,
                    priority = 3
                }
            }
        }
    },
    -- Boss monsters
    boss = {
        {
            name = "Slime Emperor",
            health = 100,
            maxHealth = 100,
            attack = 12,
            intents = {
                {
                    name = "Strong Attack",
                    description = "Deal 12 damage",
                    type = "attack",
                    value = 12,
                    trigger = "turn_start",
                    priority = 1
                },
                {
                    name = "Split",
                    description = "Heal 15 HP",
                    type = "heal",
                    value = 15,
                    trigger = "damage_taken",
                    triggerValue = 30,
                    priority = 2
                },
                {
                    name = "Shield",
                    description = "Gain 15 block",
                    type = "shield",
                    value = 15,
                    trigger = "cards_generated",
                    triggerValue = 5,
                    priority = 3
                },
                {
                    name = "Rage",
                    description = "Increase attack by 8",
                    type = "buff_attack",
                    value = 8,
                    trigger = "damage_taken",
                    triggerValue = 50,
                    priority = 4
                }
            }
        }
    }
}

return monsters