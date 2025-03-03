local stateManager = require "src.utils.state_manager"
local node = require "src.entities.node"

local map
local nodeSpacing = 100 -- 节点之间的垂直间距
local startX, startY = 400, 50 -- 地图起始坐标（居中靠上）
local offsetX, offsetY = 0, 0 -- 地图拖动的偏移量
local isDragging = false -- 是否正在拖动地图
local dragStartX, dragStartY = 0, 0 -- 拖动起始位置

-- 限制地图拖动的范围
local minOffsetX, maxOffsetX = -200, 200 -- 水平拖动范围
local minOffsetY, maxOffsetY = -300, 300 -- 垂直拖动范围

local function generateMap()
    local map = {}
    for i = 1, 10 do
        local nodeType = i == 10 and "boss" or (math.random(1, 3)) -- 最后一个节点是boss
        local nodeName = i == 10 and "Boss" or ("Node " .. i)
        table.insert(map, node.new(startX, startY + (i - 1) * nodeSpacing, nodeType, nodeName))
    end
    return map
end

local function load()
    if not map then
        print("Loading map state...")
        map = generateMap()
    end
end

local function update(dt)
    -- 更新地图逻辑
end

local function draw()
    -- 绘制地图
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Map Screen - Drag to move", 10, 10)

    -- 绘制所有节点
    for _, node in ipairs(map) do
        node:draw(offsetX, offsetY)
    end
end

local function mousepressed(x, y, button)
    if button == 1 then -- 左键
        -- 检查是否点击了节点
        for _, node in ipairs(map) do
            if node:isClicked(x, y, offsetX, offsetY) then
                print("Clicked node: " .. node.name)
                if node.type == 1 or node.type == "boss" then
                    stateManager.changeState("battle") -- 进入战斗
                else
                    node.completed = true
                end
                break
            end
        end

        -- 开始拖动地图
        isDragging = true
        dragStartX, dragStartY = x - offsetX, y - offsetY
    end
end

local function mousemoved(x, y, dx, dy)
    if isDragging then
        -- 更新地图偏移量，并限制拖动范围
        offsetX = math.max(minOffsetX, math.min(maxOffsetX, x - dragStartX))
        offsetY = math.max(minOffsetY, math.min(maxOffsetY, y - dragStartY))
    end
end

local function mousereleased(x, y, button)
    if button == 1 then -- 左键
        isDragging = false -- 停止拖动
    end
end

return {
    load = load,
    update = update,
    draw = draw,
    mousepressed = mousepressed,
    mousemoved = mousemoved,
    mousereleased = mousereleased
}