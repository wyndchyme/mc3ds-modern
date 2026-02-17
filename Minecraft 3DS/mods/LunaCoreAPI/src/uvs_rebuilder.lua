local struct = CoreAPI.Utils.Struct

---Read string
---@param f string
---@param pos number
---@return string
local function readString(f, pos)
    local idx = 0
    while f:byte(pos + idx) ~= 0 do
        idx = idx + 1
    end
    return f:sub(pos, pos + idx)
end

---@class uvs_builder_functions
local uvs_builder = {}

---Loads the content of a uvs file
---@param file FilesystemFile
---@return table?
function uvs_builder.loadFile(file)
    if not file:isOpen() then
        return nil
    end
    local fileContent = file:read("*all")
    if fileContent == nil or #fileContent < 4 * 3 then
        return nil
    end
    local stringPos = 1
    local header_1 = struct.unpack("<I", fileContent:sub(stringPos, stringPos + 3)) -- Total amount of elements not repeated
    stringPos = stringPos + 4
    local header_2 = struct.unpack("<I", fileContent:sub(stringPos, stringPos + 3)) -- Amount of elements including repeated
    stringPos = stringPos + 4
    local header_3 = struct.unpack("<I", fileContent:sub(stringPos, stringPos + 3)) -- Length of all strings
    stringPos = stringPos + 4

    local posNames = 4 * 3 + 1
    local posUVs = posNames + header_3
    local posIdx = posUVs + 4 * 7 * header_2

    local uvs_data = {}
    for i = 0, header_1 - 1 do
        stringPos = posIdx + 4 * 3 * i
        local nameHash = struct.unpack("<I", fileContent:sub(stringPos, stringPos + 3))
        stringPos = stringPos + 4
        local count = struct.unpack("<I", fileContent:sub(stringPos, stringPos + 3))
        stringPos = stringPos + 4
        local idx = struct.unpack("<I", fileContent:sub(stringPos, stringPos + 3))
        uvs_data[nameHash] = {}
        for j = 0, count - 1 do
            stringPos = posUVs + 4 * 7 * (idx + j)
            local uvs = {}
            table.insert(uvs, struct.unpack("<f", fileContent:sub(stringPos, stringPos + 3)))
            stringPos = stringPos + 4
            table.insert(uvs, struct.unpack("<f", fileContent:sub(stringPos, stringPos + 3)))
            stringPos = stringPos + 4
            table.insert(uvs, struct.unpack("<f", fileContent:sub(stringPos, stringPos + 3)))
            stringPos = stringPos + 4
            table.insert(uvs, struct.unpack("<f", fileContent:sub(stringPos, stringPos + 3)))
            stringPos = stringPos + 4
            local w = struct.unpack("<H", fileContent:sub(stringPos, stringPos + 1))
            stringPos = stringPos + 2
            local h = struct.unpack("<H", fileContent:sub(stringPos, stringPos + 1))
            stringPos = stringPos + 2
            local namePos = struct.unpack("<I", fileContent:sub(stringPos, stringPos + 3))
            stringPos = stringPos + 4
            local unknown1 = struct.unpack("<I", fileContent:sub(stringPos, stringPos + 3))
            stringPos = posNames + namePos
            local nameVal = readString(fileContent, stringPos)
            table.insert(uvs_data[nameHash], {
                name = nameVal,
                texture_width = w,
                texture_height = h,
                uv = {
                    math.floor(uvs[1] * w),
                    math.floor(uvs[2] * h),
                    math.floor(uvs[3] * w),
                    math.floor(uvs[4] * h)
                },
                data = j,
                magic = unknown1
            })
        end
    end
    return uvs_data
end

---Exports the uvs data to a file
---@param file FilesystemFile
---@param uvsDataTbl table
function uvs_builder.dumpFile(file, uvsDataTbl)
    if not file:isOpen() then
        return
    end
    local keys = {}
    for key, _ in pairs(uvsDataTbl) do
        if type(key) == "number" then
            table.insert(keys, key)
        elseif type(key) == "string" then
            local hash = CoreAPI.Utils.String.hash(key)
            uvsDataTbl[hash] = uvsDataTbl[key]
            table.insert(keys, hash)
        end
    end
    table.sort(keys)

    local indexLength = #keys
    local uvsDataLength = 0
    local namesLength = 0
    local names = ""
    local uvsData = ""
    local indexes = ""
    for i, value in ipairs(keys) do
        indexes = indexes .. struct.pack("<I", value) .. struct.pack("<I", #uvsDataTbl[value]) .. struct.pack("<I", uvsDataLength)
        for _, element in pairs(uvsDataTbl[value]) do
            uvsData = uvsData .. struct.pack("<f", element["uv"][1] / element["texture_width"]) .. struct.pack("<f", element["uv"][2] / element["texture_height"]) .. struct.pack("<f", element["uv"][3] / element["texture_width"]) .. struct.pack("<f", element["uv"][4] / element["texture_height"])
            uvsData = uvsData .. struct.pack("<H", element["texture_width"]) .. struct.pack("<H", element["texture_height"])
            uvsData = uvsData .. struct.pack("<I", #names)
            names = names .. element["name"] .. string.char(0)
            uvsData = uvsData .. struct.pack("<I", element["magic"])
            uvsDataLength = uvsDataLength + 1
        end
    end
    namesLength = #names

    file:seek(0, "set")
    file:write(struct.pack("<I", indexLength) .. struct.pack("<I", uvsDataLength) .. struct.pack("<I", namesLength))
    file:write(names)
    file:write(uvsData)
    file:write(indexes)
end

return uvs_builder