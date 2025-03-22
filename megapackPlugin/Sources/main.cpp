#include <3ds.h>
#include "csvc.h"
#include <CTRPluginFramework.hpp>
#include "cheats.hpp"
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <sstream>
#include <vector>

namespace CTRPluginFramework
{
    Handle  processHandle;
    u64 titleID = Process::GetTitleID();
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
    void PatchProcess(FwkSettings &settings){

    #if defined(__ARM_ARCH_7A__) // Check for ARMv7-A architecture
        asm volatile (
            "mrc p15, 0, r0, c1, c0, 2 \n"  // Read CPACR
            "orr r0, r0, #(0b11 << 20) \n"  // Enable access for CP10 (VFP)
            "orr r0, r0, #(0b11 << 22) \n"  // Enable access for CP11 (VFP)
            "mcr p15, 0, r0, c1, c0, 2 \n"  // Write back to CPACR
            "isb \n"                        // Instruction synchronization barrier
            "dsb \n"                        // Data synchronization barrier
        );
        // Enable the VFP itself
        asm volatile (
            "vmrs r0, fpexc \n"   // Read FPEXC (Floating-Point Exception Control Register)
            "orr r0, r0, #0x40000000 \n"  // Set EN bit to enable VFP
            "vmsr fpexc, r0 \n"  // Write back to FPEXC
        );
        OSD::Notify("Enabled VFP Mode for Minecraft 3DS.");
    #endif

    settings.CloseMenuWithB = true;
    ToggleTouchscreenForceOn();

    std::string path = "sdmc:/luma/config.ini";
    File file;

    if (File::Open(file, path, File::READ) != 0) 
    {
        OSD::Notify("Failed to open config.ini");
        return;
    }

    u32 fileSize = file.GetSize();
    std::vector<char> buffer(fileSize + 1, '\0');
    file.Read(buffer.data(), fileSize);
    file.Close();

    std::string content(buffer.begin(), buffer.end());

    if (content.find("enable_game_patching = 1") != std::string::npos)
    {
        OSD::Notify("Game patching is already enabled.");
        return;
    }

    size_t pos = content.find("enable_game_patching = 0");
    if (pos != std::string::npos)
    {
        content.replace(pos, 25, "enable_game_patching = 1");

        if (File::Open(file, path, File::WRITE) == 0)
        {
            file.Write(content.c_str(), content.size());
            file.Close();
            OSD::Notify("Game patching enabled. The game will crash.");
            OSD::Notify("Please restart the game for the patch to be applied.");
            svcSleepThread(5000000000ULL);
            Process::ReturnToHomeMenu();
        }
    }
    }

    // This function is called when the process exits
    // Useful to save settings, undo patches or clean up things
    void    OnProcessExit(void)
    {
        OSD::Stop(displayPlayerCoordsTopScreen);
        if (!Process::IsPaused())  
        {
            ToggleTouchscreenForceOn();
        }
        svcSleepThread(1000000000ULL);
        Process::ReturnToHomeMenu();
    }

