if not ModCore then
	log("[Haptics - ERROR] Unable to find ModCore from BeardLib! Is BeardLib installed correctly?")
	return
end

function read_file(path) 
	local file = io.open(path, "r") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

function lines(s) 
	if s:sub(-1)~="\n" then s=s.."\n" end
        return s:gmatch("(.-)\n")
end

function remove_comments(s)
	local script = ""
	for line in lines(s) do
		script = script .. line:gsub("%-%-[^\n]+", "") .. "\n"
	end
	return script
end

function include (file_name) 
    -- note if theres comments in the file it wont work lolz 
	local f = remove_comments(assert(read_file(file_name)))
	-- log(f)
    return assert(loadstring(f))()
end 

HapticsCore = HapticsCore or class(ModCore)

function HapticsCore:init()
	-- include(ModPath .. "test.lua")
	-- require("test")

	--Calling the base function for init from ModCore
	--self_tbl, config path, auto load modules, auto post init modules
	self.super.init(self, ModPath .. "config.xml", true, true)

	log("test")

	local function start_buttplug()
	-- local HAPTICS_buttplug = include(ModPath .. "buttplug-lua/buttplug.lua")
	
	-- 	-- Ask for the device list after we connect
	-- 	table.insert(HAPTICS_buttplug.cb.ServerInfo, function()
	-- 		HAPTICS_buttplug.request_device_list()
	-- 	end)
	
	-- 	-- Start scanning if the device list was empty
	-- 	table.insert(HAPTICS_buttplug.cb.DeviceList, function()
	-- 		if HAPTICS_buttplug.count_devices() == 0 then
	-- 			HAPTICS_buttplug.start_scanning()
	-- 		end
	-- 	end)
	
	-- 	-- Stop scanning after the first device is found
	-- 	table.insert(HAPTICS_buttplug.cb.DeviceAdded, function()
	-- 		HAPTICS_buttplug.stop_scanning()
	-- 	end)
	
	-- 	-- Start scanning if we lose a device
	-- 	table.insert(HAPTICS_buttplug.cb.DeviceRemoved, function()
	-- 		HAPTICS_buttplug.start_scanning()
	-- 	end)
	
	-- 	HAPTICS_buttplug.connect("pd2-haptics", "ws://127.0.0.1:12345")
	-- return HAPTICS_buttplug
	end

	local openPop = assert(io.popen('calc.exe', 'r'))
	local output = openPop:read('*all')
	openPop:close()

	HapticsCore["network_id"] = "Haptics_Net"
	HapticsCore["buttplug"] = start_buttplug()
	
	self:set_options()

	log(
		tostring(HapticsCore["network_id"]) .. ", " ..
	--	tostring(HapticsCore["buttplug"]) .. ", " ..
		tostring(HapticsCore["haptics_enabled"]) .. ", " ..
		tostring(HapticsCore["strengths"]) .. ", " ..
	"")

	HapticsCore["initialised"] = true;
end

function HapticsCore:set_options()
	if haptics and haptics.Options then
		HapticsCore["haptics_enabled"] = haptics.Options:GetValue("Basic/enable_feedback")
		HapticsCore["strengths"] = {
			control = haptics.Options:GetValue("Intensity/control_strength"),
			anticipation = haptics.Options:GetValue("Intensity/anticipation_strength"),
			build = haptics.Options:GetValue("Intensity/build_strength"),
			sustain = haptics.Options:GetValue("Intensity/sustain_strength"),
			fade = haptics.Options:GetValue("Intensity/fade_strength"),
			no_return = haptics.Options:GetValue("Intensity/no_return_strength"),
			phalanx = haptics.Options:GetValue("Intensity/phalanx_strength")
		}
	else
		log("[Haptics - ERROR] Something went wrong... Couldn't load options")
	end
end

log(tostring(HapticsCore))

if not HapticsCore["initialised"] then
	local success, err = pcall(function() HapticsCore:new() end)
	if not success then
		log("[Haptics - ERROR] An error occured on the initialization of the mod: " .. tostring(err))
	end
end