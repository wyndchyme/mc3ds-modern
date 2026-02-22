--thank you STBUniverse/STBrian for writing this for me based on the function pointers
Game.World.OnWorldJoin:Connect(Async.create(function ()
    while Game.World.Loaded do
        if Game.Gamepad.isPressed(Game.Gamepad.KeyCodes.DPADLEFT) then
            local entityRenderDispatcherInsP = Core.Memory.readU32(0xA3226C) or 0
            local clientInstanceP = Core.Memory.readU32(entityRenderDispatcherInsP + 4 * 3)
            Core.Memory.call(0x3E99DC, "P", "", clientInstanceP)
        end
        Async.wait()
    end
end))
