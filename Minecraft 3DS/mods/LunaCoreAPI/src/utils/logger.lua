---@class Logger
local logger = CoreAPI.Utils.Classic:extend()

function logger:new(idname)
    self._idname = idname
end

---Creates a new logger used to write to the log file.
---The idname will be appended at the start of your log messages
---@param idname string
---@return Logger
function logger.newLogger(idname)
    if type(idname) == "string" then
        return logger(idname)
    else
        error("expected string for idname")
    end
end

function logger:info(msg)
    local out = "[INFO] "
    out = out .. "(" .. self._idname .. ") " .. msg
    Core.Debug.log(out, false)
end

function logger:warn(msg)
    local out = "[WARN] "
    out = out .. "(" .. self._idname .. ") " .. msg
    Core.Debug.log(out, false)
end

function logger:error(msg)
    local out = "[ERROR] "
    out = out .. "(" .. self._idname .. ") " .. msg
    Core.Debug.log(out, false)
end

return logger