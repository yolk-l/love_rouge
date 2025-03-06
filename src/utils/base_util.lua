local M = {}

function M.inject_comp(entity, comp)
    local mt = {}
    for k, v in pairs(comp) do
        if type(v) == "function" then
            entity[k] = v
        end
    end
end

return M
