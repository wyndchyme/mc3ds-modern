--[[
This class is an item placeholder. Makes a reference to an item that may not be registered yet.
]]
---@class LCAPI_ItemPlaceholder
local ItemPlaceholder = CoreAPI.Utils.Classic:extend()

---@param id string|number
function ItemPlaceholder:new(id)
    if type(id) == "string" or type(id) == "number" then
        self._id = id
    end
    self._item = nil
end

function ItemPlaceholder:_try_get_item()
    if type(self._id) == "number" then
        self._item = Game.Items.findItemByID(self._id)
    elseif type(self._id) == "string" then
        self._item = CoreAPI.Items.getItem(self._id)
    end
end

---@return GameItem?
function ItemPlaceholder:getItem()
    if self._item ~= nil then
        self:_try_get_item()
    end
    return self._item
end

---@return integer?
function ItemPlaceholder:getID()
    if self:getItem() then
        return self._item.ID
    end
    return nil
end

return ItemPlaceholder