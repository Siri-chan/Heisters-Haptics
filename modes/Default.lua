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

function love_message()
    -- Safety Net.
    HapticsCore:StopAll()

    function getMenuItemByID(id)
        log("le epic debug")
        for key, value in _G.pairs(_G.HapticsMode["_modes"].default.menus) do
            log(value.id .. value.id)
            
            
            if value.id == id then return value.default end
        end
        --[[
        local menus = HapticsMode["_modes"].default.menus
        for key, value in pairs(menus) do
            if value.id == id then return value end
        end
        ]]
    end

    Hooks:Add("NetworkReceivedData", "NetworkHaptics", function(sender, id, data)
        log("i got here network")
        local Net = _G.LuaNetworking
        local mod_key = HapticsCore["network_id"]
        if id == mod_key and HapticsCore["haptics_enabled"] then
            local function vibrate(strength)
                log("bzzz")
                HapticsCore:Vibrate(strength)
            end
    
            if data == "control" then
                if managers.hud._hud_assault_corner._point_of_no_return then
                    -- Do the vibrator thing here.
                    vibrate(getMenuItemByID("NoReturnInput"))
                else
                    vibrate(getMenuItemByID("ControlInput"))
                    -- Do the vibrator thing here.
                    -- managers.hud._hud_assault_corner:_start_assault(get_control_lines())
                    -- managers.hud._hud_assault_corner:_set_hostage_offseted(true)
                    -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_controltask"))
                end
            end
    
            if data == "anticipation" then
                vibrate(getMenuItemByID("AnticipationInput"))
                -- Do the vibrator thing here.
                -- managers.hud._hud_assault_corner:_set_text_list(get_anticipation_lines())
                -- managers.hud._hud_assault_corner:_set_hostage_offseted(true)
                -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_anticipationtask"))
            end
    
            if data == "build" then
                vibrate(getMenuItemByID("BuildInput"))
                -- Do the vibrator thing here.
                -- managers.hud._hud_assault_corner:_set_text_list(get_build_lines())
                -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_buildtask"))
            end
    
            if data == "sustain" then
                vibrate(getMenuItemByID("SustainInput"))
                -- Do the vibrator thing here.
                -- managers.hud._hud_assault_corner:_set_text_list(get_sustain_lines())
                -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_sustaintask"))
            end
    
            if data == "fade" then
                vibrate(getMenuItemByID("FadeInput"))
                -- Do the vibrator thing here.
                -- managers.hud._hud_assault_corner:_set_text_list(get_fade_lines())
                -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_fadetask"))
            end
            if data == "phalanx" then
                vibrate(getMenuItemByID("PhalanxInput"))
                -- Do the vibrator thing here.
                -- managers.hud._hud_assault_corner:_set_text_list(get_fade_lines())
                -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_fadetask"))
            end
        end
    end)

    Hooks:PostHook(GroupAIStateBesiege, "_upd_recon_tasks", "haptics_recon_function", function(self)
        log("i got here recon")
        local Net = _G.LuaNetworking
        local data_sender = false
        local mod_key = HapticsCore["network_id"]
    
        if Net:IsHost() then
            data_sender = true
        end
    
        local function vibrate(strength)
            log("bzzz")
            HapticsCore:Vibrate(strength)
        end
    
        if not managers.hud._hud_assault_corner._assault then
            if managers.hud._hud_assault_corner._assault_mode == "phalanx" or self:get_hunt_mode() then
                -- Do the vibrator thing here.
                vibrate(getMenuItemByID("PhalanxInput"))
                -- managers.hud._hud_assault_corner:_start_assault(get_control_lines())
                -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_controltask"))
                -- managers.hud._hud_assault_corner:_set_hostage_offseted(true)
    
                if data_sender then
                    Net:SendToPeers(mod_key, "phalanx")
                end
            else
                if managers.hud._hud_assault_corner._point_of_no_return then
                    -- Do the vibrator thing here.
                    vibrate(getMenuItemByID("NoReturnInput"))
                else
                    -- Do the vibrator thing here.
                    vibrate(getMenuItemByID("ControlInput"))
                    -- managers.hud._hud_assault_corner:_start_assault(get_control_lines())
                    -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_controltask"))
                    -- managers.hud._hud_assault_corner:_set_hostage_offseted(true)
    
                    if data_sender then
                        Net:SendToPeers(mod_key, "control")
                    end
                end
            end
        end
    end)

    Hooks:PostHook(GroupAIStateBesiege, "_upd_assault_task", "haptics_assault_function", function(self)
        log("i got here assault")
        local Net = _G.LuaNetworking
        local data_sender = false
        local mod_key = HapticsCore["network_id"]
    
        if Net:IsHost() then
            data_sender = true
        end
    
        local function vibrate(strength)
            log("bzzz")
            HapticsCore:Vibrate(strength)
        end
    
        local task_data = self._task_data.assault
    
        if task_data.phase == "anticipation" then
            if managers.hud._hud_assault_corner._assault_mode ~= "phalanx" and not managers.groupai:state():get_hunt_mode() then
                vibrate(getMenuItemByID("AnticipationInput"))
                -- Do the vibrator thing here.
                -- managers.hud._hud_assault_corner:_set_text_list(get_anticipation_lines())
                -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_anticipationtask"))
    
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
            -- Do the vibrator thing here.
            vibrate(getMenuItemByID("BuildInput"))
            -- managers.hud._hud_assault_corner:_set_text_list(get_build_lines())
            -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_buildtask"))
    
            if data_sender then
                Net:SendToPeers(mod_key, "build")
            end
        end
    
        if task_data.phase == "sustain" and not managers.groupai:state():get_hunt_mode() then
            -- Do the vibrator thing here.
            vibrate(getMenuItemByID("SustainInput"))
            -- managers.hud._hud_assault_corner:_set_text_list(get_sustain_lines())
            -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_sustaintask"))
    
            if data_sender then
                Net:SendToPeers(mod_key, "sustain")
            end
        end
    
        if task_data.phase == "fade" and not managers.groupai:state():get_hunt_mode() then
            -- Do the vibrator thing here.
            vibrate(getMenuItemByID("FadeInput"))
            -- managers.hud._hud_assault_corner:_set_text_list(get_fade_lines())
            -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_fadetask"))
    
            if data_sender then
                Net:SendToPeers(mod_key, "fade")
            end
        end
    end)    
end

-- Hooks:PostHook(GroupAIStateBesiege, "_upd_recon_tasks", "assaultstates_recon_function", function(self)
--    log("Running Hook from Default Mode")
-- end)

