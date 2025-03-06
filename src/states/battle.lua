local global = require "src.global"
local button = require "src.ui.button"
local monsters = require "conf.monsters"
local eventMgr = require "src.manager.event_mgr"

-- 导入新模块
local battle_ui = require "src.ui.battle_ui"

local monster = require "src.entities.monster"

local mt = {}
mt.__index = mt
function mt:disableButtons()
    self.generateCardButton.enabled = false
    self.executeCardButton.enabled = false
end

function mt:enableButtons()
    self.generateCardButton.enabled = true
    self.executeCardButton.enabled = true
end

function mt:onGenerateCardClick()
    if not self.generateCardButton.enabled or global.cardMgr:getState().isReleasingCards then return end
    -- 生成卡牌
    global.cardMgr:generateCards()
    -- 触发卡牌生成事件
    eventMgr.emit("cards_generated", {
        value = 1,
        source = global.player
    })
end

function mt:onExecuteCardClick()
    if not self.executeCardButton.enabled or global.cardMgr:getState().isReleasingCards then return end
    if global.cardMgr:startReleasingCards() then
        self:disableButtons()
        -- 触发卡牌执行事件
        eventMgr.emit("cards_executed", {
            source = global.player
        })
    else
        print("No cards to execute! Generate cards first.")
    end
end

function mt:load(params)
    if not params then
        error("Battle state requires parameters")
        return
    end
    if params.nodeType ~= "battle" then
        error("Invalid node type for battle state: " .. tostring(params.nodeType))
        return
    end
    -- 获取战斗类型
    self.battleType = params.battleType or "normal"
    -- 选择怪物池
    local monsterPool = monsters[self.battleType]
    if not monsterPool then
        print("Warning: Invalid battle type '" .. self.battleType .. "', falling back to normal")
        monsterPool = monsters.normal
    end
    -- 初始化战斗
    local monsterData = monsterPool[math.random(1, #monsterPool)]
    local currentMonster = monster.new(monsterData, self.battleType)
    global.charaterMgr:addCharacter(global.camp.monster, currentMonster)
    global.cardMgr:reset()
    -- 初始化按钮
    self.generateCardButton = button.new("Generate Cards", 300, 550, 150, 50, self.onGenerateCardClick, self)
    self.executeCardButton = button.new("Execute Cards", 500, 550, 150, 50, self.onExecuteCardClick, self)
    self:enableButtons()
    
    -- 触发战斗开始事件
    eventMgr.emit("battle_start", {
        battleType = self.battleType,
        source = global.player
    })
end

function mt:update(dt)
    local cardState = global.cardMgr:getState()
    if not cardState.isReleasingCards then
        self.generateCardButton:update(dt)
        self.executeCardButton:update(dt)
    end

    -- 更新卡牌释放逻辑
    local cardsFinished = global.cardMgr:update(dt, function(cardData)
        global.cardMgr:executeCard(cardData)
    end)

    -- 如果卡牌释放完成，重新启用按钮
    if cardsFinished then
        self:enableButtons()
        -- 清空 playerCards
        global.cardMgr:reset()
        
        -- 触发卡牌释放完成事件
        eventMgr.emit("cards_finished", {
            source = global.player
        })
    end

    if cardsFinished then
        -- 检查战斗结果
        local battleResult = global.charaterMgr:is_battle_over()
        if battleResult then
            if battleResult == global.battle_result.player_win then
                print("Player won!")
                -- 触发战斗胜利事件
                eventMgr.emit("battle_victory", {
                    battleType = self.battleType,
                    source = global.player
                })
                global.stateMgr:changeState("map", {
                    completeBattleNode = true
                })
            elseif battleResult == global.battle_result.monster_win then
                print("Player lost!")
                -- 触发战斗失败事件
                eventMgr.emit("battle_defeat", {
                    battleType = self.battleType,
                    source = global.player
                })
                global.stateMgr:changeState("game_over")
            end
        else
            -- 回合结束
            global.charaterMgr:on_turn_end()
            -- 触发回合结束事件
            eventMgr.emit("player_turn_end", {
                source = global.player
            })
        end
    end
end

function mt:draw()
    -- 绘制战斗UI
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Battle Screen", 10, 10)
    
    -- 绘制怪物
    local monster = global.charaterMgr:getCharacter(global.camp.monster)[1]
    battle_ui.drawMonster(monster)
    
    -- 绘制玩家
    local player = global.charaterMgr:getCharacter(global.camp.player)[1]
    battle_ui.drawPlayerHealth(player)
    
    -- 绘制卡牌
    local cardState = global.cardMgr:getState()
    battle_ui.drawCards(cardState.playerCards)
    battle_ui.drawFlyingCards(cardState.flyingCards)
    
    -- 绘制按钮
    battle_ui.drawButtons(self.generateCardButton, self.executeCardButton, cardState.isReleasingCards)
end

function mt:mousepressed(x, y, button)
    if button == 1 then -- 左键点击
        self.generateCardButton:mousepressed(x, y)
        self.executeCardButton:mousepressed(x, y)
    end
end

local Battle = {}

function Battle.new()
    return setmetatable({}, mt)
end

return Battle
