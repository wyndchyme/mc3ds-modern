Game.Recipes.OnRegisterRecipes:Connect(function (recipesTable)
    local muddy = Game.Items.findItemByName("tile.reserved6")
    local bucket = Game.Items.findItemByName("bucket")
    local dirty = Game.Items.findItemByName("dirt")
    if muddy and bucket and dirty then -- Check for mud recipe

        local dirt = Game.Items.getItemInstance(dirty, 4, 0)

        local mud = Game.Items.getItemInstance(muddy, 2, 0)
        
        Game.Recipes.registerShapedRecipe(recipesTable, mud, 1, 2048, "XX", "XX", "", {{"X", dirt}})
    end
    local muddy2 = Game.Items.findItemByName("tile.reserved6")
    local brick = Game.Items.findItemByName("tile.info_update2")
    if muddy2 and brick  then -- Check for 2x2 mud brick recipe

        local mudbrick = Game.Items.getItemInstance(brick, 4, 0)
        local mud = Game.Items.getItemInstance(muddy2, 4, 0)
        
        Game.Recipes.registerShapedRecipe(recipesTable, mudbrick, 1, 2049, "XX", "XX", " ", {{"X", mud}})
    end
    local tuffy = Game.Items.findItemByName("tile.info_update")
    local tpolish = Game.Items.findItemByName("tile.stonecutter")
    if tuffy and tpolish  then -- Check for 2x2 polished tuff recipe

        local tuffpolish = Game.Items.getItemInstance(tpolish, 4, 0)
        local tuff = Game.Items.getItemInstance(tuffy, 4, 0)
        
        Game.Recipes.registerShapedRecipe(recipesTable, tuffpolish, 1, 2050, "XX", "XX", " ", {{"X", tuff}})
    end
    -- r.i.p. nether reactor core / deepslate bricks. gone but not forgotten. 3.0 - 3.1.0
end)