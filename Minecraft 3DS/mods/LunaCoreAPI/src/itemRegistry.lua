---@class ItemRegistry
local itemRegistry = CoreAPI.Utils.Classic:extend()

local function containsInvalidChars(s)
    if string.find(s, "[^%w_]") then return true else return false end
end

---@type UVsPacker
local uvs_packer = dofile(Core.getModpath("lunacoreapi") .. "/src/utils/uvs/uvs_packer.lua")
---@type UVsRebuilder
local uvs_rebuilder = dofile(Core.getModpath("lunacoreapi") .. "/src/utils/uvs/uvs_rebuilder.lua")
---@type AtlasHandler
local atlas_handler = dofile(Core.getModpath("lunacoreapi") .. "/src/utils/atlas_handler.lua")
---@type BlangParser
local blang_parser = dofile(Core.getModpath("lunacoreapi") .. "/src/utils/blang_parser.lua")

--- Backwards compatibility with 0.12.0
local OnGameRegisterCreativeItems = Game.Items.OnRegisterCreativeItems or Game.Event.OnGameCreativeItemsRegister
local OnGameRegisterItems = Game.Items.OnRegisterItems or Game.Event.OnGameItemsRegister
local OnGameRegisterItemsTextures = Game.Items.OnRegisterItemsTextures or Game.Event.OnGameItemsRegisterTexture

local Registry = CoreAPI.Items.Registry

local itemRegistryGlobals = {
    initializedItems = false,
    initialized = false,
    initializedResources = false,
    allowedUVs = {},
    allowedAtlas = {},
    allowedTextures = {}
}

OnGameRegisterItems:Connect(function ()
    itemRegistryGlobals.initializedItems = true
end)

--- Init ItemRegistry globals
local function initItemRegistry()
    local titleId = Core.getTitleId()
    local basePath = string.format("sdmc:/luma/titles/%s/romfs", titleId)

    --- Warning about missing files
    --- Atlas UVs
    for packName, value in pairs(CoreAPI.ResourcePacks) do
        if not Core.Filesystem.fileExists(string.format("%s/atlas/atlas.items.meta_%08X.uvs", basePath, value.hash)) then
            CoreAPI._logger:warn(string.format("No atlas uvs found! Custom items won't have texture for '%s' pack. Please provide an atlas uvs under %s/atlas/atlas.items.meta_%08X.uvs", packName, basePath, value.hash))
        else
            table.insert(itemRegistryGlobals.allowedUVs, packName)
        end
    end

    --- Atlas textures
    for packName, value in pairs(CoreAPI.ResourcePacks) do
        if not Core.Filesystem.fileExists(string.format("%s/atlas/atlas.items.meta_%08X_0.3dst", basePath, value.hash)) then
            CoreAPI._logger:warn(string.format("No atlas texture found! Custom items may not have texture for '%s' pack. Please provide an atlas texture under %s/atlas/atlas.items.meta_%08X_0.3dst", packName, basePath, value.hash))
        else
            table.insert(itemRegistryGlobals.allowedTextures, packName)
        end
    end

    --- Locales
    for _, localeName in pairs(CoreAPI.Languages) do
        if not Core.Filesystem.fileExists(string.format("%s/loc/%s-pocket.blang", basePath, localeName)) then
            CoreAPI._logger:warn(string.format("No locale file found! Custom items won't have a locale name for '%s'. Please provide a locale file under %s/loc/%s-pocket.blang", localeName, basePath, localeName))
        end
    end

    itemRegistryGlobals.initialized = true
end

---comment
---@param modname string
function itemRegistry:new(modname)
    self.modname = modname
    self.definitions = {}
    self.registeredTextures = {}
end

