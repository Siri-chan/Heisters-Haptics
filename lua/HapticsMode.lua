HapticsMode = HapticsMode or class()

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

    -- lightly sandbox the loading of these to not pollute global
    local sandbox_env = setmetatable({}, {
        __index = _G
    })
    local mode_file = blt.vm.loadfile(current_mode_path)
    setfenv(mode_file, sandbox_env)

    mode_file()

    for hook_key, hook_table in pairs(sandbox_env.config.hooks.post) do
        for inner_key, inner_value in pairs(hook_table) do
            local current_hook_id = "HH_HM_Hook_" .. sandbox_env.config.id .. "_" .. inner_value.id
            HapticsHook:AddPostHook(hook_key, current_hook_id, HapticsCore:CloneFunction(sandbox_env[inner_value.func]))
        end
    end

    -- destroy meta table for next mode
    setmetatable(sandbox_env, nil)
end

function HapticsMode:EnableGameMode(game_mode_id)

end

function HapticsMode:DisableGameMode(game_mode_id)

end

if not HapticsMode then
    HapticsMode:SearchGameModes()
end
