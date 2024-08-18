function HapticsCore:SearchGameModes()
    hc_gm_files_path = hc_gm_files_path or HapticsCore._gamemodes_path
    local gamemode_files = FileIO:GetFiles(hc_gm_files_path)

    if gamemode_files then
        for _, gamemode_file in pairs(gamemode_files) do
            local curr_gm_path = Path:Combine(hc_gm_files_path, gamemode_file)

            -- check suffix
            if curr_gm_path:sub(-#".lua") == ".lua" then
                HapticsCore:RegisterGameMode(curr_gm_path)
            end
        end
    end
end

function HapticsCore:RegisterGameMode(game_mode_path)
    -- load these sandboxed just to extract the configs and
    -- we don't want to pollute the global environment
    local sandbox_env = setmetatable({}, {
        __index = table.merge({}, {
            HH_GAME_MODE_LOADER = true
        })
    })
    local _, result = assert(pcall(setfenv(assert(blt.vm.loadfile(game_mode_path)), sandbox_env)))
    -- destroys the sandbox... we might not want to do this later for performance reasons
    setmetatable(sandbox_env, nil)

    log(result.desc)
end

function HapticsCore:EnableGameMode(game_mode_id)

end

function HapticsCore:DisableGameMode(game_mode_id)

end

log("Running SearchGameModes")
HapticsCore:SearchGameModes()

