local M = {}

function M.inject_comp(entity, comp)
    for k, v in pairs(comp) do
        entity[k] = v
    end
end

return M
