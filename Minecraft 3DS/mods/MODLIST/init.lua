local CURRENT_MOD = Core.getCurrentModname()
local CURRENT_MOD_PATH = Core.getModpath(CURRENT_MOD)

if not CURRENT_MOD_PATH then
    Core.Debug.logerror("[MODLIST] Could not resolve current mod path")
    return
end

local function getParentDirectory(path)
    if not path then
        return nil
    end

    path = path:gsub("[/\\]+$", "")
    local parent = path:match("^(.*)[/\\][^/\\]+$")
    return parent
end

local MODS_ROOT = getParentDirectory(CURRENT_MOD_PATH)

if not MODS_ROOT then
    Core.Debug.logerror("[MODLIST] Could not resolve mods root folder")
    return
end

local function readAllText(path)
    local file, err = Core.Filesystem.open(path, "r")
    if not file then
        Core.Debug.log("[MODLIST] Failed to open file: " .. tostring(path) .. " | " .. tostring(err))
        return nil
    end

    local data = file:read("*all")
    file:close()

    return data
end

local function extractJsonString(jsonText, key)
    if not jsonText or not key then
        return nil
    end

    local pattern = '"' .. key .. '"%s*:%s*"(.-)"'
    local value = jsonText:match(pattern)
    return value
end

local function extractJsonArray(jsonText, key)
    if not jsonText or not key then
        return {}
    end

    local pattern = '"' .. key .. '"%s*:%s*%[(.-)%]'
    local arrayContent = jsonText:match(pattern)

    if not arrayContent then
        return {}
    end

    local results = {}
    for item in arrayContent:gmatch('"(.-)"') do
        results[#results + 1] = item
    end

    return results
end

local function parseModsJson(jsonText, folderName)
    local name = extractJsonString(jsonText, "name") or folderName or "Unknown Mod"
    local description = extractJsonString(jsonText, "description") or "No description provided."
    local version = extractJsonString(jsonText, "version") or "Unknown"
    local dependencies = extractJsonArray(jsonText, "dependencies")

    return {
        name = name,
        description = description,
        version = version,
        dependencies = dependencies
    }
end

local function buildDependenciesText(dependencies)
    if not dependencies or #dependencies == 0 then
        return "None"
    end

    return table.concat(dependencies, ", ")
end

local function showModInfo(modInfo, folderName)
    local msg =
        "Name: " .. tostring(modInfo.name) ..
        "\nFolder: " .. tostring(folderName) ..
        "\nVersion: " .. tostring(modInfo.version) ..
        "\n\nDescription:\n" .. tostring(modInfo.description) ..
        "\n\nDependencies:\n" .. buildDependenciesText(modInfo.dependencies)

    Core.Menu.showMessageBox(msg)
end

local function loadInstalledMods()
    local mods = {}

    if not Core.Filesystem.directoryExists(MODS_ROOT) then
        Core.Debug.logerror("[MODLIST] Mods root does not exist: " .. tostring(MODS_ROOT))
        return mods
    end

    local elements = Core.Filesystem.getDirectoryElements(MODS_ROOT)
    if not elements then
        Core.Debug.logerror("[MODLIST] Failed to list directory elements for: " .. tostring(MODS_ROOT))
        return mods
    end

    for _, entryName in ipairs(elements) do
        local folderPath = MODS_ROOT .. "/" .. tostring(entryName)

        if Core.Filesystem.directoryExists(folderPath) then
            local jsonPath = folderPath .. "/mod.json"

            if Core.Filesystem.fileExists(jsonPath) then
                local jsonText = readAllText(jsonPath)

                if jsonText then
                    local ok, modInfo = pcall(parseModsJson, jsonText, entryName)

                    if ok and modInfo then
                        mods[#mods + 1] = {
                            folderName = entryName,
                            folderPath = folderPath,
                            jsonPath = jsonPath,
                            info = modInfo
                        }
                    else
                        Core.Debug.log("[MODLIST] Failed to parse: " .. jsonPath)
                    end
                end
            else
                Core.Debug.log("[MODLIST] Skipping folder without mod.json: " .. folderPath)
            end
        end
    end

    return mods
end

local function sortModsByName(mods)
    table.sort(mods, function(a, b)
        local an = (a.info and a.info.name or a.folderName or ""):lower()
        local bn = (b.info and b.info.name or b.folderName or ""):lower()
        return an < bn
    end)
end

local function populateMenu()
    local menu = Core.Menu.getMenuFolder()
    local modsFolder = menu:newFolder("[MODLIST] Installed Mods")

    local mods = loadInstalledMods()
    sortModsByName(mods)

    if #mods == 0 then
        modsFolder:newEntry("NO MODS INSTALLED", function()
            Core.Menu.showMessageBox("No Mod Folders with a valid mod.json were found in:\n" .. tostring(MODS_ROOT))
        end)
        return
    end

    modsFolder:newEntry("#--- CREDIT(S) ---#", function()
        Core.Menu.showMessageBox("Modname(s): MODLIST\nDeveloper: Cracko298\n\nRelease Build")
    end)

    for _, modData in ipairs(mods) do
        local entryName = modData.info.name or modData.folderName

        modsFolder:newEntry(entryName, function()
            showModInfo(modData.info, modData.folderName)
        end)
    end
end

populateMenu()
Core.Debug.log("[MODLIST] Menu Populated From: " .. tostring(MODS_ROOT), false)