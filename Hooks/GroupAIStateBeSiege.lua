--- This code is heavily based on, and adapted from Sora/Nepgearsy's Assault States <https://modworkshop.net/mod/19391>
-- I have absolutely no license to use the original code, and I'm more than willing to take this down if they don't like what I'm doing.
-- I've shot them a friend request on Steam (because I have no idea where else I can whisper them), but as of yet, have no response.
-- If there are any issues, feel free to contact me. Shoot me an email or something.

Hooks:Add("NetworkReceivedData", "NetworkAssaultStates", function(sender, id, data)
	local Net = _G.LuaNetworking
	local mod_key = _G.HAPTICS_network_id
    if id == mod_key then
        local function get_assault_state_options(option)
	 		if assaultstates and assaultstates.Options then
	 			return assaultstates.Options:GetValue(option)
	 		else
	 			log("[AssaultStates] Something went wrong.. Couldn't load data")
	 		end
	 	end

	 	local function get_control_lines()
			if managers.job:current_difficulty_stars() > 0 then
				local ids_risk = Idstring("risk")
				return {
					"ControlTask_textlist_" .. get_assault_state_options("Textlist/textlist_control_task"),
					"hud_assault_end_line",
					ids_risk,
					"hud_assault_end_line",
					"ControlTask_textlist_" .. get_assault_state_options("Textlist/textlist_control_task"),
					"hud_assault_end_line",
					ids_risk,
					"hud_assault_end_line"
				}
			else
				return {
					"ControlTask_textlist_" .. get_assault_state_options("Textlist/textlist_control_task"),
					"hud_assault_end_line",
					"ControlTask_textlist_" .. get_assault_state_options("Textlist/textlist_control_task"),
					"hud_assault_end_line",
					"ControlTask_textlist_" .. get_assault_state_options("Textlist/textlist_control_task"),
					"hud_assault_end_line",
					"ControlTask_textlist_" .. get_assault_state_options("Textlist/textlist_control_task"),
					"hud_assault_end_line"
				}
			end
	 	end

	 	local function get_anticipation_lines()
			if managers.job:current_difficulty_stars() > 0 then
				local ids_risk = Idstring("risk")
				return {
					"AnticipationTask_textlist_" .. get_assault_state_options("Textlist/textlist_anticipation_task"),
					"hud_assault_end_line",
					ids_risk,
					"hud_assault_end_line",
					"AnticipationTask_textlist_" .. get_assault_state_options("Textlist/textlist_anticipation_task"),
					"hud_assault_end_line",
					ids_risk,
					"hud_assault_end_line"
				}
			else
				return {
					"AnticipationTask_textlist_" .. get_assault_state_options("Textlist/textlist_anticipation_task"),
					"hud_assault_end_line",
					"AnticipationTask_textlist_" .. get_assault_state_options("Textlist/textlist_anticipation_task"),
					"hud_assault_end_line",
					"AnticipationTask_textlist_" .. get_assault_state_options("Textlist/textlist_anticipation_task"),
					"hud_assault_end_line"
				}
			end
	 	end

	 	local function get_build_lines()
	 		if managers.hud._hud_assault_corner._assault_mode == "normal" then
				if managers.job:current_difficulty_stars() > 0 then
					local ids_risk = Idstring("risk")
					return {
						"hud_assault_assault",
						"hud_assault_end_line",
						"BuildTask_textlist_" .. get_assault_state_options("Textlist/textlist_build_task"),
						"hud_assault_end_line",
						ids_risk,
						"hud_assault_end_line",
						"hud_assault_assault",
						"hud_assault_end_line",
						"BuildTask_textlist_" .. get_assault_state_options("Textlist/textlist_build_task"),
						"hud_assault_end_line",
						ids_risk,
						"hud_assault_end_line"
					}
				else
					return {
						"hud_assault_assault",
						"hud_assault_end_line",
						"BuildTask_textlist_" .. get_assault_state_options("Textlist/textlist_build_task"),
						"hud_assault_end_line",
						"hud_assault_assault",
						"hud_assault_end_line",
						"BuildTask_textlist_" .. get_assault_state_options("Textlist/textlist_build_task"),
						"hud_assault_end_line"
					}
				end
			end
	 	end

	 	local function get_sustain_lines()
	 		if managers.hud._hud_assault_corner._assault_mode == "normal" then
				if managers.job:current_difficulty_stars() > 0 then
					local ids_risk = Idstring("risk")
					return {
						"hud_assault_assault",
						"hud_assault_end_line",
						"SustainTask_textlist_" .. get_assault_state_options("Textlist/textlist_sustain_task"),
						"hud_assault_end_line",
						ids_risk,
						"hud_assault_end_line",
						"hud_assault_assault",
						"hud_assault_end_line",
						"SustainTask_textlist_" .. get_assault_state_options("Textlist/textlist_sustain_task"),
						"hud_assault_end_line",
						ids_risk,
						"hud_assault_end_line"
					}
				else
					return {
						"hud_assault_assault",
						"hud_assault_end_line",
						"SustainTask_textlist_" .. get_assault_state_options("Textlist/textlist_sustain_task"),
						"hud_assault_end_line",
						"hud_assault_assault",
						"hud_assault_end_line",
						"SustainTask_textlist_" .. get_assault_state_options("Textlist/textlist_sustain_task"),
						"hud_assault_end_line"
					}
				end
			end
	 	end

	 	local function get_fade_lines()
	 		if managers.hud._hud_assault_corner._assault_mode == "normal" then
				if managers.job:current_difficulty_stars() > 0 then
					local ids_risk = Idstring("risk")
					return {
						"hud_assault_assault",
						"hud_assault_end_line",
						"FadeTask_textlist_" .. get_assault_state_options("Textlist/textlist_fade_task"),
						"hud_assault_end_line",
						ids_risk,
						"hud_assault_end_line",
						"hud_assault_assault",
						"hud_assault_end_line",
						"FadeTask_textlist_" .. get_assault_state_options("Textlist/textlist_fade_task"),
						"hud_assault_end_line",
						ids_risk,
						"hud_assault_end_line"
					}
				else
					return {
						"hud_assault_assault",
						"hud_assault_end_line",
						"FadeTask_textlist_" .. get_assault_state_options("Textlist/textlist_fade_task"),
						"hud_assault_end_line",
						"hud_assault_assault",
						"hud_assault_end_line",
						"FadeTask_textlist_" .. get_assault_state_options("Textlist/textlist_fade_task"),
						"hud_assault_end_line"
					}
				end
			end
	 	end
        if data == "control" and get_assault_state_options("Enabled/enable_control_task") then
            if not managers.hud._hud_assault_corner._point_of_no_return then
                -- Do the vibrator thing here.
                -- managers.hud._hud_assault_corner:_start_assault(get_control_lines())
                -- managers.hud._hud_assault_corner:_set_hostage_offseted(true)
                -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_controltask"))
            end
        end

        if data == "anticipation" and get_assault_state_options("Enabled/enable_anticipation_task") then
            -- Do the vibrator thing here.
            -- managers.hud._hud_assault_corner:_set_text_list(get_anticipation_lines())
            -- managers.hud._hud_assault_corner:_set_hostage_offseted(true)
            -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_anticipationtask"))
        end

        if data == "build" and get_assault_state_options("Enabled/enable_build_task") then
            -- Do the vibrator thing here.
            -- managers.hud._hud_assault_corner:_set_text_list(get_build_lines())
            -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_buildtask"))
        end

        if data == "sustain" and get_assault_state_options("Enabled/enable_sustain_task") then
            -- Do the vibrator thing here.
            -- managers.hud._hud_assault_corner:_set_text_list(get_sustain_lines())
            -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_sustaintask"))
        end

        if data == "fade" and get_assault_state_options("Enabled/enable_fade_task") then
            -- Do the vibrator thing here.
            -- managers.hud._hud_assault_corner:_set_text_list(get_fade_lines())
            -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_fadetask"))
        end
    end
end)

