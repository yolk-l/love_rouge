local node = require "src.entities.node"

local m = {}

-- 状态变量
local map
local nodeSpacing = 120 -- 节点间距
local startX, startY = 80, 70 -- 地图起始坐标，向左移动
local currentBattleNodeIndex = nil -- 当前战斗节点的索引
local currentRow = 1 -- 当前可访问的行
local selectedNodes = {} -- 已选择的节点
local mapOffsetY = 0 -- 地图垂直偏移量
local isDragging = false -- 是否正在拖动
local lastMouseY = 0 -- 上一次鼠标Y坐标
local selectedNodeInRow = {} -- 记录每行已选择的节点

-- 计算两个节点之间的距离
function m.distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function m.generateMap()
    local map = {}
    local rows = 15 -- 总行数
    local nodesPerRow = {} -- 每行的节点数量
    local totalNodes = 0
    local battleCount = 0
    local targetBattles = math.random(4, 8) -- 目标战斗节点数量
    
    -- 预定义固定战斗节点
    local fixedBattles = {
        [math.floor(rows/3)] = "elite", -- 第一个精英
        [math.floor(rows*2/3)] = "elite", -- 第二个精英
        [rows] = "boss" -- 最后是boss
    }

    -- 生成每行的节点数量（1-3个）
    for row = 1, rows do
        -- 最后一行固定为1个节点（boss）
        if row == rows then
            nodesPerRow[row] = 1
        else
            nodesPerRow[row] = math.random(1, 3)
        end
    end

    -- 生成每一行的节点
    for row = 1, rows do
        local nodesInRow = nodesPerRow[row]
        local rowWidth = (nodesInRow - 1) * nodeSpacing
        local rowStartX = startX + (800 - rowWidth) / 2 -- 居中显示
        
        -- 计算当前行的节点位置
        for i = 1, nodesInRow do
            totalNodes = totalNodes + 1
            local nodeType, battleType
            
            if fixedBattles[row] then
                -- 处理固定战斗节点
                nodeType = "battle"
                battleType = fixedBattles[row]
                battleCount = battleCount + 1
            else
                -- 计算剩余需要的战斗节点数量
                local remainingNodes = rows - row
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
            
            local nodeName = (nodeType == "battle" and battleType == "boss") and "Boss" or ("Node " .. totalNodes)
            local newNode = node.new(rowStartX + (i - 1) * nodeSpacing, startY + (row - 1) * nodeSpacing, nodeType, nodeName)
            if nodeType == "battle" then
                newNode.battleType = battleType
            end
            newNode.row = row -- 记录节点所在的行
            table.insert(map, newNode)
        end
    end
    
    -- 生成节点之间的连接
    for i = 1, #map do
        map[i].connections = {}
        map[i].parentNodes = {}
    end
    
    -- 连接相邻行的节点
    for row = 1, rows - 1 do
        local currentRowStart = 1
        local currentRowEnd = 0
        local nextRowStart = 1
        local nextRowEnd = 0
        
        -- 计算当前行和下一行的节点范围
        for i = 1, row do
            currentRowStart = currentRowEnd + 1
            currentRowEnd = currentRowEnd + nodesPerRow[i]
        end
        nextRowStart = currentRowEnd + 1
        nextRowEnd = nextRowStart + nodesPerRow[row + 1] - 1
        
        -- 为下一行的每个节点分配父节点
        for i = nextRowStart, nextRowEnd do
            local targetNode = map[i]
            -- 从当前行随机选择1-2个父节点
            local parentCount = math.random(1, 2)
            local availableParents = {}
            
            -- 收集可用的父节点
            for j = currentRowStart, currentRowEnd do
                local parentNode = map[j]
                -- 检查这个父节点是否已经连接了这个子节点
                local alreadyConnected = false
                for _, connection in ipairs(parentNode.connections) do
                    if connection == targetNode then
                        alreadyConnected = true
                        break
                    end
                end
                if not alreadyConnected then
                    table.insert(availableParents, parentNode)
                end
            end
            
            -- 随机选择父节点
            while #targetNode.parentNodes < parentCount and #availableParents > 0 do
                local parentIndex = math.random(1, #availableParents)
                local parentNode = availableParents[parentIndex]
                table.insert(parentNode.connections, targetNode)
                table.insert(targetNode.parentNodes, parentNode)
                table.remove(availableParents, parentIndex)
            end
        end
        
        -- 确保当前行的每个节点都有子节点
        for i = currentRowStart, currentRowEnd do
            local currentNode = map[i]
            if #currentNode.connections == 0 then
                -- 如果没有子节点，从下一行随机选择一个节点作为子节点
                local targetIndex = math.random(nextRowStart, nextRowEnd)
                local targetNode = map[targetIndex]
                table.insert(currentNode.connections, targetNode)
                table.insert(targetNode.parentNodes, currentNode)
            end
        end
        
        -- 确保下一行的每个节点都有父节点
        for i = nextRowStart, nextRowEnd do
            local targetNode = map[i]
            if #targetNode.parentNodes == 0 then
                -- 如果没有父节点，从当前行随机选择一个节点作为父节点
                local parentIndex = math.random(currentRowStart, currentRowEnd)
                local parentNode = map[parentIndex]
                table.insert(parentNode.connections, targetNode)
                table.insert(targetNode.parentNodes, parentNode)
            end
        end
    end
    
    print(string.format("Generated map with %d nodes (%d battles)", #map, battleCount))
    return map
end

-- 提供一个函数，用于设置当前战斗节点的状态
function m.completeCurrentBattleNode()
    if currentBattleNodeIndex and map[currentBattleNodeIndex] then
        map[currentBattleNodeIndex].completed = true
        currentBattleNodeIndex = nil -- 重置当前战斗节点的索引
    end
end

function m.load(params)
    if not map then
        print("Loading map state...")
        map = m.generateMap()
    end

    -- 如果从战斗返回，并且需要更新节点状态
    if params and params.completeBattleNode then
        m.completeCurrentBattleNode()
    end
end

function m.update(dt)
    -- 更新地图逻辑
end

function m.drawConnections()
    -- 绘制节点之间的连线
    love.graphics.setColor(1, 1, 1) -- 白色连线
    for _, node in ipairs(map) do
        for _, connectedNode in ipairs(node.connections) do
            love.graphics.line(
                node.x, node.y + mapOffsetY,
                connectedNode.x, connectedNode.y + mapOffsetY
            )
        end
    end
end

function m.isNodeAccessible(node)
    -- 第一行的节点可以直接访问
    if node.row == 1 then
        return true
    end
    
    -- 检查是否有已完成的父节点
    for _, parentNode in ipairs(node.parentNodes) do
        if parentNode.completed then
            return true
        end
    end
    
    return false
end

function m.draw()
    -- 绘制地图
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Map Screen", 10, 10)
    love.graphics.print("Current Row: " .. currentRow, 10, 30)

    -- 绘制节点之间的连线
    m.drawConnections()

    -- 绘制所有节点
    for _, node in ipairs(map) do
        -- 根据节点状态设置颜色
        if node.completed then
            love.graphics.setColor(0, 1, 0) -- 绿色表示已完成
        elseif m.isNodeAccessible(node) then
            -- 如果该行已经有节点被选择，且不是当前节点，则显示为灰色
            if selectedNodeInRow[node.row] and selectedNodeInRow[node.row] ~= node then
                love.graphics.setColor(0.5, 0.5, 0.5) -- 灰色表示已废弃
            else
                love.graphics.setColor(1, 1, 0) -- 黄色表示当前可选
            end
        else
            love.graphics.setColor(0.5, 0.5, 0.5) -- 灰色表示不可访问
        end
        
        -- 绘制节点
        node:draw(0, mapOffsetY)
    end
end

function m.mousepressed(x, y, button)
    if button == 1 then -- Left click
        -- Check if clicked on a node
        for i, node in ipairs(map) do
            if m.distance(x, y, node.x, node.y + mapOffsetY) < 20 then
                if m.isNodeAccessible(node) then
                    -- If a node in this row is already selected, don't allow selecting another
                    if selectedNodeInRow[node.row] then
                        print("Already selected a node in this row!")
                        return
                    end
                    
                    -- Handle different node types
                    if node.type == "battle" then
                        currentBattleNodeIndex = i
                        -- 懒加载 state_manager
                        local stateManager = require "src.utils.state_manager"
                        stateManager.changeState("battle", {
                            nodeType = "battle",
                            battleType = node.battleType
                        })
                    elseif node.type == "shop" then
                        print("Entering shop node")
                        node.completed = true
                    elseif node.type == "event" then
                        print("Entering event node")
                        node.completed = true
                    end
                    
                    -- Mark this node as selected for its row
                    selectedNodeInRow[node.row] = node
                    return
                end
            end
        end
        
        -- If no node was clicked, start dragging
        isDragging = true
        lastMouseY = y
    elseif button == 2 then -- Right click
        -- Start dragging
        isDragging = true
        lastMouseY = y
    end
end

function m.mousereleased(x, y, button)
    if button == 1 or button == 2 then -- 左键或右键释放
        isDragging = false
    end
end

function m.mousemoved(x, y, dx, dy)
    if isDragging then
        mapOffsetY = mapOffsetY + dy
        lastMouseY = y
        
        -- 限制地图拖动范围
        local minOffset = -1200 -- 向上最多拖动1200像素，确保能看到boss节点
        local maxOffset = 0 -- 向下最多拖动0像素
        mapOffsetY = math.max(minOffset, math.min(maxOffset, mapOffsetY))
    end
end

return m