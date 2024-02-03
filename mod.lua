if not ModCore then
	log("[ERROR] Unable to find ModCore from BeardLib! Is BeardLib installed correctly?")
	return
end

AssaultStatesCore = AssaultStatesCore or class(ModCore)

function AssaultStatesCore:init()
	--Calling the base function for init from ModCore
	--self_tbl, config path, auto load modules, auto post init modules
	self.super.init(self, ModPath .. "config.xml", true, true)

	_G.HAPTICS_network_id = "Haptics_Net"
end

if not _G.AssaultStates then
	local success, err = pcall(function() AssaultStatesCore:new() end)
	if not success then
		log("[ERROR] An error occured on the initialization of Assault States. " .. tostring(err))
	end
end