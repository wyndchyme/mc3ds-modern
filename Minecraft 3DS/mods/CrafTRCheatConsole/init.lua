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

disableMobCap = false
particlePatch = true

function writeScale(scale)
	-- thanks Cracko
    Core.Memory.writeFloat(0x600BF0, 1.6200000047684*scale)
    Core.Memory.writeFloat(0x60370C, 1.6200001239777*scale)
    Core.Memory.writeFloat(0x607270, 1.6200000047684*scale)
    Core.Memory.writeFloat(0x607274, 1.7999999523163*scale)
    Core.Memory.writeFloat(0x60804C, 1.6200000047684*scale)
    Core.Memory.writeFloat(0x7218F4, 1.6200000047684*scale)
    Core.Memory.writeFloat(0x735020, 1.6200000047684*scale)
    Core.Memory.writeFloat(0x988BB8, 1.6200000047684*scale)
end

function writeMobToPlayer(mob)
	baseAddr = Core.Memory.readU32(0xFFFDF74)
	Core.Memory.writeU8(baseAddr+0x278, mob)
end

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
	    	player.Gamemode = 9
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
itemsFolder:newEntry("Give Item (numerical ID, best for blocks)", function ()
    if Game.World.Loaded then
		local tempItemID = Keyboard.getNumber("Item ID:")
		if tempItemID == nil then
			Core.Menu.showMessageBox("No text input.")
			return
		end
		tryItem = Game.Items.findItemByID(tempItemID)
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
local cheatFolder = CTRCCfolder:newFolder("Player Modifiers")
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
			local newmaxhealth = math.max(1,Keyboard.getNumber("Max Health:")) --please dont give yourself negative health
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
cheatFolder:newEntry("Set Health", function ()
    if Game.World.Loaded then
		player.CurrentHP = Keyboard.getNumber("Health:")
		Core.Menu.showMessageBox("Set health!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
cheatFolder:newEntry("Change Max Hunger", function ()
    if Game.World.Loaded then
			local newmaxhealth = math.max(1,Keyboard.getNumber("Max Hunger:")) --please dont give yourself negative health
			player.MaxHunger = newmaxhealth
			if newmaxhealth == 20 then
				Core.Menu.showMessageBox("Set max hunger to default!")
			else
				Core.Menu.showMessageBox("Set max hunger to "..newmaxhealth)
			end
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
cheatFolder:newEntry("Set Hunger", function ()
    if Game.World.Loaded then
		player.CurrentHunger = Keyboard.getNumber("Hunger:")
		Core.Menu.showMessageBox("Set hunger!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
cheatFolder:newEntry("Full Heal", function ()
    if Game.World.Loaded then
		player.CurrentHP = player.MaxHP
		player.CurrentHunger = player.MaxHunger
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
cheatFolder:newEntry("Change Player Scale", function ()
    if Game.World.Loaded then
		writeScale(Keyboard.getNumber("Scale multiplier:"))
		Core.Menu.showMessageBox("Changed player scaling! (Relog might be necessary)")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
local mobMorphFolder = cheatFolder:newFolder("Mob Morphs")
mobMorphFolder:newEntry("Player (default)", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x1E)
		Core.Menu.showMessageBox("Reverted player to default!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Chicken", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x05)
		Core.Menu.showMessageBox("Morphed player into chicken!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Cow", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x06)
		Core.Menu.showMessageBox("Morphed player into cow!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Mooshroom", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x07)
		Core.Menu.showMessageBox("Morphed player into mooshroom!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Pig", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x08)
		Core.Menu.showMessageBox("Morphed player into pig!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Sheep", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x09)
		Core.Menu.showMessageBox("Morphed player into sheep!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Bat", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x0A)
		Core.Menu.showMessageBox("Morphed player into bat! (I'd recommend enabling flight next :3)")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Wolf", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x0B)
		Core.Menu.showMessageBox("Morphed player into wolf!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Ender Dragon (Might be buggy!)", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x0C)
		Core.Menu.showMessageBox("Morphed player into dragon!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Villager", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x0E)
		Core.Menu.showMessageBox("Morphed player into villager!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Zombie", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x10)
		Core.Menu.showMessageBox("Morphed player into zombie!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Zombified Piglin", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x11)
		Core.Menu.showMessageBox("Morphed player into zombie pigman!") -- i'm playing both sides, so that i always come out on top :100:
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Ghast", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x13)
		Core.Menu.showMessageBox("Morphed player into ghast!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Silverfish", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x17)
		Core.Menu.showMessageBox("Morphed player into silverfish!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Creeper", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x18)
		Core.Menu.showMessageBox("Morphed player into creeper!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Enderman", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x1A)
		Core.Menu.showMessageBox("Morphed player into enderman!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Shulker Bullet", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x1C)
		Core.Menu.showMessageBox("Morphed player into shulker bullet!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Iron Golem", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x30)
		Core.Menu.showMessageBox("Morphed player into iron golem!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Cat", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x31)
		Core.Menu.showMessageBox("Morphed player into cat!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Snow Golem", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x32)
		Core.Menu.showMessageBox("Morphed player into snow golem!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Guardian", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x3E)
		Core.Menu.showMessageBox("Morphed player into guardian!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Wither", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x41)
		Core.Menu.showMessageBox("Morphed player into wither!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("EXP Orb", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x2E)
		Core.Menu.showMessageBox("Morphed player into an experience orb! (teeny tiny :3)")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Zombie Villager", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x2D)
		Core.Menu.showMessageBox("Morphed player into a zombie villager!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Shulker", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x33)
		Core.Menu.showMessageBox("Morphed player into a shulker!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Rabbit", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x35)
		Core.Menu.showMessageBox("Morphed player into a rabbit!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Witch", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x36)
		Core.Menu.showMessageBox("Morphed player into a witch!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Llama", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x38)
		Core.Menu.showMessageBox("Morphed player into a llama!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Camera (Edu)", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x39)
		Core.Menu.showMessageBox("Morphed player into a camera!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Husk", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x44)
		Core.Menu.showMessageBox("Morphed player into a husk!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Stray", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x45)
		Core.Menu.showMessageBox("Morphed player into a stray!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Skeleton (A)", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x46)
		Core.Menu.showMessageBox("Morphed player into a skeleton!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Skeleton (B)", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x15)
		Core.Menu.showMessageBox("Morphed player into a skeleton!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Endermite", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x49)
		Core.Menu.showMessageBox("Morphed player into an endermite!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Evoker", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x4A)
		Core.Menu.showMessageBox("Morphed player into an evoker!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Vex", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x4C)
		Core.Menu.showMessageBox("Morphed player into a vex!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Vindicator", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x4D)
		Core.Menu.showMessageBox("Morphed player into a vindicator!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Polar Bear", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x0D)
		Core.Menu.showMessageBox("Morphed player into a polar bear!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
mobMorphFolder:newEntry("Blaze", function ()
    if Game.World.Loaded then
		writeMobToPlayer(0x14)
		Core.Menu.showMessageBox("Morphed player into a blaze!")
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
			Core.Menu.showMessageBox("Invalid coords, will not teleport")
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
			Core.Menu.showMessageBox("Invalid coords, will not teleport")
			return
		end
		player.Position.set(currentx+telex, currenty+teley, currentz+telez)
		Core.Menu.showMessageBox("Teleported to X: "..currentx+telex.." Y: "..currenty+teley.." Z: "..currentz+telez)
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
local worldFolder = CTRCCfolder:newFolder("World Utilities")
worldFolder:newEntry("Remove Mob Spawn Cap", function ()
    if Game.World.Loaded then
        disableMobCap = not disableMobCap
        if disableMobCap then
            Core.Menu.showMessageBox("Mob cap disabled!")
        else
            Core.Menu.showMessageBox("Mob cap enabled!")
        end
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
worldFolder:newEntry("Change Gravity", function ()
    if Game.World.Loaded then
		Core.Memory.writeFloat(0x4ED468, Keyboard.getNumber("Gravity (~0.08 default):"))
		Core.Menu.showMessageBox("Changed gravity!")
	else
		Core.Menu.showMessageBox("First enter a world!")
	end
end)
worldFolder:newEntry("Enhanced Particles (Cracko298)", function ()
    if Game.World.Loaded then
        particlePatch = not particlePatch
        if particlePatch then
            Core.Menu.showMessageBox("Particle patch enabled!")
        else
            Core.Menu.showMessageBox("Particle patch disabled!")
        end
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
        Async.run(function()
            while Async.wait(0.05) and Game.World.Loaded do
                if disableMobCap == true then
                    --thank you to the goat Cracko298's megapackPlugin, would not be possible without him
                    Core.Memory.writeU32(0xA33898, 0x00)
                    Core.Memory.writeU32(0xA338A8, 0x00)
                    Core.Memory.writeU32(0xA338AC, 0x00)
                    Core.Memory.writeU32(0xA338B0, 0x00)
                    Core.Memory.writeU32(0xA338B4, 0x00)
                    Core.Memory.writeU32(0xA338B8, 0x00)
                    Core.Memory.writeU32(0xA338BC, 0x00)
                    Core.Memory.writeU32(0xA338C0, 0x00)
                end
                if particlePatch == true then
                    Core.Memory.writeU8(0x14A4F, 0xE2)
                end
             end
        end)
end)
