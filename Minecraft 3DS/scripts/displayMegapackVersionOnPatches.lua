local filesys = Core.Filesystem
local debug = Core.Debug
local memory = Core.Memory

if not _G.cachedPatchString then
    local patchFile = filesys.open(string.format('sdmc:/luma/titles/%s/romfs/notes/patch.txt', Core.getTitleId()), 'r')
    if patchFile then
        patchFile:seek(23)
        _G.cachedPatchString = string.format("%s\0", patchFile:read(6))
        patchFile:close()
        memory.writeString(0x790478, _G.cachedPatchString, 6)
        debug.log("File loaded and static address patched.")
    end
end

local pointer = memory.readU32(0xA30CBC)
if _G.cachedPatchString and pointer ~= 0 then
    memory.writeString(pointer, _G.cachedPatchString, 6)
end