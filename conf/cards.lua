local cards = {
    -- Attack cards
    {
        name = "Strike",
        type = "attack",
        baseDamage = 6,
        description = "Deal 6 damage",
        comboEffect = {
            [2] = {damage = 12}, -- Double damage with 2 cards
            [3] = {damage = 18}, -- Triple damage with 3 cards
            [4] = {damage = 24}, -- Quadruple damage with 4 cards
            [5] = {damage = 30}  -- Quintuple damage with 5 cards
        }
    },
    {
        name = "Heavy Strike",
        type = "attack",
        baseDamage = 8,
        description = "Deal 8 damage",
        comboEffect = {
            [2] = {damage = 16},
            [3] = {damage = 24},
            [4] = {damage = 32},
            [5] = {damage = 40}
        }
    },
    -- Defense cards
    {
        name = "Defend",
        type = "defense",
        baseBlock = 5,
        description = "Gain 5 block",
        comboEffect = {
            [2] = {block = 10},
            [3] = {block = 15},
            [4] = {block = 20},
            [5] = {block = 25}
        }
    },
    {
        name = "Iron Armor",
        type = "defense",
        baseBlock = 8,
        description = "Gain 8 block",
        comboEffect = {
            [2] = {block = 16},
            [3] = {block = 24},
            [4] = {block = 32},
            [5] = {block = 40}
        }
    },
    -- Special cards
    {
        name = "Rage",
        type = "special",
        baseDamage = 4,
        baseBlock = 4,
        description = "Deal 4 damage, gain 4 block",
        comboEffect = {
            [2] = {damage = 8, block = 8},
            [3] = {damage = 12, block = 12},
            [4] = {damage = 16, block = 16},
            [5] = {damage = 20, block = 20}
        }
    },
    {
        name = "Battle Cry",
        type = "special",
        baseDamage = 3,
        baseBlock = 3,
        description = "Deal 3 damage, gain 3 block",
        comboEffect = {
            [2] = {damage = 6, block = 6},
            [3] = {damage = 9, block = 9},
            [4] = {damage = 12, block = 12},
            [5] = {damage = 15, block = 15}
        }
    }
}

return cards