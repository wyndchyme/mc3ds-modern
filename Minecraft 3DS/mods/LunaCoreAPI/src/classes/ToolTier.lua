---@class LCAPI_ToolTier : cstruct
---@field MiningLevel number
---@field Durability number
---@field MiningEfficiency number
---@field DamageBonus number
---@field Enchantability number
local ToolTier = CoreAPI.Utils.CLike.CStruct.newStruct({
    {"int", "MiningLevel"},
    {"int", "Durability"},
    {"float", "MiningEfficiency"}, -- They really used a float for an int value 
    {"int", "DamageBonus"},
    {"int", "Enchantability"}
})

return ToolTier