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
                    description = "Deal [arg1] damage",
                    type = "attack",
                    args = { arg1 = 5 },
                    effect_list = {
                        {effect_type ="damage", effect_target = "enemy", effect_args = {"arg1"} },
                    },
                    trigger =  {
                        {trigger_type = "turn_start", trigger_args = {} },
                    },
                    priority = 1
                },
                {
                    name = "Split",
                    description = "Heal [arg1] HP. After [arg2] damage taken",
                    type = "heal",
                    args = { arg1 = 5, arg2 = 15 },
                    effect_list = {
                        {effect_type ="heal", effect_target = "self", effect_args = {"arg1"} },
                    },
                    trigger =  {
                        {trigger_type = "damage_taken", trigger_args = {"arg2"} },
                    },
                    priority = 2
                },
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
                    description = "Deal [arg1] damage",
                    type = "attack",
                    args = { arg1 = 7 },
                    effect_list = {
                        {effect_type ="damage", effect_target = "enemy", effect_args = {"arg1"} },
                    },
                    trigger =  {
                        {trigger_type = "turn_start", trigger_args = {} },
                    },
                    priority = 1
                },
                {
                    name = "Defensive Stance",
                    description = "Gain [arg1] block",
                    type = "shield",
                    args = { arg1 = 5 },
                    effect_list = {
                        {effect_type ="block", effect_target = "self", effect_args = {"arg1"} },
                    },
                    trigger =  {
                        {trigger_type = "cards_generated", trigger_args = {} },
                    },
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
                    description = "Deal [arg1] damage",
                    type = "attack",
                    args = { arg1 = 8 },
                    effect_list = {
                        {effect_type ="damage", effect_target = "enemy", effect_args = {"arg1"} },
                    },
                    trigger =  {
                        {trigger_type = "turn_start", trigger_args = {} },
                    },
                    priority = 1
                },
                {
                    name = "Split",
                    description = "Heal [arg1] HP. After [arg2] damage taken",
                    type = "heal",
                    args = { arg1 = 10, arg2 = 20 },
                    effect_list = {
                        {effect_type ="heal", effect_target = "self", effect_args = {"arg1"} },
                    },
                    trigger =  {
                        {trigger_type = "damage_taken", trigger_args = {"arg2"} },
                    },
                    priority = 2
                },
                {
                    name = "Shield",
                    description = "Gain [arg1] block",
                    type = "shield",
                    args = { arg1 = 8 },
                    effect_list = {
                        {effect_type ="block", effect_target = "self", effect_args = {"arg1"} },
                    },
                    trigger =  {
                        {trigger_type = "cards_generated", trigger_args = {} },
                    },
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
                    description = "Deal [arg1] damage",
                    type = "attack",
                    args = { arg1 = 10 },
                    effect_list = {
                        {effect_type ="damage", effect_target = "enemy", effect_args = {"arg1"} },
                    },
                    trigger =  {
                        {trigger_type = "turn_start", trigger_args = {} },
                    },
                    priority = 1
                },
                {
                    name = "Defensive Stance",
                    description = "Gain [arg1] block",
                    type = "shield",
                    args = { arg1 = 10 },
                    effect_list = {
                        {effect_type ="block", effect_target = "self", effect_args = {"arg1"} },
                    },
                    trigger =  {
                        {trigger_type = "cards_generated", trigger_args = {} },
                    },
                    priority = 2
                },
                {
                    name = "Rage",
                    description = "Increase attack by [arg1]",
                    type = "buff_attack",
                    args = { arg1 = 5, arg2 = 20 },
                    effect_list = {
                        {effect_type ="buff_attack", effect_target = "self", effect_args = {"arg1"} },
                    },
                    trigger =  {
                        {trigger_type = "damage_taken", trigger_args = {"arg2"} },
                    },
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
                    description = "Deal [arg1] damage",
                    type = "attack",
                    args = { arg1 = 12 },
                    effect_list = {
                        {effect_type ="damage", effect_target = "enemy", effect_args = {"arg1"} },
                    },
                    trigger =  {
                        {trigger_type = "turn_start", trigger_args = {} },
                    },
                    priority = 1
                },
                {
                    name = "Split",
                    description = "Heal [arg1] HP. After [arg2] damage taken",
                    type = "heal",
                    args = { arg1 = 15, arg2 = 20 },
                    effect_list = {
                        {effect_type ="heal", effect_target = "self", effect_args = {"arg1"} },
                    },
                    trigger =  {
                        {trigger_type = "damage_taken", trigger_args = {"arg2"} },
                    },
                    priority = 2
                },
                {
                    name = "Shield",
                    description = "Gain [arg1] block",
                    type = "shield",
                    args = { arg1 = 15 },
                    effect_list = {
                        {effect_type ="block", effect_target = "self", effect_args = {"arg1"} },
                    },
                    trigger =  {
                        {trigger_type = "cards_generated", trigger_args = {} },
                    },
                    priority = 3
                },
                {
                    name = "Rage",
                    description = "Increase attack by [arg1]. After [arg2] damage taken",
                    type = "buff_attack",
                    args = { arg1 = 8, arg2 = 20 },
                    effect_list = {
                        {effect_type ="buff_attack", effect_target = "self", effect_args = {"arg1"} },
                    },
                    trigger =  {
                        {trigger_type = "damage_taken", trigger_args = {"arg2"} },
                    },
                    priority = 4
                }
            }
        }
    }
}

return monsters