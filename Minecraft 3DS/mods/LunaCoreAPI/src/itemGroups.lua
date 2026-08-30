CoreAPI.ItemGroups = {
    BUILDING_BOCKS = 1,
    DECORATION = 2,
    REDSTONE = 3,
    FOOD_MINERALS = 4,
    TOOLS = 5,
    POTIONS = 6,
    OTHERS = 7
}

local OnGameRegisterCreativeItems = Game.Items.OnRegisterCreativeItems

local ItemGroupEntry = CoreAPI.ItemGroupEntry

---Helper function to add new entries to a creative group category
---@param itemGroup number
---@param registerFun fun(entries: LCAPI_ItemGroupEntry): nil
function CoreAPI.ItemGroups.registerEntries(itemGroup, registerFun)
    if itemGroup < 1 or itemGroup > 7 then
        error("Invalid item group ID")
    end
    local entries = ItemGroupEntry(itemGroup)
    OnGameRegisterCreativeItems:Connect(function ()
        registerFun(entries)
    end)
end