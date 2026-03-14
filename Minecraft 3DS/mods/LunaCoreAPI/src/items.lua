---@diagnostic disable: cast-local-type

CoreAPI.Items = {}
CoreAPI.Items.Registry = {}

local function containsInvalidChars(s)
    if string.find(s, "[^%w_]") then return true else return false end
end

local OnGameRegisterCreativeItems = Game.Items.OnRegisterCreativeItems
local OnGameRegisterItems = Game.Items.OnRegisterItems
local OnGameRegisterItemsTextures = Game.Items.OnRegisterItemsTextures

local ItemPlaceholder = CoreAPI.ItemPlaceholder

---Returns an ItemInstance that can be used when the target item is not registered yet
---@param itemid string|number
---@return LCAPI_ItemPlaceholder
function CoreAPI.Items.newItemPlaceholder(itemid)
    return ItemPlaceholder(itemid)
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