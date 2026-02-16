---@class cstruct : ClassicClass
---@field super ClassicClass
local cstruct = CoreAPI.Utils.Classic:extend()

--- Warning when using versions prior to 0.13.0
--- Writing negative values will be rounded to 0
if not Core.Memory.readS32 then
    CoreAPI._logger:warn("Signed values are not available in this version for cstruct")
end

local ctypes = {void=0, int=4, short=2, char=1, float=4, double=8, ["long long"]=8}

local readFunctions = {
    void=nil,
    int=Core.Memory.readS32 or Core.Memory.readU32, -- Compatibility with 0.12.0 although its usage is highly discouraged since values will be wrong
    uint=Core.Memory.readU32,
    short=Core.Memory.readS16 or Core.Memory.readU16,
    ushort=Core.Memory.readU16,
    char=Core.Memory.readS8 or Core.Memory.readU8,
    uchar=Core.Memory.readU8,
    float=Core.Memory.readFloat,
    double=Core.Memory.readDouble,
    ["long long"]=nil
}

local writeFunctions = {
    void=nil,
    int=Core.Memory.writeU32, -- The function works the same for both (unless you are in versions prior to 0.13.0)
    uint=Core.Memory.writeU32,
    short=Core.Memory.writeU16, -- The function works the same for both
    ushort=Core.Memory.writeU16,
    char=Core.Memory.writeU8, -- The function works the same for both
    uchar=Core.Memory.writeU8,
    float=Core.Memory.writeFloat,
    double=Core.Memory.writeDouble,
    ["long long"]=nil
}

local function align(offset, size)
    return math.floor((offset + size - 1) / size) * size
end

---@class carray
local carray = CoreAPI.Utils.Classic:extend()

function carray:new(offset, dataType, size, isPointer, isUnsigned)
    self._offset = offset
    self._dataType = dataType
    self._size = size
    self._isPointer = isPointer
    self._isUnsigned = isUnsigned
end

function carray:_get_value(key)
    if key < 1 or key > self._size then
        return nil
    end

    local dataType = self._dataType
    if self._isUnsigned then
        dataType = "u"..dataType
    end
    local readFunc = readFunctions[dataType]
    local elementSize = ctypes[self._dataType]
    if self._isPointer then
        elementSize = 4
        dataType = dataType.."*"
        readFunc = readFunctions.uint
    end
    if self._dataType == "void" then
        if not self._isPointer then
            error("void not allowed without pointer modifier")
        end
    end
    if not readFunc then
        error("not implemented for "..dataType)
    end
    return readFunc(self._offset + elementSize * (key - 1))
end

local carray_def_index = carray.__index
carray.__index = function (self, key)
    if type(key) == "number" and self._get_value then
        return self:_get_value(key)
    end
    return carray_def_index[key]
end
carray.__len = function (self)
    return self._size
end

--[[
example:
{
    {"unsigned int", "field1"},
    {"short", "field2"}
}
]]
function cstruct:new(def)
    self._allocated = false
    self._isInstance = false
    self._isClass = false
    self._fields = {}
    self._sizeof = 0
    self:_add_def_fields(def)
    self._moffset = nil
end

function cstruct:_add_def_fields(def)
    local curOffset = self._sizeof
    for _, value in ipairs(def) do
        value[1] = string.lower(value[1])
        local countMatch = 0
        local typeMatch = nil
        for dataType, _ in pairs(ctypes) do
            if string.match(value[1], dataType) then
                typeMatch = string.match(value[1], dataType)
                countMatch = countMatch + 1
            end
        end
        if countMatch > 1 then
            error("More than one type "..value[1])
        end
        if not typeMatch then
            error("Unexpected type "..value[1])
        end
        local unsignedMatch = nil
        if string.match(value[1], "unsigned") then
            unsignedMatch = string.match(value[1], "^%s*(unsigned)%s+"..typeMatch)
            if not unsignedMatch then
                error("Unexpected type "..value[1])
            end
        end
        if unsignedMatch then
            if typeMatch == "float" or typeMatch == "double" then
                error("Unexpected type "..value[1])
            end
        end
        local arrayMatch
        if string.match(value[1], "%[.*%]") then
            arrayMatch = string.match(value[1], typeMatch.." *%*? *%[(%d+)%] *$")
            if not arrayMatch then
                error("Unexpected type "..value[1])
            end
        end
        local pointerMatch = nil
        if string.match(value[1], "%*.*%*") then
            error("max pointer level is only one")
        end
        if string.match(value[1], "%*") then
            pointerMatch = string.match(value[1], "(%*) *$")
            if not pointerMatch then
                pointerMatch = string.match(value[1], "(%*) *%[%d+%] *$")
                if not pointerMatch then
                    error("Unexpected type "..value[1])
                end
            end
        end
        if typeMatch == "void" and not pointerMatch then
            error("Type cannot be void "..value[1])
        end
        local size = 0
        local elementSize = 0
        if pointerMatch then
            elementSize = 4
        else
            elementSize = ctypes[typeMatch]
        end
        if arrayMatch then
            local arraySize = tonumber(arrayMatch, 10)
            if arraySize < 1 then
                error("arrays must have at least 1 element")
            end
            size = elementSize * arraySize
        else
            size = elementSize
        end
        local name = string.match(value[2], "^ *([%w]+) *$")
        if not name or self[name] ~= nil or name == "_moffset" or name == "_sizeof" then
            error("Invalid name "..value[2])
        end
        if self._fields[name] ~= nil then
            error("Duplicated name "..value[2])
        end
        local offset = align(curOffset, elementSize)
        self._fields[name] = {
            offset = offset,
            size = size,
            elementSize = elementSize,
            dataType = typeMatch,
            isArray = arrayMatch ~= nil,
            isPointer = pointerMatch ~= nil,
            isUnsigned = unsignedMatch ~= nil
        }
        curOffset = offset + size
    end
    self._sizeof = curOffset
