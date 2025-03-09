---@class HapticsSettings: class
---@field private _settings Settings
---@field private ParseLegacySettings fun(self: HapticsSettings, loaded_settings: {enabled: boolean, websocket_uri: string, modes: table}): Settings
HapticsSettings = HapticsSettings or class()

function HapticsSettings:Init()
    ---@type string Path of `settings.json` file
    self.settings_path = Path:Combine(ModPath, "settings.json")

    ---@class Settings
    ---@field haptics_enabled boolean State of the enabled toggle in the settings menu. Defaults to `false`
    ---@field intiface_uri string URI of the intiface websocket (with port). Defaults to `localhost:12345`
    ---@field modes_settings table Contains values of modes that have been changed from their defaults. Otherwise empty
    self._settings = {
        haptics_enabled = false,
        intiface_uri = "localhost:12345",
        modes_settings = {}
    }

    self.Load(self)

    self.initialized = true
end

---Saves haptics and mode settings to `settings.json` file
function HapticsSettings:Save()
    for mode_id, mode_data in pairs(HapticsMode.loaded_modes) do
        if not self._settings.modes_settings[mode_id] then
            self._settings.modes_settings[mode_id] = {}
        end

        if not self._settings.modes_settings[mode_id].enabled then
            self._settings.modes_settings[mode_id].enabled = mode_data.enabled
        end

        for menu_id, menu_id_data in pairs(mode_data.menus) do
            if menu_id_data.value ~= nil and menu_id_data.value ~= menu_id_data.default then
                self._settings.modes_settings[mode_id][menu_id] = menu_id_data.value
            end
        end
    end

    FileIO:WriteScriptData(self.settings_path, self._settings, "json", false)
end

---Loads saved settings form the `settings.json` file
function HapticsSettings:Load()
    if not FileIO:Exists(self.settings_path) then
        return
    end

    local loaded_settings = FileIO:ReadScriptData(self.settings_path, "json", false)

    if loaded_settings.enable ~= nil or loaded_settings.websocket_uri ~= nil or loaded_settings.modes ~= nil then
        self._settings = self.ParseLegacySettings(self, loaded_settings)
    else
        self._settings = loaded_settings
    end
end

function HapticsSettings:ParseLegacySettings(loaded_settings)
    return {
        haptics_enabled = loaded_settings.enabled,
        intiface_uri = loaded_settings.websocket_uri,
        modes_settings = loaded_settings.modes
    }
end

function HapticsSettings:GetLoadedModeData(mode_id)
    if self._settings.modes_settings[mode_id] ~= nil then
        return self._settings.modes_settings[mode_id]
    end

    return nil
end

if not HapticsSettings.initialized then
    HapticsSettings:Init()
end
