#include "Helpers/Wrappers.hpp"

namespace CTRPluginFramework
{
    bool    GetInput(u8 &input, const std::string &msg, bool useHex)
    {
        Keyboard    keyboard(msg);

        if (msg.empty())
            keyboard.DisplayTopScreen = false;
        keyboard.IsHexadecimal(useHex);

        if (keyboard.Open(input, input) != -1)
            return (true);

        return (false);
    }

    bool    GetInput(u16 &input, const std::string &msg, bool useHex)
    {
        Keyboard    keyboard(msg);

        if (msg.empty())
            keyboard.DisplayTopScreen = false;
        keyboard.IsHexadecimal(useHex);

        if (keyboard.Open(input, input) != -1)
            return (true);

        return (false);
    }

    bool    GetInput(u32 &input, const std::string &msg, bool useHex)
    {
        Keyboard    keyboard(msg);

        if (msg.empty())
            keyboard.DisplayTopScreen = false;
        keyboard.IsHexadecimal(useHex);

        if (keyboard.Open(input, input) != -1)
            return (true);

        return (false);
    }

    bool    GetInput(float &input, const std::string &msg)
    {
        Keyboard    keyboard(msg);

        if (msg.empty())
            keyboard.DisplayTopScreen = false;

        if (keyboard.Open(input, input) != -1)
            return (true);

        return (false);
    }

    bool    GetInput(u16 &input, const StringVector &choices, const std::string &msg)
    {
        Keyboard    keyboard(msg);

        if (msg.empty())
            keyboard.DisplayTopScreen = false;

        keyboard.Populate(const_cast<StringVector &>(choices));

        int selected = keyboard.Open();

        if (selected != -1)
        {
            input = selected;
            return (true);
        }

        return (false);
    }

}