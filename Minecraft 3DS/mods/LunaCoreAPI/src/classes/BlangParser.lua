local struct = CoreAPI.Utils.Struct

---@class LCAPI_BlangParser
local blang_parser = CoreAPI.Utils.Classic:extend()

--- Returns a new BlangParser. It's required that file will not be the same
--- used when dumpFile is called
---@param file string The path to the blang file
---@param flags table? A table of flags that define class behaviour. Values: useAsync, noErrors
---@return LCAPI_BlangParser
function blang_parser.newParser(file, flags)
    return blang_parser(file, flags)
end

local indexIteratorElement = {}
function indexIteratorElement.__newindex(self, key, value)
    local i = self._curIdx
    local tbl = self._rootObj._tblData
    if key == "hash" then
        tbl[i*4 + 1] = value
    elseif key == "srcPos" then
        tbl[i*4 + 2] = value
    elseif key == "newPos" then
        tbl[i*4 + 3] = value
    elseif key == "length" then
        tbl[i*4 + 4] = value
    end
end
function indexIteratorElement.__index(self, key)
    local i = self._curIdx
    local tbl = self._rootObj._tblData
    if key == "hash" then
        return tbl[i*4 + 1]
    elseif key == "srcPos" then
        return tbl[i*4 + 2]
    elseif key == "newPos" then
        return tbl[i*4 + 3]
    elseif key == "length" then
        return tbl[i*4 + 4]
    elseif key == "index" then
        return i
    elseif key == "text" then
        return self._rootObj._textData:sub(self.srcPos + 1, self.srcPos + self.length)
    elseif key == "next" then
        if i < self._rootObj:len() - 1 then
            return indexIteratorElement.new(i+1, self._rootObj)
        else
            return nil
        end
    elseif key == "previous" then
        if i > 0 then
            return indexIteratorElement.new(i-1, self._rootObj)
        else
            return nil
        end
    end
end
---Creates a new indexIteratorElement
---@param idx integer The index starts at 0
---@param tbl table The reference to the index object
---@return table
function indexIteratorElement.new(idx, tbl)
    local tblData = tbl._tblData
    if tblData[idx*4+4] == nil then
        error("Index out of range. "..tostring(idx), 2)
    end
    local element = {_curIdx=idx, _rootObj=tbl}
    setmetatable(element, indexIteratorElement)
    return element
end

local indexClass = {}
indexClass.__index = function (self, key)
    if type(key) == "number" then
        if key < 0 then
            return self:getIndexElement(self:len() + key)
        else
            return self:getIndexElement(key)
        end
    end
    return indexClass[key]
end
function indexClass:len()
    return #self._tblData / 4
end
function indexClass.new(srcText)
    local newIns = {}
    newIns._tblData = {}
    newIns._textData = srcText
    newIns._newTextData = {}
    setmetatable(newIns, indexClass)
    return newIns
end
function indexClass:appendNewIndex(hash, srcPos, textLen)
    table.insert(self._tblData, hash) -- hash
    table.insert(self._tblData, srcPos) -- srcPos
    table.insert(self._tblData, srcPos) -- newPos
    if textLen ~= nil then
        table.insert(self._tblData, textLen) -- length
    else
        table.insert(self._tblData, 0) -- length
    end
    return indexIteratorElement.new(self:len() - 1, self)
end
function indexClass:insertNewIndex(idx, hash, newPos, textLen)
    local curr = self:len() - 1
    while curr >= idx do
        self._tblData[(curr+1)*4+1] = self._tblData[curr*4+1] -- hash
        self._tblData[(curr+1)*4+2] = self._tblData[curr*4+2] -- srcPos
        self._tblData[(curr+1)*4+3] = self._tblData[curr*4+3] + textLen + 1 -- newPos
        self._tblData[(curr+1)*4+4] = self._tblData[curr*4+4] -- length
        curr = curr - 1
    end
    self._tblData[idx*4+1] = hash -- hash
    self._tblData[idx*4+2] = newPos -- srcPos
    self._tblData[idx*4+3] = newPos -- newPos
    self._tblData[idx*4+4] = textLen -- length
    return indexIteratorElement.new(idx, self)
end
function indexClass:getIndexElement(idx)
    return indexIteratorElement.new(idx, self)
end

local function indexIterator(idxObj, startIndex)
    local i = -1 -- -1 so it starts with index 0
    if startIndex ~= nil then
        i = startIndex - 1
    end
    local length = idxObj:len()
    return function ()
        i = i + 1
        if i < length then
            return indexIteratorElement.new(i, idxObj)
        end
    end
end

local function binarySearch(indexObj, targetVal)
    local tbl = indexObj._tblData
    local left = 0
    local right = indexObj:len() - 1

    while left <= right do
        local mid = math.floor((left + right) / 2)

        if tbl[mid*4 + 1] == targetVal then
            return mid
        end

        if tbl[mid*4 + 1] < targetVal then
            left = mid + 1
        else
            right = mid - 1
        end
    end
    return -1
end

