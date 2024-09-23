if not ModCore then
    log("[Haptics - ERROR] Unable to find ModCore from BeardLib! Is BeardLib installed correctly?")
    return
end

---@class HapticsCore
HapticsCore = HapticsCore or class(ModCore)

function HapticsCore:init()
    ---@type string @/mods/Heisters Haptics
    HapticsCore["_mod_path"] = ModPath
    ---@type string @modes
    HapticsCore["_hapticsmode_folder"] = "modes"
    ---@type string @/mods/Heisters Haptics/lua/gamemodes
    HapticsCore["_hapticsmode_path"] = Path:Combine(HapticsCore._mod_path, HapticsCore._hapticsmode_folder)

    ---@class hapticslib @The native plugin module that actually controls the haptic devices
    ---@field public connectHaptics fun(websocket_address: string): string @Connects thread to websocket
    ---@field public ping fun(): string @Checks if the thread is still alive
    ---@field public scanStart fun(): string @Starts scanning Intiface for devices
    ---@field public scanStop fun(): string @Stops scanning Intiface for devices
    ---@field public listDevices fun(): table @Returns a list of connected devices
    ---@field public stopAll fun(): string @Stops vibration on all connected devices
    ---@field public vibrate fun(strength: integer): string @Sets the vibration strength for all connected devices

    ---@type string
    ---@type hapticslib
    local err, hapticslib = blt.load_native(Path:Combine(HapticsCore._mod_path, "hapticslib.dll"))
    if not hapticslib then
        log("[Haptics - ERROR] hapticslib failed to load with " .. err .. ".")
        return
    end
    HapticsCore:LoadSettings()

    ---@type hapticslib @Not supposed to be used from outside of HapticsCore.
    HapticsCore["hapticslib"] = hapticslib

    ---@type string @ID used for Assault State network communication
    HapticsCore["network_id"] = "Haptics_Net"

    -- Calling the base function for init from ModCore after setting some variables
    -- self_tbl, config path, auto load modules, auto post init modules
    self.super.init(self, ModPath .. "config.xml", true, true)

    -- self:set_options()

    HapticsCore["_menu"] = MenuUI:new({
        name = "HeistersHapticsSettings",
        enabled = false,
        create_items = function()
            HapticsCore:CreateMenuItems()
        end,
        use_default_close_key = true,
        layer = 500
    })

    ---@type boolean @Set if HapticsCore:init() successfully finished initializing
    HapticsCore["initialized"] = true;

    -- Initialize custom Haptics Hooks
    blt.vm.dofile(ModPath .. "lua/HapticsHook.lua")

    -- Initialize the UI creation component for modes
    blt.vm.dofile(ModPath .. "lua/HapticsModeUI.lua")
    -- After initializing Hooks and Modes UI we can start doing more stuff like loading Haptics Modes
    blt.vm.dofile(ModPath .. "lua/HapticsMode.lua")
end

function HapticsCore:GetPath()
    return HapticsCore._mod_path
end

--- Creates the Options Menu for Heister's Haptics with beardlib's MenuUI
function HapticsCore:CreateMenuItems()
    -- Needs to be done here becase it's not initialized before this callback is called
    HapticsCore["scaled_render_size"] = HapticsCore.scaled_render_size or managers.gui_data:full_scaled_size()

    HapticsCore["_main"] = HapticsCore._menu:Holder({
        name = "Background",
        background_color = Color.black,
        background_alpha = 0.5,
        h = HapticsCore.scaled_render_size.h,
        w = HapticsCore.scaled_render_size.w
    })

    HapticsCore._sidebar = HapticsCore._main:Holder({
        name = "Sidebar",
        background_color = Color.black,
        background_alpha = 0.5,
        h = HapticsCore.scaled_render_size.h,
        w = HapticsCore.scaled_render_size.w / 3,
        min_width = 400,
        position = "Right",
        layer = 1
    })

    HapticsCore._sidebar:Toggle({
        name = "Haptics_Options_EnableFeedback",
        text = "Haptics_Options_EnableFeedback_Title",
        help = "Haptics_Options_EnableFeedback_Desc",
        localized = true,
        value = HapticsCore["haptics_enabled"],
        on_callback = function(item)
            HapticsCore["haptics_enabled"] = item:Value()
        end
    })

    HapticsCore._sidebar:TextBox({
        name = "Websocket",
        text = "Haptics_Options_Websocket_Title",
        help = "Haptics_Options_Websocket_Desc",
        localized = true,
        value = HapticsCore["websocket"],
        on_callback = function(item)
            HapticsCore["websocket"] = item:Value()
        end
    })

    HapticsCore._sidebar:Button({
        name = "SearchModes",
        text = "Search Modes",
        localized = false,
        size_by_text = true,
        on_callback = function(item)
            HapticsMode:SearchGameModes()
            HapticsModeUI:Parse("default", HapticsMode._modes.default.menus)
        end
    })

    HapticsCore["mode_stash"] = HapticsCore._sidebar:Holder({
        name = "mode_stash",
        background_alpha = 0,
        min_height = HapticsCore.scaled_render_size.h / 5
    })

    HapticsCore._sidebar:Button({
        name = "SaveAndClose",
        text = "Haptics_Options_SaveExit",
        localized = true,
        size_by_text = true,
        on_callback = function(item)
            HapticsCore:SaveSettings()
            HapticsCore["_menu"]:Disable()
        end,
        position = "BottomRight",
        layer = 2
    })
    HapticsCore._sidebar:Button({
        name = "Close",
        text = "Haptics_Options_Exit",
        localized = true,
        size_by_text = true,
        on_callback = function(item)
            HapticsCore["_menu"]:Disable()
        end,
        position = "BottomLeft",
        layer = 2
    })

