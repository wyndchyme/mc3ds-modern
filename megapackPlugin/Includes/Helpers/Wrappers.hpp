#ifndef WRAPPERS_HPP
#define WRAPPERS_HPP

#include "CTRPluginFramework.hpp"

namespace CTRPluginFramework
{
    using StringVector = std::vector<std::string>;
    
    bool    GetInput(u8 &input, const std::string &msg = "", bool useHex = false);
    bool    GetInput(u16 &input, const std::string &msg = "", bool useHex = false);
    bool    GetInput(u32 &input, const std::string &msg = "", bool useHex = false);
    bool    GetInput(float &input, const std::string &msg = "");
    bool    GetInput(u16 &input, const StringVector &choices, const std::string &msg = "");
}

#endif