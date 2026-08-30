local ffi = require("ffi")
jit.off()

---@class LCAPI_BlangParser
local blang_parser = {}
blang_parser.__index = blang_parser

--- Returns a new BlangParser. It's required that file will not be the same
--- used when dumpFile is called
---@param file string The path to the blang file
---@param flags table? A table of flags that define class behaviour. Values: useAsync, noErrors
---@return LCAPI_BlangParser
function blang_parser.newParser(file, flags)
    local tbl = setmetatable({}, blang_parser)
    tbl:new(file, flags)
    return tbl
end

pcall(function ()
ffi.cdef([[
typedef struct {
    uint32_t hashName;
    uint32_t textPos;
} BlangIndexElement;
]])
end)

local function BlangIndexArrayLen(indexObj)
    return ffi.sizeof(indexObj) / ffi.sizeof("BlangIndexElement")
end

local function binarySearch(indexObj, targetVal, arrLen)
    local left = 0
    local right = (arrLen or BlangIndexArrayLen(indexObj)) - 1

    while left <= right do
        local mid = math.floor((left + right) / 2)

        if indexObj[mid].hashName == targetVal then
            return mid
        end

        if indexObj[mid].hashName < targetVal then
            left = mid + 1
        else
            right = mid - 1
        end
    end
    return -1
end

local function binarySearchInsertPos(indexObj, val, arrLen)
    local start = 0
    local endI = (arrLen or BlangIndexArrayLen(indexObj)) - 1

    while start < endI do
        local mid = math.floor((start + endI) / 2)
        if val < indexObj[mid].hashName then
            endI = mid
        else
            start = mid + 1
        end
    end
    return start
end

---Tries to read an unsigned integer from srcFile. Returns nil if failure and sets error
---@param srcFile FilesystemFile
---@return integer
local function readU32(srcFile)
    local data = srcFile:read(4)
    if not data then error("Read u32 error") end
    local buf = ffi.new("uint32_t[1]")
    ffi.copy(buf, data, 4)
    return tonumber(buf[0])
end

---Writes value to srcFile
---@param srcFile FilesystemFile
---@param value integer
local function writeU32(srcFile, value)
    srcFile:write(ffi.string(ffi.new("uint32_t[1]", value), 4))
end

---Tries to read the amount of bytes from srcFile. Throws error if failure
---@param srcFile FilesystemFile
---@param buffer any
---@param len integer
local function readToBuffer(srcFile, buffer, len)
    local data = srcFile:read(len)
    if not data then error("Read buffer error") end
    ffi.copy(buffer, data, len)
end

---comment
---@param file string
---@param flags table?
function blang_parser:new(file, flags)
    if flags then
        -- No needed with jit
        --self._useAsync = flags.useAsync 
        self._noErrors = flags.noErrors
    end
    self.error = nil
    if self._useAsync and coroutine.running() == nil then
        self:throwError("This function must be called inside an async task")
        return
    end

    -- Open necessary files and prepare data
    local srcFile = Core.Filesystem.open(file, "r")
    if not srcFile then
        self:throwError("Failed to open file")
        return
    end

    -- Load and parse index data
    local indexData, textsData
    local status, err = pcall(function ()
        indexData = ffi.new("BlangIndexElement[?]", readU32(srcFile))
        readToBuffer(srcFile, indexData, ffi.sizeof(indexData) or 0);
        textsData = ffi.new("char[?]", readU32(srcFile))
        readToBuffer(srcFile, textsData, ffi.sizeof(textsData) or 0)
    end)
    if not status then
        self:throwError(err)
        return
    end
    srcFile:close()

    self._indexData = indexData
    self._textsData = textsData
    self._newData = {}
    self.parsed = true
end

function blang_parser:throwError(msg)
    if self._noErrors then
        self.error = msg
        return
    end
    error(msg, 2)
end

--- Checks if a textId is present
---@param textId string
---@return boolean
function blang_parser:containsText(textId)
    local textIdHash = CoreAPI.Utils.String.hash(textId:lower())
    if self._newData[textIdHash] ~= nil then
        return true
    else
        return binarySearch(self._indexData, textIdHash) > -1
    end
