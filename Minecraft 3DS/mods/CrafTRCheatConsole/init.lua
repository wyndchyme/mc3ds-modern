-- this code is messy so i can't fully recommend diving through it unless you know very well what you're doing

-- generic variables
local gamepad = Game.Gamepad
local keys = gamepad.KeyCodes
local Keyboard = Core.Keyboard
local keyboardOpen = false
local player = Game.LocalPlayer
local logger = CoreAPI.Utils.Logger.newLogger("craftrcheatmenu")
local commandPageLabels = {
	"Gamemode",
	"Items (Buggy!)",
	"Weather",
	"Rendering",
	"Mischief [Page 1]",
	"Mischief [Page 2]",
	"Credits"
}
local commonColors = {
	red = Core.Graphics.colorRGB(255, 0, 0),
	black = Core.Graphics.colorRGB(0, 0, 0),
	bg = Core.Graphics.colorRGB(139, 139, 139),
	section = Core.Graphics.colorRGB(22, 22, 22),
	span = Core.Graphics.colorRGB(56, 56, 56),
	button = Core.Graphics.colorRGB(109, 109, 109),
	white = Core.Graphics.colorRGB(255, 255, 255)
}
local frames = 0


--functions
local function drawStrokedRect(x,y,width,height,colorOut,colorIn)
        Core.Graphics.drawRectFill(x-2, y-2, width+4, height+4, colorOut)
        Core.Graphics.drawRectFill(x, y, width, height, colorIn)
end

local function drawCenteredLabel(text,x,y,width,height,color)
	local textx = x+(width-Core.Graphics.getTextWidth(text))/2
	local texty = y+(height-(16))/2
	Core.Graphics.drawText(text, textx+2, texty+2, commonColors.section)
	Core.Graphics.drawText(text, textx, texty, color)
end

function quickDrawButtons(text1, text2, text3)
	if text1 ~= nil then
        	drawStrokedRect(26, 46, 268, 40, commonColors.black, commonColors.button)
		drawCenteredLabel(text1, 26, 46, 268, 40, commonColors.white)
	end
	if text2 ~= nil then
        	drawStrokedRect(26, 92, 268, 40, commonColors.black, commonColors.button)
		drawCenteredLabel(text2, 26, 92, 268, 40, commonColors.white)
	end
	if text3 ~= nil then
       		drawStrokedRect(26, 140, 268, 40, commonColors.black, commonColors.button)
		drawCenteredLabel(text3, 26, 140, 268, 40, commonColors.white)
	end
end

local function cheatAndGameLog(text)
	cheatLog = text
	logger:info("cheatLog: "..text)
end

function checkTouchInBoundsOf(x,y,width,height)
	local touchx, touchy = Game.Gamepad.getTouch()
	return ((touchx > x and touchx < (x+width)) and (touchy > y and touchy < (y+height)))
end

-- main drawing section
local function drawGraphics(screen)
    if screen == "bottom" then
	Core.Graphics.drawRectFill(0, 0, 320, 240, commonColors.bg)
        drawStrokedRect(20, 20, 280, 200, commonColors.black, commonColors.section)
	if curPage == 1 then
        	quickDrawButtons("Survival", "Creative", "Adventure")
	elseif curPage == 2 then
        	quickDrawButtons("Replace Held Item", "Hand Item to Helmet (DELETES HELMET)")
       		drawStrokedRect(26, 140, 268, 40, commonColors.span, commonColors.black)
		drawCenteredLabel("Keep Inventory", 26, 140, 268, 40, Core.Graphics.colorRGB(127, 127, 127))
	elseif curPage == 3 then
		quickDrawButtons("Clear","Rain","Thunder")
	elseif curPage == 4 then
		drawStrokedRect(26, 46, 268, 40, commonColors.black, commonColors.span)
		drawStrokedRect(math.floor(((player.Camera.FOV/90)*268)-56), 46, 8, 40, commonColors.black, commonColors.button)
		drawCenteredLabel("FOV: "..player.Camera.FOV, 26, 46, 268, 40, commonColors.white)
       		drawStrokedRect(26, 140, 268, 40, commonColors.black, commonColors.button)
		drawCenteredLabel("Save FOV (Automatically Loads)", 26, 140, 268, 40, commonColors.white)
	elseif curPage == 5 then
		quickDrawButtons("Toggle Flight","Speed Boost","Experience")
	elseif curPage == 6 then
		quickDrawButtons("Teleport to Coordinates","Health Boost","Instant Kill")
	elseif curPage == 7 then
        	drawStrokedRect(26, 46, 268, 170, commonColors.black, commonColors.button)
		drawCenteredLabel("CrafTR Cheat Menu", 26, 46, 268, 20, commonColors.white)
		drawCenteredLabel("Written by: Damienne", 26, 66, 268, 20, commonColors.white)
		 
		drawCenteredLabel("Made possible by:", 26, 86, 268, 20, commonColors.white)
		drawCenteredLabel("STBrian's LunaCore and contributors", 26, 96, 268, 20, commonColors.white)
		
		drawCenteredLabel("Go open the ingame credits", 26, 126, 268, 20, commonColors.white)
		drawCenteredLabel("to see the GOATs of this project", 26, 136, 268, 20, commonColors.white)
		drawCenteredLabel("(the Modernization Megapack team)", 26, 146, 268, 20, commonColors.white)
	end
        Core.Graphics.drawText(commandPageLabels[curPage], 24, 24, commonColors.white)
	if cheatLog ~= nil then
	    drawStrokedRect(10, 75, 300, 90, commonColors.black, commonColors.span)
	    drawCenteredLabel(cheatLog, 10, 75, 300, 90, commonColors.white)
	end
    else
        frames = frames + 1
        if frames % 2 == 0 then -- Execute only when both framebuffers were drawn
            if firstframe then -- Avoid execute when first frame
                firstframe = false
                return
            end
            if frames > 0xFF then
                frames = 0
            end
        end
    end
