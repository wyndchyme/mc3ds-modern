--[[ 
KNOWN BUGS WITH THIS MOD:
Fireworks can be used without actively flying as long as elytra is equipped: You can't check elytra flight with LunaCore right now :()
No flight durations: don't know how to implement that given the shitty horizontal speed limitations this game puts on elytras
]]

local testModReg = CoreAPI.Items.newItemRegistry("fireworkmod")

local FIREWORK_ROCKET = testModReg:registerItem("firework_rocket", 254, {
    texture = "items/firework_rocket.3dst", 
    locales = {
        en_US = "Firework Rocket",
        es_MX = "Firework Rocket"
    }
})

CoreAPI.ItemGroups.registerEntries(CoreAPI.ItemGroups.TOOLS, function (entries)
    entries:addAfter(FIREWORK_ROCKET, "flint_and_steel")
end)

function angToVec(pitch, yaw)
	local yawRad = math.rad(yaw)
	local pitchRad = math.rad(pitch)
	local x = (-math.sin(yawRad) * math.cos(pitchRad))
	local y = -math.sin(pitchRad)
	local z = (math.cos(yawRad) * math.cos(pitchRad))
	return {x=x, y=y, z=z}
end

local player = Game.LocalPlayer
local gamepad = Game.Gamepad
local first = true

Game.World.OnWorldJoin:Connect(function ()
    if first then
        fwItem = Game.Items.findItemByName("fireworkmod_firework_rocket")
        elytraItem = Game.Items.findItemByName("elytra")

        Game.Gamepad.OnKeyPressed:Connect(function ()
            if Game.World.Loaded then
                if gamepad.isDown(gamepad.KeyCodes.L) then
                    local playerHand = player.Inventory.Slots["hand"]
                    local playerChest = player.Inventory.ArmorSlots["chestplate"]
                    if not playerHand:isEmpty() and playerHand.Item == fwItem and playerChest.Item == elytraItem then
                        local elyDir = angToVec(Game.LocalPlayer.Camera.Pitch, Game.LocalPlayer.Camera.Yaw)
                        Game.LocalPlayer.Velocity.set(elyDir.x, elyDir.y, elyDir.z)
                        if player.Gamemode ~= 1 then
                            playerHand.ItemCount = playerHand.ItemCount - 1
                        end
                    end
                end
            end
        end)
        first = false
    end
end)

Game.Recipes.OnRegisterRecipes:Connect(function (recipesTable)
    local gp = Game.Items.findItemByName("gunpowder")
    local paper = Game.Items.findItemByName("paper")
    if gp and paper and FIREWORK_ROCKET then
        local gpIns = Game.Items.getItemInstance(gp, 1, 0)
        local paperIns = Game.Items.getItemInstance(paper, 1, 0)
        local rocketOut = Game.Items.getItemInstance(FIREWORK_ROCKET, 3, 0)
        Game.Recipes.registerShapedRecipe(recipesTable, rocketOut, 2, 50, "X#", "", "", {{"X", gpIns}, {"#", paperIns}})
    end
end)

testModReg:buildResources()
