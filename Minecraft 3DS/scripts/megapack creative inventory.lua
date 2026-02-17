CoreAPI.ItemGroups.registerEntries(1, function (entries)
    mud = Game.Items.findItemByName("tile.reserved6")
    mudbricks = Game.Items.findItemByName("tile.info_update2")

    tuff = Game.Items.findItemByName("tile.info_update")
    polished_tuff = Game.Items.findItemByName("tile.netherreactor")
    tuff_bricks = Game.Items.findItemByName("tile.stonecutter")


    entries:addAfter(tuff_bricks, "dirt")
    entries:addAfter(polished_tuff, "dirt")
    entries:addAfter(tuff, "dirt")
    entries:addAfter(mudbricks, "dirt")
    entries:addAfter(mud, "dirt")
end)