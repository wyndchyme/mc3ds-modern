#ifndef STRINGS_HPP
#define STRINGS_HPP

#include <string>

namespace CTRPluginFramework
{
    std::string     Hex(u8 x);
    std::string     Hex(u16 x);
    std::string     Hex(u32 x);
    std::string     Hex(u64 x);
    std::string     Hex(float x);
    std::string     Hex(double x);    
}

#endif