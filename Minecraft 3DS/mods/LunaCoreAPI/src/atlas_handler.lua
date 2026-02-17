local struct = CoreAPI.Utils.Struct
local bit = CoreAPI.Utils.Bitop

---@class AtlasHandler
local atlasHandler = CoreAPI.Utils.Classic:extend()

---@class atlas_handler_functions
local atlas_handler_functions = {}

local function calculateLinearPosition(x, y, w, h)
    return (bit.lshift(bit.rshift(y, 3) * bit.rshift(w, 3) + bit.rshift(x, 3), 6) +
        (bit.bor(bit.bor(bit.bor(bit.bor(bit.bor(bit.band(x, 1), bit.lshift(bit.band(y, 1), 1)), bit.lshift(bit.band(x, 2), 1)), bit.lshift(bit.band(y, 2), 2)), bit.lshift(bit.band(x, 4), 2)), bit.lshift(bit.band(y, 4), 3))))
end

---New atlas handler
---@param file FilesystemFile
---@return AtlasHandler
function atlas_handler_functions.newAtlasHandler(file)
    return atlasHandler(file)
end

---comment
---@param file FilesystemFile
function atlasHandler:new(file)
    self.file = file
    self.parsed = false
    if not file:isOpen() then
        return
    end
    local signature = file:read(4)
    if signature ~= "3DST" then
        return
    end
    local mode = struct.unpack("<I", file:read(4))
    if mode ~= 3 then
        return
    end
    local format = struct.unpack("<I", file:read(4))
    if format ~= 0 then
        return
    end
    self.full_w = struct.unpack("<I", file:read(4))
    self.full_h = struct.unpack("<I", file:read(4))
    self.w = struct.unpack("<I", file:read(4))
    self.h = struct.unpack("<I", file:read(4))
    self.mip_level = struct.unpack("<I", file:read(4))
    self.file = file
    self.parsed = true
end

---Paste texture
---@param textureData FilesystemFile
---@param ax integer
---@param ay integer
---@return boolean
function atlasHandler:pasteTexture(textureData, ax, ay)
    if not textureData:isOpen() then
        return false
    end
    local signature = textureData:read(4)
    if signature ~= "3DST" then
        return false
    end
    local mode = struct.unpack("<I", textureData:read(4))
    if mode ~= 3 then
        return false
    end
    local format = struct.unpack("<I", textureData:read(4))
    if format ~= 0 then
        return false
    end
    local tfull_w = struct.unpack("<I", textureData:read(4))
    local tfull_h = struct.unpack("<I", textureData:read(4))
    local tw = struct.unpack("<I", textureData:read(4))
    local th = struct.unpack("<I", textureData:read(4))
    local dataStart = 32
    for y = 0, th - 1 do
        for x = 0, tw - 1 do
            local apos = calculateLinearPosition(ax + x, (ay + y - (self.full_h - 1)) * -1, self.full_w, self.full_h)
            local apixelPos = dataStart + apos * 4
            local tpos = calculateLinearPosition(x, (y - (tfull_h - 1)) * -1, tfull_w, tfull_h)
            local tpixelPos = dataStart + tpos * 4
            textureData:seek(tpixelPos, "set")
            local tpixelData = textureData:read(4)
            self.file:seek(apixelPos, "set")
            if tpixelData then
                self.file:write(tpixelData)
            end
        end
    end
    self.file:flush()
    return true
end

return atlas_handler_functions