local modPath = Core.getModpath("lunacoreapi")

---@type LCAPI_ItemGroupEntry
CoreAPI.ItemGroupEntry = dofile(modPath .. "/src/classes/ItemGroupEntry.lua")

---@type LCAPI_ItemPlaceholder
CoreAPI.ItemPlaceholder = dofile(modPath .. "/src/classes/ItemPlaceholder.lua")

---@type LCAPI_ToolTier
CoreAPI.ToolTier = dofile(modPath .. "/src/classes/ToolTier.lua")

---@type LCAPI_BlangParser
CoreAPI.BlangParser = dofile(Core.getModpath("lunacoreapi") .. "/src/classes/BlangParser.lua")