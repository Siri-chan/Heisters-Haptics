---@class HapticsUtility: class
HapticsUtility = HapticsUtility or class()

function HapticsUtility:Init()
    ---@type boolean @Set if HapticsUtility:init() successfully finished initializing
    HapticsUtility.initialized = true;
end

function HapticsUtility:Oscillate()

end

function HapticsUtility:Clamp(val, min, max)
    if val < min then
        return min
    elseif val > max then
        return max
    else
        return val
    end
end

function HapticsUtility:DeepCopy(orig)
    local orig_type = type(orig)
    local copy

    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[HapticsUtility:DeepCopy(orig_key)] = HapticsUtility:DeepCopy(orig_value)
        end
        setmetatable(copy, HapticsUtility:DeepCopy(getmetatable(orig)))
    else
        -- anything that isn't a table is passed by value anyway
        copy = orig
    end

    return copy
end

---Clones an entire function with upvalues (thanks luajit)
---@param func function @The function to clone
---@return function? @Returns the cloned function
function HapticsUtility:CloneFunction(func)
    local func_string = string.dump(func)
    local cloned_func = loadstring(func_string)
    local i = 1

    while true do
        local name = debug.getupvalue(func, i)
        if not name then
            break
        end
        -- This works trust
        ---@diagnostic disable-next-line: param-type-mismatch
        debug.upvaluejoin(cloned_func, i, func, i)
        i = i + 1
    end

    return cloned_func
end

-- Ensure a global instance of this class is created
if not HapticsUtility.initialized then
    local success, err = pcall(function()
        HapticsUtility:new()
    end)

    if not success then
        log("[Haptics - ERROR] An error occured on the initialization of HapticsUtility: " .. tostring(err))
    end
end
