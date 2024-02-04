-- todo: toggle buttplug on/off
if haptics and haptics.Options then
    _G.HAPTICS_enabled = !haptics.Options:GetValue("enable_feedback")
    haptics.Options.SetValue("enable_feedback", _G.HAPTICS_enabled)
else
    log("[Haptics - ERROR] Something went wrong... Couldn't load options")
end