---Registers an item and sets other properties including its texture
---@param nameId string
---@param definition table
---@return GameItem?
function itemRegistry:registerItem(nameId, itemId, definition)
    if itemRegistryGlobals.initializedItems then
        error("new items must be registered on mod load")
    end
    if type(nameId) ~= "string" then
        error("'nameId' must be a string")
    end
    if containsInvalidChars(nameId) then
        error("'nameId' contains invalid characters")
    end

    if not itemRegistryGlobals.initialized then
        initItemRegistry()
    end

    -- Validate item definition
    local regNameId = string.lower(self.modname .. ":" .. nameId)
    if Registry[regNameId] ~= nil then
        error("Item '" .. regNameId "' is already registered")
    end
    local gameNameId = string.lower(self.modname .. "_" .. nameId)

    local itemDefinition = {}
    itemDefinition.name = gameNameId
    itemDefinition.nameId = regNameId
    itemDefinition.locales = {}

    -- Default values
    itemDefinition.hasTexture = false

    itemDefinition.itemId = itemId
    if type(definition) == "table" then
        if type(definition.locales) == "table" then
            for localeName, value in pairs(definition.locales) do
                if not CoreAPI.Utils.Table.contains(CoreAPI.Languages, localeName) then
                    error("Invalid locale '" .. localeName .. "'")
                else
                    if type(value) ~= "string" then
                        error("Expected string for locale text '" .. localeName .. "'")
                    else
                        itemDefinition.locales[localeName] = value
                    end
                end
            end
        end

        if type(definition.texture) == "string" then
            local modPath = Core.getModpath(string.lower(self.modname))
            local texture = definition.texture
            if texture:match("^/") then
                texture = string.sub(texture, 2)
            end
            texture = string.gsub(texture, "\\", "/")
            local fullPath = string.format("%s/assets/textures/%s", modPath, texture)
            if not Core.Filesystem.fileExists(fullPath) then
                CoreAPI._logger:warn("Texture path '" .. fullPath .. "' doesn't exists")
            else
                itemDefinition.texturePath = fullPath
                itemDefinition.texture = "textures/" .. texture:gsub(".3dst$", "")
                itemDefinition.textureName = texture:gsub(".3dst$", "")
                itemDefinition.hasTexture = true
            end
        end
    end
    local regItem = Game.Items.registerItem(itemDefinition.name, itemDefinition.itemId)
    if regItem ~= nil then
        itemDefinition.item = regItem
    else
        CoreAPI._logger:warn("Failed to register item '" .. itemDefinition.nameId .. "'")
        return
    end

    table.insert(self.definitions, itemDefinition)
    Registry[regNameId] = {itemId = itemId + 256, name = gameNameId, locales = itemDefinition.locales, item = regItem}
    return itemDefinition.item
end

---Returns true if any change was made
---@param packer UVsPacker
---@param definition any
---@return boolean
local function registerUV(packer, definition)
    if packer:contains(definition.textureName:gsub("/", "_")) then
        return false
    end
    if not packer:addUV(definition.textureName:gsub("/", "_"), definition.texture) then
        CoreAPI._logger:warn("Failed to register UV for item '" .. definition.nameId .. "'")
        return false
    end
    return true
end

--- It returns true if the function executes without errors. The UVs data is copied to out table
---@param pack table
---@param packName string
---@param out table?
---@return boolean
function itemRegistry:modifyPackUVs(pack, packName, out)
    local titleId = Core.getTitleId()
    local basePath = string.format("sdmc:/luma/titles/%s/romfs", titleId)

    local uvsFile = Core.Filesystem.open(string.format("%s/atlas/atlas.items.meta_%08X.uvs", basePath, pack.hash), "r+")
    if not uvsFile then
        CoreAPI._logger:warn(string.format("Failed to open UVs file. Custom items may not have texture for '%s' pack", packName))
        return false
    end

    local uvsData = uvs_rebuilder.loadFile(uvsFile)
    if not uvsData then
        CoreAPI._logger:warn(string.format("Failed to parse UVs file. Custom items may not have texture for '%s' pack", packName))
        return false
    end

    local packer = uvs_packer.newPacker(uvsData, 16)
    local changed = false
    for _, definition in ipairs(self.definitions) do
        if definition.hasTexture then
            changed = registerUV(packer, definition) or changed
        end
    end
    if changed then
        uvs_rebuilder.dumpFile(uvsFile, uvsData)
    end
    uvsFile:close()

    if type(out) == "table" then
        for key, value in pairs(uvsData) do
            out[key] = value
        end
    end

    return true
end

