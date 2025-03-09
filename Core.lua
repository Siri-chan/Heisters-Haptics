if not ModCore then
    log("[Haptics - ERROR] Unable to find ModCore from BeardLib! Is BeardLib installed correctly?")
    return
end

---@class HapticsCore: ModCore
HapticsCore = HapticsCore or class(ModCore)

function HapticsCore:init()
    ---@type string /mods/HeistersHaptics
    HapticsCore.ModPath = ModPath
    ---@type string modes
    HapticsCore.modes_directory = "modes"
    ---@type string /mods/HeistersHaptics/lua/modes
    HapticsCore.modes_path = Path:Combine(HapticsCore.ModPath, HapticsCore.modes_directory)

    ---@class hapticslib The native plugin module that actually controls the haptic devices
    ---@field public connectHaptics fun(websocket_address: string): string @Connects thread to websocket
    ---@field public kill fun(): string @Kills the Haptics thread
    ---@field public ping fun(): string @Checks if the thread is still alive
    ---@field public scanStart fun(): string @Starts scanning Intiface for devices
    ---@field public scanStop fun(): string @Stops scanning Intiface for devices
    ---@field public listDevices fun(): table @Returns a list of connected devices
    ---@field public stopAll fun(): string @Stops vibration on all connected devices
    ---@field public vibrate fun(strength: integer): string @Sets the vibration strength for all connected devices

    ---@type string, hapticslib
    local err, hapticslib = blt.load_native(Path:Combine(HapticsCore.ModPath, "hapticslib.dll"))
    if not hapticslib then
        log("[Haptics - ERROR] hapticslib failed to load with " .. err .. ".")
        return
    end

    ---@type hapticslib @Not supposed to be used from outside of HapticsCore.
    HapticsCore.hapticslib = hapticslib

    ---@type string @ID used for Assault State network communication
    HapticsCore.network_id = "Haptics_Net"

    -- Calling the base function for init from ModCore after setting some variables
    -- self_tbl, config path, auto load modules, auto post init modules
    self.super.init(self, ModPath .. "config.xml", true)

    -- Load Haptics Utility function class
    blt.vm.dofile(ModPath .. "lua/HapticsUtility.lua")
    -- Initialize Settings module for HeistersHaptics and modes
    blt.vm.dofile(ModPath .. "lua/HapticsSettings.lua")
    -- Initialized HeistersHaptics mod options menu and modes settings
    blt.vm.dofile(ModPath .. "lua/HapticsUI.lua")
    -- After initializing Hooks and Modes UI we can start doing more stuff like loading Haptics Modes
    blt.vm.dofile(ModPath .. "lua/HapticsMode.lua")

    -- BeardLib:AddUpdater("Haptics:Test", function (t, dt)
    --     log("Beardlib Updater")
    --     log("Time: " .. t)
    --     log("DeltaTime: " .. dt)
    -- end)

    ---@type boolean @Set if HapticsCore:init() successfully finished initializing
    HapticsCore.initialized = true
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

---Kills the Haptics Thread if it is running.
---@return string @Success or failure message
function HapticsCore:Kill()
    return HapticsCore.hapticslib.kill()
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

if not HapticsCore.initialized then
    local success, err = pcall(function()
        HapticsCore:new()
    end)
    if not success then
        log("[Haptics - ERROR] An error occured on the initialization of the mod: " .. tostring(err))
    end
end
