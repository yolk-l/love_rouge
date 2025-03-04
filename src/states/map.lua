local stateManager = require "src.utils.state_manager"
local node = require "src.entities.node"

local map
local nodeSpacing = 100 -- 节点之间的水平和垂直间距
local startX, startY = 120, 70 -- 地图起始坐标（向右下移动 20 像素）
local currentBattleNodeIndex = nil -- 当前战斗节点的索引

local function generateMap()
    local map = {}
    local nodesPerRow = 5 -- 每行最多 5 个节点
    local rowDirection = 1 -- 1 表示从左到右，-1 表示从右到左
    local currentX, currentY = startX, startY
    local totalNodes = 15 -- 总节点数量
    local battleCount = 0 -- 追踪战斗节点数量
    local targetBattles = math.random(4, 8) -- 目标战斗节点数量
    
    -- 预定义固定战斗节点
    local fixedBattles = {
        [math.floor(totalNodes/3)] = "elite", -- 第一个精英
        [math.floor(totalNodes*2/3)] = "elite", -- 第二个精英
        [totalNodes] = "boss" -- 最后是boss
    }

    for i = 1, totalNodes do
        local nodeType, battleType
        
        if fixedBattles[i] then
            -- 处理固定战斗节点
            nodeType = "battle"
            battleType = fixedBattles[i]
            battleCount = battleCount + 1
        else
            -- 计算剩余需要的战斗节点数量
            local remainingNodes = totalNodes - i
            local remainingNeededBattles = targetBattles - battleCount
            
            -- 计算生成战斗节点的概率
            local battleChance = 0
            if remainingNeededBattles > 0 then
                battleChance = (remainingNeededBattles / remainingNodes) * 100
            end
            
            -- 根据概率决定节点类型
            if math.random(100) <= battleChance and battleCount < targetBattles then
                nodeType = "battle"
                battleType = "normal"
                battleCount = battleCount + 1
            else
                -- 非战斗节点随机为商店或事件
                nodeType = math.random(100) <= 50 and "shop" or "event"
            end
        end
        
        local nodeName = (nodeType == "battle" and battleType == "boss") and "Boss" or ("Node " .. i)
        local newNode = node.new(currentX, currentY, nodeType, nodeName)
        if nodeType == "battle" then
            newNode.battleType = battleType
        end
        table.insert(map, newNode)

        -- 更新下一个节点的位置
        currentX = currentX + nodeSpacing * rowDirection
        if i % nodesPerRow == 0 then
            -- 换行并改变方向
            currentY = currentY + nodeSpacing
            rowDirection = -rowDirection
            currentX = currentX + nodeSpacing * rowDirection
        end
    end
    
    print(string.format("Generated map with %d nodes (%d battles)", #map, battleCount))
    return map
end

-- 提供一个函数，用于设置当前战斗节点的状态
local function completeCurrentBattleNode()
    if currentBattleNodeIndex and map[currentBattleNodeIndex] then
        map[currentBattleNodeIndex].completed = true
        currentBattleNodeIndex = nil -- 重置当前战斗节点的索引
    end
end

local function load(params)
    if not map then
        print("Loading map state...")
        map = generateMap()
    end

    -- 如果从战斗返回，并且需要更新节点状态
    if params and params.completeBattleNode then
        completeCurrentBattleNode()
    end
end

local function update(dt)
    -- 更新地图逻辑
end

local function drawConnections()
    -- 绘制节点之间的连线
    love.graphics.setColor(1, 1, 1) -- 白色连线
    for i = 2, #map do
        local prevNode = map[i - 1]
        local currentNode = map[i]
        love.graphics.line(
            prevNode.x, prevNode.y,
            currentNode.x, currentNode.y
        )
    end
end

local function draw()
    -- 绘制地图
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Map Screen", 10, 10)

    -- 绘制节点之间的连线
    drawConnections()

    -- 绘制所有节点
    for _, node in ipairs(map) do
        node:draw(0, 0) -- 不再需要偏移量
    end
end

local function mousepressed(x, y, button)
    if button == 1 then -- 左键
        -- 检查是否点击了节点
        for i, node in ipairs(map) do
            if node:isClicked(x, y, 0, 0) then
                -- 检查上一个节点是否已完成
                if i > 1 and not map[i - 1].completed then
                    print("You must complete the previous node first!")
                    break
                end

                -- 根据节点类型执行不同操作
                if not node.completed then
                    if node.type == "battle" then
                        currentBattleNodeIndex = i
                        stateManager.changeState("battle", {
                            nodeType = "battle",
                            battleType = node.battleType
                        })
                    elseif node.type == "shop" then
                        print("Entering shop...")
                        -- TODO: 实现商店逻辑
                        node.completed = true
                    elseif node.type == "event" then
                        print("Triggering event...")
                        -- TODO: 实现事件逻辑
                        node.completed = true
                    end
                end
                break
            end
        end
    end
end

return {
    load = load,
    update = update,
    draw = draw,
    mousepressed = mousepressed,
    completeCurrentBattleNode = completeCurrentBattleNode
}