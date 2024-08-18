if HH_GAME_MODE_LOADER then
    local config = {
        id = "default",
        name = "Default",
        desc = "Vibration based on Assault States. The default mode.",
        hook = "",
        menus = {
            anticipation = {
                type = "slider",
                id = "AnticipationInput",
                text = "Vibration Strength - Anticipation State",
                default_value = 0,
                min = 0,
                max = 100
            },
            build = {
                type = "slider",
                id = "BuildInput",
                text = "Vibration Strength - Build State",
                default_value = 0,
                min = 0,
                max = 100
            }
        }
    }

    return config
end

Hooks:PostHook(GroupAIStateBesiege, "_upd_recon_tasks", "assaultstates_recon_function", function(self)
    -- Stuffs in here
end)
