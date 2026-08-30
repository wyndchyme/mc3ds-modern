CoreAPI.Tools = {}

local ToolTier = CoreAPI.ToolTier

CoreAPI.Tools.ToolTier = ToolTier

local tiers = {}
---@type LCAPI_ToolTier
tiers.WOOD = ToolTier:newInstanceFromMemory(0x00b0e124)
---@type LCAPI_ToolTier
tiers.STONE = ToolTier:newInstanceFromMemory(0x00b0e138)
---@type LCAPI_ToolTier
tiers.IRON = ToolTier:newInstanceFromMemory(0x00b0e14c)
---@type LCAPI_ToolTier
tiers.DIAMOND = ToolTier:newInstanceFromMemory(0x00b0e160)
---@type LCAPI_ToolTier
tiers.GOLD = ToolTier:newInstanceFromMemory(0x00b0e174)

CoreAPI.Tools.Tiers = tiers