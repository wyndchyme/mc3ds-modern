#include <CTRPluginFramework/Menu/PluginMenu.hpp>
#include "Helpers/QuickMenu.hpp"
#include <algorithm>

namespace CTRPluginFramework
{
    QuickMenuItem::QuickMenuItem(const std::string &name_, const ItemType itemType_) :
        name(name_), itemType(itemType_)
    {
    }

    QuickMenuEntry::QuickMenuEntry(const std::string& name, VoidMethod method) :
        QuickMenuItem(name, ItemType::Entry)
    {
        methodType = MethodType::VOID;
        voidMethod = method;
        methodArg = nullptr;
    }

    QuickMenuEntry::QuickMenuEntry(const std::string& name, ArgMethod method, void* arg) :
        QuickMenuItem(name, ItemType::Entry)
    {
        methodType = MethodType::ARG;
        argMethod = method;
        methodArg = arg;
    }

    QuickMenuEntry::~QuickMenuEntry()
    {
    }

    QuickMenuSubMenu::QuickMenuSubMenu(const std::string& name) :
        QuickMenuItem(name, ItemType::SubMenu)
    {
    }

    QuickMenuSubMenu::QuickMenuSubMenu(const std::string& name, const std::vector<QuickMenuItem*>& items_) :
        QuickMenuItem(name, ItemType::SubMenu)
    {
        for (QuickMenuItem *item : items_)
            items.push_back(item);
    }

    QuickMenuSubMenu::~QuickMenuSubMenu()
    {
        for (QuickMenuItem *item : items)
            delete item;

        items.clear();
    }

    void    QuickMenuSubMenu::operator+=(QuickMenuItem* item)
    {
        items.push_back(item);
    }

    void    QuickMenuSubMenu::operator-=(QuickMenuItem* item)
    {
        items.erase(std::remove(items.begin(), items.end(), item), items.end());
    }

    QuickMenu   QuickMenu::_instance(Key::Start);

    QuickMenu::QuickMenu(u32 hotkey) :
        _hotkey(hotkey, Seconds(0.5f)),
        _subMenuOpened(nullptr)
    {
    }

    QuickMenu::~QuickMenu()
    {
        for (QuickMenuItem *item : _root)
            delete item;
    }

    QuickMenu &QuickMenu::GetInstance(void)
    {
        return (_instance);
    }

    void    QuickMenu::operator+=(QuickMenuItem* item)
    {
        _root.push_back(item);
    }

    void    QuickMenu::operator-=(QuickMenuItem* item)
    {
        _root.erase(std::remove(_root.begin(), _root.end(), item), _root.end());
    }

    void    QuickMenu::operator()(void)
    {
        if (!_hotkey())
            return;

        Keyboard        keyboard;
        StringVector    options;

        // Create our list of options
        for (auto *item : _root)
            options.push_back(item->name);

        // Pass it to our keyboard 
        keyboard.Populate(options);
        options.clear();
        while (true)
        {
            int userChoice = keyboard.Open();

            // If user selected an item
            if (userChoice >= 0)
            {
                QuickMenuItem *selected = _subMenuOpened ? _subMenuOpened->items[userChoice] : _root[userChoice];

                // If the selected item is an entry, execute the function
                if (selected->itemType == QuickMenuItem::ItemType::Entry)
                {
                    QuickMenuEntry *entry = static_cast<QuickMenuEntry *>(selected);

                    if (entry->methodType == QuickMenuEntry::MethodType::VOID)
                        entry->voidMethod();
                    else
                        entry->argMethod(entry->methodArg);
                }
                // If it's a submenu, open it
                else
                {
                    QuickMenuSubMenu *entry = static_cast<QuickMenuSubMenu *>(selected);

                    if (_subMenuOpened != nullptr)
                        _submenus.push(_subMenuOpened);
                    _subMenuOpened = entry;

                    // Refresh our list of options
                    for (QuickMenuItem *item : _subMenuOpened->items)
                        options.push_back(item->name);
                    keyboard.Populate(options);
                    options.clear();
                }
            }
            // Else if user pressed B
            else
            {
                // If we're inside a submenu, close it
                if (_subMenuOpened != nullptr)
                {
                    // If we have a parent, open it
                    if (_submenus.size())
                    {
                        _subMenuOpened = _submenus.top();
                        _submenus.pop();
                    }
                    // Else open root
                    else
                        _subMenuOpened = nullptr;

                    // Refresh out list of options
                    for (auto *item : (_subMenuOpened ? _subMenuOpened->items : _root))
                        options.push_back(item->name);
                    keyboard.Populate(options);
                    options.clear();
                }
                // Else if we're on root, close quickmenu
                else
                    break;
            }           
        }
    }

    void    QuickMenu::ChangeHotkey(u32 newHotkey)
    {
        _hotkey = newHotkey;
    }
}
