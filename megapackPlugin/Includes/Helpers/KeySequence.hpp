#ifndef HELPERS_KEYSEQUENCE_HPP
#define HELPERS_KEYSEQUENCE_HPP

#include "types.h"
#include "CTRPluginFramework/System/Controller.hpp"
#include "CTRPluginFramework/System/Clock.hpp"

#include <vector>

namespace CTRPluginFramework
{
    using KeyVector = std::vector<Key>;

    class   KeySequence
    {
    public:

        KeySequence(KeyVector sequence);
        ~KeySequence(){}

        /**
         * \brief Check the sequence
         * \return true if the sequence is completed, false otherwise
         */
        bool  operator()(void);

    private:

        KeyVector   _sequence;
        Clock       _timer;
        int         _indexInSequence;
        
    };
}

#endif