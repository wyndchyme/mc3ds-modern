#include "cheats.hpp"
#include "types.h"
#include "3ds.h"
#include <iostream>
#include <fstream>
#include <unordered_map>
#include <sstream>
#include <cstdint>

namespace CTRPluginFramework
{

void dropEverything(MenuEntry *entry){
    if (!Process::IsPaused()){
    static int myInt = 1;
    if (myInt == 1){
        OSD::Notify("Use ZL+ZR to drop item in hand.");
        myInt++;
    }
    if (hidKeysDown() & (KEY_ZL | KEY_ZR))
    {
        Process::Write32(0xB329E8, 0x02);
        Process::Write32(0xB32948, 0x02);
        Process::Write32(0xB32A00, 0x02);
        Process::Write32(0xB32A18, 0x02);
        Process::Write32(0xB32A30, 0x02);
        Process::Write32(0xB32A48, 0x02);
        Process::Write32(0xB32A60, 0x02);
        Process::Write32(0xB32A78, 0x02);
        Process::Write32(0xB32A90, 0x02);
        Process::Write32(0xB32AB0, 0x02);
        svcSleepThread(16666);
        Process::Write32(0xB329E8, 0x00);
        Process::Write32(0xB32948, 0x00);
        Process::Write32(0xB32A00, 0x00);
        Process::Write32(0xB32A18, 0x00);
        Process::Write32(0xB32A30, 0x00);
        Process::Write32(0xB32A48, 0x00);
        Process::Write32(0xB32A60, 0x00);
        Process::Write32(0xB32A78, 0x00);
        Process::Write32(0xB32A90, 0x00);
        Process::Write32(0xB32AB0, 0x00);
        svcSleepThread(16666);
    }
}
}

void ninetyFov(MenuEntry *entry){
    if (!Process::IsPaused()){
    static int myInt = 1;
    if (myInt == 1){
        OSD::Notify("Set FOV to 90.");
        myInt++;
    }
    float fovVal = 90;
    Process::WriteFloat(0x3CEE80, fovVal);
}
}

void defaultCodes(MenuEntry *entry){
    if (!Process::IsPaused()){
    static int myInt = 1;
    if (myInt == 1){
        OSD::Notify("Enabled MegaPack default codes.");
        myInt++;
    }
    float swimVal = 0.075;
    float viewBobVal = 10.0;
    Process::WriteFloat(0x4EA090, swimVal);
    Process::WriteFloat(0x3CF2A0, viewBobVal);
}
}

void removeMobCap(MenuEntry *entry){
    if (!Process::IsPaused()){
    static int myInt = 1;
    if (myInt == 1){
        OSD::Notify("Disabled mob spawning limit.");
        myInt++;
    }
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

void stopMobSpawns(MenuEntry *entry){
    if (!Process::IsPaused()){
    static int myInt = 1;
    if (myInt == 1){
        OSD::Notify("Disabled mob spawning.");
        myInt++;
    }
    Process::Write32(0xA33898, 0xB0);
    Process::Write32(0xA338A8, 0xB0);
    Process::Write32(0xA338AC, 0xB0);
    Process::Write32(0xA338B0, 0xB0);
    Process::Write32(0xA338B4, 0xB0);
    Process::Write32(0xA338B8, 0xB0);
    Process::Write32(0xA338BC, 0xB0);
    Process::Write32(0xA338C0, 0xB0);
}
}

void itemExpLimit(MenuEntry *entry){
    if (!Process::IsPaused()){
    static int myInt = 1;
    if (myInt == 1){
        OSD::Notify("Removed dropped item limit.");
        myInt++;
    }
    Process::Write32(0xA339C0, 0x00);
    Process::Write32(0xA339AC, 0x00);
}
}

void enhancedParticles(MenuEntry *entry){
    if (!Process::IsPaused()){
    static int myInt = 1;
    if (myInt == 1){
        OSD::Notify("Fixed Write32 panic.");
        myInt++;
    }
    Process::Write8(0x14A4F, 0xE2);
}
}

bool displayPlayerCoordsTopScreen(const Screen& screen){
	if (!screen.IsTop) return false;
    static bool erb, uwtr;
	static float x, y, z;
    static u16 mid;
    static u32 mc1, mc2, mc3, mc4, mc5, mc6, mc7, mc8, er3, itm, exp, wtr0, wtr1;
    if (!Process::IsPaused()){
    	Process::ReadFloat(0xAC1E48, x);
	    Process::ReadFloat(0xAC1E4C, y);
		Process::ReadFloat(0xAC1E50, z);
        Process::Read32(0xA33898, mc1);
        Process::Read32(0xA338A8, mc2);
        Process::Read32(0xA338AC, mc3);
        Process::Read32(0xA338B0, mc4);
        Process::Read32(0xA338B4, mc5);
        Process::Read32(0xA338B8, mc6);
        Process::Read32(0xA338BC, mc7);
        Process::Read32(0xA338C0, mc8);
        Process::Read16(0x3504A092, mid);
        Process::Read32(0x3018AEF0, er3);
        Process::Read32(0xA339C0, itm);
        Process::Read32(0xA339AC, exp);
        Process::Read32(0xFFFE064, wtr0);
        Process::Read32(0xFFFDFFC, wtr1);
    }
    if (wtr0 == 1 || wtr1 == 1){
        uwtr = true;
    } else {
        uwtr = false;
    }
    u32 noe = mc1+mc2+mc3+mc4+mc5+mc6+mc7+mc8;
    if (er3 == 1) {
        erb = true;
    } else {
        erb = false;
    }
	screen.Draw("Player.X: " + Utils::Format("%.2f", x), 10, 45, Color::White, Color::Black);
    screen.Draw("Player.Y: " + Utils::Format("%.2f", y), 10, 55, Color::White, Color::Black);
    screen.Draw("Player.Z: " + Utils::Format("%.2f", z), 10, 65, Color::White, Color::Black);
    screen.Draw("3D Engine?: " + Utils::Format("%s", erb ? "true" : "false"), 10, 85, Color::White, Color::Black);
    screen.Draw("IsSwimming?: " + Utils::Format("%s", uwtr ? "true" : "false"), 10, 95, Color::White, Color::Black);
    screen.Draw("EXP Rendered: " + Utils::Format("%u", exp), 10, 105, Color::White, Color::Black);
    screen.Draw("Mobs Rendered: " + Utils::Format("%u", noe), 10, 115, Color::White, Color::Black);
    screen.Draw("Items Rendered: " + Utils::Format("%u", itm), 10, 125, Color::White, Color::Black);
    // screen.Draw("Entity In-Hand: " + Utils::Format("%u", mid), 10, 85, Color::White, Color::Black);
	return true;
}

// fun codes
void betterMinecartPhysics(MenuEntry *entry){
    if (!Process::IsPaused()){
    static int myInt = 1;
    if (myInt == 1){
        OSD::Notify("Configured Better Minecart Physics.");
        myInt++;
    }
    Process::WriteFloat(0x659B48, 0.0);
    Process::WriteFloat(0x659B54, 0.0085);
}
}

void removeHeads(MenuEntry *entry){
    if (!Process::IsPaused()){
    static int myInt = 1;
    if (myInt == 1){
        OSD::Notify("Removed most mob heads.");
        myInt++;
    }
    Process::WriteFloat(0x21F42C, 0.0);
}
}

void everythingSpinny(MenuEntry *entry){
    if (!Process::IsPaused()){
    static int myInt = 1;
    static float playerPos;
    if (myInt == 1){
        OSD::Notify("Everything is now spinning.");
        myInt++;
    }
    Process::ReadFloat(0x6A6D3C, playerPos);
    Process::WriteFloat(0x6A6D3C, playerPos+1);
    Process::WriteFloat(0x17B728, 0.0);
}
}

void ModifySignedIntFromFile(const std::string& filename, std::streampos offset) {
    File file;
    int32_t value;

    // Open the file for reading and writing
    if (File::Open(file, filename, File::READ | File::WRITE) != 0) {
        OSD::Notify("Failed to open file!");
        return;
    }

    // Seek to the offset and read 4 bytes (signed 32-bit integer)
    file.Seek(offset, File::SET);
    file.Read(&value, sizeof(value));

    OSD::Notify(Utils::Format("Initial Value: %d", value));

    // Infinite loop (press SELECT + B in CTRPF to exit)
    while (true) {
        // Increment 5 times
        for (int i = 0; i < 5; ++i) {
            value++;
            file.Seek(offset, File::SET);
            file.Write(&value, sizeof(value));
            OSD::Notify(Utils::Format("Incremented: %d", value));
        }

        // Decrement 5 times
        for (int i = 0; i < 5; ++i) {
            value--;
            file.Seek(offset, File::SET);
            file.Write(&value, sizeof(value));
            OSD::Notify(Utils::Format("Decremented: %d", value));
        }
    }

    file.Close();  // Close file (though we never reach this due to infinite loop)
}

void moveBodyPart(MenuEntry *entry){
    std::streampos offset = 0x188;
    std::string filename = "sdmc:/luma/titles/00040000001B8700/romfs/resourcepacks/skins/skinpacks/skins.bjson";
    ModifySignedIntFromFile(filename, offset);
}


// Lookup table for offsets
std::unordered_map<std::string, int> modelOffsets = {
    {"Body.Pivot.X", 0x50}, {"Body.Pivot.Y", 0x5C}, {"Body.Pivot.Z", 0x68},
    {"Body.Origin.X", 0x98}, {"Body.Origin.Y", 0xA4}, {"Body.Origin.Z", 0xB0},
    {"Body.Size.X", 0xC8}, {"Body.Size.Y", 0xD4}, {"Body.Size.Z", 0xE0},
    {"Body.UV.X", 0xF8}, {"Body.UV.Y", 0x104},
    {"Head.Pivot.X", 0x134}, {"Head.Pivot.Y", 0x140}, {"Head.Pivot.Z", 0x14C},
    {"Head.Origin.X", 0x17C}, {"Head.Origin.Y", 0x188}, {"Head.Origin.Z", 0x194},
    {"Head.Size.X", 0x1AC}, {"Head.Size.Y", 0x1B8}, {"Head.Size.Z", 0x1C4},
    {"Head.UV.X", 0x1DC}, {"Head.UV.Y", 0x1E8},
    {"Hat.Pivot.X", 0x218}, {"Hat.Pivot.Y", 0x224}, {"Hat.Pivot.Z", 0x230},
    {"Hat.Origin.X", 0x260}, {"Hat.Origin.Y", 0x26C}, {"Hat.Origin.Z", 0x278},
    {"Hat.Size.X", 0x290}, {"Hat.Size.Y", 0x29C}, {"Hat.Size.Z", 0x2A8},
    {"Hat.UV.X", 0x2C0}, {"Hat.UV.Y", 0x2CC},
    {"RightArm.Pivot.X", 0x314}, {"RightArm.Pivot.Y", 0x320}, {"RightArm.Pivot.Z", 0x32C},
    {"RightArm.Origin.X", 0x35C}, {"RightArm.Origin.Y", 0x368}, {"RightArm.Origin.Z", 0x374},
    {"RightArm.Size.X", 0x38C}, {"RightArm.Size.Y", 0x398}, {"RightArm.Size.Z", 0x3A4},
    {"RightArm.UV.X", 0x3BC}, {"RightArm.UV.Y", 0x3C8},
    {"LeftArm.Pivot.X", 0x3F8}, {"LeftArm.Pivot.Y", 0x404}, {"LeftArm.Pivot.Z", 0x410},
    {"LeftArm.Origin.X", 0x440}, {"LeftArm.Origin.Y", 0x44C}, {"LeftArm.Origin.Z", 0x458},
    {"LeftArm.Size.X", 0x470}, {"LeftArm.Size.Y", 0x47C}, {"LeftArm.Size.Z", 0x488},
    {"LeftArm.UV.X", 0x4A0}, {"LeftArm.UV.Y", 0x4AC},
    {"RightLeg.Pivot.X", 0x4E8}, {"RightLeg.Pivot.Y", 0x4F4}, {"RightLeg.Pivot.Z", 0x500},
    {"RightLeg.Origin.X", 0x530}, {"RightLeg.Origin.Y", 0x53C}, {"RightLeg.Origin.Z", 0x548},
    {"RightLeg.Size.X", 0x560}, {"RightLeg.Size.Y", 0x56C}, {"RightLeg.Size.Z", 0x578},
    {"RightLeg.UV.X", 0x590}, {"RightLeg.UV.Y", 0x59C},
    {"LeftLeg.Pivot.X", 0x5CC}, {"LeftLeg.Pivot.Y", 0x5D8}, {"LeftLeg.Pivot.Z", 0x5E4},
    {"LeftLeg.Origin.X", 0x614}, {"LeftLeg.Origin.Y", 0x620}, {"LeftLeg.Origin.Z", 0x62C},
    {"LeftLeg.Size.X", 0x644}, {"LeftLeg.Size.Y", 0x650}, {"LeftLeg.Size.Z", 0x65C},
    {"LeftLeg.UV.X", 0x674}, {"LeftLeg.UV.Y", 0x680},
};

int getOffset(const std::string &key) {
    auto it = modelOffsets.find(key);
    return (it != modelOffsets.end()) ? it->second : -1;
}

void selectAndModifyOffset() {
    std::stringstream ss;
    u64 processId = Process::GetTitleID();
    ss << "sdmc:/luma/titles/000" << std::hex << processId << "/romfs/resourcepacks/skins/skinpacks/skins.bjson";
    std::string filename = ss.str();  // Store formatted string
    std::vector<std::string> bodyParts = {"Body", "Head", "Hat", "RightArm", "LeftArm", "RightLeg", "LeftLeg"};
    std::vector<std::string> properties = {"Pivot", "Origin", "Size", "UV"};
    std::vector<std::string> coordinates = {"X", "Y", "Z"};

    Keyboard kb1("Select body part:");
    kb1.Populate(bodyParts);
    int bodyIndex = kb1.Open();
    if (bodyIndex < 0) return;

    Keyboard kb2("Select property:");
    kb2.Populate(properties);
    int propIndex = kb2.Open();
    if (propIndex < 0) return; 
    
    if (properties[propIndex] == "UV"){
        coordinates = {"X", "Y"};
    }

    Keyboard kb3("Select coordinate:");
    kb3.Populate(coordinates);
    int coordIndex = kb3.Open();
    if (coordIndex < 0) return; 

    std::string key = bodyParts[bodyIndex] + "." + properties[propIndex] + "." + coordinates[coordIndex];

    int offset = getOffset(key);
    if (offset != -1) {
        File file;
        u32 value;

        if (File::Open(file, filename, File::READ | File::WRITE) != 0) {
            OSD::Notify("Failed to open file!");
            return;
        }

        file.Seek(offset, File::SET);
        OSD::Notify("Selected: " + key + " | Offset: 0x" + Utils::Format("%X", offset));

        Keyboard kb4("Enter new value:");
        kb4.IsHexadecimal(false);
        if (kb4.Open(value) != -1) {
            file.Write(&value, sizeof(value));
            OSD::Notify("Updated " + key + " to " + std::to_string(value));
        }
        file.Close();
    } else {
        OSD::Notify("Invalid selection!");
    }
}

void backupWorld(){
    std::vector<u8> valToSearch {0x98, 0xEF, 0xCD, 0xAB};  // Pattern to search for
    u32 endAddress = 0x36480000;
    static u32 startAddress = 0x33000000;
    static u32 size = endAddress - startAddress; 
    static u16 i = 0;
    File file;
    while (true){
        u32 getBaseAddress = Utils::Search(startAddress, size, valToSearch);
        if (getBaseAddress != 0x00){
            OSD::Notify(Utils::Format("Found save address at: 0x%X", getBaseAddress));
            File::Create(Utils::Format("sdmc:/DCIM/slt%u.cdb", i));

            if (File::Open(file, Utils::Format("sdmc:/DCIM/slt%u.cdb", i), File::WRITE) != 0){
                OSD::Notify("Failed to open the CDB slot file!");
                return;
            } else{
                file.Dump(getBaseAddress, 0x140000);
                OSD::Notify("Dumped CDB chunk.");
            }
            file.Close();
            startAddress += 0x140000;
            size = endAddress - startAddress;
            i++;
        } else{
            break;
        }
    }
    i = 0;
    startAddress = 0x33000000;
    size = endAddress - startAddress;
    return;
}


}