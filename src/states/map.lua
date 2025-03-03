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

    for i = 1, 20 do
        local nodeType = i == 20 and "boss" or (math.random(1, 3)) -- 最后一个节点是boss
        local nodeName = i == 20 and "Boss" or ("Node " .. i)
        table.insert(map, node.new(currentX, currentY, nodeType, nodeName))

        -- 更新下一个节点的位置
        currentX = currentX + nodeSpacing * rowDirection
        if i % nodesPerRow == 0 then
            -- 换行并改变方向
            currentY = currentY + nodeSpacing
            rowDirection = -rowDirection
            currentX = currentX + nodeSpacing * rowDirection
        end
    end
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

                -- 如果节点是战斗节点且未完成，则进入战斗
                if (node.type == 1 or node.type == "boss") and not node.completed then
                    currentBattleNodeIndex = i -- 保存当前战斗节点的索引
                    stateManager.changeState("battle") -- 进入战斗
                elseif node.type ~= 1 and node.type ~= "boss" then
                    node.completed = true -- 非战斗节点直接标记为完成
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
    completeCurrentBattleNode = completeCurrentBattleNode -- 暴露给其他模块使用
}