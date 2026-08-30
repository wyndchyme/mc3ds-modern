local BLOCKS_ID = {137, 188, 189, 252, 246, 247, 248, 249, 255}

CoreAPI.ItemGroups.registerEntries(CoreAPI.ItemGroups.OTHERS, function (entries)
    local curIdx = -50
    for _, id in ipairs(BLOCKS_ID) do
        local block = Game.Items.findItemByID(id)
        if block then
            entries:add(block, curIdx)
            curIdx = curIdx + 1
        end
    end
end)