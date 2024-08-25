HapticsModeUI = HapticsModeUI or class()

---@param mode_id string @Id of the HapticsMode
---@param mode_menus_table table @table of menu items to create
function HapticsModeUI:Parse(mode_id, mode_menus_table)
    for _, v in mode_menus_table do
        if v.type:lower() == "slider" then
            HapticsModeUI:CreateSlider(v)
            -- Add to UI table somewhere so i can destroy it again if disabled
        end
    end
end

---@param parent_menu_item table
function HapticsModeUI:CreateSlider(mode_ui_item)
    parent_menu_item:Slider({
        -- Maybe add the mode id in front like modeid_sliderid
        name = mode_ui_item.id,
        text = mode_ui_item.text,
        value = mode_ui_item.default or 0,
        min = mode_ui_item.min or 0,
        max = mode_ui_item.max or 100
    })
end

