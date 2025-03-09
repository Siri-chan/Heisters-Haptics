---@class HapticsMode: class
HapticsMode = HapticsMode or class()

function HapticsMode:Init()
    self.loaded_modes = {}
    self.menu_initialized = false

    -- Initialize custom HapticsHooks handler
    blt.vm.dofile(ModPath .. "lua/HapticsHook.lua")
    -- Initialize the HapticsMode Data class
    blt.vm.dofile(ModPath .. "lua/HapticsModeData.lua")

    -- Create sliders once MenuUI is ready to render them
    Hooks:Add("MenuManagerPostInitialize", "Haptics_Menu_UI_Initialized", function(_)
        self.menu_initialized = true
        self:SearchModes()
    end)

    self.initialized = true
end

function HapticsMode:SearchModes()
    local mode_files = FileIO:GetFiles(HapticsCore.modes_path)

    for _, mode_file in pairs(mode_files) do
        -- check suffix to only find lua files
        if mode_file:sub(- #".lua") == ".lua" then
            self:RegisterMode(mode_file)
        end
    end

    if self.menu_initialized then
        for _, mode_data in pairs(self.loaded_modes) do
            mode_data:RenderMenu(HapticsUI.options_menu.modes_stash)
        end
    end
end

function HapticsMode:RegisterMode(haptics_mode_file_name)
    local mode_data = HapticsModeData:Create(Path:Combine(HapticsCore.modes_path, haptics_mode_file_name))

    if self.loaded_modes[mode_data.id] ~= nil then
        log("[Haptics - WARNING] Haptics mode with ID " .. mode_data.id .. " is already registered. Ignoring...")
        return
    end

    self.loaded_modes[mode_data.id] = mode_data
end

function HapticsMode:EnableMode(mode_id)
    if not self.loaded_modes[mode_id] then
        return
    end

    self.loaded_modes[mode_id].enabled = true
end

function HapticsMode:DisableMode(mode_id)
    if not self.loaded_modes[mode_id] then
        return
    end

    self.loaded_modes[mode_id].enabled = false
end

function HapticsMode:ToggleModeEnabled(mode_id)
    if not self.loaded_modes[mode_id] then
        return
    end

    self.loaded_modes[mode_id].enabled = not self.loaded_modes[mode_id].enabled
end

function HapticsMode:GetMenuValue(mode_id, menu_item_id)
    if self.loaded_modes[mode_id] and self.loaded_modes[mode_id].menus[menu_item_id] then
        return self.loaded_modes[mode_id].menus[menu_item_id].value
    end

    return 0
end

if not HapticsMode.initialized then
    HapticsMode:Init()
end
