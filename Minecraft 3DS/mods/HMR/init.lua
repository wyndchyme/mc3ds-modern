local LOGGER = CoreAPI.Utils.Logger.newLogger("HMR")
local hmrModReg = CoreAPI.Items.newItemRegistry("HMR") -- This must be the same as the mod name in mod.json

-- Tier for the Mace
local MaceTier = Game.Items.newToolTier()
MaceTier.MiningLevel = 0
MaceTier.Durability = 500
MaceTier.MiningEfficiency = 1
MaceTier.DamageBonus = 3
MaceTier.Enchantability = 15

-- Defs for registering the Mace \(^-^)/
local MACE_WEAPON = hmrModReg:registerItem("mace_weapon", 131, {
    texture = "items/mace.3dst",
    locales = {
        en_US = "Mace"
    },
    tool = "sword",
    tier = MaceTier
})
Core.Debug.log("[HMR] Registered Mace - Name: " .. MACE_WEAPON.NameID .. " | ID: " .. MACE_WEAPON.ID)
-- MACE_WEAPON.StackSize = 1

CoreAPI.ItemGroups.registerEntries(CoreAPI.ItemGroups.TOOLS, function (entries)
    entries:addAfter(MACE_WEAPON, "lead")
end)
Core.Debug.log("[HMR] Added Mace Weapon to Creative and Crafting Menu.", false)

-- Register Recipe for the Mace :3c
Game.Recipes.OnRegisterRecipes:Connect(function (recipesTable)
    local netherStar = Game.Items.findItemByID(399)
    local obsidian = Game.Items.findItemByID(49)
    local blazeRod = Game.Items.findItemByID(369)
    local diamond = Game.Items.findItemByID(264)
    if netherStar and obsidian and blazeRod and diamond then -- Check no nil
        local netherStarInst = Game.Items.getItemInstance(netherStar, 1, 0)
        local obsidianInst = Game.Items.getItemInstance(obsidian, 1, 0)
        local blazeRodInst = Game.Items.getItemInstance(blazeRod, 1, 0)
        local diamondInst = Game.Items.getItemInstance(diamond, 1, 0)
        local maceWeaponInst = Game.Items.getItemInstance(MACE_WEAPON, 1, 0)
        Game.Recipes.registerShapedRecipe(recipesTable, maceWeaponInst, 2, 510, "DND", "OBO", " B ", {{"D", diamondInst}, {"N", netherStarInst}, {"O", obsidianInst}, {"B", blazeRodInst}})
    end
end)
Core.Debug.log("[HMR] Registered the Crafting Recipe for Mace Weapon.", false)

-- Build the Resources when loading the mod for the first time.
hmrModReg:buildResources()

-- Mace Logic System
local MIN_FALL_FOR_BONUS = 3.0
local FALL_DAMAGE_SCALE = 2.0
local MAX_BONUS_DAMAGE = 20

local MACE_ITEM_ID = 131
local BONUS_DAMAGE_OFFSET = 0xAC

local maceState = {
    weaponPtr = 0,
    originalBonus = 0,
    initialized = false,
    lastWritten = nil,
    started = false,
    loopDelay = 0.01
}

local fallTracker = {
    lastY = nil,
    falling = false,
    fallStartY = 0.0,
    fallDistance = 0.0
}

local function getHandSlot()
    return Game.LocalPlayer.Inventory.Slots["hand"]
end

local function isHoldingMace()
    local hand = getHandSlot()
    if hand == nil or hand:isEmpty() or hand.Item == nil then
        return false
    end

    return hand.Item.ID == MACE_ITEM_ID
end

local function getMaceBonusDamage(fallDistance)
    if not fallDistance or fallDistance <= MIN_FALL_FOR_BONUS then
        return 0
    end

    local bonus = math.floor((fallDistance - MIN_FALL_FOR_BONUS) * FALL_DAMAGE_SCALE)

    if bonus < 0 then
        bonus = 0
    elseif bonus > MAX_BONUS_DAMAGE then
        bonus = MAX_BONUS_DAMAGE
    end

    return bonus
end

local function resetMacePointerState()
    if maceState.initialized and maceState.weaponPtr ~= 0 then
        Core.Memory.writeU32(maceState.weaponPtr + BONUS_DAMAGE_OFFSET, maceState.originalBonus)
    end

    maceState.weaponPtr = 0
    maceState.originalBonus = 0
    maceState.initialized = false
    maceState.lastWritten = nil
