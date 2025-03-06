local mt = {}
mt.__index = mt

function mt:getEnemy()
    return self.entity:getEnemy()
end

return mt