end

---Connects the Heister's Haptics client to the Intiface Websocket.
---Takes one parameter which is the websocket address.
---This includes an IP and a port.
---@param self HapticsCore
---@param websocket_address string @Example `127.0.0.1:12345`
---@return string @Success or failure message
function HapticsCore:ConnectHaptics(websocket_address)
    return HapticsCore.hapticslib.connectHaptics(websocket_address)
end

---Pings the Heister's Haptics thread to see if it, and it's connection to Intiface, are still alive.
---@return string @Success or failure message
function HapticsCore:Ping()
    return HapticsCore.hapticslib.ping()
end

---Starts scanning for haptic devices in Intiface.
---@return string @Success or failure message
function HapticsCore:ScanStart()
    return HapticsCore.hapticslib.scanStart()
end

---Stops scanning for haptic devices in Intiface.
---@return string @Success or failure message
function HapticsCore:ScanStop()
    return HapticsCore.hapticslib.scanStop()
end

---Returns an array (table) of device names currently known by HapticsCore.
---Keys are numbered starting with 1 as is standard in lua.
---@return table @Array of device names
function HapticsCore:ListDevices()
    return HapticsCore.hapticslib.listDevices()
end

---Sets the vibration strength of all connected devices to 0.
---Therefore stopping them all.
---@return string @Success or failure message
function HapticsCore:StopAll()
    return HapticsCore.hapticslib.stopAll()
end

---Sets the vibration strength of all connected devices to the strength specified in the parameter.
---Strength is set in percent.
---@return string @Success or failure message
---@param strength integer @Value expected to be between 0 and 100
function HapticsCore:Vibrate(strength)
    return HapticsCore.hapticslib.vibrate(strength)
end

--- Saves the settings set in the menu to a "settings.json" file
function HapticsCore:SaveSettings()
    log("saving")
    local settings = {
        enabled = HapticsCore["haptics_enabled"],
        websocket_uri = HapticsCore["websocket"],
        strengths = {
            control = HapticsCore["strengths"].control,
            anticipation = HapticsCore["strengths"].anticipation,
            build = HapticsCore["strengths"].build,
            sustain = HapticsCore["strengths"].sustain,
            fade = HapticsCore["strengths"].fade,
            no_return = HapticsCore["strengths"].no_return,
            phalanx = HapticsCore["strengths"].phalanx
        }
    }
    FileIO:WriteScriptData(HapticsCore["_mod_path"] .. "settings.json", settings, "json", false)

end

--- Load saved settings from the "settings.json" file
function HapticsCore:LoadSettings()
    if not FileIO:Exists(HapticsCore["_mod_path"] .. "settings.json") then
        HapticsCore:DefaultSettings()
        return false
    end
    local settings = FileIO:ReadScriptData(ModPath .. "settings.json", "json", false)
    HapticsCore["haptics_enabled"] = settings.enabled
    HapticsCore["websocket"] = settings.websocket_uri
    HapticsCore["strengths"] = {}
    HapticsCore["strengths"].control = settings.strengths.control
    HapticsCore["strengths"].anticipation = settings.strengths.anticipation
    HapticsCore["strengths"].build = settings.strengths.build
    HapticsCore["strengths"].sustain = settings.strengths.sustain
    HapticsCore["strengths"].fade = settings.strengths.fade
    HapticsCore["strengths"].no_return = settings.strengths.no_return
    HapticsCore["strengths"].phalanx = settings.strengths.phalanx
end

--- Sets reasonable and necessary defaults
function HapticsCore:DefaultSettings()
    HapticsCore["haptics_enabled"] = false
    HapticsCore["websocket"] = "localhost:12345"
    HapticsCore["strengths"] = {}
    -- TODO: Set actual defaults??
    HapticsCore["strengths"].control = 0
    HapticsCore["strengths"].anticipation = 0
    HapticsCore["strengths"].build = 0
    HapticsCore["strengths"].sustain = 0
    HapticsCore["strengths"].fade = 0
    HapticsCore["strengths"].no_return = 0
    HapticsCore["strengths"].phalanx = 0
end

---Clones an entire function with upvalues (thanks luajit)
---@param func function @The function to clone
---@return function @Returns the cloned function
function HapticsCore:CloneFunction(func)
    local func_string = string.dump(func)
    local cloned_func = loadstring(func_string)
    local i = 1

    while true do
        local name = debug.getupvalue(func, i)
        if not name then
            break
        end
        debug.upvaluejoin(cloned_func, i, func, i)
        i = i + 1
    end

    return cloned_func
end

if not HapticsCore.initialized then
    local success, err = pcall(function()
        HapticsCore:new()
    end)
    if not success then
        log("[Haptics - ERROR] An error occured on the initialization of the mod: " .. tostring(err))
    end
end

-- Adds our MenuUI menu to the "Mod Options" entry in the settings menu option
Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_HeistersHaptics", function(menu_manager, nodes)
    -- Only need an open callback because closing is handled inside the menu
    MenuCallbackHandler.OpenHeistersHapticsModOptions = function(self, item)
        if HapticsCore["_menu"] then
            HapticsCore["_menu"]:Enable()
        end
    end

    local item = nodes["blt_options"]:create_item({
        type = "CoreMenuItem.Item"
    }, {
        name = "Haptics_OpenMenu",
        text_id = "Haptics_Options_Title",
        help_id = "Haptics_Options_Desc",
        callback = "OpenHeistersHapticsModOptions",
        localize = true
    })

    nodes["blt_options"]:add_item(item)
end)
