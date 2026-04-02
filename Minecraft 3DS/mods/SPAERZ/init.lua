local LOGGER = CoreAPI.Utils.Logger.newLogger("SPAERZ")
local spearsModReg = CoreAPI.Items.newItemRegistry("SPAERZ") -- This must be the same as the mod name in mod.json

-- Tiers of Spears ^_^
local WoodTier = Game.Items.newToolTier()
WoodTier.MiningLevel = 0
WoodTier.Durability = 59
WoodTier.MiningEfficiency = 2
WoodTier.DamageBonus = 1
WoodTier.Enchantability = 15

local StoneTier = Game.Items.newToolTier()
StoneTier.MiningLevel = 1
StoneTier.Durability = 131
StoneTier.MiningEfficiency = 4
StoneTier.DamageBonus = 1
StoneTier.Enchantability = 5

local IronTier = Game.Items.newToolTier()
IronTier.MiningLevel = 2
IronTier.Durability = 250
IronTier.MiningEfficiency = 6
IronTier.DamageBonus = 2
IronTier.Enchantability = 14

local GoldTier = Game.Items.newToolTier()
GoldTier.MiningLevel = 0
GoldTier.Durability = 32
GoldTier.MiningEfficiency = 12
GoldTier.DamageBonus = 1
GoldTier.Enchantability = 22

local DiamondTier = Game.Items.newToolTier()
DiamondTier.MiningLevel = 3
DiamondTier.Durability = 1561
DiamondTier.MiningEfficiency = 8
DiamondTier.DamageBonus = 3
DiamondTier.Enchantability = 10

-- Defs for registering my Spears \(^-^)/
local WOODEN_SPEAR = spearsModReg:registerItem("wooden_spear", 70, {
    texture = "items/wooden_spear.3dst",
    locales = {
        en_US = "Wooden Spear"
    },
    tool = "sword",
    tier = WoodTier
})
Core.Debug.log("[SPAERZ] Registered Spear - Name: " .. WOODEN_SPEAR.NameID .. " | ID: " .. WOODEN_SPEAR.ID)
-- WOODEN_SPEAR.StackSize = 1

local STONE_SPEAR = spearsModReg:registerItem("stone_spear", 71, {
    texture = "items/stone_spear.3dst",
    locales = {
        en_US = "Stone Spear"
    },
    tool = "sword",
    tier = StoneTier
})
Core.Debug.log("[SPAERZ] Registered Spear - Name: " .. STONE_SPEAR.NameID .. " | ID: " .. STONE_SPEAR.ID)
-- STONE_SPEAR.StackSize = 1

local IRON_SPEAR = spearsModReg:registerItem("iron_spear", 79, {
    texture = "items/iron_spear.3dst",
    locales = {
        en_US = "Iron Spear"
    },
    tool = "sword",
    tier = IronTier
})
Core.Debug.log("[SPAERZ] Registered Spear - Name: " .. IRON_SPEAR.NameID .. " | ID: " .. IRON_SPEAR.ID)
-- IRON_SPEAR.StackSize = 1

local GOLD_SPEAR = spearsModReg:registerItem("golden_spear", 87, {
    texture = "items/golden_spear.3dst",
    locales = {
        en_US = "Golden Spear"
    },
    tool = "sword",
    tier = GoldTier
})
Core.Debug.log("[SPAERZ] Registered Spear - Name: " .. GOLD_SPEAR.NameID .. " | ID: " .. GOLD_SPEAR.ID)
-- GOLD_SPEAR.StackSize = 1

local DIAMOND_SPEAR = spearsModReg:registerItem("diamond_spear", 130, {
    texture = "items/diamond_spear.3dst",
    locales = {
        en_US = "Diamond Spear"
    },
    tool = "sword",
    tier = DiamondTier
})
Core.Debug.log("[SPAERZ] Registered Spear - Name: " .. DIAMOND_SPEAR.NameID .. " | ID: " .. DIAMOND_SPEAR.ID)
-- DIAMOND_SPEAR.StackSize = 1


