local global = require "src.global"

local mt = {}

function mt.getEnemy(self)
    return global.charaterMgr:getEnemiesByCamp(self.camp)[1]
end

function mt.getSelf(self)
    return self
end

return mt