    void InitMenu(PluginMenu &menu)
    {
        MenuFolder *codesFolder = new MenuFolder("Default Codes");
        MenuFolder *funFolder = new MenuFolder("Fun Codes");
        MenuFolder *configFolder = new MenuFolder("Config");
        MenuFolder *toolsFolder = new MenuFolder("Tools");
        codesFolder->Append(new MenuEntry("MegaPack Default Codes", defaultCodes));
        codesFolder->Append(new MenuEntry("Drop Everything In Hand", dropEverything));
        codesFolder->Append(new MenuEntry("Disable Dropped Item/EXP Limit", itemExpLimit));
        codesFolder->Append(new MenuEntry("Remove Mob Spawn Cap", removeMobCap));
        codesFolder->Append(new MenuEntry("Disable Mob Spawning", stopMobSpawns));
        codesFolder->Append(new MenuEntry("Enhanced Particles", enhancedParticles));
        codesFolder->Append(new MenuEntry("Set FOV to 90", ninetyFov));
        funFolder->Append(new MenuEntry("Better Minecart Physics", betterMinecartPhysics));
        funFolder->Append(new MenuEntry("Remove (most) Mob Heads", removeHeads));
        funFolder->Append(new MenuEntry("Every Mob/Player Spins", everythingSpinny));
        toolsFolder->Append(new MenuEntry("Player Model Editor", nullptr, [](MenuEntry *entry)
        {
            if (MessageBox("Are you sure?", "The model editor will permanently change your skin attributes.", DialogType::DialogOkCancel, ClearScreen::Both)()){
                selectAndModifyOffset();
            } else{
                OSD::Notify("Operation cancelled.");
            }
            
        }));
        funFolder->Append(new MenuEntry("Change Player Scaling", nullptr, [](MenuEntry *entry)
        {
            float userValue;

            Keyboard kb("Enter a float value (Recommended 0->10):");
            float input;

            if (kb.Open(input) != -1)
            {
                float userValue = input;

                Process::WriteFloat(0x600BF0, userValue);
                Process::WriteFloat(0x60370C, userValue);
                Process::WriteFloat(0x607270, userValue);
                Process::WriteFloat(0x607274, userValue);
                Process::WriteFloat(0x60804C, userValue);
                Process::WriteFloat(0x7218F4, userValue);
                Process::WriteFloat(0x735020, userValue);
                Process::WriteFloat(0x988BB8, userValue);

                OSD::Notify(Utils::Format("Written: %.2f to Scaling Address'", userValue));
                OSD::Notify("Requires a world restart, or for you to load a world.");
                OSD::Notify("This does not scale the player skin.");
        }
        }));
        funFolder->Append(new MenuEntry("Change Player Arm Length", nullptr, [](MenuEntry *entry)
        {
            float userValue;

            Keyboard kb("Enter a float value (Recomended 5->15):");
            float input;

            if (kb.Open(input) != -1)
            {
                float userValue = input;

                Process::WriteFloat(0x64FB68, userValue);

                OSD::Notify(Utils::Format("Written: %.2f to 0x64FB68", userValue));
        }
        }));
        funFolder->Append(new MenuEntry("Change Jump Velocity", nullptr, [](MenuEntry *entry)
        {
            float userValue;

            Keyboard kb("Enter a float value (Recomended 0->1):");
            float input;

            if (kb.Open(input) != -1)
            {
                float userValue = input;

                Process::WriteFloat(0x7139F8, userValue);

                OSD::Notify(Utils::Format("Written: %.2f to 0x7139F8", userValue));
        }
        }));
        funFolder->Append(new MenuEntry("Turn Player Upside Down", nullptr, [](MenuEntry *entry)
        {
            Keyboard kb("Enter your system nickname (Not NNID/PID):");
            std::string input;

            if (kb.Open(input) != -1)
            {
                if (input.size() < 10)
                    input.append(10 - input.size(), '\0');
                else
                    input = input.substr(0, 10);

                Process::WriteString(0x6A6D50, input, StringFormat::Utf8);
            
                OSD::Notify("Cracked name function to accept: " + input);
            }

        }));
        // configs
        configFolder->Append(new MenuEntry("Change View Bobbing Sensitivity", nullptr, [](MenuEntry *entry)
        {
            float userValue;

            Keyboard kb("Enter a float value (Recomended 0->30):");
            float input;

            if (kb.Open(input) != -1)
            {
                float userValue = input;

                Process::WriteFloat(0x3CF2A0, userValue);

                OSD::Notify(Utils::Format("Written: %.2f to 0x3CF2A0", userValue));
        }
        }));
        configFolder->Append(new MenuEntry("Display Debug Information", nullptr, [](MenuEntry *entry)
		{
            if (entry->WasJustActivated())
                OSD::Stop(displayPlayerCoordsTopScreen);
            else 
                OSD::Run(displayPlayerCoordsTopScreen);
        }));
        configFolder->Append(new MenuEntry("Change Camera Sensitivity", nullptr, [](MenuEntry *entry)
        {
            float userValue;

            Keyboard kb("Enter a float value (Recomended 0->5):");
            float input;

            if (kb.Open(input) != -1)
            {
                float userValue = input;

                Process::WriteFloat(0x10B4D4, userValue);

                OSD::Notify(Utils::Format("Written: %.2f to 0x10B4D4", userValue));
        }
        }));
        configFolder->Append(new MenuEntry("Change Cloud Heightmap", nullptr, [](MenuEntry *entry)
        {
            float userValue;

            Keyboard kb("Enter a float value (Recomended (-80)->2):");
            float input;

            if (kb.Open(input) != -1)
            {
                float userValue = input;

                Process::WriteFloat(0x3C5398, userValue);

                OSD::Notify(Utils::Format("Written: %.2f to 0x3C5398", userValue));
        }
        }));
        //configFolder->Append(new MenuEntry("Fix C-Stick", nullptr, [](MenuEntry *entry)
		//{
        //    keys |= Key::CStickRight;
        //    keys |= Key::CStickLeft;
        //    keys |= Key::CStickUp;
        //    keys |= Key::CStickDown;
        //}));
        configFolder->Append(new MenuEntry("Change FOV", nullptr, [](MenuEntry *entry)
        {
            float userValue;
            Keyboard kb("Enter a float value (Recomended 50->130):");
            float input;

            if (kb.Open(input) != -1)
            {
                float userValue = input;

                Process::WriteFloat(0x3CEE80, userValue);

                OSD::Notify(Utils::Format("Written: %.2f to 0x3CEE80", userValue));
        }
        }));
        toolsFolder->Append(new MenuEntry("World Extractor", nullptr, [](MenuEntry *entry)
        {
            if (MessageBox("WARNING - Are you sure?", "World extractor will extract your currently running world if you're in one. The plugin will freeze. This can take up a lot of SDMC Space (5MiB->50MiB) and can bloat the DCIM camera directory, please wait (30s->45s) for the plugin to finish. Once started, you cannot cancel the operation.\n\nNote: These worlds once extracted will need to have the headers rebuilt.", DialogType::DialogOkCancel, ClearScreen::Both)()){
                backupWorld();
            } else{
                OSD::Notify("Operation cancelled.");
            }
        }));
        menu += codesFolder;
        menu += funFolder;
        menu += configFolder;
        menu += toolsFolder;
    }