-- Register Entries for Items >.<"
CoreAPI.ItemGroups.registerEntries(CoreAPI.ItemGroups.TOOLS, function (entries)
    entries:addBefore(WOODEN_SPEAR, "wooden_sword")
    entries:addBefore(STONE_SPEAR, "stone_sword")
    entries:addBefore(IRON_SPEAR, "iron_sword")
    entries:addBefore(GOLD_SPEAR, "golden_sword")
    entries:addBefore(DIAMOND_SPEAR, "diamond_sword")
end)

-- Register Recipes :3c
Game.Recipes.OnRegisterRecipes:Connect(function (recipesTable)
    local stick = Game.Items.findItemByID(280)
    local plank = Game.Items.findItemByID(5)
    local stone = Game.Items.findItemByID(4)
    local iron = Game.Items.findItemByID(265)
    local gold = Game.Items.findItemByID(266)
    local diamond = Game.Items.findItemByID(264)
    if stick and plank and stone and iron and gold and diamond then -- Check no nil
        local stickInst = Game.Items.getItemInstance(stick, 1, 0)
        local plankInst = Game.Items.getItemInstance(plank, 1, 0)
        local stoneInst = Game.Items.getItemInstance(stone, 1, 0)
        local ironInst = Game.Items.getItemInstance(iron, 1, 0)
        local goldInst = Game.Items.getItemInstance(gold, 1, 0)
        local diamondInst = Game.Items.getItemInstance(diamond, 1, 0)
        local woodenSpearInst = Game.Items.getItemInstance(WOODEN_SPEAR, 1, 0)
        local stoneSpearInst = Game.Items.getItemInstance(STONE_SPEAR, 1, 0)
        local ironSpearInst = Game.Items.getItemInstance(IRON_SPEAR, 1, 0)
        local goldSpearInst = Game.Items.getItemInstance(GOLD_SPEAR, 1, 0)
        local diamondSpearInst = Game.Items.getItemInstance(DIAMOND_SPEAR, 1, 0)
        Game.Recipes.registerShapedRecipe(recipesTable, woodenSpearInst, 2, 505, "  M", " S ", "S  ", {{"M", plankInst}, {"S", stickInst}})
        Game.Recipes.registerShapedRecipe(recipesTable, stoneSpearInst, 2, 506, "  M", " S ", "S  ", {{"M", stoneInst}, {"S", stickInst}})
        Game.Recipes.registerShapedRecipe(recipesTable, ironSpearInst, 2, 507, "  M", " S ", "S  ", {{"M", ironInst}, {"S", stickInst}})
        Game.Recipes.registerShapedRecipe(recipesTable, goldSpearInst, 2, 508, "  M", " S ", "S  ", {{"M", goldInst}, {"S", stickInst}})
        Game.Recipes.registerShapedRecipe(recipesTable, diamondSpearInst, 2, 509, "  M", " S ", "S  ", {{"M", diamondInst}, {"S", stickInst}})
    end
end)

-- Build these damn recources
spearsModReg:buildResources()

-- Spear Logic System
local SPEAR_RUNTIME = {
    spearBaseDamage = {
        [WOODEN_SPEAR.ID]  = 2, -- wooden_spear
        [STONE_SPEAR.ID]  = 2, -- stone_spear
        [IRON_SPEAR.ID]  = 3, -- iron_spear
        [GOLD_SPEAR.ID]  = 2, -- golden_spear
        [DIAMOND_SPEAR.ID] = 4  -- diamond_spear
    },

    DAMAGE_BONUS_OFFSET = 0xAC,

    velocityDamageMultiplier = 6.0,
    survivalDashMultiplier   = 15.0,
    creativeDashMultiplier   = 5.0,
    dashDuration             = 0.2,
    survivalDashCooldown     = 3.00,
    creativeDashCooldown     = 1.00,
    loopDelay                = 0.01,

    dashActive               = false,
    dashEndTime              = 0,
    nextDashTime             = 0,

    started                  = false,

    lastItemId               = nil,
    lastItemPtr              = nil,
    lastDamageAddr           = nil,
    lastBaseDamage           = nil,
    lastAppliedDamage        = nil,
    cooldownNoticeTime       = 0
}

