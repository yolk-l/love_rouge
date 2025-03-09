-- Buff配置文件
local buffs = {
    -- 正面buff
    positive = {
        -- 再生buff：每回合结束时恢复生命值
        regeneration = {
            name = "Regeneration",
            description = "Heal [arg1] HP at the end of each turn",
            args = { arg1 = 3 },
            effect_list = {
                {
                    effect_type = "heal",
                    effect_target = "self",
                    effect_args = {"arg1"}
                }
            },
            trigger = {
                event = "cards_finished",
                check_condition = "self_damaged",
                remove_after_trigger = false
            }
        },
        
        -- 格挡增强buff：增加获得的格挡值
        block_boost = {
            name = "Block Boost",
            description = "Gain [arg1]% more block",
            args = { arg1 = 50 },
            effect_list = {
                {
                    effect_type = "modify_block",
                    effect_target = "self",
                    effect_args = {"arg1"}
                }
            },
            trigger = {
                event = "before_block_gained",
                check_condition = "self_blocking",
                remove_after_trigger = false
            }
        },
        
        -- 反击buff：受到伤害时对攻击者造成伤害
        thorns = {
            name = "Thorns",
            description = "Deal [arg1] damage to attacker when damaged",
            args = { arg1 = 3 },
            effect_list = {
                {
                    effect_type = "damage",
                    effect_target = "enemy",
                    effect_args = {"arg1"}
                }
            },
            trigger = {
                event = "character_damaged",
                check_condition = "self_damaged",
                remove_after_trigger = false
            }
        }
    },
    
    -- 负面buff
    negative = {
        -- 中毒buff：每回合结束时受到伤害
        poison = {
            name = "Poison",
            description = "Take [arg1] damage at the end of each turn",
            args = { arg1 = 3 },
            effect_list = {
                {
                    effect_type = "damage",
                    effect_target = "self",
                    effect_args = {"arg1"}
                }
            },
            trigger = {
                event = "cards_finished",
                check_condition = "always",
                remove_after_trigger = false
            }
        },
        
        -- 易伤buff：受到的伤害增加
        vulnerable = {
            name = "Vulnerable",
            description = "Take [arg1]% more damage",
            args = { arg1 = 50 },
            effect_list = {
                {
                    effect_type = "modify_damage_percent",
                    effect_target = "self",
                    effect_args = {"arg1"}
                }
            },
            trigger = {
                event = "before_damage_taken",
                check_condition = "self_damaged",
                remove_after_trigger = false
            }
        }
    }
}

return buffs 