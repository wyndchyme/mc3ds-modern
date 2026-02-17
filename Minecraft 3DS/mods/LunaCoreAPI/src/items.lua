---@diagnostic disable: cast-local-type

CoreAPI.Items = {}
CoreAPI.Items.Registry = {}

local function containsInvalidChars(s)
    if string.find(s, "[^%w_]") then return true else return false end
end

--- Backwards compatibility with 0.12.0
local OnGameRegisterCreativeItems = Game.Items.OnRegisterCreativeItems or Game.Event.OnGameCreativeItemsRegister
local OnGameRegisterItems = Game.Items.OnRegisterItems or Game.Event.OnGameItemsRegister
local OnGameRegisterItemsTextures = Game.Items.OnRegisterItemsTextures or Game.Event.OnGameItemsRegisterTexture

---API Utility class for items. Allows to store info about an item that may or may not
---be registered yet
---@class ItemInstance
local ItemInstance = CoreAPI.Utils.Classic:extend()

---@param id string|number
function ItemInstance:new(id)
    if type(id) == "string" or type(id) == "number" then
        self._id = id
    end
    self._item = nil
end

function ItemInstance:_try_get_item()
    if type(self._id) == "number" then
        ---@diagnostic disable-next-line: param-type-mismatch
        self._item = Game.Items.findItemByID(self._id)
    elseif type(self._id) == "string" then
        ---@diagnostic disable-next-line: param-type-mismatch
        self._item = CoreAPI.Items.getItem(self._id)
    end
end

---@return GameItem?
function ItemInstance:getItem()
    if self._item ~= nil then
        self:_try_get_item()
    end
    return self._item
end

---@return integer?
function ItemInstance:getID()
    if self:getItem() then
        return self._item.ID
    end
    return nil
end

CoreAPI.Items.ItemInstance = ItemInstance

---Returns an ItemInstance that can be used when the target item is not registered yet
---@param itemid string|number
---@return ItemInstance
function CoreAPI.Items.newItemInstance(itemid)
    return ItemInstance(itemid)
end

---@type ItemRegistry
local itemRegistry = dofile(Core.getModpath("lunacoreapi") .. "/src/itemRegistry.lua")

local itemsGlobals = {
    initializedItems = false
}

---Creates and returns an ItemRegistry object that allows to register custom items
---@param modname string
---@return ItemRegistry
function CoreAPI.Items.newItemRegistry(modname)
    if itemsGlobals.initializedItems then
        error("new items must be registered on mod load")
    end
    if type(modname) ~= "string" then
        error("'modname' must be a string")
    end
    if containsInvalidChars(modname) then
        error("'modname' contains invalid characters")
    end
    local modPath = Core.getModpath(string.lower(modname))
    if modPath == nil then
        error("modname not registered")
    end
    return itemRegistry(modname)
end

OnGameRegisterItems:Connect(function ()
    CoreAPI._logger:info("Register items")
    itemsGlobals.initializedItems = true
end)
OnGameRegisterItemsTextures:Connect(function ()
    CoreAPI._logger:info("Register items texture")
end)
OnGameRegisterCreativeItems:Connect(function ()
    CoreAPI._logger:info("Register creative items")
end)

--- Get the item id with the item identifier
---@param itemName string
---@return GameItem?
function CoreAPI.Items.getItem(itemName)
    itemName = string.lower(itemName)
    local regInstance = CoreAPI.Items.Registry[itemName]
    if regInstance ~= nil then
        return regInstance.item
    elseif string.match(itemName, "^minecraft:") then
        itemName = string.gsub(itemName, "^minecraft:", "")
        return Game.Items.findItemByName(itemName)
    else
        return Game.Items.findItemByName(itemName)
    end
end