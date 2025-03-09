#ifndef HELPERS_QUICKMENU_HPP
#define HELPERS_QUICKMENU_HPP
#include "types.h"
#include <string>
#include <vector>
#include <stack>
#include "HoldKey.hpp"

namespace CTRPluginFramework
{
    using VoidMethod = void(*)(void);
    using ArgMethod = void(*)(void *);
    using StringVector = std::vector<std::string>;
    struct QuickMenuItem
    {
        enum class ItemType
        {
            Entry, SubMenu
        };

        QuickMenuItem(const std::string &name, const ItemType itemType);

        std::string name;
        const ItemType    itemType;
    };

    struct QuickMenuEntry : QuickMenuItem
    {
        enum class MethodType
        {
            VOID, ARG
        };

        QuickMenuEntry(const std::string &name, VoidMethod method);
        QuickMenuEntry(const std::string &name, ArgMethod method, void *arg);
        ~QuickMenuEntry();

        MethodType      methodType;
        union
        {
            VoidMethod  voidMethod;
            ArgMethod   argMethod;
        };
        void            *methodArg;
    };

    struct QuickMenuSubMenu : QuickMenuItem
    {
        QuickMenuSubMenu(const std::string &name);
        QuickMenuSubMenu(const std::string &name, const std::vector<QuickMenuItem *> &items);
        ~QuickMenuSubMenu();
        void    operator += (QuickMenuItem *item);
        void    operator -= (QuickMenuItem *item);

        std::vector<QuickMenuItem *>    items;
    };

    class QuickMenu
    {
    public:        
        ~QuickMenu();        
        static QuickMenu &GetInstance(void);

        void     ChangeHotkey(u32 newHotkey);

        void    operator += (QuickMenuItem *item);
        void    operator -= (QuickMenuItem *item);
        void    operator () (void);

    private:
        QuickMenu(u32 hotkey);

        HoldKey                         _hotkey;
        QuickMenuSubMenu                *_subMenuOpened;
        std::vector<QuickMenuItem *>    _root;
        std::stack<QuickMenuSubMenu *>  _submenus;

        static QuickMenu                _instance;
    };
}

#endif