local function roundNumber(v)
    return math.floor(v + 0.5)
end

local function getItemPointerFromUserdata(item)
    if not item then
        return nil
    end

    local s = tostring(item)
    if not s then
        return nil
    end

    local hex = s:match("userdata:%s*(0x%x+)")
    if hex then
        return tonumber(hex)
    end

    hex = s:match("userdata:%s*(%x+)")
    if hex then
        return tonumber(hex, 16)
    end

    return nil
end

local function isCreativeOrFlying()
    return Game.LocalPlayer.Gamemode == 1 and Game.LocalPlayer.Flying
end

local function getDashSettings()
    if isCreativeOrFlying() then
        return SPEAR_RUNTIME.creativeDashMultiplier, SPEAR_RUNTIME.creativeDashCooldown
    end

    return SPEAR_RUNTIME.survivalDashMultiplier, SPEAR_RUNTIME.survivalDashCooldown
end

local function getHeldSpearInfo()
    if not Game.LocalPlayer.Loaded or not Game.World.Loaded then
        return nil
    end

    local hand = Game.LocalPlayer.Inventory.Slots["hand"]
    if not hand or hand:isEmpty() or not hand.Item then
        return nil
    end

    local item = hand.Item
    local itemId = item.ID
    local baseDamage = SPEAR_RUNTIME.spearBaseDamage[itemId]

    if not baseDamage then
        return nil
    end

    return item, itemId, baseDamage
end

local function resolveDamageAddress(item, itemId, baseDamage)
    if SPEAR_RUNTIME.lastItemId == itemId and SPEAR_RUNTIME.lastDamageAddr then
        return SPEAR_RUNTIME.lastDamageAddr
    end

    local itemPtr = getItemPointerFromUserdata(item)
    if not itemPtr then
        Core.Debug.log("[SPAERZ] Failed to resolve item pointer for item ID " .. tostring(itemId))
        return nil
    end

    local damageAddr = itemPtr + SPEAR_RUNTIME.DAMAGE_BONUS_OFFSET

    SPEAR_RUNTIME.lastItemId = itemId
    SPEAR_RUNTIME.lastItemPtr = itemPtr
    SPEAR_RUNTIME.lastDamageAddr = damageAddr
    SPEAR_RUNTIME.lastBaseDamage = baseDamage
    SPEAR_RUNTIME.lastAppliedDamage = nil

    Core.Debug.log(string.format(
        "[SPAERZ] Bound spear item ID %d -> ptr 0x%08X -> damage addr 0x%08X",
        itemId, itemPtr, damageAddr
    ))

    return damageAddr
end

local function restoreLastBaseDamage()
    if SPEAR_RUNTIME.lastDamageAddr and SPEAR_RUNTIME.lastBaseDamage then
        if SPEAR_RUNTIME.lastAppliedDamage ~= SPEAR_RUNTIME.lastBaseDamage then
            Core.Memory.writeU32(SPEAR_RUNTIME.lastDamageAddr, SPEAR_RUNTIME.lastBaseDamage)
            SPEAR_RUNTIME.lastAppliedDamage = SPEAR_RUNTIME.lastBaseDamage
        end
    end
end

local function applyHeldSpearDamage(damageValue)
    local item, itemId, baseDamage = getHeldSpearInfo()
    if not item then
        restoreLastBaseDamage()
        return false
    end

    local damageAddr = resolveDamageAddress(item, itemId, baseDamage)
    if not damageAddr then
        return false
    end

    local finalDamage = math.max(0, roundNumber(damageValue))

    if SPEAR_RUNTIME.lastAppliedDamage ~= finalDamage then
        Core.Memory.writeU32(damageAddr, finalDamage)
        SPEAR_RUNTIME.lastAppliedDamage = finalDamage
    end

    return true
end

local function getVelocityMagnitudeHorizontal()
    local vx, vy, vz = Game.LocalPlayer.Velocity.get()
    vx = vx or 0.0
    vy = vy or 0.0
    vz = vz or 0.0

    return math.sqrt((vx * vx) + (vz * vz)), vx, vy, vz
end

