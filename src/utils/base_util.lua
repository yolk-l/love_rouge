local M = {}

function M.inject_comp(entity, comp)
    for k, v in pairs(comp) do
        entity[k] = v
    end
end

-- 替换描述中的参数
-- @param description 包含参数占位符的描述文本
-- @param args 参数表
-- @return 替换后的描述文本
function M.replaceParams(description, args)
    if not description or not args then
        return description
    end
    
    local result = description
    for argName, argValue in pairs(args) do
        result = result:gsub("%[" .. argName .. "%]", tostring(argValue))
    end
    return result
end

return M
