HapticsHook = HapticsHook or class()

function HapticsHook:Init()
    HapticsHook["_hooks"] = {
        pre = {},
        post = {}
    }

    HapticsHook["_blt_run_hook_table"] = _G.BLT["RunHookTable"]

    HapticsHook:OverrideBLTRunHookTable()

    HapticsHook["initialized"] = true
end

function HapticsHook:AddPostHook(source_file, hook_id, hook_function)
    if not HapticsHook._hooks.post[source_file] then
        HapticsHook._hooks.post[source_file] = {}
    end

    if not HapticsHook._hooks.post[source_file][hook_id] then
        HapticsHook._hooks.post[source_file][hook_id] = {
            enabled = true,
            func = hook_function
        }
    end
end

function HapticsHook:AddPostHooks(source_file, hook_function_table_with_ids)
    for hook_id, hook_function in pairs(hook_function_table_with_ids) do
        HapticsHook:AddPostHook(source_file, hook_id, hook_function)
    end
end

function HapticsHook:AddPreHook(source_file, hook_id, hook_function)
    if not HapticsHook._hooks.pre[source_file] then
        HapticsHook._hooks.pre[source_file] = {}
    end

    if not HapticsHook._hooks.pre[source_file][hook_id] then
        HapticsHook._hooks.pre[source_file][hook_id] = {
            enabled = true,
            func = hook_function
        }
    end
end

function HapticsHook:AddPreHooks(source_file, hook_function_table_with_ids)
    for hook_id, hook_function in pairs(hook_function_table_with_ids) do
        HapticsHook:AddPreHook(source_file, hook_id, hook_function)
    end
end

function HapticsHook:RemoveHook(hook_id, pre)
    local pre_or_post = pre and "pre" or "post"

    if HapticsHook._hooks and HapticsHook._hooks[pre_or_post] then
        for source_key, hooks_table in pairs(HapticsHook._hooks[pre_or_post]) do
            if hooks_table and hooks_table[hook_id] then
                HapticsHook._hooks[pre_or_post][source_key].remove(hook_id)
            end
        end
    end
end

function HapticsHook:OverrideBLTRunHookTable()
    _G.BLT["RunHookTable"] = HapticsHook["RunHookTable"]
end

function HapticsHook:RunHookTable(hooks_table, path)
    -- Run our own hooks based on if blt would run pre or post hooks right now
    if hooks_table == BLT.hook_tables.pre then
        if HapticsHook._hooks.pre and HapticsHook._hooks.pre[path] then
            HapticsHook:RunHookFunctions(path, true)
        end
    elseif hooks_table == BLT.hook_tables.post then
        if HapticsHook._hooks.post and HapticsHook._hooks.post[path] then
            HapticsHook:RunHookFunctions(path, false)
        end
    end

    -- Then run the origial blt RunHookTable function
    HapticsHook._blt_run_hook_table(BLT, hooks_table, path)
end

function HapticsHook:RunHookFunctions(source_file, pre)
    for _, hook_data in pairs(HapticsHook._hooks[pre and "pre" or "post"][source_file]) do
        log(hook_data.enabled)
        if hook_data.enabled then
            hook_data.func()
        end
    end
end

function HapticsHook:EnableHook(source_file, hook_id)
    HapticsHook:ChangeHookState(source_file, hook_id, true)
end

function HapticsHook:DisableHook(source_file, hook_id)
    HapticsHook:ChangeHookState(source_file, hook_id, false)
end

function HapticsHook:ChangeHookState(source_file, hook_id, enabled)
    if HapticsHook._hooks.pre[source_file] and HapticsHook._hooks.pre[source_file][hook_id] then
        HapticsHook._hooks.pre[source_file][hook_id].enabled = enabled
    end

    if HapticsHook._hooks.post[source_file] and HapticsHook._hooks.post[source_file][hook_id] then
        HapticsHook._hooks.post[source_file][hook_id].enabled = enabled
    end
end

if not HapticsHook.initialized then
    HapticsHook:Init()
end