end

local function getHeldMacePointer()
    local hand = getHandSlot()
    if hand == nil or hand:isEmpty() or hand.Item == nil then
        return 0
    end

    if hand.Item.ID ~= MACE_ITEM_ID then
        return 0
    end

    if hand.Item.getAddress ~= nil then
        return hand.Item:getAddress()
    end

    return 0
end

local attackIFrames = {
    active = false,
    untilTime = 0
}

local function triggerAirAttackIFrames()
    if not Game.LocalPlayer then
        return
    end

    attackIFrames.active = true
    attackIFrames.untilTime = os.clock() + 0.5
    Game.LocalPlayer.Invincible = true
end

local function updateAirAttackIFrames()
    if not Game.LocalPlayer then
        return
    end

    if attackIFrames.active and os.clock() >= attackIFrames.untilTime then
        Game.LocalPlayer.Invincible = false
        attackIFrames.active = false
    end
end

local function updateFallDistance()
    local player = Game.LocalPlayer
    if not player then return 0 end

    local pos = player.Position
    if not pos then return 0 end

    local currentY = pos.y

    if fallTracker.lastY == nil then
        fallTracker.lastY = currentY
        return 0
    end

    local deltaY = currentY - fallTracker.lastY

    -- Detect falling
    if deltaY < 0 then
        if not fallTracker.falling then
            fallTracker.falling = true
            fallTracker.fallStartY = fallTracker.lastY
        end

        fallTracker.fallDistance = fallTracker.fallStartY - currentY
    else
        -- Landed or going up
        fallTracker.falling = false
        fallTracker.fallDistance = 0
    end

    fallTracker.lastY = currentY
    return fallTracker.fallDistance
end

local function applyMaceFallDamage()
    if not Game.LocalPlayer or not Game.LocalPlayer.Inventory or not Game.World.Loaded then
        resetMacePointerState()
        maceState.started = false
        return
    end

    updateAirAttackIFrames()
    local ptr = getHeldMacePointer()
    if ptr == 0 then
        resetMacePointerState()
        return
    end

    if (not maceState.initialized) or maceState.weaponPtr ~= ptr then
        resetMacePointerState()

        maceState.weaponPtr = ptr
        maceState.originalBonus = Core.Memory.readU32(ptr + BONUS_DAMAGE_OFFSET)
        maceState.initialized = true
        maceState.lastWritten = maceState.originalBonus
    end

    local fallDistance = updateFallDistance()
    if isHoldingMace() and Controller:isKeyPressed(Game.KeyCodes.R) and not Game.LocalPlayer.OnGround then
        triggerAirAttackIFrames()
        local extraBonus = getMaceBonusDamage(fallDistance)
        local newBonus = maceState.originalBonus + extraBonus
    else
        local newBonus = maceState.originalBonus
    end

    updateAirAttackIFrames()
    if newBonus < 0 then
        newBonus = 0
    elseif newBonus > 0xFFFFFFFF then
        newBonus = 0xFFFFFFFF
    end

    if maceState.lastWritten ~= newBonus then
        Core.Memory.writeU32(ptr + BONUS_DAMAGE_OFFSET, newBonus)
        maceState.lastWritten = newBonus
    end
end

local function startMaceSystem()
    if maceState.started then
        return
    end

    maceState.started = true

    Async.run(function()
        while maceState.started do
            applyMaceFallDamage()
            Async.wait(maceState.loopDelay)
        end
    end)
end

local rootFolder = Core.Menu.getMenuFolder()
local mainFolder = rootFolder:newFolder("HMR (Hammer/Mace)")

mainFolder:newEntry("Credit(s)", function()
    Core.Menu.showMessageBox("Modname(s): HMR\nDeveloper: Cracko298\n\nRelease Build")
end)

mainFolder:newEntry("Start Mace Runtime Manually", function()
    startMaceSystem()
    Core.Debug.log("[HMR] Started Mace Runtime Loop Manually.", false)
end)

Game.World.OnWorldJoin:Connect(function()
    Core.Debug.log("[HMR] Started Mace Runtime Loop.", false)
    startMaceSystem()
end)

Game.World.OnWorldLeave:Connect(function()
    resetMacePointerState()
    maceState.started = false

end)

if Game.LocalPlayer.Loaded and Game.World.Loaded then
    Core.Debug.log("[HMR] Started Mace Runtime Loop (Ignore this Log).", false)
    startMaceSystem()
end
