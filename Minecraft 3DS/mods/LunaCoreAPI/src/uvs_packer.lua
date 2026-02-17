local function containsInvalidChars(s)
    if string.find(s, "[^%w_]") then
        return true
    else
        return false
    end
end

local function rects_overlap(a, b)
    return not (a[3] <= b[1] or b[3] <= a[1] or a[4] <= b[2] or b[4] <= a[2])
end

local function findFreeSpace(uvs, tileSize, aw, ah)
    local freeSpace = {}
    for y = 0, ah - tileSize, tileSize do
        for x = 0, aw - tileSize, tileSize do
            local candidate = {x, y, x + tileSize, y + tileSize}
            local overlaps = false
            for _, element in pairs(uvs) do
                for _, value in pairs(element) do
                    if rects_overlap(candidate, value.uv) then
                        overlaps = true
                        break
                    end
                end
                if overlaps then
                    break
                end
            end
            if not overlaps then
                table.insert(freeSpace, {x, y})
            end
        end
    end
    return freeSpace
end

---@class UVs_packer
local uvs_packer = CoreAPI.Utils.Classic:extend()

---Returns a new instance of UVs_packer
---@param uvs table
---@param tileSize number
---@return UVs_packer
local function newUVsPacker(uvs, tileSize)
    return uvs_packer(uvs, tileSize)
end

---@param uvs table
function uvs_packer:new(uvs, tileSize)
    self.uvs = uvs
    self.tileSize = tileSize
    local firstElement = nil
    for key, value in pairs(uvs) do
        firstElement = value
        break
    end
    self.magic = firstElement[1].magic
    self.atlas_w = firstElement[1].texture_width
    self.atlas_h = firstElement[1].texture_height
    self.freeSpace = findFreeSpace(uvs, tileSize, self.atlas_w, self.atlas_h)
    self.lastX = 0
    self.lastY = 0
end

function uvs_packer:addUV(nameId, textureName)
    if type(nameId) ~= "string" then
        error("'nameId' must be a string")
    end
    if containsInvalidChars(nameId) then
        error("'nameId' contains invalid characters")
    end
    if self.uvs[CoreAPI.Utils.String.hash(nameId)] ~= nil or self.uvs[nameId] ~= nil then
        return true
    end
    if self.freeSpace[1] == nil then
        return false
    else
        local coords = table.remove(self.freeSpace, 1)
        self.uvs[nameId] = {}
        table.insert(self.uvs[nameId], {
            name = textureName,
            texture_width = self.atlas_w,
            texture_height = self.atlas_h,
            uv = {
                coords[1],
                coords[2],
                coords[1] + self.tileSize,
                coords[2] + self.tileSize
            },
            data = 0,
            magic = self.magic
        })
    end
    return true
end

---@class uvs_packer_funcs
local uvs_packer_funcs = {newPacker = newUVsPacker}

return uvs_packer_funcs