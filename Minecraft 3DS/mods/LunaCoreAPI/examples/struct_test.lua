local stoneTier = CoreAPI.Tools.Tiers.STONE
stoneTier.Durability = -1

Game.Gamepad.OnKeyPressed:Connect(function ()
    Core.Debug.message("Stone tier")
    Core.Debug.message("Durability: "..stoneTier.Durability)
end)