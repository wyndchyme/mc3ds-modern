--[[
This class represents a wrapper for an item group. Is used as a helper for
registering items in the creative menu.
]]
---@class LCAPI_ItemGroupEntry
local ItemGroupEntry = CoreAPI.Utils.Classic:extend()

function ItemGroupEntry:new(itemGroup)
    self._groupid = itemGroup
end

local isinstance = CoreAPI.Utils.isinstance

local function _get_item_and_target(item, target)
    local addItem = nil
    if isinstance(item, CoreAPI.Items.ItemInstance) then
        addItem = item:getItem()
    elseif isinstance(item, "GameItem") then
        addItem = item
    end
    local positionItem = nil
    if isinstance(target, CoreAPI.Items.ItemInstance) then
        positionItem = target:getItem()
    elseif isinstance(target, "GameItem") then
        positionItem = target
    elseif type(target) == "string" then
        positionItem = CoreAPI.Items.getItem(target)
    end
    return addItem, positionItem
end

---Adds the item at the end of the group. It doesn't do anything if item is nil
---@param item GameItem|LCAPI_ItemPlaceholder|nil
---@param position integer?
function ItemGroupEntry:add(item, position)
    if item == nil then return end
    local addItem, _ = _get_item_and_target(item, nil)
    if addItem then
        local finalPos = 0x7FFF
        if position then finalPos = position end
        Game.Items.registerCreativeItem(addItem, self._groupid, finalPos)
    end
end

---Adds the item after another item. It doesn't do anything if item is nil
---@param item GameItem|LCAPI_ItemPlaceholder|nil
---@param target GameItem|LCAPI_ItemPlaceholder|string
function ItemGroupEntry:addAfter(item, target)
    if item == nil then return end
    local addItem, positionItem = _get_item_and_target(item, target)
    if positionItem and addItem then
        local position = Game.Items.getCreativePosition(positionItem.ID, self._groupid)
        Game.Items.registerCreativeItem(addItem, self._groupid, position + 1)
    end
end

---Adds the item before another item. It doesn't do anything if item is nil
---@param item GameItem|LCAPI_ItemPlaceholder|nil
---@param target GameItem|LCAPI_ItemPlaceholder|string
function ItemGroupEntry:addBefore(item, target)
    if item == nil then return end
    local addItem, positionItem = _get_item_and_target(item, target)
    if positionItem and addItem then
        local position = Game.Items.getCreativePosition(positionItem.ID, self._groupid)
        Game.Items.registerCreativeItem(addItem, self._groupid, position - 1)
    end
end

return ItemGroupEntry