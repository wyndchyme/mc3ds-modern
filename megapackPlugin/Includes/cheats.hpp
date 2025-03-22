#ifndef CHEATS_H
#define CHEATS_H

#include <CTRPluginFramework.hpp>
#include "Helpers.hpp"
#include "Unicode.h"

namespace CTRPluginFramework
{
    using StringVector = std::vector<std::string>;
    void dropEverything(MenuEntry *entry);
    void ninetyFov(MenuEntry *entry);
    void defaultCodes(MenuEntry *entry);
    void removeMobCap(MenuEntry *entry);
    void itemExpLimit(MenuEntry *entry);
    void enhancedParticles(MenuEntry *entry);
    void betterMinecartPhysics(MenuEntry *entry);
    void stopMobSpawns(MenuEntry *entry);
    void removeHeads(MenuEntry *entry);
    void everythingSpinny(MenuEntry *entry);
    bool displayPlayerCoordsTopScreen(const Screen& screen);
    void ModifySignedIntFromFile(const std::string& filename, std::streampos offset);
    void moveBodyPart(MenuEntry *entry);
    void backupWorld();
    void selectAndModifyOffset();
    int getOffset(const std::string &key);
}
#endif
