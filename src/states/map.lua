local global = require "src.global"
local nodeEntity = require "src.entities.node"

local mt = {}
mt.__index = mt

-- Calculate distance between two nodes
function mt:distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function mt:generateMap()
    local rows = 15 -- Total rows
    local nodesPerRow = {} -- Nodes per row
    local totalNodes = 0
    local battleCount = 0
    local targetBattles = math.random(4, 8) -- Target number of battle nodes

    -- Predefined fixed battle nodes
    local fixedBattles = {
        [math.floor(rows/3)] = "elite", -- First elite
        [math.floor(rows*2/3)] = "elite", -- Second elite
        [rows] = "boss" -- Final boss
    }

    -- Generate number of nodes per row (1-3)
    for row = 1, rows do
        -- Last row is fixed to 1 node (boss)
        if row == rows then
            nodesPerRow[row] = 1
        else
            nodesPerRow[row] = math.random(1, 3)
        end
    end

    -- Generate nodes for each row
    for row = 1, rows do
        local nodesInRow = nodesPerRow[row]
        local rowWidth = (nodesInRow - 1) * self.nodeSpacing
        local rowStartX = self.startX + (800 - rowWidth) / 2 -- Center display
        -- Calculate node positions for current row
        for i = 1, nodesInRow do
            totalNodes = totalNodes + 1
            local nodeType, battleType
            if fixedBattles[row] then
                -- Handle fixed battle nodes
                nodeType = "battle"
                battleType = fixedBattles[row]
                battleCount = battleCount + 1
            else
                -- Calculate remaining needed battle nodes
                local remainingNodes = rows - row
                local remainingNeededBattles = targetBattles - battleCount
                -- Calculate probability of generating a battle node
                local battleChance = 0
                if remainingNeededBattles > 0 then
                    battleChance = (remainingNeededBattles / remainingNodes) * 100
                end
                -- Determine node type based on probability
                if math.random(100) <= battleChance and battleCount < targetBattles then
                    nodeType = "battle"
                    battleType = "normal"
                    battleCount = battleCount + 1
                else
                    -- Non-battle nodes are randomly shop or event
                    nodeType = math.random(100) <= 50 and "shop" or "event"
                end
            end
            local nodeName = (nodeType == "battle" and battleType == "boss") and "Boss" or ("Node " .. totalNodes)
            local newNode = nodeEntity.new(
                rowStartX + (i - 1) * self.nodeSpacing,
                self.startY + (row - 1) * self.nodeSpacing,
                nodeType,
                nodeName
            )
            if nodeType == "battle" then
                newNode.battleType = battleType
            end
            newNode.row = row -- Record node's row
            table.insert(self.map, newNode)
        end
    end
    -- Generate connections between nodes
    for i = 1, #self.map do
        self.map[i].connections = {}
        self.map[i].parentNodes = {}
    end
    -- Connect adjacent row nodes
    for row = 1, rows - 1 do
        local currentRowStart = 1
        local currentRowEnd = 0
        local nextRowStart
        local nextRowEnd
        -- Calculate current and next row node ranges
        for i = 1, row do
            currentRowStart = currentRowEnd + 1
            currentRowEnd = currentRowEnd + nodesPerRow[i]
        end
        nextRowStart = currentRowEnd + 1
        nextRowEnd = nextRowStart + nodesPerRow[row + 1] - 1
        
        -- Connect current row and next row nodes
        for i = currentRowStart, currentRowEnd do
            for j = nextRowStart, nextRowEnd do
                table.insert(self.map[i].connections, self.map[j])
                table.insert(self.map[j].parentNodes, self.map[i])
            end
        end
    end
    print(string.format("Generated map with %d nodes (%d battles)", #self.map, battleCount))
    return self.map
end

-- Provide a function to set the current battle node's state
function mt:completeCurrentBattleNode()
    if self.currentBattleNodeIndex and self.map[self.currentBattleNodeIndex] then
        self.map[self.currentBattleNodeIndex].completed = true
        self.currentBattleNodeIndex = nil -- Reset current battle node index
    end
end

-- Add a function to reset map node click states
function mt:resetNodeClickStates()
    -- Reset selected nodes for each row
    self.selectedNodeInRow = {}
    self.currentBattleNodeIndex = nil
end

function mt:load(params)
    if params and params.completeBattleNode and self.currentBattleNodeIndex then
        -- Mark current battle node as completed
        self.map[self.currentBattleNodeIndex].completed = true
        -- Update current accessible row
        self.currentRow = self.map[self.currentBattleNodeIndex].row + 1
        self.currentBattleNodeIndex = nil
    elseif not self.map or #self.map == 0 then
        -- First load or restart game, generate map
        self.map = {}
        self:generateMap()
    end
end

function mt:update(dt)
    -- Update map logic
end

function mt:drawConnections()
    love.graphics.setColor(0.5, 0.5, 0.5)
    for _, node in ipairs(self.map) do
        for _, connectedNode in ipairs(node.connections) do
            love.graphics.line(
                node.x, 
                node.y + self.mapOffsetY, 
                connectedNode.x, 
                connectedNode.y + self.mapOffsetY
            )
        end
    end
end

function mt:isNodeAccessible(node)
    -- First row nodes are directly accessible
    if node.row == 1 then
        return true
    end

    -- Check if any parent node is completed
    for _, parentNode in ipairs(node.parentNodes) do
        if parentNode.completed then
            return true
        end
    end

    return false
end

function mt:draw()
    -- Draw map
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Map Screen", 10, 10)
    love.graphics.print("Current Row: " .. self.currentRow, 10, 30)
    love.graphics.print("Gold: " .. global.player.gold, 700, 10)
    love.graphics.print("Health: " .. global.player.health .. "/" .. global.player.maxHealth, 700, 30)

    -- Draw connections between nodes
    self:drawConnections()

    -- Draw all nodes
    for _, node in ipairs(self.map) do
        -- Set color based on node state
        if node.completed then
            love.graphics.setColor(0, 1, 0) -- Green for completed
        elseif self:isNodeAccessible(node) then
            -- If a node in this row is already selected and not the current node, show as gray
            if self.selectedNodeInRow[node.row] and self.selectedNodeInRow[node.row] ~= node then
                love.graphics.setColor(0.5, 0.5, 0.5) -- Gray for unavailable
            else
                love.graphics.setColor(1, 1, 0) -- Yellow for currently selectable
            end
        else
            love.graphics.setColor(0.5, 0.5, 0.5) -- Gray for inaccessible
        end
        -- Draw node
        node:draw(0, self.mapOffsetY)
    end
end

function mt:mousepressed(x, y, button)
    if button == 1 then -- Left click
        -- Check if clicked on a node
        for i, node in ipairs(self.map) do
            if self:distance(x, y, node.x, node.y + self.mapOffsetY) < 20 then
                if self:isNodeAccessible(node) then
                    -- If a node in this row is already selected, don't allow selecting another
                    if self.selectedNodeInRow[node.row] then
                        print("Already selected a node in this row!")
                        return
                    end
                    -- Handle different node types
                    if node.type == "battle" then
                        self.currentBattleNodeIndex = i
                        -- Lazy load state_manager
                        global.stateMgr:changeState("battle", {
                            nodeType = "battle",
                            battleType = node.battleType
                        })
                    elseif node.type == "shop" then
                        print("Entering shop node")
                        global.stateMgr:changeState("shop")
                        node.completed = true
                        -- Mark this row's node as selected
                        self.selectedNodeInRow[node.row] = node
                        -- Update current accessible row
                        self.currentRow = node.row + 1
                    elseif node.type == "event" then
                        print("Entering event node")
                        global.stateMgr:changeState("event")
                        node.completed = true
                        -- Mark this row's node as selected
                        self.selectedNodeInRow[node.row] = node
                        -- Update current accessible row
                        self.currentRow = node.row + 1
                    end
                    return
                end
            end
        end
        -- If no node was clicked, start dragging
        self.isDragging = true
        self.lastMouseY = y
    elseif button == 2 then -- Right click
        -- Start dragging
        self.isDragging = true
        self.lastMouseY = y
    end
end

function mt:mousereleased(x, y, button)
    if button == 1 or button == 2 then -- Left or right button release
        self.isDragging = false
    end
end

function mt:mousemoved(x, y, dx, dy)
    if self.isDragging then
        self.mapOffsetY = self.mapOffsetY + dy
        self.lastMouseY = y
        -- Limit map drag range
        local minOffset = -1200 -- Maximum upward drag of 1200 pixels to ensure boss node is visible
        local maxOffset = 0 -- Maximum downward drag of 0 pixels
        self.mapOffsetY = math.max(minOffset, math.min(maxOffset, self.mapOffsetY))
    end
end

local Map = {}

function Map.new()
    return setmetatable({
        map = {},
        nodeSpacing = 120, -- Node spacing
        startX = 80,
        startY = 70, -- Map starting coordinates, moved left
        currentBattleNodeIndex = nil, -- Current battle node index
        currentRow = 1, -- Current accessible row
        selectedNodes = {}, -- Selected nodes
        mapOffsetY = 0, -- Map vertical offset
        isDragging = false, -- Whether dragging
        lastMouseY = 0, -- Last mouse Y coordinate
        selectedNodeInRow = {}, -- Record selected node for each row
    }, mt)
end

return Map