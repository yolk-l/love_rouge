local global = require "src.global"
local button = require "src.ui.button"
local cards = require "conf.cards"

local mt = {}
mt.__index = mt

function mt:load(params)
    if not params then
        error("Battle reward state requires parameters")
        return
    end
    
    -- 获取战斗类型
    self.battleType = params.battleType or "normal"
    
    -- 生成随机金币奖励
    self.goldReward = 0
    if self.battleType == "normal" then
        self.goldReward = math.random(15, 30)
    elseif self.battleType == "elite" then
        self.goldReward = math.random(30, 50)
    elseif self.battleType == "boss" then
        self.goldReward = math.random(50, 80)
    end
    
    -- 自动添加金币奖励
    global.player:addGold(self.goldReward)
    
    -- 生成三张随机卡牌作为奖励选择
    self.cardRewards = {}
    for i = 1, 3 do
        local randomCard = global.cardMgr:getRandomCard()
        if randomCard then
            table.insert(self.cardRewards, randomCard)
        end
    end
    
    -- 创建卡牌选择按钮
    self.cardButtons = {}
    for i, card in ipairs(self.cardRewards) do
        local x = 200 + (i - 1) * 200
        local y = 300
        local cardButton = button.new("选择", x, y + 150, 100, 40, function()
            self:selectCard(i)
        end)
        table.insert(self.cardButtons, cardButton)
    end
    
    -- 创建跳过按钮
    self.skipButton = button.new("跳过", 400, 500, 150, 50, function()
        self:skipReward()
    end)
    
    -- 标记是否已经选择了奖励
    self.rewardSelected = false
end

function mt:selectCard(index)
    if self.rewardSelected then return end
    
    local selectedCard = self.cardRewards[index]
    if selectedCard then
        -- 添加卡牌到玩家卡组
        global.cardMgr:addCardToDeck(selectedCard.name)
        print("选择了卡牌奖励: " .. selectedCard.name)
        
        -- 标记已选择奖励
        self.rewardSelected = true
        
        -- 返回地图
        global.stateMgr:changeState("map", {
            completeBattleNode = true
        })
    end
end

function mt:skipReward()
    if self.rewardSelected then return end
    
    print("跳过了卡牌奖励")
    
    -- 标记已选择奖励
    self.rewardSelected = true
    
    -- 返回地图
    global.stateMgr:changeState("map", {
        completeBattleNode = true
    })
end

function mt:update(dt)
    if not self.rewardSelected then
        for _, btn in ipairs(self.cardButtons) do
            btn:update(dt)
        end
        self.skipButton:update(dt)
    end
end

function mt:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("战斗胜利!", 350, 50, 0, 2, 2)
    
    -- 显示金币奖励
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.print("获得 " .. self.goldReward .. " 金币!", 350, 100, 0, 1.5, 1.5)
    
    -- 显示卡牌奖励标题
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("选择一张卡牌添加到你的卡组:", 250, 150)
    
    -- 绘制卡牌选项
    for i, card in ipairs(self.cardRewards) do
        local x = 200 + (i - 1) * 200
        local y = 200
        
        -- 绘制卡牌背景
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", x - 50, y, 100, 140)
        
        -- 根据卡牌类型设置边框颜色
        if card.type == "attack" then
            love.graphics.setColor(1, 0.3, 0.3) -- 红色边框
        elseif card.type == "defense" then
            love.graphics.setColor(0.3, 0.3, 1) -- 蓝色边框
        else
            love.graphics.setColor(0.3, 1, 0.3) -- 绿色边框
        end
        
        -- 绘制卡牌边框
        love.graphics.rectangle("line", x - 50, y, 100, 140)
        
        -- 绘制卡牌名称和描述
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(card.name, x - 40, y + 10)
        love.graphics.print("类型: " .. card.type, x - 40, y + 30)
        
        -- 处理描述文本中的参数替换
        local description = card.description
        for argName, argValue in pairs(card.args) do
            description = description:gsub("%[" .. argName .. "%]", tostring(argValue))
        end
        
        -- 绘制卡牌描述
        love.graphics.printf(description, x - 45, y + 50, 90, "left", 0, 0.8, 0.8)
        
        -- 绘制选择按钮
        self.cardButtons[i]:draw()
    end
    
    -- 绘制跳过按钮
    self.skipButton:draw()
end

function mt:mousepressed(x, y, button)
    if button == 1 and not self.rewardSelected then -- 左键点击
        for _, btn in ipairs(self.cardButtons) do
            btn:mousepressed(x, y)
        end
        self.skipButton:mousepressed(x, y)
    end
end

local BattleReward = {}

function BattleReward.new()
    return setmetatable({}, mt)
end

return BattleReward 