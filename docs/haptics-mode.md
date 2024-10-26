# haptics-mode Developer Guide
> [!IMPORTANT]  
 This is a guide for developers. If you are looking to install a `haptics-mode` mode, you just need to place the packaged `.lua` file in `steamapps/common/PAYDAY2/mods/HeistersHaptics/modes` and start the game.
## Introduction
Hi, welcome. We're glad you're enthusiastic about writing your own mode for Heister's Haptics.
If you've written Lua mods for Payday 2, the process is *very* similar, and you shouldn't feel out of your depth here.
Heister's Haptics sort-of sandboxes each mode, but it exposes a very-similar overall API to BLT and SuperBLT.
Heister's Haptics will be used interchangeably with the abbreviation HH from here on out.
## Quick Start
Getting started is pretty easy.
First, open up the`HeistersHaptics/modes` folder within your mod path.
Here is where you'll write your mode.
Create a new file in here, with the `.lua` extension.
In here, we will first write out the configuration for our mod, so that HH can see it.

```lua
config = {
	-- This ID must be unique.
    id = "my-mode",
    name = "Example Mode",
    desc = "Vibrate when a Heist ends.",
    hooks = {
        pre = {
            ["lib/states/missionendstate"] = {{
                id = "enable",
                func = "on"
            }}
        },
        post = {
            ["lib/states/menumainstate"] = {{
                id = "disable",
                func = "off"
            }}
        },
    },
    menus = {{
        type = "slider",
        id = "strength",
        text = "Strength",
        default = 50,
        min = 0,
        max = 100
    }}
}
```

This table is pulled out of the sandbox by HH, and provides information about what functions are hooked, and how to display the mode and its settings in the menu.

Next, we have to actually write the hooks that we are promising.
In this mode, we are hooking files with the functions `on` and `off`, so we need to write those.

```lua
function on()
	-- We use this function as a helper to avoid writing the mode id over and over.
    local function getMenuItemByID(id)
        log("Value: ", _G.HapticsMode:GetMenuValue("my-mode", id))
        return _G.HapticsMode:GetMenuValue("my-mode", id)
    end

    Hooks:Add("MissionEndState", "at_enter", function(old_state, params)
	        HapticsCore:Vibrate(getMenuItemByID("strength"))
	end)
end
function off() 
	Hooks:PostHook(MenuMainState, "at_enter", "unique-hook-id", function(old_state)
	        HapticsCore:StopAll()
	end)
end
```

In these functions, we simply do the bare minimum of enabling then disabling vibration.
In a more complex mode, there would likely be branching logic and more settings.
Now, you're done!
To test this mode, you can enable it through the main menu, and when you finish a heist, you should feel a half-strength vibration until you leave.

Under this section, there's proper API docs, that should cover everything unique to HH.
*Also, the `Hooks:` functions are just SuperBLT's, so there's no need to relearn anything.*

## The `config` table
The config table is a table read at launch-time by Heister's Haptics.
It describes a mode, and it must be present, or HH will fail to initialise, and no modes will work.
<!-- TODO: We intend to fix this, by making sure `config ~= nil` later. -->
It is comprised of 3 string values; `id`, `name` and `desc` - and 2 child tables, `hooks` and `menus`.
### `id`
`id` is a unique identifier string for your mode. It is never seen by the player, but it is used internally to identify everything about your mod including the hooks (which are in the format `HH_HM_Hook_{mode_id}_{hook_id}` when passed back to SuperBLT), menu items, whose values are only accessible by your mode `id`, and your mode's saved settings in `settings.json`.
### `name`
`name` is the human-readable name for your mode. It is shown in the in-game settings, and is how the player will generally tell your mode apart from others.

### `desc`
`desc` is the on-hover description of the mod, for the settings page. It is not used elsewhere.

### `hooks`
The `hooks` table is the meat of HH, and it defines (up to) two child tables, `pre` and `post`, for Pre- and Post-Hooks, respectively. Both of these children expect the same schema - a table keyed by an array (usually with one element) of string filenames,  with tables containing a mode-unique hook `id`, and the name of the function you're hooking into the specified source file with, as a string.
```lua
[source_file] = {{
	id = "whatever", func = "function_name"
}}
```

### `menus`
The `menus` table describes the settings menu items for a given mode, using an array of tables.
Currently, the only valid `type` is `"slider"`, but we intend to make more available in future, and each will get it's own dedicated section.

#### Common Elements
Every menu table has a few key values that are expected, regardless of the table's `type`.
- `type` is a string that defines which type of input the table describes.
- `id` is a mode-unique ID string that is used to retrieve the set value of a menu item and to store an item's value in settings.
- `text` is a string that will be used as the option's label in the in-game settings menu.
<!-- TODO: Add a don't save bool key? -->
#### Sliders
The slider table is the first menu table we designed, and by far the most useful, as it is the easiest way for a user to manipulate vibration strengths.
It takes in 3 unique number values:
- `min` and `max` are the lowest and highest values that the slider can represent, respectively.
- `default` is the value that the slider has when a user first launches Payday 2 after installing your mode. Be cautious not to set these values too high, as users haptics motors may be stronger or weaker than yours.
<!-- TODO: Add a "I should be set to default if set-to-default button is pressed" flag that defaults to true. -->
```lua
{
	type = "slider",
	id = "strength",
	text = "Strength",
	default = 50,
	min = 0,
	max = 100
}
```

## The `hapticslib` API
One thing that you will likely want to do, when you write a mod for HH, is to make a haptics motor vibrate (I know, pretty important, right?). We do this through an asynchronous native plugin for SuperBLT called `hapticslib`. `hapticslib` does all of the dirty work required to not block the game thread, while persisting a connection to an Intiface Server.
However, Heister's Haptics has a convenient API that exposes `hapticslib`'s functionality on the `HapticsCore` object.

It provides the following functions:
```lua
---Connects the Heister's Haptics client to the Intiface Websocket.
---Takes one parameter which is the websocket address.
---This includes an IP and a port.
---@param self HapticsCore
---@param websocket_address string @Example `127.0.0.1:12345`
---@return string @Success or failure message
HapticsCore:ConnectHaptics(websocket_address)

---Kills the Haptics Thread if it is running.
---@return string @Success or failure message
HapticsCore:Kill()

---Pings the Heister's Haptics thread to see if it, and it's connection to Intiface, are still alive.
---@return string @Success or failure message
HapticsCore:Ping()

---Sets the vibration strength of all connected devices to 0.
---Therefore stopping them all.
---@return string @Success or failure message
HapticsCore:StopAll()

---Sets the vibration strength of all connected devices to the strength specified in the parameter.
---Strength is set in percent.
---@return string @Success or failure message
---@param strength integer @Value expected to be between 0 and 100
HapticsCore:Vibrate(strength)
```

There are also a couple of unused (and currently useless) functions, that may be more useful in the future:
```lua
---Starts scanning for haptic devices in Intiface.
---@return string @Success or failure message
HapticsCore:ScanStart()

---Stops scanning for haptic devices in Intiface.
---@return string @Success or failure message
HapticsCore:ScanStop()

---Returns an array (table) of device names currently known by HapticsCore.
---Keys are numbered starting with 1 as is standard in lua.
---@return table @Array of device names
HapticsCore:ListDevices()
```
