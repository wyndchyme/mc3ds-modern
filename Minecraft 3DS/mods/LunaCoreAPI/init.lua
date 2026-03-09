local modid = "lunacoreapi"

CoreAPI = {_VERSION = "0.3.0"}

local dataDir = "sdmc:/Minecraft 3DS/data"
Core.Filesystem.createDirectory(dataDir)
dataDir = dataDir .. "/LunaCoreAPI"
Core.Filesystem.createDirectory(dataDir)

local modMenuFolder = Core.Menu.getMenuFolder():newFolder("LunaCoreAPI")
CoreAPI._addMenuEntry = function (name, callback)
    modMenuFolder:newEntry(name, callback)
end

-- Earlier versions of the runtime doesn't contain Core._VERSION so it will be nil
if Core._VERSION then
    local maj, min, pat = Core._VERSION:match("^LunaCore (%d+)%.(%d+)%.(%d+)$")
    -- only check min because major will still be 0 and patch doesn't really matter
    min = tonumber(min)
    if min < 15 then
        error("LunaCoreAPI requires runtime version 0.15.0 or greater")
    end
end

local modpath = Core.getModpath(modid)

CoreAPI.Utils = {}
dofile(modpath .. "/src/utils/string.lua")
dofile(modpath .. "/src/utils/table.lua")
---@type JsonClass
CoreAPI.Utils.Json = dofile(modpath .. "/src/external/json.lua")
---@type StructClass
CoreAPI.Utils.Struct = dofile(modpath .. "/src/external/struct.lua")
---@type ClassicClass
CoreAPI.Utils.Classic = dofile(modpath .. "/src/external/classic.lua")
---@type BitOpClass
CoreAPI.Utils.Bitop = dofile(modpath .. "/src/external/bitop/funcs.lua")

---@type Logger
CoreAPI.Utils.Logger = dofile(modpath .. "/src/utils/logger.lua")

CoreAPI._logger = CoreAPI.Utils.Logger.newLogger(modid)

CoreAPI.Utils.CLike = {}
---@type cstruct
CoreAPI.Utils.CLike.CStruct = dofile(modpath .. "/src/utils/clike/cstruct.lua")

--- Returns if the object is from an instance or type
---@param t any
---@param o string|table
---@return boolean
function CoreAPI.Utils.isinstance(t, o)
    if type(o) == "table" then
        if type(t) == "table" then
            if t.is and o.is then
                return t:is(o)
            end
            return false
        end
        return false
    elseif type(o) == "string" and type(t) == "userdata" and t.isType then
        return t:isType(o) -- Added in v0.17.0
    end
    return type(t) == o
end

CoreAPI.ResourcePacks = {}
CoreAPI.ResourcePacks.vanilla = {hash = 0x79954554, res = 16}


CoreAPI.Languages = {"de_DE", "en_GB", "en_US", "es_ES", "es_MX", "fr_CA",
    "fr_FR", "it_IT", "ja_JP", "ko_KR", "nl_NL", "pt_BR", "pt_PT", "ru_RU",
    "zh_CN", "zh_TW"}

dofile(modpath .. "/src/classes.lua")

dofile(modpath .. "/src/items.lua")
dofile(modpath .. "/src/tools.lua")
dofile(modpath .. "/src/itemGroups.lua")

CoreAPI._addMenuEntry = nil
CoreAPI._logger:info("Loaded")