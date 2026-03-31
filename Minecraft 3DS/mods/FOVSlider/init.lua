local MODNAME = "FOVSlider"

local MIN_FOV = 70.0
local MAX_FOV = 110.0

local fovSliderEnabled = true
local lastSlider = nil
local lastAppliedFov = nil

local function getConfigPaths()
    local modPath = Core.getModpath(MODNAME)
    if modPath == nil then
        Core.Debug.logerror("[FOV] Failed to resolve mod path for " .. tostring(MODNAME))
        return nil, nil
    end

    local configDir = modPath .. "/data"
    local configFile = configDir .. "/fovSliderConfig.txt"
    return configDir, configFile
end

local function ensureConfigDir()
    local configDir = getConfigPaths()
    if configDir == nil then
        return false
    end

    if not Core.Filesystem.directoryExists(configDir) then
        local ok = Core.Filesystem.createDirectory(configDir)
        if not ok then
            Core.Debug.logerror("[FOV] Failed to create config dir: " .. tostring(configDir))
            return false
        end
    end

    return true
end

local function saveFovSliderSetting()
    local _, configFile = getConfigPaths()
    if configFile == nil then
        return false
    end

    if not ensureConfigDir() then
        return false
    end

    local f, err = Core.Filesystem.open(configFile, "w")
    if f == nil then
        Core.Debug.logerror("[FOV] Failed to open config for write: " .. tostring(err))
        return false
    end

    local value = fovSliderEnabled and "1" or "0"
    local ok = f:write(value)
    f:flush()
    f:close()

    if ok then
        Core.Debug.log("[FOV] Saved slider setting: " .. value)
    end

    return ok == true
end

local function loadFovSliderSetting()
    local _, configFile = getConfigPaths()
    if configFile == nil then
        fovSliderEnabled = true
        return
    end

    if not ensureConfigDir() then
        fovSliderEnabled = true
        return
    end

    if not Core.Filesystem.fileExists(configFile) then
        fovSliderEnabled = true
        saveFovSliderSetting()
        Core.Debug.log("[FOV] No config found, defaulting to enabled")
        return
    end

    local f, err = Core.Filesystem.open(configFile, "r")
    if f == nil then
        Core.Debug.logerror("[FOV] Failed to open config for read: " .. tostring(err))
        fovSliderEnabled = true
        return
    end

    local raw = f:read("*all")
    f:close()

    raw = tostring(raw or ""):gsub("%s+", "")

    if raw == "0" then
        fovSliderEnabled = false
    else
        fovSliderEnabled = true
    end

    Core.Debug.log("[FOV] Loaded slider setting: " .. tostring(fovSliderEnabled))
end

local function clamp(v, minv, maxv)
    if v < minv then return minv end
    if v > maxv then return maxv end
    return v
end

local function sliderToFov(slider)
    slider = clamp(slider or 0.0, 0.0, 1.0)
    return MIN_FOV + (slider * (MAX_FOV - MIN_FOV))
end

local function applySliderFovIfNeeded()
    if not fovSliderEnabled then
        lastSlider = nil
        lastAppliedFov = nil
        return
    end

    if not Game.World.Loaded or not Game.LocalPlayer.Loaded then
        lastSlider = nil
        lastAppliedFov = nil
        return
    end

    local slider = clamp(Core.System.get3DSliderState() or 0.0, 0.0, 1.0)

    if lastSlider == nil or math.abs(slider - lastSlider) > 0.001 then
        local newFov = sliderToFov(slider)

        if lastAppliedFov == nil or math.abs(newFov - lastAppliedFov) > 0.001 then
            Game.LocalPlayer.Camera.FOV = newFov
            lastAppliedFov = newFov
        end

        lastSlider = slider
    end
end

local function showFovSliderStatus()
    Core.Menu.showMessageBox(
        "3D Slider FOV is currently " .. (fovSliderEnabled and "ENABLED" or "DISABLED")
    )
end

local function enableFovSlider()
    fovSliderEnabled = true
    lastSlider = nil
    lastAppliedFov = nil
    saveFovSliderSetting()
    Core.Menu.showMessageBox("3D Slider FOV enabled.")
end

local function disableFovSlider()
    fovSliderEnabled = false
    lastSlider = nil
    lastAppliedFov = nil
    saveFovSliderSetting()
    Core.Menu.showMessageBox("3D Slider FOV disabled.")
end

local function toggleFovSlider()
    fovSliderEnabled = not fovSliderEnabled
    lastSlider = nil
    lastAppliedFov = nil
    saveFovSliderSetting()
    Core.Menu.showMessageBox(
        "3D Slider FOV " .. (fovSliderEnabled and "enabled." or "disabled.")
    )
end

loadFovSliderSetting()

local folder = Core.Menu.getMenuFolder():newFolder("FOVSlider")
folder:newEntry("Toggle Feature", toggleFovSlider)
folder:newEntry("Enable Feature", enableFovSlider)
folder:newEntry("Disable Feature", disableFovSlider)
folder:newEntry("Show Status", showFovSliderStatus)

Async.run(function()
    while true do
        applySliderFovIfNeeded()
        Async.wait(0.03)
    end
end)
