#include "Helpers/HoldKey.hpp"

namespace CTRPluginFramework
{
    HoldKey::HoldKey(u32 keys, Time holdTime) :
        _goal(holdTime), _isHold(false), _keys(keys)
    {
    }

    bool    HoldKey::operator()(void)
    {
        bool isHold = Controller::IsKeysDown(_keys);

        // If currently hold
        if (isHold && _isHold && _timer.HasTimePassed(_goal))
        {
            _isHold = false;
            return (true);
        }
        
        

        if (isHold && !_isHold)
        {
            _isHold = true;
            _timer.Restart();
        }
        else if (_isHold && !isHold)
            _isHold = false;

        return (false);
    }

    void HoldKey::operator=(u32 newKeys)
    {
        _keys = newKeys;
        _isHold = false;
        _timer.Restart();
    }
}
