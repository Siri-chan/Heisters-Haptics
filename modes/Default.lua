config = {
    id = "default",
    name = "Default",
    desc = "Vibration based on Assault States. The default mode.",
    hooks = {
        pre = {
            ["lib/states/missionendstate"] = {{
                id = "disable_menu",
                func = "le_menu"
            }}
        },
        post = {
            ["lib/managers/group_ai_states/groupaistatebesiege"] = {{
                id = "default_groupaistatebesiege",
                func = "groupaistatebesiege"
            } --[[,{
                    id = "dwadawdw"
                    src_obj = "GroupAIStateBesiege",
                    func = "some_other_global_from_here"
                }]] }
        }
    },
    menus = {{
        type = "slider",
        id = "ControlInput",
        text = "Control State",
        default = 0,
        min = 0,
        max = 100
    }, {
        type = "slider",
        id = "AnticipationInput",
        text = "Anticipation State",
        default = 15,
        min = 0,
        max = 100
    }, {
        type = "slider",
        id = "BuildInput",
        text = "Build State",
        default = 25,
        min = 0,
        max = 100
    }, {
        type = "slider",
        id = "SustainInput",
        text = "Sustain State",
        default = 50,
        min = 0,
        max = 100
    }, {
        type = "slider",
        id = "FadeInput",
        text = "Fade State",
        default = 30,
        min = 0,
        max = 100
    }, {
        type = "slider",
        id = "NoReturnInput",
        text = "Point of No Return State",
        default = 100,
        min = 0,
        max = 100
    }, {
        type = "slider",
        id = "PhalanxInput",
        text = "Captain Winters State",
        default = 75,
        min = 0,
        max = 100
    }}
}

function le_menu()
    Hooks:Add("MissionEndState", "at_enter", function(old_state, params)
        HapticsCore:StopAll()
    end)
end

function groupaistatebesiege()
    -- Safety Net.
    HapticsCore:StopAll()

    local function getMenuItemByID(id)
        log("Value: ", _G.HapticsMode:GetMenuValue("default", id))
        return _G.HapticsMode:GetMenuValue("default", id)
    end

    local function vibrate(strength)
        log("Called Vibrate with strength: ", strength)
        HapticsCore:Vibrate(strength)
    end

    Hooks:Add("NetworkReceivedData", "NetworkHaptics", function(sender, id, data)
        local Net = _G.LuaNetworking
        local mod_key = HapticsCore["network_id"]
        if id == mod_key and HapticsCore["haptics_enabled"] then
            if data == "control" then
                log(getMenuItemByID("ControlInput"))
                if managers.hud._hud_assault_corner._point_of_no_return then
                    vibrate(getMenuItemByID("NoReturnInput"))
                else
                    vibrate(getMenuItemByID("ControlInput"))
                end
            end

            if data == "anticipation" then
                vibrate(getMenuItemByID("AnticipationInput"))
            end

            if data == "build" then
                vibrate(getMenuItemByID("BuildInput"))
            end

            if data == "sustain" then
                vibrate(getMenuItemByID("SustainInput"))
            end

            if data == "fade" then
                vibrate(getMenuItemByID("FadeInput"))
            end
            if data == "phalanx" then
                vibrate(getMenuItemByID("PhalanxInput"))
            end
        end
    end)

    Hooks:PostHook(GroupAIStateBesiege, "_upd_recon_tasks", "haptics_recon_function", function(self)
        local Net = _G.LuaNetworking
        local data_sender = false
        local mod_key = HapticsCore["network_id"]

        if Net:IsHost() then
            data_sender = true
        end

        if not managers.hud._hud_assault_corner._assault then
            if managers.hud._hud_assault_corner._assault_mode == "phalanx" or self:get_hunt_mode() then
                vibrate(getMenuItemByID("PhalanxInput"))

                if data_sender then
                    Net:SendToPeers(mod_key, "phalanx")
                end
            else
                if managers.hud._hud_assault_corner._point_of_no_return then
                    vibrate(getMenuItemByID("NoReturnInput"))
                else
                    vibrate(getMenuItemByID("ControlInput"))

                    if data_sender then
                        Net:SendToPeers(mod_key, "control")
                    end
                end
            end
        end
    end)

    Hooks:PostHook(GroupAIStateBesiege, "_upd_assault_task", "haptics_assault_function", function(self)
        local Net = _G.LuaNetworking
        local data_sender = false
        local mod_key = HapticsCore["network_id"]

        if Net:IsHost() then
            data_sender = true
        end

        local task_data = self._task_data.assault

        if task_data.phase == "anticipation" then
            if managers.hud._hud_assault_corner._assault_mode ~= "phalanx" and
                not managers.groupai:state():get_hunt_mode() then
                vibrate(getMenuItemByID("AnticipationInput"))

                if data_sender then
                    Net:SendToPeers(mod_key, "anticipation")
                end
            else
                vibrate(getMenuItemByID("PhalanxInput"))
                if data_sender then
                    Net:SendToPeers(mod_key, "phalanx")
                end
            end
        end

        if task_data.phase == "build" and not managers.groupai:state():get_hunt_mode() then
            vibrate(getMenuItemByID("BuildInput"))

            if data_sender then
                Net:SendToPeers(mod_key, "build")
            end
        end

        if task_data.phase == "sustain" and not managers.groupai:state():get_hunt_mode() then
            vibrate(getMenuItemByID("SustainInput"))

            if data_sender then
                Net:SendToPeers(mod_key, "sustain")
            end
        end

        if task_data.phase == "fade" and not managers.groupai:state():get_hunt_mode() then
            vibrate(getMenuItemByID("FadeInput"))

            if data_sender then
                Net:SendToPeers(mod_key, "fade")
            end
        end
    end)
end
