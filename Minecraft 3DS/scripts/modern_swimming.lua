function angToVec(pitch, yaw)
	local yawRad = math.rad(yaw)
	local pitchRad = math.rad(pitch)
	local x = (-math.sin(yawRad) * math.cos(pitchRad))
	local y = -math.sin(pitchRad)
	local z = (math.cos(yawRad) * math.cos(pitchRad))
	return {x=x, y=y, z=z}
end

Async.run(function ()
    while Async.wait() do
        if Game.World.Loaded then
            if Game.LocalPlayer.Sprinting == true then
		Game.LocalPlayer.SwimSpeed = 0.06
		if Game.LocalPlayer.UnderWater == true then
			local swimMovement = angToVec(Game.LocalPlayer.Camera.Pitch, Game.LocalPlayer.Camera.Yaw)
			Game.LocalPlayer.Velocity.set(swimMovement.x*0.25, swimMovement.y*0.25, swimMovement.z*0.25)
		end
            else
		Game.LocalPlayer.SwimSpeed = 0.04
            end
        end
    end
end)

