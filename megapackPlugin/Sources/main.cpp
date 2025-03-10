#include <3ds.h>
#include "csvc.h"
#include <CTRPluginFramework.hpp>
#include "cheats.hpp"
#include <vector>

namespace CTRPluginFramework
{
    // This patch the NFC disabling the touchscreen when scanning an amiibo, which prevents ctrpf to be used
    static void    ToggleTouchscreenForceOn(void)
    {
        static u32 original = 0;
        static u32 *patchAddress = nullptr;

        if (patchAddress && original)
        {
            *patchAddress = original;
            return;
        }

        static const std::vector<u32> pattern =
        {
            0xE59F10C0, 0xE5840004, 0xE5841000, 0xE5DD0000,
            0xE5C40008, 0xE28DD03C, 0xE8BD80F0, 0xE5D51001,
            0xE1D400D4, 0xE3510003, 0x159F0034, 0x1A000003
        };

        Result  res;
        Handle  processHandle;
        s64     textTotalSize = 0;
        s64     startAddress = 0;
        u32 *   found;

        if (R_FAILED(svcOpenProcess(&processHandle, 16)))
            return;

        svcGetProcessInfo(&textTotalSize, processHandle, 0x10002);
        svcGetProcessInfo(&startAddress, processHandle, 0x10005);
        if(R_FAILED(svcMapProcessMemoryEx(CUR_PROCESS_HANDLE, 0x14000000, processHandle, (u32)startAddress, textTotalSize)))
            goto exit;

        found = (u32 *)Utils::Search<u32>(0x14000000, (u32)textTotalSize, pattern);

        if (found != nullptr)
        {
            original = found[13];
            patchAddress = (u32 *)PA_FROM_VA((found + 13));
            found[13] = 0xE1A00000;
        }

        svcUnmapProcessMemoryEx(CUR_PROCESS_HANDLE, 0x14000000, textTotalSize);
exit:
        svcCloseHandle(processHandle);
    }

    // This function is called before main and before the game starts
    // Useful to do code edits safely
    void    PatchProcess(FwkSettings &settings)
    {
        ToggleTouchscreenForceOn();
    }

    // This function is called when the process exits
    // Useful to save settings, undo patchs or clean up things
    void    OnProcessExit(void)
    {
        ToggleTouchscreenForceOn();
    }

    void InitMenu(PluginMenu &menu)
    {
        menu += new MenuEntry("Megapack Default Codes", defaultCodes, nullptr);
        menu += new MenuEntry("Disable Ground Item Limit", itemLimit, nullptr);
        menu += new MenuEntry("Remove Mob Spawn-Cap", removeMobCap, nullptr);
        menu += new MenuEntry("Enhanced Particles", enhancedParticles, nullptr);
        menu += new MenuEntry("Set FOV to 90", ninetyFov, nullptr);

        menu += new MenuEntry("Change FOV", nullptr, [](MenuEntry *entry)
        {
            float userValue;
            Keyboard kb("Enter a Float Value (Recomended 50-130):");
            std::string input;

            if (kb.Open(input) != -1)
            {
                userValue = std::stof(input);

                Process::WriteFloat(0x3CEE80, userValue);

                OSD::Notify(Utils::Format("Written: %.2f to 0x3CEE80", userValue));
        }
        });
        menu += new MenuEntry("Change ViewBobbing Sensitivity", nullptr, [](MenuEntry *entry)
        {
            float userValue;

            Keyboard kb("Enter a Float Value (Recomended 0-30):");
            std::string input;

            if (kb.Open(input) != -1)
            {
                userValue = std::stof(input);

                Process::WriteFloat(0x3CF2A0, userValue);

                OSD::Notify(Utils::Format("Written: %.2f to 0x3CF2A0", userValue));
        }
        });
        menu += new MenuEntry("Change Camera Sensitivity", nullptr, [](MenuEntry *entry)
        {
            float userValue;

            Keyboard kb("Enter a Float Value (Recomended 0-5):");
            std::string input;

            if (kb.Open(input) != -1)
            {
                userValue = std::stof(input);

                Process::WriteFloat(0x10B4D4, userValue);

                OSD::Notify(Utils::Format("Written: %.2f to 0x10B4D4", userValue));
        }
        });
        menu += new MenuEntry("Change Cloud Heightmap", nullptr, [](MenuEntry *entry)
        {
            float userValue;

            Keyboard kb("Enter a Float Value (Recomended (-80)-2):");
            std::string input;

            if (kb.Open(input) != -1)
            {
                userValue = std::stof(input);

                Process::WriteFloat(0x3C5398, userValue);

                OSD::Notify(Utils::Format("Written: %.2f to 0x3C5398", userValue));
        }
        });
        
    }

    int main(void)
    {
        PluginMenu *menu = new PluginMenu("Megapack Plugin", 1, 0, 0, "A CTRPF Plugin meant for Working with Minecraft 3DS' Modernization Megapack (Modpack).");
        // Synnchronize the menu with frame event
        menu->SynchronizeWithFrame(true);

        // Init our menu entries & folders
        InitMenu(*menu);
        OSD::Notify("Megapack has Successfully Loaded.\nPress 'select' to Open Menu.");

        // Launch menu and mainloop
        menu->Run();

        delete menu;

        // Exit plugin
        return (0);
    }
}
