local mapGenerator = {}

function mapGenerator.generateMap(layers)
    local map = {}
    for i = 1, layers do
        map[i] = {}
        local nodeCount = math.min(3, layers - i + 1)
        for j = 1, nodeCount do
            map[i][j] = {
                type = math.random(1, 3), -- 1:战斗, 2:商店, 3:事件
                completed = false
            }
        end
    end
    return map
end

return mapGenerator