#include "Helpers/AutoRegion.hpp"


namespace CTRPluginFramework
{
    // Global to keep the current region
    Region   g_region = USA;

    AutoRegion::AutoRegion(u32 usa, u32 eur) :
    Usa(usa), Eur(eur)
    {
        
    }

    u32    AutoRegion::operator()(void) const
    {
        if (g_region == EUR)
            return (Eur);
        return (Usa);
    }
}
