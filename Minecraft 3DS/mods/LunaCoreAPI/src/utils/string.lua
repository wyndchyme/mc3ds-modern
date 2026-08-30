CoreAPI.Utils.String = {}

--- Returns a table with a string splitted
---@param s string
---@param separator string
---@return table<string>
function CoreAPI.Utils.String.split(s, separator)
    if separator == nil then
        separator = "%s"
    end
    local escaped_delimiter = separator:gsub('([%.%*%+%?%^%$%[%]%(%)%{%}%|%\\])', '%%%1')
    local pattern = string.format('([^%s]+)', escaped_delimiter)
    local result = {}
    for str in s:gmatch(pattern) do
        table.insert(result, str)
    end
    return result
end

--- Generates a 32 bit hash (uses JOAAT algorithm)
---@param s string
---@return integer
function CoreAPI.Utils.String.hash(s)
    local bit = CoreAPI.Utils.Bitop
    local hash_ = 0
    for i = 1, #s do
        hash_ = hash_ + string.byte(s, i)
        hash_ = bit.band(hash_, 0xFFFFFFFF)
        hash_ = hash_ + bit.lshift(hash_, 10)
        hash_ = bit.band(hash_, 0xFFFFFFFF)
        hash_ = bit.bxor(hash_, bit.rshift(hash_, 6))
    end
    hash_ = hash_ + bit.lshift(hash_, 3)
    hash_ = bit.band(hash_, 0xFFFFFFFF)
    hash_ = bit.bxor(hash_, bit.rshift(hash_, 11))
    hash_ = hash_ + bit.lshift(hash_, 15)
    hash_ = bit.band(hash_, 0xFFFFFFFF)
    return hash_
end