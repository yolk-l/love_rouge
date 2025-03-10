local global = require "src.global"
local button = require "src.ui.button"
local cards = require "conf.cards"

local mt = {}
mt.__index = mt

-- 商店卡牌价格
local CARD_PRICE = 50
-- 移除卡牌价格
local REMOVE_CARD_PRICE = 75

function mt:load(params)
    -- 初始化商店
    self.shopItems = {}
    self.selectedCard = nil
    self.selectedDeckCard = nil
    self.showingDeck = false
    
    -- 生成3张随机卡牌出售
    for i = 1, 3 do
        local randomCard = global.cardMgr:getRandomCard()
        if randomCard then
            table.insert(self.shopItems, {
                type = "card",
                card = randomCard,
                price = CARD_PRICE
            })
        end
    end
    
    -- 创建按钮
    self.backButton = button.new("Back to Map", 400, 550, 150, 50, function()
        global.stateMgr:changeState("map")
    end)
    
    self.viewDeckButton = button.new("View Deck", 600, 550, 150, 50, function()
        self.showingDeck = not self.showingDeck
        if self.showingDeck then
            self.viewDeckButton.text = "Hide Deck"
        else
            self.viewDeckButton.text = "View Deck"
        end
    end)
    
    self.removeCardButton = button.new("Remove Card (" .. REMOVE_CARD_PRICE .. " Gold)", 200, 550, 180, 50, function()
        if not self.showingDeck then
            self.showingDeck = true
            self.viewDeckButton.text = "Hide Deck"
        end
    end)
end

function mt:update(dt)
    self.backButton:update(dt)
    self.viewDeckButton:update(dt)
    self.removeCardButton:update(dt)
end

function mt:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Shop", 400, 30, 0, 2, 2)
    
    -- 显示玩家金币
    love.graphics.print("Gold: " .. global.player.gold, 700, 30)
    
    if self.showingDeck then
        -- 显示玩家卡组
        self:drawDeck()
    else
        -- 显示商店物品
        self:drawShopItems()
    end
    
    -- 绘制按钮
    self.backButton:draw()
    self.viewDeckButton:draw()
    self.removeCardButton:draw()
    
    -- 显示选中卡牌的详细信息
    if self.selectedCard then
        self:drawCardDetails(self.selectedCard, 600, 250)
    end
    
    if self.selectedDeckCard then
        self:drawCardDetails(self.selectedDeckCard.card, 600, 250)
    end
end

function mt:drawShopItems()
    love.graphics.print("Available Items:", 50, 80)
    
    for i, item in ipairs(self.shopItems) do
        local x = 50
        local y = 120 + (i - 1) * 100
        
        -- 绘制卡牌背景
        if self.selectedCard == item.card then
            love.graphics.setColor(0.8, 0.8, 0.2)
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
        end
        love.graphics.rectangle("fill", x, y, 100, 80)
        
        -- 绘制卡牌信息
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(item.card.name, x + 10, y + 10)
        love.graphics.print("Type: " .. item.card.type, x + 10, y + 30)
        love.graphics.print("Price: " .. item.price, x + 10, y + 50)
        
        -- 绘制购买按钮
        love.graphics.setColor(0.2, 0.6, 0.2)
        love.graphics.rectangle("fill", x + 120, y + 20, 80, 40)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Buy", x + 140, y + 30)
    end
end

function mt:drawDeck()
    love.graphics.print("Your Deck:", 50, 80)
    
    local deck = global.cardMgr:getDeck()
    local cardsPerRow = 5
    
    for i, card in ipairs(deck) do
        local row = math.floor((i - 1) / cardsPerRow)
        local col = (i - 1) % cardsPerRow
        
        local x = 50 + col * 110
        local y = 120 + row * 100
        
        -- 绘制卡牌背景
        if self.selectedDeckCard and self.selectedDeckCard.index == i then
            love.graphics.setColor(0.8, 0.8, 0.2)
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
        end
        love.graphics.rectangle("fill", x, y, 100, 80)
        
        -- 绘制卡牌信息
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(card.name, x + 10, y + 10)
        love.graphics.print("Type: " .. card.type, x + 10, y + 30)
        
        -- 如果是移除卡牌模式，显示移除按钮
        if global.player.gold >= REMOVE_CARD_PRICE then
            love.graphics.setColor(0.8, 0.2, 0.2)
            love.graphics.rectangle("fill", x + 10, y + 50, 80, 20)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Remove", x + 20, y + 52)
        end
    end
end