local function getVelocityMagnitudeAllDirections()
    local vx, vy, vz = Game.LocalPlayer.Velocity.get()
    vx = vx or 0.0
    vy = vy or 0.0
    vz = vz or 0.0

    return math.sqrt((vx * vx) + (vy * vy) + (vz * vz)), vx, vy, vz
end

local function performDash()
    local now = Core.System.getTime()

    if now < SPEAR_RUNTIME.nextDashTime then
        if now >= SPEAR_RUNTIME.cooldownNoticeTime then
            local remaining = SPEAR_RUNTIME.nextDashTime - now
            Core.Debug.message(string.format("Dash cooldown: %.1fs", remaining))
            SPEAR_RUNTIME.cooldownNoticeTime = now + 0.5
        end
        return
    end

    local item = getHeldSpearInfo()
    if not item then
        return
    end

    local dashMultiplier, dashCooldown = getDashSettings()
    local mag, vx, vy, vz = getVelocityMagnitudeHorizontal()

    if mag < 0.01 then
        local yaw = Game.LocalPlayer.Camera.Yaw or 0.0
        local yawRad = math.rad(yaw)
        vx = -math.sin(yawRad)
        vz =  math.cos(yawRad)
        vy = 0.0
    end

    Game.LocalPlayer.Velocity.set(vx * dashMultiplier, vy, vz * dashMultiplier)

    SPEAR_RUNTIME.dashActive = true
    SPEAR_RUNTIME.dashEndTime = now + SPEAR_RUNTIME.dashDuration
    SPEAR_RUNTIME.nextDashTime = now + dashCooldown

    if isCreativeOrFlying() then
        Core.Debug.log("[SPAERZ] Creative dash used (half power, 1s cooldown)")
    else
        Core.Debug.log("[SPAERZ] Survival dash used (full power, 3s cooldown)")
    end
end

function mainLogicFunction()
    if not Game.LocalPlayer.Loaded or not Game.World.Loaded then
        restoreLastBaseDamage()
        return
    end

    local now = Core.System.getTime()

    local item, itemId, baseDamage = getHeldSpearInfo()
    if item and Game.Gamepad.isDown(Game.Gamepad.KeyCodes.L) then
        performDash()
    end

    if SPEAR_RUNTIME.dashActive and now >= SPEAR_RUNTIME.dashEndTime then
        SPEAR_RUNTIME.dashActive = false
    end

    if item and Game.Gamepad.isDown(Game.Gamepad.KeyCodes.R) then
        local speedMagnitude = getVelocityMagnitudeAllDirections()
        local boostedDamage = baseDamage + (speedMagnitude * SPEAR_RUNTIME.velocityDamageMultiplier)
        applyHeldSpearDamage(boostedDamage)
    else
        restoreLastBaseDamage()
    end
end

local function startSpearVelocitySystem()
    if SPEAR_RUNTIME.started then
        return
    end

    SPEAR_RUNTIME.started = true

    Async.run(function()
        while true do
            mainLogicFunction()
            Async.wait(SPEAR_RUNTIME.loopDelay)
        end
    end)

    Core.Debug.message("SPAERZ runtime started.")
end

local rootFolder = Core.Menu.getMenuFolder()
local mainFolder = rootFolder:newFolder("SPAERZ (Spears)")

mainFolder:newEntry("Credit(s)", function()
    Core.Menu.showMessageBox("Modname(s): SPAERZ\nDeveloper: Cracko298\n\nRelease Build")
end)

mainFolder:newEntry("Start Spear Runtime Manually", function()
    startSpearVelocitySystem()
    Core.Debug.log("[SPAERZ] Started SPAERZ Runtime Loop Manually.", true)
end)

Game.World.OnWorldJoin:Connect(function()
    Core.Debug.log("[SPAERZ] Started SPAERZ Runtime Loop.", true)
    startSpearVelocitySystem()
end)

Game.World.OnWorldLeave:Connect(function()
    restoreLastBaseDamage()
end)

if Game.LocalPlayer.Loaded and Game.World.Loaded then
    Core.Debug.log("[SPAERZ] Started SPAERZ Runtime Loop (Ignore this Log).")
    startSpearVelocitySystem()
end