Hooks:PostHook( GroupAIStateBesiege, "_upd_recon_tasks", "assaultstates_recon_function", function(self)
	local Net = _G.LuaNetworking
 	local data_sender = false
    local mod_key = _G.HAPTICS_network_id

 	if Net:IsHost() then
    	data_sender = true
	end

	local function get_assault_state_options(option)
 		if assaultstates and assaultstates.Options then
 			return assaultstates.Options:GetValue(option)
 		else
 			log("[AssaultStates] Something went wrong.. Couldn't load data")
 		end
 	end
 	

    if not managers.hud._hud_assault_corner._assault and get_assault_state_options("Enabled/enable_control_task") then
        if managers.hud._hud_assault_corner._assault_mode ~= "phalanx" and not self:get_hunt_mode() then
            -- Do the vibrator thing here.
            -- managers.hud._hud_assault_corner:_start_assault(get_control_lines())
            -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_controltask"))
            -- managers.hud._hud_assault_corner:_set_hostage_offseted(true)

            if data_sender then
                Net:SendToPeers( mod_key, "control" )
            end
        end
    end
end)

Hooks:PostHook( GroupAIStateBesiege, "_upd_assault_task", "assaultstates_function", function(self)
 	
 	local Net = _G.LuaNetworking
 	local data_sender = false
    local mod_key = _G.HAPTICS_network_id

 	if Net:IsHost() then
    	data_sender = true
	end

 	local function get_assault_state_options(option)
 		if assaultstates and assaultstates.Options then
 			return assaultstates.Options:GetValue(option)
 		else
 			log("[AssaultStates] Something went wrong.. Couldn't load data")
 		end
 	end

 	local task_data = self._task_data.assault

    if task_data.phase == "anticipation" and get_assault_state_options("Enabled/enable_anticipation_task") and not managers.groupai:state():get_hunt_mode() then
        if managers.hud._hud_assault_corner._assault_mode ~= "phalanx" then
            if not managers.hud._hud_assault_corner._assault then
                -- Do the vibrator thing here.
                -- managers.hud._hud_assault_corner:_start_assault(get_anticipation_lines())
                -- managers.hud._hud_assault_corner:_set_hostage_offseted(true)
            end
            
            -- Do the vibrator thing here.
            -- managers.hud._hud_assault_corner:_set_text_list(get_anticipation_lines())
            -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_anticipationtask"))
        
            if data_sender then
                Net:SendToPeers( mod_key, "anticipation" )
            end
        end
    end

    if task_data.phase == "build" and get_assault_state_options("Enabled/enable_build_task") and not managers.groupai:state():get_hunt_mode() then
        -- Do the vibrator thing here.
        -- managers.hud._hud_assault_corner:_set_text_list(get_build_lines())
        -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_buildtask"))

        if data_sender then
            Net:SendToPeers( mod_key, "build" )
        end
    end

    if task_data.phase == "sustain" and get_assault_state_options("Enabled/enable_sustain_task") and not managers.groupai:state():get_hunt_mode() then
        -- Do the vibrator thing here.
        -- managers.hud._hud_assault_corner:_set_text_list(get_sustain_lines())
        -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_sustaintask"))

        if data_sender then
            Net:SendToPeers( mod_key, "sustain" )
        end
    end

    if task_data.phase == "fade" and get_assault_state_options("Enabled/enable_fade_task") and not managers.groupai:state():get_hunt_mode() then
        -- Do the vibrator thing here.
        -- managers.hud._hud_assault_corner:_set_text_list(get_fade_lines())
        -- managers.hud._hud_assault_corner:_update_assault_hud_color(get_assault_state_options("Color/color_fadetask"))

        if data_sender then
            Net:SendToPeers( mod_key, "fade" )
        end
    end
end )