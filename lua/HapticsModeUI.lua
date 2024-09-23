HapticsModeUI = HapticsModeUI or class()

function HapticsModeUI:Init()
    HapticsModeUI["_mode_menus"] = {}

    HapticsModeUI["initialized"] = true
end

local function HapticsClamp(num)
    if num < 0 then
        return 0
    end
    if num > 100 then
        return 100
    end
    return num
end

---@param mode_id string @Id of the HapticsMode
---@param mode_menus_table table @Table of menu items to create
function HapticsModeUI:Parse(mode_id, mode_menus_table)
    if HapticsModeUI._mode_menus[mode_id] then
        return
    end

    HapticsModeUI._mode_menus[mode_id] = HapticsCore.mode_stash:Group({
        name = mode_id,
        text = HapticsMode._modes[mode_id].name
    })

    for _, mode_ui_item in pairs(mode_menus_table) do
        HapticsModeUI:CreateSlider(mode_id, mode_ui_item)
        -- Add to UI table somewhere so i can destroy it again if disabled
    end
end

---@param mode_id string @Id of the HapticsMode
---@param mode_ui_item table @Table of information about the slider to create
function HapticsModeUI:CreateSlider(mode_id, mode_ui_item)
    local slider_initial_value = 0
    -- Check if the value was loaded from a save file and assign that
    if HapticsCore.strengths[mode_id] and HapticsCore.strengths[mode_id][mode_ui_item.id] then
        slider_initial_value = HapticsCore.strengths[mode_id][mode_ui_item.id]
    -- If not then check for default
    elseif mode_ui_item["default"] then
        slider_initial_value = HapticsClamp(mode_ui_item.default)
    end

    -- Re-assign this to the menu so saving reads it out even without user changes
    HapticsMode._modes[mode_id].menus[mode_ui_item.id].value = slider_initial_value

    HapticsModeUI._mode_menus[mode_id]:Slider({
        -- Maybe add the mode id in front like modeid_sliderid
        name = mode_ui_item.id,
        text = mode_ui_item.text,
        -- Default these and make sure they are in a reasonable range
        value = slider_initial_value,
        min = (mode_ui_item.min and HapticsClamp(mode_ui_item.min)) or 0,
        max = (mode_ui_item.max and HapticsClamp(mode_ui_item.max)) or 100,
        -- We don't need decimals
        step = 1,
        floats = 0,
        on_callback = function(item)
            -- Sliders even with a step of 1 assign decimal numbers
            HapticsMode._modes[mode_id].menus[mode_ui_item.id].value = math.floor(item:Value() + 0.5)
        end
    })
end

if not HapticsModeUI.initialized then
    HapticsModeUI:Init()
end
