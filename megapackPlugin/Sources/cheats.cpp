#include "cheats.hpp"
#include "3ds.h"

namespace CTRPluginFramework
{

void dropEverything(MenuEntry *entry){
    static int myInt = 1;
    if (myInt == 1){
        OSD::Notify("Use ZL+ZR to Drop Item in Hand.");
        myInt++;
    }
    if (hidKeysDown() & (KEY_ZL | KEY_ZR))
    {
        Process::Write32(0xB329E8, 0x02);
        svcSleepThread(16666);
        Process::Write32(0xB329E8, 0x00);
        svcSleepThread(16666);
        Process::Write32(0xB32948, 0x02);
        svcSleepThread(16666);
        Process::Write32(0xB32948, 0x00);
        svcSleepThread(16666);
        Process::Write32(0xB32A00, 0x02);
        svcSleepThread(16666);
        Process::Write32(0xB32A00, 0x00);
        svcSleepThread(16666);
        Process::Write32(0xB32A18, 0x02);
        svcSleepThread(16666);
        Process::Write32(0xB32A18, 0x00);
        svcSleepThread(16666);
        Process::Write32(0xB32A30, 0x02);
        svcSleepThread(16666);
        Process::Write32(0xB32A30, 0x00);
        svcSleepThread(16666);
        Process::Write32(0xB32A48, 0x02);
        svcSleepThread(16666);
        Process::Write32(0xB32A48, 0x00);
        svcSleepThread(16666);
        Process::Write32(0xB32A60, 0x02);
        svcSleepThread(16666);
        Process::Write32(0xB32A60, 0x00);
        svcSleepThread(16666);
        Process::Write32(0xB32A78, 0x02);
        svcSleepThread(16666);
        Process::Write32(0xB32A78, 0x00);
        svcSleepThread(16666);
        Process::Write32(0xB32A90, 0x02);
        svcSleepThread(16666);
        Process::Write32(0xB32A90, 0x00);
        svcSleepThread(16666);
        Process::Write32(0xB32AB0, 0x02);
        svcSleepThread(16666);
        Process::Write32(0xB32AB0, 0x00);
        svcSleepThread(16666);
    }
}

void ninetyFov(MenuEntry *entry){
    static int myInt = 1;
    if (myInt == 1){
        OSD::Notify("Set FOV to 90.");
        myInt++;
    }
    float fovVal = 90;
    Process::WriteFloat(0x3CEE80, fovVal);
}

void defaultCodes(MenuEntry *entry){
    static int myInt = 1;
    if (myInt == 1){
        OSD::Notify("Set Megapack Default Codes.");
        myInt++;
    }
    float swimVal = 0.075;
    float viewBobVal = 10.0;
    Process::WriteFloat(0x4EA090, swimVal);
    Process::WriteFloat(0x3CF2A0, viewBobVal);
}

void removeMobCap(MenuEntry *entry){
    Process::Write32(0xA33898, 0x00);
    Process::Write32(0xA338A8, 0x00);
    Process::Write32(0xA338AC, 0x00);
    Process::Write32(0xA338B0, 0x00);
    Process::Write32(0xA338B4, 0x00);
    Process::Write32(0xA338B8, 0x00);
    Process::Write32(0xA338BC, 0x00);
    Process::Write32(0xA338C0, 0x00);
}

}
