--- This code is heavily based on, and adapted from Sora/Nepgearsy/Azureé's Assault States <https://modworkshop.net/mod/19391>
-- I have absolutely no license to use the original code, and I'm more than willing to take this down if they don't like what I'm doing.
-- I've shot them a friend request on Steam (because I have no idea where else I can whisper them), but as of yet, have no response.
-- If there are any issues, feel free to contact me. Shoot me an email or something.
Hooks:Add("NetworkReceivedData", "NetworkAssaultStates", function(sender, id, data)
    local Net = _G.LuaNetworking
    local mod_key = HapticsCore["network_id"]
    if id == mod_key and HapticsCore["haptics_enabled"] then
        local err = HapticsCore["buttplug"].get_and_handle_message()
        if err ~= nil then
            log("[Haptics - ERROR] Something went wrong... Couldn't connect to buttplug server")
            return
        end

        local function vibrate(strength)
            if HapticsCore["buttplug"].count_devices() > 0 then
                HapticsCore["buttplug"].send_vibrate_cmd(0, {strength})
            end
        end

        if data == "control" then
            if managers.hud._hud_assault_corner._point_of_no_return then
                -- Do the vibrator thing here.
                vibrate(HapticsCore["strengths"]["no_return"])
            else
                vibrate(HapticsCore["strengths"]["control"])
                -- Do the vibrator thing here.
                -- managers.hud._hud_assault_corner:_start_assault(get_control_lines())
                -- managers.hud._hud_assault_corner:_set_hostage_offseted(true)
                -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_controltask"))
            end
        end

        if data == "anticipation" then
            vibrate(HapticsCore["strengths"]["anticipation"])
            -- Do the vibrator thing here.
            -- managers.hud._hud_assault_corner:_set_text_list(get_anticipation_lines())
            -- managers.hud._hud_assault_corner:_set_hostage_offseted(true)
            -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_anticipationtask"))
        end

        if data == "build" then
            vibrate(HapticsCore["strengths"]["build"])
            -- Do the vibrator thing here.
            -- managers.hud._hud_assault_corner:_set_text_list(get_build_lines())
            -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_buildtask"))
        end

        if data == "sustain" then
            vibrate(HapticsCore["strengths"]["sustain"])
            -- Do the vibrator thing here.
            -- managers.hud._hud_assault_corner:_set_text_list(get_sustain_lines())
            -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_sustaintask"))
        end

        if data == "fade" then
            vibrate(HapticsCore["strengths"]["fade"])
            -- Do the vibrator thing here.
            -- managers.hud._hud_assault_corner:_set_text_list(get_fade_lines())
            -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_fadetask"))
        end
        if data == "phalanx" then
            vibrate(HapticsCore["strengths"]["phalanx"])
            -- Do the vibrator thing here.
            -- managers.hud._hud_assault_corner:_set_text_list(get_fade_lines())
            -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_fadetask"))
        end
    end
end)

Hooks:PostHook(GroupAIStateBesiege, "_upd_recon_tasks", "assaultstates_recon_function", function(self)
    local Net = _G.LuaNetworking
    local data_sender = false
    local mod_key = HapticsCore["network_id"]

    if Net:IsHost() then
        data_sender = true
    end

    local err = HapticsCore["buttplug"].get_and_handle_message()
    if err ~= nil then
        log("[Haptics - ERROR] Something went wrong... Couldn't connect to buttplug server")
        return
    end

    local function vibrate(strength)
        if HapticsCore["buttplug"].count_devices() > 0 and HapticsCore["haptics_enabled"] then
            HapticsCore["buttplug"].send_vibrate_cmd(0, {strength})
        end
    end

    if not managers.hud._hud_assault_corner._assault then
        if managers.hud._hud_assault_corner._assault_mode == "phalanx" or self:get_hunt_mode() then
            -- Do the vibrator thing here.
            vibrate(HapticsCore["strengths"]["phalanx"])
            -- managers.hud._hud_assault_corner:_start_assault(get_control_lines())
            -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_controltask"))
            -- managers.hud._hud_assault_corner:_set_hostage_offseted(true)

            if data_sender then
                Net:SendToPeers(mod_key, "phalanx")
            end
        else
            if managers.hud._hud_assault_corner._point_of_no_return then
                -- Do the vibrator thing here.
                vibrate(HapticsCore["strengths"]["no_return"])
            else
                -- Do the vibrator thing here.
                vibrate(HapticsCore["strengths"]["control"])
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

Hooks:PostHook(GroupAIStateBesiege, "_upd_assault_task", "assaultstates_function", function(self)

    local Net = _G.LuaNetworking
    local data_sender = false
    local mod_key = HapticsCore["network_id"]

    if Net:IsHost() then
        data_sender = true
    end

    local err = HapticsCore["buttplug"].get_and_handle_message()
    if err ~= nil then
        log("[Haptics - ERROR] Something went wrong... Couldn't connect to buttplug server")
        return
    end

    local function vibrate(strength)
        if HapticsCore["buttplug"].count_devices() > 0 and HapticsCore["haptics_enabled"] then
            HapticsCore["buttplug"].send_vibrate_cmd(0, {strength})
        end
    end

    local task_data = self._task_data.assault

    if task_data.phase == "anticipation" then
        if managers.hud._hud_assault_corner._assault_mode ~= "phalanx" and not managers.groupai:state():get_hunt_mode() then
            vibrate(HapticsCore["strengths"]["anticipation"])
            -- Do the vibrator thing here.
            -- managers.hud._hud_assault_corner:_set_text_list(get_anticipation_lines())
            -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_anticipationtask"))

            if data_sender then
                Net:SendToPeers(mod_key, "anticipation")
            end
        else
            vibrate(HapticsCore["strengths"]["phalanx"])
            if data_sender then
                Net:SendToPeers(mod_key, "phalanx")
            end
        end
    end

    if task_data.phase == "build" and not managers.groupai:state():get_hunt_mode() then
        -- Do the vibrator thing here.
        vibrate(HapticsCore["strengths"]["build"])
        -- managers.hud._hud_assault_corner:_set_text_list(get_build_lines())
        -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_buildtask"))

        if data_sender then
            Net:SendToPeers(mod_key, "build")
        end
    end

    if task_data.phase == "sustain" and not managers.groupai:state():get_hunt_mode() then
        -- Do the vibrator thing here.
        vibrate(HapticsCore["strengths"]["sustain"])
        -- managers.hud._hud_assault_corner:_set_text_list(get_sustain_lines())
        -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_sustaintask"))

        if data_sender then
            Net:SendToPeers(mod_key, "sustain")
        end
    end

    if task_data.phase == "fade" and not managers.groupai:state():get_hunt_mode() then
        -- Do the vibrator thing here.
        vibrate(HapticsCore["strengths"]["fade"])
        -- managers.hud._hud_assault_corner:_set_text_list(get_fade_lines())
        -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_fadetask"))

        if data_sender then
            Net:SendToPeers(mod_key, "fade")
        end
    end
end)
