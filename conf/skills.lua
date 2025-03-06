local skills = {
    Attack = {
        name = "Attack",
        description = "Deal 5 damage",
        type = "attack",
        value = 5,
        trigger = "turn_start",
        priority = 1
    },
    Split = {
        name = "Split",
        description = "Heal 5 HP",
        type = "heal",
        value = 5,
        trigger = "damage_taken",
        triggerValue = 15,
        priority = 2
    },
}

return skills