end

---Creates a class for a cstruct definition
---@param def table
---@return table
function cstruct.newStruct(def)
    if type(def) ~= "table" then
        error("def must be a table")
    end
    local cls = cstruct:extend()
    cls:new(def)
    cls._isClass = true
    return cls
end

function cstruct:newInstance()
    if not self._isClass then
        error("you can only create an instance from a struct class")
    end
    local t = self({})
    t._fields = self._fields
    t._sizeof = self._sizeof
    local moffset = Core.Memory.malloc(self._sizeof)
    if not moffset then
        error("Failed to allocate memory")
    end
    t._allocated = true
    t._moffset = moffset
    t._isInstance = true
    return t
end

function cstruct:newInstanceFromMemory(offset)
    if not self._isClass then
        error("you can only create an instance from a struct class")
    end
    local t = self({})
    t._fields = self._fields
    t._sizeof = self._sizeof
    t._allocated = false
    t._moffset = offset
    t._isInstance = true
    return t
end

function cstruct:_check_instance()
    if not self._isInstance then
        error("Not an instance")
    end
end

function cstruct:free()
    self:_check_instance()
    if self._allocated then
        Core.Memory.free(self._moffset)
        self._allocated = false
    end
end

function cstruct:getPointer()
    self:_check_instance()
    return self._moffset
end

function cstruct:_get_value(key)
    self:_check_instance()
    local value = self._fields[key]
    if value.isArray then
        return carray(self._moffset + value.offset, value.dataType, math.floor(value.size / value.elementSize), value.isPointer, value.isUnsigned)
    end

    local dataType = value.dataType
    if value.isUnsigned then
        dataType = "u"..dataType
    end
    local readFunc = readFunctions[dataType]
    if value.isPointer then
        dataType = dataType.."*"
        readFunc = readFunctions.uint
    end

    if not readFunc then
        error("not implemented for "..dataType)
    end
    return readFunc(self._moffset + value.offset)
end

function cstruct:_set_value(key, newvalue)
    self:_check_instance()
    local field = self._fields[key]
    if field.isArray then
        error("not implemented for arrays")
    end

    local dataType = field.dataType
    if field.isUnsigned then
        dataType = "u"..dataType
    end
    local writeFunc = writeFunctions[dataType]
    if field.isPointer then
        dataType = dataType.."*"
        writeFunc = writeFunctions.uint
    end

    if not writeFunc then
        error("not implemented for "..dataType)
    end
    writeFunc(self._moffset + field.offset, newvalue)
end

function cstruct:_implementIndex()
    local def_index = self.__index
    self.__index = function (t, key)
        if key ~= "_fields" and t._fields and t._fields[key] ~= nil then
            return t:_get_value(key)
        end
        return def_index[key]
    end
    self.__newindex = function (t, key, value)
        if key ~= "_fields" and t._fields and t._fields[key] ~= nil then
            t:_set_value(key, value)
            return
        end
        rawset(t, key, value)
    end
end

function cstruct:extendStructClass(def)
    if not self._isClass then
        error("you can only extend a struct class")
    end
    local cls = self:extend()
    cls:new({})
    for key, value in pairs(self._fields) do
        cls._fields[key] = value
    end
    cls._sizeof = self._sizeof
    cls:_add_def_fields(def)
    return cls
end

function cstruct:extend()
    local cls = self.super.extend(self)
    cls:_implementIndex()
    return cls
end

cstruct:_implementIndex()
cstruct.__gc = function (self)
    if self._allocated then
        Core.Memory.free(self._moffset)
    end
end

return cstruct