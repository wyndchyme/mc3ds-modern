-- this code is messy so i can't fully recommend diving through it unless you know very well what you're doing

-- generic variables
local gamepad = Game.Gamepad
local keys = gamepad.KeyCodes
local Keyboard = Core.Keyboard
local keyboardOpen = false
local player = Game.LocalPlayer
local logger = CoreAPI.Utils.Logger.newLogger("craftrcheatmenu")

local mainFolder = Core.Menu.getMenuFolder()
local CTRCCfolder = mainFolder:newFolder("CrafTRCheatConsole")
local gamemodesFolder = CTRCCfolder:newFolder("Gamemodes")
gamemodesFolder:newEntry("Survival", function ()
    if Game.World.Loaded then
        if not Core.Graphics.isOpen() then
	    	player.Gamemode = 0
			Core.Menu.showMessageBox("Changed gamemode to Survival!")
		end
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
gamemodesFolder:newEntry("Creative", function ()
    if Game.World.Loaded then
        if not Core.Graphics.isOpen() then
	    	player.Gamemode = 1
			Core.Menu.showMessageBox("Changed gamemode to Creative!")
		end
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
gamemodesFolder:newEntry("Adventure", function ()
    if Game.World.Loaded then
        if not Core.Graphics.isOpen() then
	    	player.Gamemode = 3
			Core.Menu.showMessageBox("Changed gamemode to Adventure!")
		end
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
gamemodesFolder:newEntry("The secret 4th one", function ()
    if Game.World.Loaded then
        if not Core.Graphics.isOpen() then
	    	player.Gamemode = 6
			Core.Menu.showMessageBox("Changed gamemode to ???!")
		end
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
local itemsFolder = CTRCCfolder:newFolder("Item Utilities")
itemsFolder:newEntry("Give Item (overwrites hand slot)", function ()
    if Game.World.Loaded then
		local tempItemID = Keyboard.getString("Item ID:")
		if tempItemID == nil then
			Core.Menu.showMessageBox("No text input.")
			return
		end
		tryItem = CoreAPI.Items.getItem(tempItemID)
		if tryItem == nil then
			Core.Menu.showMessageBox("Invalid item ID!")
			return
		end
		itemCount = Keyboard.getNumber("Count:")
		if itemCount == nil then
			Core.Menu.showMessageBox("No item quantity provided!")
			return
		elseif itemCount == 0 then
			Core.Menu.showMessageBox("Cannot give 0 of an item!")
			return
		end
		itemData = Keyboard.getNumber("Data (optional):")
		if itemData ~= nil then
			player.Inventory.Slots["hand"].Item = tryItem
			player.Inventory.Slots["hand"].ItemCount = itemCount
			player.Inventory.Slots["hand"].ItemData = itemData
		else
			player.Inventory.Slots["hand"].Item = tryItem
			player.Inventory.Slots["hand"].ItemCount = itemCount
			player.Inventory.Slots["hand"].ItemData = 0
		end
		Core.Menu.showMessageBox("Item given\n(may need relog to render properly)")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
itemsFolder:newEntry("Modify Held Item Data", function ()
    if Game.World.Loaded then
		itemData = Keyboard.getNumber("Data:")
		if itemData ~= nil then
			player.Inventory.Slots["hand"].ItemData = itemData
			Core.Menu.showMessageBox("Item data changed: "..itemData)
		else
			Core.Menu.showMessageBox("Item unmodified. (No data)")
		end
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
itemsFolder:newEntry("Swap held item to head (DELETES HELMETS)", function ()
    if Game.World.Loaded then
		local tempItem = player.Inventory.Slots["hand"]
		if tempItem.Item ~= nil then
			player.Inventory.ArmorSlots["helmet"].Item = tempItem.Item
			player.Inventory.ArmorSlots["helmet"].ItemCount = tempItem.ItemCount
			player.Inventory.ArmorSlots["helmet"].ItemData = tempItem.ItemData
		else
			Core.Menu.showMessageBox("Your hand slot is empty!")
			return
		end
		tempItem.ItemCount = 0
		Core.Menu.showMessageBox("Equipped held item to hat slot!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
local weatherFolder = CTRCCfolder:newFolder("Weather")
weatherFolder:newEntry("Clear All Weather", function ()
    if Game.World.Loaded then
		Game.World.Raining = false
		Game.World.Thunderstorm = false
		Core.Menu.showMessageBox("Weather cleared!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
weatherFolder:newEntry("Set Weather to Rain", function ()
    if Game.World.Loaded then
		Game.World.Raining = true
		Game.World.Thunderstorm = false
		Core.Menu.showMessageBox("Weather set to rain!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
weatherFolder:newEntry("Set Weather to Thunder", function ()
    if Game.World.Loaded then
		Game.World.Raining = true
		Game.World.Thunderstorm = true
		Core.Menu.showMessageBox("Weather set to thunder!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
CTRCCfolder:newEntry("FOV Adjust", function ()
    if Game.World.Loaded then
		player.Camera.FOV = Keyboard.getNumber("FOV:")
		fovFile = Core.Filesystem.open("sdmc:/Minecraft 3DS/mods/CrafTRCheatConsole/fov.txt", "w")
		if fovFile ~= nil then
			if not fovFile:write(tostring(player.Camera.FOV)) then
				Core.Menu.showMessageBox("FOV applied, but couldn't write to file!")
			else
				Core.Menu.showMessageBox("Successfully saved and applied FOV.")
			end
			fovFile:close()
		else
			Core.Menu.showMessageBox("FOV applied, but couldn't write to file: FOV.txt failed to load.")
		end
	else
		fovFile = Core.Filesystem.open("sdmc:/Minecraft 3DS/mods/CrafTRCheatConsole/fov.txt", "w")
		if fovFile ~= nil then
			if not fovFile:write(tostring(Keyboard.getNumber("FOV:"))) then
				Core.Menu.showMessageBox("Failed to write FOV!")
			else
				Core.Menu.showMessageBox("Successfully saved FOV. Open a world to apply!")
			end
			fovFile:close()
		else
			Core.Menu.showMessageBox("FOV.txt failed to load.")
		end
	end
end)
local cheatFolder = CTRCCfolder:newFolder("Cheats")
cheatFolder:newEntry("Toggle Flight", function ()
    if Game.World.Loaded then
		if not player.CanFly then
			player.CanFly = true
			Core.Menu.showMessageBox("You can now fly!")
		else
			player.CanFly = false
			Core.Menu.showMessageBox("Flight disabled.")
		end
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
cheatFolder:newEntry("Boost Speed", function ()
    if Game.World.Loaded then
			local multiplier = Keyboard.getNumber("Speed Multiplier:")
			player.BaseMoveSpeed = 0.1 * multiplier
			player.MoveSpeed = 0.1 * multiplier
			player.SwimSpeed = 0.04 * multiplier
			player.FlySpeed = 0.05 * multiplier
			if multipier == 1 then
				Core.Menu.showMessageBox("Set speed to default!")
			else
				Core.Menu.showMessageBox("Set speed multiplier to "..multiplier)
			end
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
cheatFolder:newEntry("Change Max Health", function ()
    if Game.World.Loaded then
			local newmaxhealth = math.min(1,Keyboard.getNumber("Max Health:")) --please dont give yourself negative health
			player.MaxHP = newmaxhealth
			if newmaxhealth == 20 then
				Core.Menu.showMessageBox("Set max health to default!")
			elseif newmaxhealth == 1 then
				Core.Menu.showMessageBox("Set max health to half a heart! What are you doing, a challenge run?")
			else
				Core.Menu.showMessageBox("Set max health to "..newmaxhealth)
			end
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
cheatFolder:newEntry("Full Heal", function ()
    if Game.World.Loaded then
		player.CurrentHP = player.MaxHP
		player.CurrentHunger = 20
		Core.Menu.showMessageBox("Player fully healed!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
cheatFolder:newEntry("The Button That Kills You Instantly", function ()
    if Game.World.Loaded then
		player.CurrentHP = -1
		Core.Menu.showMessageBox("Ouch! That looked like it hurt.")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
cheatFolder:newEntry("Add XP Levels", function ()
    if Game.World.Loaded then
		player.CurrentLevel = player.CurrentLevel + Keyboard.getNumber("Levels:")
		Core.Menu.showMessageBox("Added levels!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
local movementFolder = CTRCCfolder:newFolder("Movement/Teleport Utilities")
movementFolder:newEntry("Teleport To Coordinates", function ()
    if Game.World.Loaded then
		local telex = Keyboard.getNumber("X coordinate:")
		local teley = Keyboard.getNumber("Y coordinate:")
		local telez = Keyboard.getNumber("Z coordinate:")
		if telex == nil or teley == nil or telez == nil then
			cheatAndGameLog("Invalid coords, will not teleport")
			return
		end
		player.Position.set(telex, teley, telez)
		Core.Menu.showMessageBox("Teleported to X: "..telex.." Y: "..teley.." Z: "..telez)
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
movementFolder:newEntry("Teleport Relative to Player", function ()
    if Game.World.Loaded then
		local currentx, currenty, currentz = Game.LocalPlayer.Position.get()
		local telex = Keyboard.getNumber("X coordinate:")
		local teley = Keyboard.getNumber("Y coordinate:")
		local telez = Keyboard.getNumber("Z coordinate:")
		if telex == nil or teley == nil or telez == nil then
			cheatAndGameLog("Invalid coords, will not teleport")
			return
		end
		player.Position.set(currentx+telex, currenty+teley, currentz+telez)
		Core.Menu.showMessageBox("Teleported to X: "..currentx+telex.." Y: "..currenty+teley.." Z: "..currentz+telez)
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)

Game.World.OnWorldJoin:Connect(function ()
	fovFile = Core.Filesystem.open("sdmc:/Minecraft 3DS/mods/CrafTRCheatConsole/fov.txt", "r")
		if fovFile ~= nil then
			player.Camera.FOV = tonumber(fovFile:read("*all"))
			fovFile:close()
		else
			player.Camera.FOV = 70
		end 
end)