    int main(void)
    {
        u64 titleID = Process::GetTitleID();
        u64 usaTID = 1125899908646656;
        u64 eurTID = 1125899908401664;
        u64 jpnTID = 1125899908414720;
        PluginMenu *menu = nullptr;
        std::string mgapckTxt = "MegaPack Plugin - ";
        std::string abtPlg = "A CTRPF Plugin meant for working with Minecraft 3DS' Modernization MegaPack.\nDeveloped by: Cracko298";

        if (usaTID == titleID)
            menu = new PluginMenu(mgapckTxt + "USA", 1, 0, 0, abtPlg);
        else if (eurTID == titleID)
            menu = new PluginMenu(mgapckTxt + "EUR", 1, 0, 0, abtPlg);
        else if (jpnTID == titleID)
            menu = new PluginMenu(mgapckTxt + "JPN", 1, 0, 0, abtPlg);
        else
            menu = new PluginMenu(mgapckTxt + "BAD", 1, 0, 0, abtPlg);

        menu->SynchronizeWithFrame(true);
        InitMenu(*menu);

        OSD::Notify(Utils::Format("TitleID: %llu", titleID));
        if (titleID != usaTID && titleID != eurTID && titleID != jpnTID){
            OSD::Notify("Plugin should only be running on 'Minecraft: New Nintendo 3DS Edition'.");
            svcSleepThread(5000000000);
            delete menu;
            OnProcessExit();
            svcCloseHandle(processHandle);
            return (0);
        } else {
            OSD::Notify("MegaPack has successfully loaded.");
            OSD::Notify("Press 'Select' to open menu.");
            svcSleepThread(500000000);
            
            // Start Menu
            menu->ShowWelcomeMessage(false);
            menu->Run();

            // Exit Menu
            delete menu;
            OnProcessExit();
            svcCloseHandle(processHandle);
            return (0);
        }

    }
}