--- Returns if succeeded
---@param uvItem table
---@param definition table
---@param handler AtlasHandler
---@return boolean
local function pasteTextureToAtlas(uvItem, definition, handler)
    local texLoadFile = Core.Filesystem.open(definition.texturePath, "r")
    if not texLoadFile then
        CoreAPI._logger:warn("Failed to open texture '" .. definition.texturePath .. "'")
        return false
    end

    -- File is updated automatically to 
    if not handler:pasteTexture(texLoadFile, uvItem[1]["uv"][1], uvItem[1]["uv"][2]) then
        CoreAPI._logger:warn("Failed to load texture '" .. definition.texturePath .. "'")
        return false
    end

    texLoadFile:close()
    return true
end

function itemRegistry:modifyTextureAtlas(pack, packName, uvsData)
    local titleId = Core.getTitleId()
    local basePath = string.format("sdmc:/luma/titles/%s/romfs", titleId)

    local atlasFile = Core.Filesystem.open(string.format("%s/atlas/atlas.items.meta_%08X_0.3dst", basePath, pack.hash), "r+")
    if not atlasFile then
        CoreAPI._logger:warn(string.format("Failed to open atlas file. Custom items may not have texture for '%s' pack", packName))
        return false
    end

    local handler = atlas_handler.newAtlasHandler(atlasFile)
    if not handler.parsed then
        CoreAPI._logger:warn(string.format("Failed to parse atlas file. Custom items may not have texture for '%s' pack", packName))
        atlasFile:close()
        return false
    end

    for _, definition in ipairs(self.definitions) do
        if definition.hasTexture then
            local uvItem = uvsData[definition.textureName:gsub("/", "_")] or uvsData[CoreAPI.Utils.String.hash(definition.textureName:gsub("/", "_"))]
            if uvItem then
                if not CoreAPI.Utils.Table.contains(self.registeredTextures, definition.textureName) then
                    pasteTextureToAtlas(uvItem, definition, handler)
                    table.insert(self.registeredTextures, definition.textureName)
                end
            end
        end
    end

    atlasFile:close()
    return true
end

local function initResources()
    local titleId = Core.getTitleId()
    local basePath = string.format("sdmc:/luma/titles/%s/romfs", titleId)

    --- Modify every locale file
    for _, localeName in pairs(CoreAPI.Languages) do
        OnGameRegisterItems:Connect(function ()
            local count = 0
            for _ in pairs(Registry) do
                count = count + 1
                break -- Well we only need to check if at least there is one item
            end
            if count == 0 then
                return
            end
            if Core.Filesystem.fileExists(string.format("%s/loc/%s-pocket.blang", basePath, localeName)) then
                local localeFile = Core.Filesystem.open(string.format("%s/loc/%s-pocket.blang", basePath, localeName), "r+")
                if not localeFile then
                    CoreAPI._logger:warn(string.format("Failed to open locale file. Custom items may not have names for '%s'", localeName))
                else
                    local localeParser = blang_parser.newParser(localeFile)
                    if not localeParser.parsed then
                        CoreAPI._logger:warn(string.format("Failed to parse locale file. Custom items may not have names for '%s'", localeName))
                    else
                        local changed = false
                        for _, definition in pairs(Registry) do
                            local itemName = definition.locales[localeName] or definition.locales["en_US"]
                            if itemName ~= nil then
                                if not (localeParser:containsText("item."..definition.name..".name") and localeParser:areEqual("item."..definition.name..".name", itemName)) then
                                    localeParser:addText("item." .. definition.name .. ".name", itemName)
                                    changed = true
                                end
                            end
                            definition.locales[localeName] = nil
                        end
                        if changed then
                            localeParser:dumpFile(localeFile)
                            collectgarbage("collect")
                        end
                    end
                    localeFile:close()
                end
            end
            collectgarbage("collect")
        end)
    end
end

function itemRegistry:buildResources()
    for packName, value in pairs(CoreAPI.ResourcePacks) do
        local uvsData = {}
        if self:modifyPackUVs(value, packName, uvsData) then
            self:modifyTextureAtlas(value, packName, uvsData)
        end
    end

    OnGameRegisterItemsTextures:Connect(function ()
        for _, definition in ipairs(self.definitions) do
            if definition.item ~= nil then
                if definition.hasTexture then
                    definition.item:setTexture(definition.textureName:gsub("/", "_"), 0)
                end
            end
        end
    end)

    if not itemRegistryGlobals.initializedResources then
        initResources()
        itemRegistryGlobals.initializedResources = true
    end
end

return itemRegistry