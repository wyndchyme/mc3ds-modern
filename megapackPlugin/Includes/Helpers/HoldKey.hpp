#ifndef HOLDKEY_HPP
#define HOLDKEY_HPP

#include "CTRPluginFramework.hpp"

namespace CTRPluginFramework
{
    class   HoldKey
    {
    public:
        /**
         * \brief A helping class to check if a key(s) is pressed for a period of time
         * \param keys A key or a combo that have to be pressed
         * \param holdTime The time the key(s) need to be pressed
         */
        HoldKey(u32 keys, Time holdTime);
        ~HoldKey(void) {};

        /**
         * \brief Check if the key is pressed
         * \return If the key(s) were holded the required amount of time
         */
        bool    operator()(void);
        /**
         * \brief Change the keys that needs to be pressed
         * \param newKeys The new keys value
         */
        void    operator = (u32 newKeys);
    private:
        Clock   _timer;
        Time    _goal;
        bool    _isHold;
        u32     _keys;
    };
};

#endif