local global = require "src.global"

local mt = {}

function mt:getEnemy()
    return global.charaterMgr:getEnemiesByCamp(self.camp)[1]
end

function mt:getSelf()
    return self
end

return mt
