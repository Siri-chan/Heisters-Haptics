if not ModCore then
    log("[Haptics - ERROR] Unable to find ModCore from BeardLib! Is BeardLib installed correctly?")
    return
end

---@class HapticsCore
HapticsCore = HapticsCore or class(ModCore)

function HapticsCore:init()
    -- Calling the base function for init from ModCore
    -- self_tbl, config path, auto load modules, auto post init modules
    self.super.init(self, ModPath .. "config.xml", true, true)
    HapticsCore["_mod_path"] = ModPath

    ---@class hapticslib
    ---@field public connectHaptics fun(websocket_address: string): string @Connects thread to websocket
    ---@field public ping fun(): string @Checks if the thread is still alive
    ---@field public scanStart fun(): string @Starts scanning Intiface for devices
    ---@field public scanStop fun(): string @Stops scanning Intiface for devices
    ---@field public setStrength fun(strength: integer): string @Sets the vibration strength for all connected devices
    ---@field public stopAll fun(): string @Stops vibration on all connected devices

    ---@type string
    ---@type hapticslib
    local err, hapticslib = blt.load_native(ModPath .. "hapticslib.dll")
    if not hapticslib then
        log("[Haptics - ERROR] hapticslib failed to load with " .. err .. ".")
        return
    end
    HapticsCore:LoadSettings()

    ---@type hapticslib @Not supposed to be used from outside of HapticsCore.
    HapticsCore["hapticslib"] = hapticslib

    ---@type string @ID used for Assault State network communication
    HapticsCore["network_id"] = "Haptics_Net"

    -- self:set_options()

    HapticsCore["_menu"] = MenuUI:new({
        name = "HeistersHapticsSettings",
        enabled = false,
        create_items = function()
            HapticsCore.CreateMenuItems()
        end,
        use_default_close_key = true,
        layer = 500000
    })

    ---@type boolean @Set if HapticsCore:init() successfully finished initializing
    HapticsCore["initialized"] = true;
end

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
    return self.hapticslib.connectHaptics(websocket_address)
end

---Pings the Heister's Haptics thread to see if it, and it's connection to Intiface, are still alive.
---@return string @Success or failure message
function HapticsCore:Ping()
    return self.hapticslib.ping()
end

---Starts scanning for haptic devices in Intiface.
---@return string @Success or failure message
function HapticsCore:ScanStart()
    return self.hapticslib.scanStart()
end

---Stops scanning for haptic devices in Intiface.
---@return string @Success or failure message
function HapticsCore:ScanStop()
    return self.hapticslib.scanStop()
end

---Sets the vibration strength of all connected devices to the strength specified in the parameter.
---Strength is set in percent.
---@return string @Success or failure message
---@param strength integer @Value expected to be between 0 and 100
function HapticsCore:SetStrength(strength)
    return self.hapticslib.setStrength(strength)
end

---Sets the vibration strength of all connected devices to 0.
---Therefore stopping them all.
---@return string @Success or failure message
function HapticsCore:StopAll()
    return self.hapticslib.stopAll()
end

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

if not HapticsCore.initialized then
    local success, err = pcall(function()
        HapticsCore:new()
    end)
    if not success then
        log("[Haptics - ERROR] An error occured on the initialization of the mod: " .. tostring(err))
    end
end

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_HeistersHaptics", function(menu_manager, nodes)
    MenuCallbackHandler.OpenHeistersHapticsModOptions = function(self, item)
        log(HapticsCore["_menu"])
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