end
--main logic section
Game.Gamepad.OnKeyReleased:Connect(function ()
    if (gamepad.isReleased(keys.DPADLEFT) or gamepad.isReleased(keys.DPADRIGHT)) and Game.World.Loaded then
        if not Core.Graphics.isOpen() then
	    curPage = 1
            firstframe = true
            Core.Graphics.open(drawGraphics)
	elseif gamepad.isReleased(keys.DPADLEFT) and cheatLog == nil then
	    curPage = ((curPage - 2)%#commandPageLabels)+1
	elseif gamepad.isReleased(keys.DPADRIGHT) and cheatLog == nil then
	    curPage = ((curPage)%#commandPageLabels)+1
        end
    end
    if gamepad.isReleased(keys.B) and Core.Graphics.isOpen() then
	if cheatLog == nil then
		Core.Graphics.close()
	else
	        cheatLog = nil
	end
    end
end)
gamepad.OnKeyPressed:Connect(function ()
    if gamepad.isPressed(keys.TOUCHPAD) and Core.Graphics.isOpen() and not keyboardOpen and cheatLog == nil then
        if curPage == 1 then
	    if checkTouchInBoundsOf(26, 46, 268, 40) then
	    	player.Gamemode = 0
	    	cheatAndGameLog("Set gamemode to Survival")
	    elseif checkTouchInBoundsOf(26, 92, 268, 40) then
	    	player.Gamemode = 1
	    	cheatAndGameLog("Set gamemode to Creative")
	    elseif checkTouchInBoundsOf(26, 140, 268, 40) then
	    	player.Gamemode = 2
	    	cheatAndGameLog("Set gamemode to Adventure")
	    end
	end
        if curPage == 2 then
	    if checkTouchInBoundsOf(26, 46, 268, 40) then
		keyboardOpen = true
		local tempItemID = Keyboard.getString("Item ID:")
		if tempItemID == nil then
			cheatAndGameLog("No text input.")
			keyboardOpen = false
		        return
		end
		tryItem = CoreAPI.Items.getItem(tempItemID)
		if tryItem == nil then
			cheatAndGameLog("Invalid item ID!")
			keyboardOpen = false
		        return
		end
		itemCount = Keyboard.getNumber("Count:")
		if itemCount == nil then
			cheatAndGameLog("No item quantity provided!")
			keyboardOpen = false
		        return
		elseif itemCount == 0 then
			cheatAndGameLog("Cannot give 0 of an item!")
			keyboardOpen = false
		        return
		end
		itemData = Keyboard.getNumber("Data (optional):")
		keyboardOpen = false
		if itemData ~= nil then
			player.Inventory.Slots["hand"].Item = tryItem
			player.Inventory.Slots["hand"].ItemCount = itemCount
			player.Inventory.Slots["hand"].ItemData = itemData
		else
			player.Inventory.Slots["hand"].Item = tryItem
			player.Inventory.Slots["hand"].ItemCount = itemCount
			player.Inventory.Slots["hand"].ItemData = 0
		end
		cheatAndGameLog("Item given\n(may need relog to render properly)")
	    elseif checkTouchInBoundsOf(26, 92, 268, 40) then
		local tempItem = player.Inventory.Slots["hand"]
		if tempItem.Item ~= nil then
			player.Inventory.ArmorSlots["helmet"].Item = tempItem.Item
			player.Inventory.ArmorSlots["helmet"].ItemCount = tempItem.ItemCount
			player.Inventory.ArmorSlots["helmet"].ItemData = tempItem.ItemData
		else
			cheatAndGameLog("Your hand slot is empty!")
			return
		end
		tempItem.ItemCount = 0
		cheatAndGameLog("Equipped held item to hat slot!")
	    elseif checkTouchInBoundsOf(26, 140, 268, 40) then
		cheatAndGameLog("Not yet implemented.")
	    end
	end
        if curPage == 3 then
	    if checkTouchInBoundsOf(26, 46, 268, 40) then
		Game.World.Raining = false
		Game.World.Thunderstorm = false
		cheatAndGameLog("Cleared all weather")
	    elseif checkTouchInBoundsOf(26, 92, 268, 40) then
		Game.World.Raining = true
		Game.World.Thunderstorm = false
		cheatAndGameLog("Set weather to rain")
	    elseif checkTouchInBoundsOf(26, 140, 268, 40) then
		Game.World.Raining = true
		Game.World.Thunderstorm = true
		cheatAndGameLog("Set weather to a thunderstorm")
	    end
	end
	if curPage == 4 then
	    if checkTouchInBoundsOf(26, 46, 268, 40) then
		local touchx, touchy = Game.Gamepad.getTouch()
		player.Camera.FOV = math.floor(((math.min(242, touchx-36)/260)*90)+30.5)
	    elseif checkTouchInBoundsOf(26, 140, 268, 40) then
		fovFile = Core.Filesystem.open("sdmc:/Minecraft 3DS/mods/CrafTRCheatConsole/fov.txt", "w")
		if fovFile ~= nil then
			if not fovFile:write(tostring(player.Camera.FOV)) then
				cheatAndGameLog("Failed to write FOV")
			else
				cheatAndGameLog("Successfully saved FOV.")
			end
			fovFile:close()
		else
			cheatAndGameLog("FOV.txt failed to load.")
		end
	    end
	elseif curPage == 5 then
	    if checkTouchInBoundsOf(26, 46, 268, 40) then
		if not player.CanFly then
			player.CanFly = true
			cheatAndGameLog("You can now fly!")
		else
			player.CanFly = false
			cheatAndGameLog("Flight disabled.")
		end
		cheatAndGameLog("Toggled flight to: "..tostring(player.CanFly))
	    elseif checkTouchInBoundsOf(26, 92, 268, 40) then
		if not speedBoosted then
			speedBoosted = true
			player.BaseMoveSpeed = 1
			player.MoveSpeed = 1
			player.SwimSpeed = 0.4
			player.FlySpeed = 0.5
			
			cheatAndGameLog("Player speed boosted!")
		else
			speedBoosted = false
			player.BaseMoveSpeed = 0.1
			player.MoveSpeed = 0.1
			player.SwimSpeed = 0.04
			player.FlySpeed = 0.05
			cheatAndGameLog("Player speed set to normal")
		end
	    elseif checkTouchInBoundsOf(26, 140, 268, 40) then
		player.CurrentLevel = 99999
		cheatAndGameLog("Unlimited experience!")
	    end
	elseif curPage == 6 then
	    if checkTouchInBoundsOf(26, 46, 268, 40) then
		keyboardOpen = true
		local telex = Keyboard.getNumber("X coordinate:")
		local teley = Keyboard.getNumber("Y coordinate:")
		local telez = Keyboard.getNumber("Z coordinate:")
		keyboardOpen = false
		if telex == nil or teley == nil or telez == nil then
			cheatAndGameLog("Invalid coords, will not teleport")
			return
		end
		player.Position.set(telex, teley, telez)
		cheatAndGameLog("Teleported to X: "..telex.." Y: "..teley.." Z: "..telez)
	    elseif checkTouchInBoundsOf(26, 92, 268, 40) then
		if player.MaxHP ~= 255 then
			player.CurrentHP = 255
			player.MaxHP = 255
			cheatAndGameLog("HP boosted!")
		else
			player.MaxHP = 20
			cheatAndGameLog("HP reset to default.")
		end
	    elseif checkTouchInBoundsOf(26, 140, 268, 40) then
		player.CurrentHP = -1
		cheatAndGameLog("Ouch! That looked like it hurt.")
	    end
	elseif curPage == 7 then
	    if checkTouchInBoundsOf(26, 166, 268, 40) then
		cheatAndGameLog("Looking closely at the UI... there's no secrets.") -- yet
	    end
		
	end
    end
end)

Game.World.OnWorldJoin:Connect(function ()
	fovFile = Core.Filesystem.open("sdmc:/Minecraft 3DS/mods/CrafTRCheatConsole/fov.txt", "r")
		if fovFile ~= nil then
			player.Camera.FOV = fovFile:read("*all")
			fovFile:close()
		else
			player.Camera.FOV = 70
		end 
end)