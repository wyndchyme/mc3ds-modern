CoreAPI.Tools = {}

--- Backwards compatibility with 0.12.0
local intType = "int"
if not Core.Memory.readS32 then
    intType = "unsigned int"
end

---@class ToolTier : cstruct
---@field MiningLevel number
---@field Durability number
---@field MiningEfficiency number
---@field DamageBonus number
---@field Enchantability number
local ToolTier = CoreAPI.Utils.CLike.CStruct.newStruct({
    {intType, "MiningLevel"},
    {intType, "Durability"},
    {"float", "MiningEfficiency"}, -- They really used float for an int value 
    {intType, "DamageBonus"},
    {intType, "Enchantability"}
})

CoreAPI.Tools.ToolTier = ToolTier

local tiers = {}
---@type ToolTier
tiers.WOOD = ToolTier:newInstanceFromMemory(0x00b0e124)
---@type ToolTier
tiers.STONE = ToolTier:newInstanceFromMemory(0x00b0e138)
---@type ToolTier
tiers.IRON = ToolTier:newInstanceFromMemory(0x00b0e14c)
---@type ToolTier
tiers.DIAMOND = ToolTier:newInstanceFromMemory(0x00b0e160)
---@type ToolTier
tiers.GOLD = ToolTier:newInstanceFromMemory(0x00b0e174)

CoreAPI.Tools.Tiers = tiers