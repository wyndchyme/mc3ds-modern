--[[ 
KNOWN BUGS WITH THIS MOD:
Fireworks can be used without actively flying as long as elytra is equipped: You can't check elytra flight with LunaCore right now :()
No flight durations: don't know how to implement that given the shitty horizontal speed limitations this game puts on elytras
]]

local testModReg = CoreAPI.Items.newItemRegistry("suspiciousstewmod")

local DANDELION_STEW = testModReg:registerItem("dandelion", 253, {
    texture = "items/suspiciousstew.3dst", 
    locales = {
        en_US = "Suspicious Stew",
        en_GB = "Suspicious Stew",
        ru_RU = "Suspicious Stew"
    }
})
local POPPY_STEW = testModReg:registerItem("poppy", 252, {
    texture = "items/suspiciousstew.3dst", 
    locales = {
        en_US = "Suspicious Stew",
        en_GB = "Suspicious Stew",
        ru_RU = "Suspicious Stew"
    }
})
local BLUE_ORCHID_STEW = testModReg:registerItem("blue_orchid", 251, {
    texture = "items/suspiciousstew.3dst", 
    locales = {
        en_US = "Suspicious Stew",
        en_GB = "Suspicious Stew",
        ru_RU = "Suspicious Stew"
    }
})
local ALLIUM_STEW = testModReg:registerItem("allium", 250, {
    texture = "items/suspiciousstew.3dst", 
    locales = {
        en_US = "Suspicious Stew",
        en_GB = "Suspicious Stew",
        ru_RU = "Suspicious Stew"
    }
})
local AZURE_BLUET_STEW = testModReg:registerItem("azure_bluet", 249, {
    texture = "items/suspiciousstew.3dst", 
    locales = {
        en_US = "Suspicious Stew",
        en_GB = "Suspicious Stew",
        ru_RU = "Suspicious Stew"
    }
})
local TULIPS_STEW = testModReg:registerItem("tulips", 248, {
    texture = "items/suspiciousstew.3dst", 
    locales = {
        en_US = "Suspicious Stew",
        en_GB = "Suspicious Stew",
        ru_RU = "Suspicious Stew"
    }
})
local OXEYE_DAISY_STEW = testModReg:registerItem("oxeye_daisy", 247, {
    texture = "items/suspiciousstew.3dst", 
    locales = {
        en_US = "Suspicious Stew",
        en_GB = "Suspicious Stew",
        ru_RU = "Suspicious Stew"
    }
})

CoreAPI.ItemGroups.registerEntries(CoreAPI.ItemGroups.FOOD_MINERALS, function (entries)
    entries:add(DANDELION_STEW)
    entries:add(POPPY_STEW)
    entries:add(BLUE_ORCHID_STEW)
    entries:add(ALLIUM_STEW)
    entries:add(AZURE_BLUET_STEW)
    entries:add(TULIPS_STEW)
    entries:add(OXEYE_DAISY_STEW)
end)


Game.Recipes.OnRegisterRecipes:Connect(function (recipesTable)
    local dandelion = Game.Items.findItemByID(37)
    local poppy = Game.Items.findItemByID(38)
    local redshroom = Game.Items.findItemByID(40) --of course red is 40.
    local brownshroom = Game.Items.findItemByID(39)
    local bowl = Game.Items.findItemByID(281)
    if dandelion and poppy and redshroom and brownshroom and bowl and DANDELION_STEW then
        local dlIns = Game.Items.getItemInstance(dandelion, 1, 0)
        local bowlIns = Game.Items.getItemInstance(bowl, 1, 0)
        local rsIns = Game.Items.getItemInstance(redshroom, 1, 0)
        local bsIns = Game.Items.getItemInstance(brownshroom, 1, 0)
        local dlStewOut = Game.Items.getItemInstance(DANDELION_STEW, 1, 0)
        Game.Recipes.registerShapedRecipe(recipesTable, dlStewOut, 3, 50, "#B", "RF", "", {{"#", bowlIns}, {"B", bsIns}, {"R", rsIns}, {"F", dlIns}})
        local poppyIns = Game.Items.getItemInstance(poppy, 1, 0)
        local poppyStewOut = Game.Items.getItemInstance(POPPY_STEW, 1, 0)
        Game.Recipes.registerShapedRecipe(recipesTable, poppyStewOut, 3, 50, "#B", "RF", "", {{"#", bowlIns}, {"B", bsIns}, {"R", rsIns}, {"F", poppyIns}})
        local blorchidIns = Game.Items.getItemInstance(poppy, 1, 1)
        local blorchidStewOut = Game.Items.getItemInstance(BLUE_ORCHID_STEW, 1, 0)
        Game.Recipes.registerShapedRecipe(recipesTable, blorchidStewOut, 3, 50, "#B", "RF", "", {{"#", bowlIns}, {"B", bsIns}, {"R", rsIns}, {"F", blorchidIns}})
        local alliumIns = Game.Items.getItemInstance(poppy, 1, 2)
        local alliumStewOut = Game.Items.getItemInstance(ALLIUM_STEW, 1, 0)
        Game.Recipes.registerShapedRecipe(recipesTable, alliumStewOut, 3, 50, "#B", "RF", "", {{"#", bowlIns}, {"B", bsIns}, {"R", rsIns}, {"F", alliumIns}})
        local azbIns = Game.Items.getItemInstance(poppy, 1, 3)
        local azbStewOut = Game.Items.getItemInstance(AZURE_BLUET_STEW, 1, 0)
        Game.Recipes.registerShapedRecipe(recipesTable, azbStewOut, 3, 50, "#B", "RF", "", {{"#", bowlIns}, {"B", bsIns}, {"R", rsIns}, {"F", azbIns}})
        local tulipAIns = Game.Items.getItemInstance(poppy, 1, 4)
        local tulipBIns = Game.Items.getItemInstance(poppy, 1, 5)
        local tulipCIns = Game.Items.getItemInstance(poppy, 1, 6)
        local tulipDIns = Game.Items.getItemInstance(poppy, 1, 7)
        local tulipStewOut = Game.Items.getItemInstance(TULIPS_STEW, 1, 0)
        Game.Recipes.registerShapedRecipe(recipesTable, tulipStewOut, 3, 50, "#B", "RF", "", {{"#", bowlIns}, {"B", bsIns}, {"R", rsIns}, {"F", tulipAIns}})
        Game.Recipes.registerShapedRecipe(recipesTable, tulipStewOut, 3, 50, "#B", "RF", "", {{"#", bowlIns}, {"B", bsIns}, {"R", rsIns}, {"F", tulipBIns}})
        Game.Recipes.registerShapedRecipe(recipesTable, tulipStewOut, 3, 50, "#B", "RF", "", {{"#", bowlIns}, {"B", bsIns}, {"R", rsIns}, {"F", tulipCIns}})
        Game.Recipes.registerShapedRecipe(recipesTable, tulipStewOut, 3, 50, "#B", "RF", "", {{"#", bowlIns}, {"B", bsIns}, {"R", rsIns}, {"F", tulipDIns}})
        local daisyIns = Game.Items.getItemInstance(poppy, 1, 8)
        local daisyStewOut = Game.Items.getItemInstance(OXEYE_DAISY_STEW, 1, 0)
        Game.Recipes.registerShapedRecipe(recipesTable, daisyStewOut, 3, 50, "#B", "RF", "", {{"#", bowlIns}, {"B", bsIns}, {"R", rsIns}, {"F", daisyIns}})
    end
end)

testModReg:buildResources()

collectgarbage("collect")
