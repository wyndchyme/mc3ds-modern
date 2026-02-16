local modPath = Core.getModpath("lunacoreapi")

CoreAPI.ItemGroups = {
    BUILDING_BOCKS = 1,
    DECORATION = 2,
    REDSTONE = 3,
    FOOD_MINERALS = 4,
    TOOLS = 5,
    POTIONS = 6,
    OTHERS = 7
}

local OnGameRegisterCreativeItems = Game.Items.OnRegisterCreativeItems or Game.Event.OnGameCreativeItemsRegister

---@class ItemGroupEntries
local ItemGroupEntries = CoreAPI.Utils.Classic:extend()

function ItemGroupEntries:new(itemGroup)
    self._groupid = itemGroup
end

function ItemGroupEntries:_get_item_and_target(item, target)
    local addItem = nil
    if CoreAPI.Utils.isinstance(item, CoreAPI.Items.ItemInstance) then
        addItem = item:getItem()
    elseif CoreAPI.Utils.isinstance(item, "GameItem") then
        addItem = item
    end
    local positionItem = nil
    if CoreAPI.Utils.isinstance(target, CoreAPI.Items.ItemInstance) then
        positionItem = target:getItem()
    elseif CoreAPI.Utils.isinstance(target, "GameItem") then
        positionItem = target
    elseif type(target) == "string" then
        positionItem = CoreAPI.Items.getItem(target)
    end
    return addItem, positionItem
end

---Adds the item at the end of the group
---@param item GameItem|ItemInstance|nil
---@param position integer?
function ItemGroupEntries:add(item, position)
    if item == nil then return end
    local addItem, _ = self:_get_item_and_target(item, nil)
    if not addItem then
        return
    end
    if position then
        Game.Items.registerCreativeItem(addItem, self._groupid, position)
    else
        Game.Items.registerCreativeItem(addItem, self._groupid, 0x7FFF)
    end
end

---Adds the item after another item
---@param item GameItem|ItemInstance|nil
---@param target GameItem|ItemInstance|string
function ItemGroupEntries:addAfter(item, target)
    if item == nil then return end
    local addItem, positionItem = self:_get_item_and_target(item, target)
    if not positionItem or not addItem then
        return
    end
    local position = Game.Items.getCreativePosition(positionItem.ID, self._groupid)
    Game.Items.registerCreativeItem(addItem, self._groupid, position + 1)
end

---Adds the item before another item
---@param item GameItem|ItemInstance|nil
---@param target GameItem|ItemInstance|string
function ItemGroupEntries:addBefore(item, target)
    if item == nil then return end
    local addItem, positionItem = self:_get_item_and_target(item, target)
    if not positionItem or not addItem then
        return
    end
    local position = Game.Items.getCreativePosition(positionItem.ID, self._groupid)
    Game.Items.registerCreativeItem(addItem, self._groupid, position - 1)
end

---Helper function to add new entries to a creative group category
---@param itemGroup number
---@param registerFun fun(entries: ItemGroupEntries): nil
function CoreAPI.ItemGroups.registerEntries(itemGroup, registerFun)
    if itemGroup < 1 or itemGroup > 7 then
        error("Invalid item group ID")
    end
    local entries = ItemGroupEntries(itemGroup)
    OnGameRegisterCreativeItems:Connect(function ()
        registerFun(entries)
    end)
end