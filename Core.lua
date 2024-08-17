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
    if err ~= nil then
        log(err)
        return
    end

    ---@type hapticslib @Not supposed to be used from outside of HapticsCore.
    HapticsCore["hapticslib"] = hapticslib

    ---@type string @ID used for Assault State network communication
    HapticsCore["network_id"] = "Haptics_Net"

    self:set_options()

    ---@type boolean @Set if HapticsCore:init() successfully finished initializing
    HapticsCore["initialized"] = true;
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

function HapticsCore:set_options()
    if haptics and haptics.Options then
        HapticsCore["haptics_enabled"] = haptics.Options:GetValue("Basic/enable_feedback")
        HapticsCore["strengths"] = {
            control = haptics.Options:GetValue("Intensity/control_strength"),
            anticipation = haptics.Options:GetValue("Intensity/anticipation_strength"),
            build = haptics.Options:GetValue("Intensity/build_strength"),
            sustain = haptics.Options:GetValue("Intensity/sustain_strength"),
            fade = haptics.Options:GetValue("Intensity/fade_strength"),
            no_return = haptics.Options:GetValue("Intensity/no_return_strength"),
            phalanx = haptics.Options:GetValue("Intensity/phalanx_strength")
        }
    else
        log("[Haptics - ERROR] Something went wrong... Couldn't load options")
    end
end

if not HapticsCore.initialized then
    local success, err = pcall(function()
        HapticsCore:new()
    end)
    if not success then
        log("[Haptics - ERROR] An error occured on the initialization of the mod: " .. tostring(err))
    end
end
