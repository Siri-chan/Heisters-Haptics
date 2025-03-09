HapticsModeData = {}
HapticsModeData.__index = HapticsModeData

function HapticsModeData:Create(mode_file_path)
    local mode_data = {}
    setmetatable(mode_data, HapticsModeData)

    -- Load file into sandbox to not pollute global namespace
    local sandbox_env = setmetatable({}, {
        __index = _G
    })
    local mode_file = blt.vm.loadfile(mode_file_path)
    setfenv(mode_file, sandbox_env)

    -- Declare the config and defined functions in the global space of the sanbox
    mode_file()

    -- Check if there's any mode data that was loaded from the settings file and overwrite
    local loaded_mode_data = HapticsSettings:GetLoadedModeData(sandbox_env.config.id)

    -- Read mode data out of the sandbox
    mode_data.id = HapticsUtility:DeepCopy(sandbox_env.config.id)
    mode_data.name = HapticsUtility:DeepCopy(sandbox_env.config.name)
    mode_data.enabled = loaded_mode_data and loaded_mode_data.enabled or false
    mode_data.hooks = {
        pre  = {},
        post = {}
    }
    mode_data.menus = {}
    mode_data.menu_label = "menus_" .. mode_data.id
    mode_data.menu_group = nil

    -- Extract Pre-Hook functions
    for hook_src_file, hooks_table in pairs(sandbox_env.config.hooks.pre) do
        if mode_data.hooks.pre[hook_src_file] == nil then
            mode_data.hooks.pre[hook_src_file] = {}
        end

        for _, hook_data in pairs(hooks_table) do
            if mode_data.hooks.pre[hook_src_file][hook_data.id] == nil then
                mode_data.hooks.pre[hook_src_file][hook_data.id] = HapticsUtility:CloneFunction(sandbox_env
                    [hook_data.func])
            end
        end
    end

    -- Extract Post-Hook functions
    for hook_src_file, hooks_table in pairs(sandbox_env.config.hooks.post) do
        if mode_data.hooks.post[hook_src_file] == nil then
            mode_data.hooks.post[hook_src_file] = {}
        end

        for _, hook_data in pairs(hooks_table) do
            if mode_data.hooks.post[hook_src_file][hook_data.id] == nil then
                mode_data.hooks.post[hook_src_file][hook_data.id] = HapticsUtility:CloneFunction(sandbox_env
                    [hook_data.func])
            end
        end
    end

    -- Extract Menus
    for _, menu_item in pairs(sandbox_env.config.menus) do
        if mode_data.menus[menu_item.id] == nil then
            mode_data.menus[menu_item.id] = HapticsUtility:DeepCopy(menu_item)
            mode_data.menus[menu_item.id].value = loaded_mode_data and loaded_mode_data[menu_item.id]
        end
    end

    -- Destroy Sandbox
    setmetatable(sandbox_env, nil)

    return mode_data
end

-- TODO: Proper parametrization
function HapticsModeData:CreateFromConfig(mode_file_path)
    local mode_data = {}
    setmetatable(mode_data, HapticsModeData)

    -- Do proper initialization from file

    return mode_data
end

function HapticsModeData:GetHooksForFile(source_file)
    return self.hooks[source_file] or {}
end

function HapticsModeData:GetPreHooksForFile(source_file)
    if self.hooks.pre[source_file] ~= nil and next(self.hooks.pre[source_file]) ~= nil then
        return self.hooks.pre[source_file]
    else
        return {}
    end
end

function HapticsModeData:GetPostHooksForFile(source_file)
    if self.hooks.post[source_file] ~= nil and next(self.hooks.post[source_file]) ~= nil then
        return self.hooks.post[source_file]
    else
        return {}
    end
end

function HapticsModeData:RunPreHooksForFile(source_file)
    if not self.enabled then
        return
    end

    if next(self.hooks.pre[source_file]) ~= nil then
        for _, hook_func in pairs(self.hooks.pre[source_file]) do
            hook_func()
        end
    end
end

function HapticsModeData:RunPostHooksForFile(source_file)
    if not self.enabled then
        return
    end

    if next(self.hooks.post[source_file]) ~= nil then
        for _, hook_func in pairs(self.hooks.post[source_file]) do
            hook_func()
        end
    end
end

function HapticsModeData:RenderMenu(menu_root)
    if self.menu_group ~= nil then
        log("[Haptics - INFO] Re-rendering menu options for mode id " .. self.id)

        menu_root:ClearItems(self.menu_label)
        self.menu_group = nil
    end

    self.menu_group = menu_root:Group({
        name = self.id,
        text = self.name,
        label = self.menu_label,
        accent_color = Color.green
    })

    self.menu_group:Toggle({
        name = "toggle_" .. self.id,
        text = "Enabled",
        label = self.menu_label,
        value = self.enabled,
        on_callback = function(_)
            self.enabled = not self.enabled
            -- TODO: visual indication
        end
    })

    for menu_item_id, menu_item in pairs(self.menus) do
        -- Sliders are the default option for inputs
        if menu_item.type == nil or menu_item.type == "" or menu_item.type == "slider" then
            self.menu_group:Slider({
                -- MAYBE: Might want to add mode id in front of the menu item id?
                name = menu_item_id,
                text = menu_item.text,
                label = self.menu_label,
                -- Value will be set by changing the slider, default is default
                value = self.menus[menu_item_id].value or menu_item.default,
                min = (menu_item.min and HapticsUtility:Clamp(menu_item.min, 0, 100)) or 0,
                max = (menu_item.max and HapticsUtility:Clamp(menu_item.max, 0, 100)) or 100,
                -- TODO: Decimals are planned but are disabled for now
                step = 1,
                floats = 0,
                on_callback = function(item)
                    self.menus[menu_item_id].value = math.floor(item:Value() + 0.5)
                end
            })
        end
    end
end
