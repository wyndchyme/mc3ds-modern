local struct = CoreAPI.Utils.Struct

---@class BlangParser
local blang_parser = CoreAPI.Utils.Classic:extend()

---New blang parser
---@param file FilesystemFile
---@return BlangParser
function blang_parser.newParser(file)
    return blang_parser(file)
end

---comment
---@param file FilesystemFile
function blang_parser:new(file)
    self.parsed = false
    self.error = nil
    if not file:isOpen() then
        return
    end

    local intSize = 4
    file:seek(0, "set")
    local length = struct.unpack("<I", file:read(intSize))
    local file_data = file:read(length * intSize * 2)
    local indexData = {}
    if file_data == nil then
        self.error = "Failed to read index data"
        return
    else
        for i = 0, length - 1 do
            local hashName = struct.unpack("<I", file_data:sub(((intSize * 2 * i) + 1), ((intSize * 2 * i + 3) + 1)))
            local texPos = struct.unpack("<I", file_data:sub(((intSize * 2 * i) + intSize + 1), (((intSize * 2 * i) + intSize + 3) + 1)))
            table.insert(indexData, {hashName, texPos})
        end
    end

    file_data = nil
    collectgarbage("collect")

    length = struct.unpack("<I", file:read(intSize))
    file_data = file:read(length)
    local data = {}
    if file_data == nil then
        self.error = "Failed to read text data"
        return
    else
        for index, value in ipairs(indexData) do
            local finalPos = 0
            if index < #indexData then
                finalPos = indexData[index + 1][2] - 2
            else
                finalPos = #file_data - 1
            end
            data[value[1]] = string.sub(file_data, value[2] + 1, finalPos + 1)
        end
    end

    self.data = data
    indexData = nil
    collectgarbage("collect")
    self.parsed = true
end

--- Adds a text
---@param textId string
---@return boolean
function blang_parser:containsText(textId)
    return self.data[CoreAPI.Utils.String.hash(textId:lower())] ~= nil
end

--- Compares strings
---@param textId string
---@param s string
---@return boolean
function blang_parser:areEqual(textId, s)
    return self.data[CoreAPI.Utils.String.hash(textId:lower())] == s
end

--- Adds a text
---@param textId string
---@param text string
function blang_parser:addText(textId, text)
    self.data[CoreAPI.Utils.String.hash(textId:lower())] = text
end

--- Dumps to file
---@param file FilesystemFile
---@return boolean
function blang_parser:dumpFile(file)
    if not file:isOpen() then
        return false
    end
    local keys = {}
    for key, _ in pairs(self.data) do
        table.insert(keys, key)
    end
    table.sort(keys)

    local indexData = {}
    local currStringPos = 0
    file:seek(0, "set")
    file:write(struct.pack("<I", #keys))
    for _, key in ipairs(keys) do
        table.insert(indexData, struct.pack("<I", key) .. struct.pack("<I", currStringPos))
        currStringPos = currStringPos + #self.data[key] + 1
    end
    file:write(table.concat(indexData))
    file:write(struct.pack("<I", currStringPos))
    indexData = nil
    collectgarbage("collect")

    -- Avoid copy all texts
    local stringData = {}
    for _, key in ipairs(keys) do
        table.insert(stringData, self.data[key])
    end
    table.insert(stringData, "")
    file:write(table.concat(stringData, string.char(0)))
    file:flush()
    stringData = nil
    collectgarbage("collect")
    return true
end

return blang_parser