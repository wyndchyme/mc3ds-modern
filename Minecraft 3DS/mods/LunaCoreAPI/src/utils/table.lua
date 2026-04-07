CoreAPI.Utils.Table = {}

--- Checks if a value is in a table
---@param t table
---@param value any
---@return boolean
function CoreAPI.Utils.Table.contains(t, value)
    for k, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end