local function binarySearchInsertPos(indexObj, val)
    local tbl = indexObj._tblData
    local start = 0
    local endI = indexObj:len() - 1

    while start < endI do
        local mid = math.floor((start + endI) / 2)
        if val < tbl[mid*4 + 1] then
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
    local status, res = pcall(struct.unpack, "<I", srcFile:read(4))
    if not status then
        error("Read error")
    end
    return res
end

---comment
---@param file string
---@param flags table?
function blang_parser:new(file, flags)
    if flags then
        self._useAsync = flags.useAsync
        self._noErrors = flags.noErrors
    end
    self.error = nil
    if self._useAsync and coroutine.running() == nil then
        self:throwError("This function must be called inside an async task")
        return
    end
    local intSize = 4

    -- Open necessary files and prepare data
    local srcFile = Core.Filesystem.open(file, "r")
    if not srcFile then
        self:throwError("Failed to open file")
        return
    end

    -- Load and parse index data
    local idxLen, file_data, textsLen, indexData
    local status, err = pcall(function ()
        idxLen = readU32(srcFile)
        file_data = srcFile:read(idxLen * intSize * 2)
        textsLen = readU32(srcFile)
        indexData = indexClass.new(srcFile:read(textsLen))
    end)
    if not status then
        self:throwError(err)
        return
    end
    if file_data == nil then
        self:throwError("Failed to read index data")
        return
    end
    srcFile:close()

    local asyncCounter = 0
    for i = 0, idxLen - 1 do
        local hashName = struct.unpack("<I", file_data:sub(((intSize * 2 * i) + 1), ((intSize * 2 * i + 3) + 1)))
        local texPos = struct.unpack("<I", file_data:sub(((intSize * 2 * i) + intSize + 1), (((intSize * 2 * i) + intSize + 3) + 1)))
        local newEntry = indexData:appendNewIndex(hashName, texPos)
        local previous = newEntry.previous
        if previous then -- Calculate previous text length
            previous.length = (newEntry.srcPos - 1) - previous.srcPos
        end
        asyncCounter = asyncCounter + 1
        if asyncCounter > 150 then
            if self._useAsync then Async.wait() end
            asyncCounter = 0
        end
    end
    local lastEntry = indexData[-1]
    lastEntry.length = (textsLen - 1) - lastEntry.srcPos

    self._indexData = indexData
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
            return idx.text == s
        end
    end
    return false
end

--- Adds a text
---@param textId string
---@param text string
function blang_parser:addText(textId, text)
    self._newData[CoreAPI.Utils.String.hash(textId:lower())] = text
end

--- Dumps to file. Returns if succeded. This function will fail if the output file
--- is the same used as the input file
---@param file string
---@return boolean
function blang_parser:dumpFile(file)
    if self._useAsync and coroutine.running() == nil then
        error("This function must be called inside an async task", 2)
    end
    local outFile = Core.Filesystem.open(file, "w")
    if not outFile then
        return false
    end

    local asyncCounter = 0
    -- Insert new text entries to the index data
    for key, textValue in pairs(self._newData) do
        local itemIdx = binarySearch(self._indexData, key)
        if itemIdx > -1 then -- Already exists so replace it
            local entry = self._indexData[itemIdx]
            local offset = #textValue - entry.length
            entry.length = #textValue
            entry.srcPos = -1
            for subEntry in indexIterator(self._indexData, entry.index + 1) do
                subEntry.newPos = subEntry.newPos + offset
            end
        else -- Doesn't exists so insert or append a new one
            local insertIdx = binarySearchInsertPos(self._indexData, key)
            if insertIdx >= self._indexData:len() then -- Out of range so appendNewIndex
                local entry = self._indexData[-1]
                local textPos = entry.newPos + entry.length + 1
                self._indexData:appendNewIndex(key, textPos, #textValue)
            else -- Else inside the list so insertNewIndex
                local entry = self._indexData[insertIdx]
                self._indexData:insertNewIndex(insertIdx, key, entry.newPos, #textValue)
            end
        end
    end
    if self._useAsync then Async.wait() end

    local indexData = {}
    outFile:write(struct.pack("<I", self._indexData:len())) -- Write index section length
    for entry in indexIterator(self._indexData) do
        table.insert(indexData, struct.pack("<I", entry.hash) .. struct.pack("<I", entry.newPos))
        asyncCounter = asyncCounter + 1
        if asyncCounter > 200 then
            asyncCounter = 0
            if self._useAsync then Async.wait() end
        end
    end
    outFile:write(table.concat(indexData))
    local lastItem = self._indexData[-1]
    outFile:write(struct.pack("<I", lastItem.newPos + lastItem.length + 1)) -- Write texts section length

    -- Write texts
    local buffer = ""
    for value in indexIterator(self._indexData) do
        if self._newData[value.hash] ~= nil then
            buffer = buffer .. self._newData[value.hash] .. string.char(0)
        else
            buffer = buffer .. value.text .. string.char(0)
        end
        if #buffer > 500 then
            if #buffer > 0 then
                outFile:write(buffer)
                buffer = ""
            end
            if self._useAsync then Async.wait() end
        end
    end
    if #buffer > 0 then
        outFile:write(buffer)
        buffer = ""
    end
    outFile:close()
    return true
end

return blang_parser