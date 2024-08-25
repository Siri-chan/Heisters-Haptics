config = {
    id = "default",
    name = "Default",
    desc = "Vibration based on Assault States. The default mode.",
    hooks = {
        post = {
            ["lib/managers/group_ai_states/groupaistatebesiege"] = {{
                id = "i_love_my_wife",
                func = "love_message"
            } --[[,{
                    id = "dwadawdw"
                    src_obj = "GroupAIStateBesiege",
                    func = "some_other_global_from_here"
                }]] }
        }
    },
    menus = {{
        type = "slider",
        id = "AnticipationInput",
        text = "Anticipation State",
        default = 0,
        min = 0,
        max = 100
    }, {
        type = "slider",
        id = "BuildInput",
        text = "Build State",
        default = 0,
        min = 0,
        max = 100
    }}
}

function love_message()
    Hooks:PostHook(GroupAIStateBesiege, "_upd_recon_tasks", "assaultstates_recon_function", function(self)
        log("I love my wife")
    end)
end

-- Hooks:PostHook(GroupAIStateBesiege, "_upd_recon_tasks", "assaultstates_recon_function", function(self)
--    log("Running Hook from Default Mode")
-- end)

