Game.World.OnWorldJoin:Connect(function()

    if Game.LocalPlayer.Sprinting == true then
        Game.LocalPlayer.SwimSpeed = 0.06
        Core.Debug.message("speed:"..Game.LocalPlayer.SwimSpeed)

        else Game.LocalPlayer.SwimSpeed = 0.04
    end
end)
