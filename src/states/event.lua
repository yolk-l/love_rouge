local global = require "src.global"
local button = require "src.ui.button"
local eventMgr = require "src.manager.event_mgr"

local mt = {}
mt.__index = mt

-- 事件类型定义
local EVENT_TYPES = {
    {
        name = "Treasure Chest",
        description = "You found a treasure chest. Opening it might grant you some gold.",
        options = {
            {
                text = "Open Chest",
                effect = function()
                    local goldAmount = math.random(20, 50)
                    global.player:addGold(goldAmount)
                    return "You gained " .. goldAmount .. " gold!"
                end
            },
            {
                text = "Leave",
                effect = function()
                    return "You decided not to risk it and left the chest."
                end
            }
        }
    },
    {
        name = "Mysterious Merchant",
        description = "A mysterious merchant offers to trade one of your cards for gold.",
        options = {
            {
                text = "Trade a Card",
                effect = function()
                    local deck = global.cardMgr:getDeck()
                    if #deck > 1 then -- 确保玩家至少有2张卡牌
                        local randomIndex = math.random(1, #deck)
                        local removedCard = global.cardMgr:removeCardFromDeck(randomIndex)
                        local goldAmount = math.random(15, 30)
                        global.player:addGold(goldAmount)
                        return "You traded " .. removedCard.name .. " and received " .. goldAmount .. " gold!"
                    else
                        return "You don't have enough cards to trade."
                    end
                end
            },
            {
                text = "Decline Trade",
                effect = function()
                    return "You declined the merchant's offer."
                end
            }
        }
    },
    {
        name = "Mysterious Altar",
        description = "You found a mysterious altar. It seems it can increase your maximum health, but requires a sacrifice of health.",
        options = {
            {
                text = "Sacrifice Health",
                effect = function()
                    local healthLoss = math.random(5, 15)
                    local maxHealthGain = math.random(10, 20)
                    
                    if global.player.health > healthLoss then
                        global.player.health = global.player.health - healthLoss
                        global.player.maxHealth = global.player.maxHealth + maxHealthGain
                        
                        -- 触发最大生命值变化事件
                        eventMgr.emit("character_max_health_changed", {
                            value = maxHealthGain,
                            source = global.player
                        })
                        
                        return "You sacrificed " .. healthLoss .. " health and gained " .. maxHealthGain .. " maximum health!"
                    else
                        return "Your health is too low to make a sacrifice."
                    end
                end
            },
            {
                text = "Leave Altar",
                effect = function()
                    return "You decided not to risk it and left the altar."
                end
            }
        }
    },
    {
        name = "Card Master",
        description = "A card master is willing to teach you a new card.",
        options = {
            {
                text = "Learn Attack Card",
                effect = function()
                    local card = global.cardMgr:getRandomCard("attack")
                    if card then
                        global.cardMgr:addCardToDeck(card.name)
                        return "You learned a new attack card: " .. card.name
                    else
                        return "The card master seems to have forgotten how to teach attack cards."
                    end
                end
            },
            {
                text = "Learn Defense Card",
                effect = function()
                    local card = global.cardMgr:getRandomCard("defense")
                    if card then
                        global.cardMgr:addCardToDeck(card.name)
                        return "You learned a new defense card: " .. card.name
                    else
                        return "The card master seems to have forgotten how to teach defense cards."
                    end
                end
            },
            {
                text = "Learn Skill Card",
                effect = function()
                    local card = global.cardMgr:getRandomCard("skill")
                    if card then
                        global.cardMgr:addCardToDeck(card.name)
                        return "You learned a new skill card: " .. card.name
                    else
                        return "The card master seems to have forgotten how to teach skill cards."
                    end
                end
            }
        }
    }
}

function mt:load(params)
    -- 随机选择一个事件
    self.currentEvent = EVENT_TYPES[math.random(1, #EVENT_TYPES)]
    self.resultText = nil
    self.optionButtons = {}
    
    -- 创建选项按钮
    local buttonY = 300
    for i, option in ipairs(self.currentEvent.options) do
        local btn = button.new(option.text, 400, buttonY, 200, 50, function()
            self.resultText = option.effect()
            self:disableButtons()
        end)
        table.insert(self.optionButtons, btn)
        buttonY = buttonY + 60
    end
    
    -- 创建返回按钮
    self.backButton = button.new("Back to Map", 400, 550, 150, 50, function()
        global.stateMgr:changeState("map")
    end)
    
    -- 初始状态下，如果有结果文本，禁用选项按钮
    if self.resultText then
        self:disableButtons()
    end
end

function mt:disableButtons()
    for _, btn in ipairs(self.optionButtons) do
        btn.enabled = false
    end
end

function mt:update(dt)
    -- 更新按钮状态
    for _, btn in ipairs(self.optionButtons) do
        btn:update(dt)
    end
    self.backButton:update(dt)
end

function mt:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Event: " .. self.currentEvent.name, 400, 50, 0, 2, 2)
    
    -- 显示事件描述
    love.graphics.printf(self.currentEvent.description, 200, 150, 400, "center")
    
    -- 显示结果文本（如果有）
    if self.resultText then
        love.graphics.setColor(0.8, 0.8, 0.2)
        love.graphics.printf(self.resultText, 200, 220, 400, "center")
    end
    
    -- 绘制选项按钮
    for _, btn in ipairs(self.optionButtons) do
        btn:draw()
    end
    
    -- 绘制返回按钮
    self.backButton:draw()
    
    -- 显示玩家状态
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Health: " .. global.player.health .. "/" .. global.player.maxHealth, 50, 50)
    love.graphics.print("Gold: " .. global.player.gold, 50, 80)
end

function mt:mousepressed(x, y, button)
    if button == 1 then -- 左键点击
        for _, btn in ipairs(self.optionButtons) do
            btn:mousepressed(x, y)
        end
        self.backButton:mousepressed(x, y)
    end
end

local Event = {}

function Event.new()
    return setmetatable({}, mt)
end

return Event 