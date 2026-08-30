local menu = Core.Menu
local baseFolder = menu.getMenuFolder()
local modFolder = baseFolder:newFolder("Dynamic(s)") 

-- Helper for random floats within a range
local function randomFloat(min, max)
    return min + math.random() * (max - min)
end

---------------------------------------------------------
-- Dynamic Clouds Logic
---------------------------------------------------------
local function runDynamicClouds()
    Async.run(function()
        local timerCount = 1020 -- adjusted the timer for both because of Async
        local timer = 0
        local heightRate = 0.0035
        local thicknessRate = 0.0035
        local increasing = true
    
        local chAdd = 0x3C5398 -- Cloud Height Address
        local ctAdd = 0x3C53BC -- Cloud Thickness Address

        while true do
            local ct = Core.Memory.readFloat(ctAdd) or 0
            local ch = Core.Memory.readFloat(chAdd) or 0
            
            if increasing then
                ct = ct + thicknessRate
                ch = ch - heightRate
                timer = timer + 1
                if timer >= timerCount then increasing = false end
            else
                ct = ct - thicknessRate
                ch = ch + heightRate
                timer = timer - 1
                if timer <= 0 then
                    increasing = true
                    timerCount = math.random(750, 1500)
                    heightRate = randomFloat(0.001, 0.01)
                    thicknessRate = heightRate
                end
            end
            
            Core.Memory.writeFloat(ctAdd, ct)
            Core.Memory.writeFloat(chAdd, ch)
            
            Async.wait(0.02)
        end
    end)
end

---------------------------------------------------------
-- Dynamic Fog Logic
---------------------------------------------------------
local function runDynamicFog()
    Async.run(function()
        local timer = 0
        local baseFog = 4.0
        local timerCount = 5000 -- adjusted the timer for both because of Async (29400)
        local fogDensity = 0
        local weatherSetAmount = 0
        local bWeather = false
        local bFadingIn = false
        local bFadingOut = false
        local bHolding = false
        local weatherChance = 2.0
        local fogAdd = 0x3C7F9C

        while true do
            local currentFog = Core.Memory.readFloat(fogAdd) or baseFog

            if bWeather then
                if bFadingIn then
                    if currentFog < fogDensity then
                        currentFog = math.min(currentFog + weatherSetAmount, fogDensity)
                        Core.Memory.writeFloat(fogAdd, currentFog)
                    else
                        -- Notification when fog reaches target density
                        Core.Debug.message("The fog has settled.")
                        bFadingIn = false
                        bHolding = true
                        timer = 0
                    end
                elseif bHolding then
                    if timer >= timerCount then
                        bHolding = false
                        bFadingOut = true
                        timer = 0
                        -- Notification when fog begins to clear
                        Core.Debug.message("The fog is clearing...")
                    else
                        timer = timer + 1
                    end
                elseif bFadingOut then
                    if currentFog > baseFog then
                        currentFog = math.max(currentFog - weatherSetAmount, baseFog)
                        Core.Memory.writeFloat(fogAdd, currentFog)
                    else
                        bFadingOut = false
                        bWeather = false
                        timerCount = math.random(4000, 7500)
                    end
                end
            else
                if timer >= timerCount then
                    if randomFloat(0, 10) < weatherChance then
                        weatherSetAmount = randomFloat(0.01, 0.05)
                        fogDensity = randomFloat(30.0, 100.0)
                        bWeather = true
                        bFadingIn = true
                        timer = 0
                        -- Notification when fog activates
                        if fogDensity <= 50.0 then
                            Core.Debug.message("Notice: Light-Fog Detected.")
                        elseif fogDensity > 50.0 and fogDensity <= 70.0 then
                            Core.Debug.message("Warning: Thick-Fog Approaching.")
                        elseif fogDensity > 70.0 and fogDensity <= 90.0 then
                            Core.Debug.message("Danger: Severe-Fog Density.")
                        else
                            Core.Debug.message("Danger: Extreme-Fog Inbound.")
                        end
                    else
                        timer = 0
                    end
                else
                    timer = timer + 1
                end
            end
            
            Async.wait(0.02)
        end
    end)
end

---------------------------------------------------------
-- Menu Entries
---------------------------------------------------------
modFolder:newEntry("Enable Dynamic Clouds", function()
    runDynamicClouds()
    Core.Debug.message("Dynamic Clouds Enabled")
end)

modFolder:newEntry("Enable Dynamic Fog", function()
    runDynamicFog()
    Core.Debug.message("Dynamic Fog Enabled")
end)
