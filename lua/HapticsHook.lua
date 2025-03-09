---@class HapticsHook: class
HapticsHook = HapticsHook or class()

function HapticsHook:Init()
    self._blt_run_hook_table = _G.BLT["RunHookTable"]
    self:OverrideBLTRunHookTable()

    self.initialized = true
end

function HapticsHook:OverrideBLTRunHookTable()
    _G.BLT["RunHookTable"] = self.RunHookTable
end

function HapticsHook:RunHookTable(hooks_table, path)
    -- Run our own hooks based on if blt would run pre or post hooks right now
    if hooks_table == BLT.hook_tables.pre then
        -- self cannot be used in this context because self is not HapticsHook anymore
        HapticsHook:RunHookFunctions(path, true)
    elseif hooks_table == BLT.hook_tables.post then
        HapticsHook:RunHookFunctions(path, false)
    end

    -- Then run the origial blt RunHookTable function
    HapticsHook._blt_run_hook_table(BLT, hooks_table, path)
end

function HapticsHook:RunHookFunctions(source_file, pre)
    for _, mode_data in pairs(HapticsMode.loaded_modes) do
        if pre then
            mode_data:RunPreHooks(source_file)
        else
            mode_data:RunPostHooks(source_file)
        end
    end
end

if not HapticsHook.initialized then
    HapticsHook:Init()
end
