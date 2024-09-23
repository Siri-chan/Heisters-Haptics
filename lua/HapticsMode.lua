HapticsMode = HapticsMode or class()

function HapticsMode:Init()
    HapticsMode["_modes"] = {}

    HapticsMode["initialized"] = true

    -- HapticsMode:DisableGameMode("default")
end

function HapticsMode:SearchGameModes()
    local gamemode_files = FileIO:GetFiles(HapticsCore._hapticsmode_path)

    if gamemode_files then
        for _, gamemode_file in pairs(gamemode_files) do
            -- check suffix
            if gamemode_file:sub(-#".lua") == ".lua" then
                HapticsMode:RegisterGameMode(gamemode_file)
            end
        end
    end
end

function HapticsMode:RegisterGameMode(haptics_mode_file_name)
    local current_mode_path = Path:Combine(HapticsCore._hapticsmode_path, haptics_mode_file_name)

    -- Lightly sandbox the loading of these to not pollute global
    local sandbox_env = setmetatable({}, {
        __index = _G
    })
    local mode_file = blt.vm.loadfile(current_mode_path)
    setfenv(mode_file, sandbox_env)

    mode_file()

    local current_mode_id = sandbox_env.config.id

    -- Do not re-register this file if it's already registered
    if not HapticsMode._modes[current_mode_id] then
        HapticsMode._modes[current_mode_id] = {
            enabled = true,
            hooks = {},
            menus = {},
            name = sandbox_env.config.name
        }

        for hook_src_file, hook_table in pairs(sandbox_env.config.hooks.post) do
            -- Create table entry for the source file if it doesn't exist
            if not HapticsMode._modes[current_mode_id].hooks[hook_src_file] then
                HapticsMode._modes[current_mode_id].hooks[hook_src_file] = {}
            end

            for inner_key, inner_value in pairs(hook_table) do
                local current_hook_id = "HH_HM_Hook_" .. current_mode_id .. "_" .. inner_value.id

                -- Do not re-register hooks that we already know (by id anyway)
                if not HapticsMode._modes[current_mode_id][inner_value.id] then
                    HapticsHook:AddPostHook(hook_src_file, current_hook_id,
                        HapticsCore:CloneFunction(sandbox_env[inner_value.func]))

                    -- Save the hook for enable/disable
                    table.insert(HapticsMode._modes[current_mode_id].hooks[hook_src_file], current_hook_id)
                end
            end
        end

        for _, menu_item in pairs(sandbox_env.config.menus) do
            if not HapticsMode._modes[current_mode_id].menus[menu_item.id] then
                -- This will ensure using the id as a key and having it as part of the value
                HapticsMode._modes[current_mode_id].menus[menu_item.id] = menu_item
            end
        end
    end

    -- destroy meta table for next mode
    setmetatable(sandbox_env, nil)
end

function HapticsMode:EnableGameMode(game_mode_id)
    if not HapticsMode._modes[game_mode_id] or HapticsMode._modes[game_mode_id].enabled then
        return
    end

    for hook_src_file, hook_id_table in pairs(HapticsMode._modes[game_mode_id].hooks) do
        for _, hook_id in pairs(hook_id_table) do
            HapticsHook:EnableHook(hook_src_file, hook_id)
        end
    end
end

function HapticsMode:DisableGameMode(game_mode_id)
    if not HapticsMode._modes[game_mode_id] or not HapticsMode._modes[game_mode_id].enabled then
        return
    end

    for hook_src_file, hook_id_table in pairs(HapticsMode._modes[game_mode_id].hooks) do
        for _, hook_id in pairs(hook_id_table) do
            HapticsHook:DisableHook(hook_src_file, hook_id)
        end
    end
end

if not HapticsMode.initialized then
    HapticsMode:Init()
end