end

--- Returns the index of indexData that corresponds to the textId. Returns -1 on failure
---@param textId string
---@return table?
function blang_parser:getTextIndex(textId)
    local textIdHash = CoreAPI.Utils.String.hash(textId:lower())
    local textIndex = binarySearch(self._indexData, textIdHash)
    if textIndex > -1 then
        return self._indexData[textIndex]
    end
    return nil
end

function blang_parser:textFromIndexObj(obj)
    local textPtr = ffi.cast("const char*", self._textsData) + obj.textPos
    return ffi.string(textPtr)
end

--- Compares strings
---@param textId string
---@param s string
---@return boolean
function blang_parser:areEqual(textId, s)
    local textIdHash = CoreAPI.Utils.String.hash(textId:lower())
    if self._newData[textIdHash] ~= nil then
        return self._newData[textIdHash] == s
    else
        local idx = self:getTextIndex(textId)
        if idx then
            return self:textFromIndexObj(idx) == s
        end
        return false
    end
end

--- Adds a text
---@param textId string
---@param text string
function blang_parser:addText(textId, text)
    self._newData[CoreAPI.Utils.String.hash(textId:lower())] = text
end

local function insertNewIndex(indexData, newValue, idx)
    local maxLen = BlangIndexArrayLen(indexData)
    if idx >= maxLen then
        return
    end
    for i = maxLen - 2, idx, -1 do
        indexData[i+1].hashName = indexData[i].hashName
        indexData[i+1].textPos = indexData[i].textPos
    end
    indexData[idx] = newValue
end

--- Dumps to file. Returns if succeded. This function will fail if the output file
--- is the same used as the input file
---@param file string
---@return boolean
function blang_parser:dumpFile(file)
    if self._useAsync and coroutine.running() == nil then
        error("This function must be called inside an async task", 2)
    end

    local newDataLen = 0
    for _, _ in pairs(self._newData) do
        newDataLen = newDataLen + 1
    end

    local oldArrLen = BlangIndexArrayLen(self._indexData)
    local nelemlen = oldArrLen
    local currTextPos = ffi.sizeof(self._textsData)
    local newDataToAppend = ""
    if newDataLen > 0 then
        nelemlen = oldArrLen + newDataLen
        local nbuf = ffi.new("BlangIndexElement[?]", nelemlen)
        ffi.copy(nbuf, self._indexData, ffi.sizeof(self._indexData))
        self._indexData = nbuf
        collectgarbage("collect")
        for key, textValue in pairs(self._newData) do
            local itemIdx = binarySearch(self._indexData, key, oldArrLen)
            if itemIdx > -1 then -- Already exists so replace it
                local entry = self._indexData[itemIdx]
                local len = #self:textFromIndexObj(entry)
                if len == #textValue or len < #textValue then
                    ffi.copy(ffi.cast("const char*", self._textsData) + entry.textPos, textValue..string.char(0))
                else
                    entry.textPos = currTextPos
                    currTextPos = currTextPos + #textValue + 1
                    newDataToAppend = newDataToAppend .. textValue..string.char(0)
                end
            else -- Doesn't exists so insert or append a new one
                local insertIdx = binarySearchInsertPos(self._indexData, key, oldArrLen)
                oldArrLen = oldArrLen + 1
                insertNewIndex(self._indexData, {hashName = key, textPos = currTextPos}, insertIdx)
                currTextPos = currTextPos + #textValue + 1
                newDataToAppend = newDataToAppend .. textValue..string.char(0)
            end
        end
    end

    local outFile = Core.Filesystem.open(file, "w")
    if not outFile then
        return false
    end
    writeU32(outFile, nelemlen)
    outFile:write(ffi.string(self._indexData, ffi.sizeof(self._indexData)))
    writeU32(outFile, currTextPos)
    outFile:write(ffi.string(self._textsData, ffi.sizeof(self._textsData)))
    if #newDataToAppend > 0 then
        outFile:write(newDataToAppend)
    end
    outFile:flush()
    outFile:close()
    return true
end

return blang_parser