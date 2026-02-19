local filesys = Core.Filesystem
local debug = Core.Debug
local memory = Core.Memory

local pointer = memory.readU32(0xA30CBC)
local patchFile = filesys.open(string.format('sdmc:/luma/titles/%016X/romfs/notes/patch.txt', Core.getTitleId()))
if patchFile then
    patchFile:seek(23)
    local fullString = string.format("%s\0", patchFile:read(5))
    memory.writeString(pointer, fullString, 6)
patchFile:close()