function mt:drawCardDetails(card, x, y)
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", x, y, 200, 200)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(card.name, x + 10, y + 10, 0, 1.5, 1.5)
    love.graphics.print("Type: " .. card.type, x + 10, y + 40)
    
    -- 替换描述中的参数
    local description = card.description
    if card.args then
        for argName, argValue in pairs(card.args) do
            description = description:gsub("%[" .. argName .. "%]", tostring(argValue))
        end
    end
    
    love.graphics.printf(description, x + 10, y + 70, 180, "left")
    
    -- 显示combo效果
    if card.comboEffect and type(card.comboEffect) == "table" then
        love.graphics.print("Combo Effects:", x + 10, y + 120)
        local yOffset = 140
        for count, effect in pairs(card.comboEffect) do
            local comboText = count .. "x: "
            
            -- 处理不同格式的comboEffect
            if type(effect) == "table" then
                for effectType, args in pairs(effect) do
                    comboText = comboText .. effectType .. " "
                    if type(args) == "table" then
                        for argName, argValue in pairs(args) do
                            comboText = comboText .. argValue .. " "
                        end
                    else
                        comboText = comboText .. tostring(args) .. " "
                    end
                end
            else
                comboText = comboText .. tostring(effect)
            end
            
            love.graphics.print(comboText, x + 20, y + yOffset)
            yOffset = yOffset + 20
        end
    end
end

function mt:mousepressed(x, y, button)
    if button == 1 then -- 左键点击
        self.backButton:mousepressed(x, y)
        self.viewDeckButton:mousepressed(x, y)
        self.removeCardButton:mousepressed(x, y)
        
        -- 检查是否点击了商店物品
        if not self.showingDeck then
            for i, item in ipairs(self.shopItems) do
                local itemX = 50
                local itemY = 120 + (i - 1) * 100
                
                -- 检查是否点击了卡牌区域
                if x >= itemX and x <= itemX + 100 and y >= itemY and y <= itemY + 80 then
                    self.selectedCard = item.card
                    self.selectedDeckCard = nil
                    print("选中商店卡牌: " .. item.card.name)
                    return
                end
                
                -- 检查是否点击了购买按钮
                if x >= itemX + 120 and x <= itemX + 200 and y >= itemY + 20 and y <= itemY + 60 then
                    print("点击购买按钮，卡牌: " .. item.card.name)
                    self:buyItem(item)
                    return
                end
            end
        else
            -- 检查是否点击了卡组中的卡牌
            local deck = global.cardMgr:getDeck()
            local cardsPerRow = 5
            
            for i, card in ipairs(deck) do
                local row = math.floor((i - 1) / cardsPerRow)
                local col = (i - 1) % cardsPerRow
                
                local cardX = 50 + col * 110
                local cardY = 120 + row * 100
                
                -- 检查是否点击了卡牌区域
                if x >= cardX and x <= cardX + 100 and y >= cardY and y <= cardY + 80 then
                    self.selectedDeckCard = {index = i, card = card}
                    self.selectedCard = nil
                    print("选中卡组卡牌: " .. card.name .. "，索引: " .. i)
                    return
                end
                
                -- 检查是否点击了移除按钮
                if global.player.gold >= REMOVE_CARD_PRICE and
                   x >= cardX + 10 and x <= cardX + 90 and 
                   y >= cardY + 50 and y <= cardY + 70 then
                    print("点击移除按钮，卡牌: " .. card.name .. "，索引: " .. i)
                    self:removeCard(i)
                    return
                end
            end
        end
        
        -- 如果点击了空白区域，取消选择
        if not (x >= 600 and x <= 800 and y >= 250 and y <= 450) then
            self.selectedCard = nil
            self.selectedDeckCard = nil
        end
    end
end

function mt:buyItem(item)
    if global.player.gold >= item.price then
        if item.type == "card" then
            -- 添加卡牌到玩家卡组
            print("尝试购买卡牌: " .. item.card.name)
            
            -- 使用卡牌的name属性而不是键名
            local success = global.cardMgr:addCardToDeck(item.card.name)
            
            if success then
                -- 扣除金币
                global.player:spendGold(item.price)
                -- 从商店移除该物品
                for i, shopItem in ipairs(self.shopItems) do
                    if shopItem == item then
                        table.remove(self.shopItems, i)
                        break
                    end
                end
                -- 重置选中状态
                self.selectedCard = nil
                print("成功购买卡牌: " .. item.card.name)
                
                -- 如果商店没有卡牌了，可以选择重新生成一些
                if #self.shopItems == 0 then
                    print("商店已售空，返回地图")
                end
            else
                print("添加卡牌失败: " .. item.card.name)
            end
        end
    else
        print("金币不足! 需要 " .. item.price .. " 金币")
    end
end

function mt:removeCard(index)
    if global.player.gold >= REMOVE_CARD_PRICE then
        -- 从卡组中移除卡牌
        local deck = global.cardMgr:getDeck()
        if index <= 0 or index > #deck then
            print("错误: 无效的卡牌索引: " .. index .. "，当前卡组大小: " .. #deck)
            return
        end
        
        local cardName = deck[index].name
        local removedCard = global.cardMgr:removeCardFromDeck(index)
        
        if removedCard then
            -- 扣除金币
            global.player:spendGold(REMOVE_CARD_PRICE)
            -- 重置选中状态
            self.selectedDeckCard = nil
            print("成功移除卡牌: " .. cardName)
        else
            print("移除卡牌失败，索引: " .. index .. "，当前卡组大小: " .. #global.cardMgr:getDeck())
        end
    else
        print("金币不足! 需要 " .. REMOVE_CARD_PRICE .. " 金币")
    end
end

local Shop = {}

function Shop.new()
    return setmetatable({}, mt)
end

return Shop 