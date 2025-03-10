---@class HapticsUI: class
HapticsUI = HapticsUI or class()

function HapticsUI:Init()
    self.options_menu = {
        main = MenuUI:new({
            name = "Haptics_Options_Menu",
            enabled = false,
            create_items = function()
                self:CreateOptionsMenu()
            end,
            use_default_close_key = true,
            layer = 500
        }),
        background_panel = nil,
        modes_stash = nil,
        sidebar = nil
    }

    self.scaled_render_size = nil

    -- Adds our MenuUI menu to the "Mod Options" entry in the settings menu option
    Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_HeistersHaptics", function(_, nodes)
        -- Only need an open callback because closing is handled inside the menu
        MenuCallbackHandler.OpenHeistersHapticsModOptions = function(_, _)
            if self.options_menu.main then
                self.options_menu.main:Enable()
            end
        end

        local item = nodes["blt_options"]:create_item({
            type = "CoreMenuItem.Item"
        }, {
            name = "Haptics_Options_Menu_Open",
            text_id = "Haptics_Options_Title",
            help_id = "Haptics_Options_Desc",
            callback = "OpenHeistersHapticsModOptions",
            localize = true
        })

        nodes["blt_options"]:add_item(item)
    end)

    self.initialized = true
end

function HapticsUI:CreateOptionsMenu()
    self.scaled_render_size = self.scaled_render_size or managers.gui_data:full_scaled_size()

    self.options_menu.background_panel = self.options_menu.main:Holder({
        name = "Haptics_Options_Background",
        background_color = Color.black,
        background_alpha = 0.5,
        h = self.scaled_render_size.h,
        w = self.scaled_render_size.w
    })

    self.options_menu.sidebar = self.options_menu.background_panel:Holder({
        name = "Haptics_Options_Sidebar",
        background_color = Color.black,
        background_alpha = 0.5,
        h = self.scaled_render_size.h,
        w = self.scaled_render_size.w / 3,
        min_width = 400,
        position = "Right",
        layer = 1
    })

    self.options_menu.sidebar:Toggle({
        name = "Haptics_Options_Enable",
        text = "Haptics_Options_EnableFeedback_Title",
        help = "Haptics_Options_EnableFeedback_Desc",
        localized = true,
        value = HapticsSettings._settings.haptics_enabled,
        on_callback = function(item)
            HapticsSettings._settings.haptics_enabled = item:Value()
        end
    })

    self.options_menu.sidebar:TextBox({
        name = "Haptics_Options_Intiface_URI",
        text = "Haptics_Options_Intiface_Title",
        help = "Haptics_Options_Intiface_Desc",
        localized = true,
        value = HapticsSettings._settings.intiface_uri,
        on_callback = function(item)
            HapticsSettings._settings.intiface_uri = item:Value()
        end
    })

    -- TODO: Add localization for button text
    self.options_menu.sidebar:Button({
        name = "Haptics_Options_Search_Modes",
        text = "Haptics_Options_Search_Modes_Text",
        help = "Haptics_Options_Search_Modes_Desc",
        localized = true,
        size_by_text = true,
        on_callback = function(_)
            HapticsMode:SearchModes()
        end
    })

    -- Modes Options --

    self.options_menu.modes_stash = self.options_menu.sidebar:Holder({
        name = "Haptics_Options_Modes",
        background_alpha = 0,
        min_height = self.scaled_render_size.h / 5
    })

    -- Settings/Menu Options --

    self.options_menu.sidebar:Button({
        name = "Haptics_Options_SaveExit",
        text = "Haptics_Options_SaveExit",
        localized = true,
        size_by_text = true,
        on_callback = function(_)
            HapticsSettings:Save()

            if HapticsSettings._settings.haptics_enabled then
                HapticsCore:ConnectHaptics(HapticsSettings._settings.intiface_uri)
            end

            self.options_menu.main:Disable()
        end,
        position = "BottomRight",
        layer = 2
    })

    self.options_menu.sidebar:Button({
        name = "Haptics_Options_Exit",
        text = "Haptics_Options_Exit",
        localized = true,
        size_by_text = true,
        on_callback = function(_)
            self.options_menu.main:Disable()
        end,
        position = "BottomLeft",
        layer = 2
    })
end

if not HapticsUI.initialized then
    HapticsUI:Init()
end
