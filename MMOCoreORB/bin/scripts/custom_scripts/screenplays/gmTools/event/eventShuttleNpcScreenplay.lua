-- Written by Tyclo | 2019-05-10
-- https://github.com/Sphazz
--[[
	Give credit to all assets and custom content in your repo and files or don't use this.
	Pretending to be ignorant doesn't count.
]]

eventShuttleNpcScreenplay = ScreenPlay:new {
	scriptName = "eventShuttleNpcScreenplay",
	maxNpcs = 8,
	windowPrefix = "[Event Shuttle]",
	timerOptions = {
		{ "10 minutes", 10 },
		{ "15 minutes", 15 },
		{ "60 minutes", 60 },
		{ "120 minutes", 120 },
		{ "Never", -1 },
	},

	npcMaxNameLength = 50,
	teleportMobile = "event_shuttle_npc_neutral",
	shuttleTitle = "(Event Transport Shuttle)",
}

registerScreenPlay("eventShuttleNpcScreenplay", false)

function eventShuttleNpcScreenplay:openEventTeleportNPCWindow(pPlayer)
	local playerID = SceneObject(pPlayer):getObjectID()
	local sui = SuiListBox.new(self.scriptName, "teleportNpcMainCallback")
	sui.setTargetNetworkId(0)
	sui.setTitle(self.windowPrefix .. " Main Menu")
	local message = colorGrey .. "Choose an Event Shuttle to \\#pcontrast3 Setup " .. colorGrey .. "or " .. colorEmphasis .. "Manage.\n\n"
	message = message .. colorGrey .. "You may have up to " .. colorCounter .. self.maxNpcs .. colorGrey .. " active Event Shuttles. You can move around and change planets with Event Shuttle window open. The window will save your input, so you may also close it to resume progress later without spawning an Event Shuttle.\n\nSelect a slot and choose an option. To Spawn an Event Shuttle, you must set an " .. colorEmphasis .. "Event Shuttle Location" .. colorGrey .. ", " .. colorEmphasis .. "Destination" .. colorGrey .. " and " .. colorEmphasis .. "Despawn Timer" .. colorGrey .. ". The Event Shuttle Location or Destination will set the location at your current location.\n\nAdditionally, you may choose to set a custom " .. colorGrey .. "Name " .. colorGrey .. "for the Event Shuttle."
	sui.setPrompt(message)

	for i = 1, self.maxNpcs do
		local teleportNpcSetup = readData("eventTeleportNpc:Setup:" .. playerID .. ":" .. i)
		if (teleportNpcSetup > 0) then
			sui.add("\\#pcontrast1 [Manage]\t " .. colorEmphasis .. "Event Shuttle " .. colorCounter .. "#" .. i, "")
		else
			sui.add("\\#pcontrast2 [Setup]\t\t " .. colorEmphasis .. "Event Shuttle " .. colorCounter .. "#" .. i, "")
		end
	end

	sui.add("\\#cef46eList Server Wide Event Shuttles", "")

	sui.sendTo(pPlayer)
end

function eventShuttleNpcScreenplay:teleportNpcMainCallback(pPlayer, pSui, eventIndex, args)
	local cancelPressed = (eventIndex == 1)

	if (cancelPressed) then
		return
	end

	if (args == "-1") then
		return
	end

	if (pPlayer == nil) then
		return
	end

	local playerID = SceneObject(pPlayer):getObjectID()

	local selectedOption = tonumber(args) + 1

	if (selectedOption == self.maxNpcs + 1) then
		self:getAllTeleportNPCs(pPlayer)
		return
	end

	writeData("eventTeleportNpc:SetupNPC:" .. playerID, selectedOption)

	local npcLocation = self:getLocationTable(pPlayer, selectedOption, "npcLocation")
	local destination = self:getLocationTable(pPlayer, selectedOption, "destinationLocation")
	local timer = readData("eventTeleportNpc:" .. playerID .. ":timer:" .. selectedOption)
	local npcName = readStringData("eventTeleportNpc:" .. playerID .. ":npcName:" .. selectedOption)

	local sui = SuiListBox.new(self.scriptName, "teleportNpcCallback")
	sui.setTargetNetworkId(0)
	sui.setTitle(self.windowPrefix .. " Event Shuttle #" .. selectedOption)
	sui.showOtherButton()
	sui.setOtherButtonText("Back")
	sui.setProperty("btnRevert", "OnPress", "RevertWasPressed=1\r\nparent.btnOk.press=t")

	local message = "\\#ffffffEvent Shuttle " .. colorCounter .. "#" .. selectedOption .. "\n\n" .. colorSlate .. "Status: "
	local npcState = 0

	local npcMsg = colorEmphasis .. "Event Shuttle Location"
	local destinationMsg = colorEmphasis .. "Destination"
	local timerMsg = colorEmphasis .. "Despawn Timer"
	local npcNameMsg = colorEmphasis .. "Name"

	local setMsg = colorSuccess .. "[Set]\t\t "
	local unsetMsg = colorFail .. "[Unset]\t\t "

	if (npcLocation ~= nil) then
		local npcID = readData("eventTeleportNpc:" .. playerID .. ":npcID:" .. selectedOption)
		if (npcID ~= 0) then
			local pMobile = getCreatureObject(npcID)
			message = message .. colorTealCnf .. "Event Shuttle Spawned\n\n" .. colorGrey .. "While the Event Shuttle is spawned, you may still change the Destination location and Event Shuttle's Name.\n\nUse the " .. colorRedWarn .. "Destroy Event Shuttle" .. colorGrey .. " option to free up this Event Shuttle slot."
			npcState = 2
			npcMsg = colorTealCnf .. "[Spawned]\t " .. npcMsg
		else
			npcState = 1
			npcMsg = setMsg .. npcMsg
		end
		npcMsg = npcMsg .. ": "  .. colorWhite .. npcLocation[1] .. ", " .. colorSlate .. "X: " .. colorWhite .. npcLocation[2] .. ", " .. colorSlate .. "Y: " .. colorWhite .. npcLocation[4] .. ", " .. colorSlate .. "Z: " .. colorWhite .. npcLocation[3] .. ", " .. colorSlate .. "Rot: " .. colorWhite .. npcLocation[5] .. ", " .. colorSlate .. "Cell: " .. colorWhite .. npcLocation[6]
	else
		npcMsg = unsetMsg .. npcMsg
 	end

	if (destination ~= nil) then
		destinationMsg = setMsg .. destinationMsg .. ": " .. colorWhite .. destination[1] .. ", " .. colorSlate .. "X: " .. colorWhite .. destination[2] .. ", " .. colorSlate .. "Y: " .. colorWhite .. destination[4] .. ", " .. colorSlate .. "Z: " .. colorWhite .. destination[3] .. ", " .. colorSlate .. "Cell: " .. colorWhite .. destination[6]
	else
		destinationMsg = unsetMsg .. destinationMsg
	end

	if (timer ~= 0) then
		timerMsg = setMsg .. timerMsg .. ": " .. colorWhite .. self.timerOptions[timer][1]
	else
		timerMsg = unsetMsg .. colorWhite .. timerMsg
	end

	if (npcName ~= "") then
		npcNameMsg = setMsg .. npcNameMsg .. ": " .. colorWhite .. npcName
	else
		npcNameMsg = unsetMsg .. npcNameMsg .. colorPrimary .. " - " .. colorSlate .. "Optional"
	end

	if (npcState == 1 and destination ~= nil and timer ~= 0) then
		message = message .. colorGreenCnf .. "Pending Spawn\n\n" .. colorGrey .. "Event Shuttle is ready to be deployed.\n\nYou may still change all of the Event Shuttle's options. Select " .. colorGreenCnf .. "Deploy Event Shuttle" .. colorGrey .. " to spawn."
	elseif (npcState ~= 2) then
		message = message .. colorOrangeDeny .. "Requires Additional Set Up\n\n" .. colorGrey .. "You must set the Event Shuttle's Location, Destination and Timer before deploying this Event Shuttle.\n\nOnce the Event Shuttle is deployed, you may NOT" .. colorGrey .. " change the Event Shuttle Location or Despawn Timer, but you can change the Destination Location and Name.\n\nBefore spawning the Event Shuttle, you may choose to " .. colorOrangeDeny .. "Reset Setup" .. colorGrey .. " to reset all options before deploying to start anew."
	end

	sui.setPrompt(message)

	sui.add(npcMsg, "")
	sui.add(destinationMsg, "")
	sui.add(timerMsg, "")
	sui.add(npcNameMsg, "")

	if (npcState == 2) then
  		sui.add(colorRedWarn .. "Destroy Event Shuttle", "")
	elseif (npcLocation ~= nil and destination ~= nil and timer ~= 0) then
		sui.add(colorGreenCnf .. "Deploy Event Shuttle", "")
	else
		sui.add(colorOrangeDeny .. "Reset Setup", "")
	end

	sui.sendTo(pPlayer)
end

function eventShuttleNpcScreenplay:teleportNpcCallback(pPlayer, pSui, eventIndex, selectedOption, otherPressed)
	if (pPlayer == nil) then
		return
	end

	local cancelPressed = (eventIndex == 1)

	if (cancelPressed) then
		return
	end

	if (otherPressed == "true") then
		self:openEventTeleportNPCWindow(pPlayer)
		return
	end

	if (selectedOption == "-1") then
		return
	end

	local playerID = SceneObject(pPlayer):getObjectID()

	local selectedOption = tonumber(selectedOption) + 1

	local teleportNpcSetup = readData("eventTeleportNpc:SetupNPC:" .. playerID)

	local npcID = readData("eventTeleportNpc:" .. playerID .. ":npcID:" .. teleportNpcSetup)
	local pMobile = nil

	if (npcID ~= 0) then
		pMobile = getCreatureObject(npcID)
	end

	if (selectedOption == 1) then
		if (pMobile ~= nil) then
			CreatureObject(pPlayer):sendSystemMessage(colorSysWarning .. "[WARNING] \\#ffffffCannot change Event Shuttle's spawn point. Please use this menu to destroy the Event Shuttle to change the Event Shuttle's location.")
		else
			self:writeCurrentLocation(pPlayer, teleportNpcSetup, "npcLocation")
			writeData("eventTeleportNpc:Setup:" .. playerID .. ":" .. teleportNpcSetup, 1)
		end

		self:teleportNpcMainCallback(pPlayer, "", 0, teleportNpcSetup - 1)
	elseif (selectedOption == 2) then
		local destination = readStringData("eventTeleportNpc:destinationLocation:" .. playerID .. ":" .. teleportNpcSetup)
		local setNewDestination = false

		if (destination ~= "") then
			npcID = readData("eventTeleportNpc:" .. playerID .. ":npcID:" .. teleportNpcSetup)
			setNewDestination = true
			-- Check if mobile is spawned, otherwise, no need to show message
			if (npcID ~= 0) then
				pMobile = getCreatureObject(npcID)
			end
		end

		self:writeCurrentLocation(pPlayer, teleportNpcSetup, "destinationLocation")
		writeData("eventTeleportNpc:Setup:" .. playerID .. ":" .. teleportNpcSetup, 2)

		if (pMobile ~= nil and setNewDestination == true) then
			local newDestination = readStringData("eventTeleportNpc:destinationLocation:" .. playerID .. ":" .. teleportNpcSetup)
			writeStringData("eventTeleportNpc:Destination:" .. CreatureObject(pMobile):getObjectID(), newDestination)
			CreatureObject(pPlayer):sendSystemMessage(colorSysNotice .. "[NOTICE] \\#ffffffTeleport destination has been updated for Event Shuttle " .. colorCounter .. "#" .. teleportNpcSetup .. "\\#ffffff.")
		end

		self:teleportNpcMainCallback(pPlayer, "", 0, teleportNpcSetup - 1)
	elseif (selectedOption == 3) then
		if (npcID ~= 0) then
			pMobile = getCreatureObject(npcID)
		end

		if (pMobile ~= nil) then
			CreatureObject(pPlayer):sendSystemMessage(colorSysWarning .. "[WARNING] \\#ffffffCannot change despawn timer while the Event Shuttle is spawned. Please use this menu to destroy the Event Shuttle to change the timer.")
			self:teleportNpcMainCallback(pPlayer, "", 0, teleportNpcSetup - 1)
		else
			self:setTimerWindow(pPlayer, teleportNpcSetup)
			writeData("eventTeleportNpc:Setup:" .. playerID .. ":" .. teleportNpcSetup, 3)
		end
	elseif (selectedOption == 4) then
		self:openRenameNpcWindow(pPlayer)
		writeData("eventTeleportNpc:Setup:" .. playerID .. ":" .. teleportNpcSetup, 4)
	elseif (selectedOption == 5) then
		self:doNpcSpawnResetDestroyOptions(pPlayer, teleportNpcSetup)
  end

end

function eventShuttleNpcScreenplay:openRenameNpcWindow(pPlayer)
	local sui = SuiInputBox.new(self.scriptName, "renameNpcCallback")
	if (pUsingObject == nil) then
		sui.setTargetNetworkId(0)
	else
		sui.setTargetNetworkId(SceneObject(pPlayer):getObjectID())
	end

	sui.setTitle(self.windowPrefix .. " Rename Event Shuttle")
	local suiBody = "Enter a new name for the Event Shuttle. Maximum of " .. self.npcMaxNameLength .. " characters."
	sui.setPrompt(suiBody)

	sui.sendTo(pPlayer)
end

function eventShuttleNpcScreenplay:renameNpcCallback(pPlayer, pSui, eventIndex, args)
	local cancelPressed = (eventIndex == 1)

	if (pPlayer == nil) then
		return
	end

	local playerID = SceneObject(pPlayer):getObjectID()
	local teleportNpcSetup = readData("eventTeleportNpc:SetupNPC:" .. playerID)

	if (cancelPressed) then
		self:teleportNpcMainCallback(pPlayer, "", 0, teleportNpcSetup - 1)
		return
	end

	if (args == "-1" or args == nil) then
		return
	end

	if (string.len(args) >= self.npcMaxNameLength) then
		CreatureObject(pPlayer):sendSystemMessage(colorSysWarning .. "[WARNING] \\#ffffffError renaming Event Shuttle, name is too long. (" .. self.npcMaxNameLength .. " max limit)")
		self:openRenameNpcWindow(pPlayer)
		return
	end

	if (teleportNpcSetup == 0) then
		return
	end

	writeStringData("eventTeleportNpc:" .. playerID .. ":npcName:" .. teleportNpcSetup, args)

	local npcID = readData("eventTeleportNpc:" .. playerID .. ":npcID:" .. teleportNpcSetup)
	local pMobile = nil

	if (npcID ~= 0) then
		pMobile = getCreatureObject(npcID)
	end

	if (pMobile ~= nil) then
		SceneObject(pMobile):setCustomObjectName(args .. "\n" .. self.shuttleTitle)
	end

	self:teleportNpcMainCallback(pPlayer, "", 0, teleportNpcSetup - 1)
end

function eventShuttleNpcScreenplay:writeCurrentLocation(pPlayer, npcIndex, locationType)
	if (pPlayer == nil) then
		return
	end

	local playerID = SceneObject(pPlayer):getObjectID()

	writeStringData("eventTeleportNpc:" .. locationType .. ":" .. playerID .. ":" .. npcIndex, CreatureObject(pPlayer):getZoneName() .. "," .. math.floor(CreatureObject(pPlayer):getPositionX()) .. "," .. math.floor(CreatureObject(pPlayer):getPositionZ()) .. "," .. math.floor(CreatureObject(pPlayer):getPositionY()) .. "," .. math.floor(CreatureObject(pPlayer):getDirectionAngle()) .. "," .. CreatureObject(pPlayer):getParentID())
end

function eventShuttleNpcScreenplay:getLocationTable(pPlayer, npcIndex, locationType)
	if (pPlayer == nil) then
		return
	end

	if (npcIndex == nil) then
		return
	end

	if (locationType == "" or locationType == nil) then
		return
	end

	local playerID = SceneObject(pPlayer):getObjectID()

	if (playerID == nil) then
		return
	end

	local locationData = readStringData("eventTeleportNpc:" .. locationType .. ":" .. playerID .. ":" .. npcIndex)

	if (locationData == "") then
		return
	end

	local locationTable = HelperFuncs:splitString(locationData, ",")

	if (locationTable == "") then
		return
	end

	return locationTable
end

function eventShuttleNpcScreenplay:setTimerWindow(pPlayer, npcIndex)
	if (pPlayer == nil) then
		return
	end

	if (npcIndex == nil) then
		return
	end

	local message = "Set the Event Shuttle's despawn timer.\n\nAn Event Shuttle with a despawn timer of \"Never\" will not despawn until server restart or destructed from the Event Shuttle's menu."

	local sui = SuiListBox.new(self.scriptName, "setTimerCallback")
	sui.setTargetNetworkId(0)
	sui.setTitle(self.windowPrefix .. " Despawn Timer")
	sui.setPrompt(message)
	for i,option in pairs(self.timerOptions) do
		sui.add(option[1], "")
	end
	sui.sendTo(pPlayer)

end

function eventShuttleNpcScreenplay:setTimerCallback(pPlayer, pSui, eventIndex, args)
  local cancelPressed = (eventIndex == 1)

	if (cancelPressed) then
		return
	end

	if (args == "-1") then
		return
	end

	if (pPlayer == nil) then
		return
	end

	local playerID = SceneObject(pPlayer):getObjectID()

	local selectedOption = tonumber(args) + 1

	local teleportNpcSetup = readData("eventTeleportNpc:SetupNPC:" .. playerID)

	writeData("eventTeleportNpc:" .. playerID .. ":timer:" .. teleportNpcSetup, selectedOption)

	self:teleportNpcMainCallback(pPlayer, "", 0, teleportNpcSetup - 1)
end

function eventShuttleNpcScreenplay:doNpcSpawnResetDestroyOptions(pPlayer, npcIndex)
	if (pPlayer == nil) then
		return
	end

	if (npcIndex == nil) then
		return
	end

	local playerID = SceneObject(pPlayer):getObjectID()

	local npcID = readData("eventTeleportNpc:" .. playerID .. ":npcID:" .. npcIndex)
	local npcLocation = readStringData("eventTeleportNpc:npcLocation:" .. playerID .. ":" .. npcIndex)
	local destination = readStringData("eventTeleportNpc:destinationLocation:" .. playerID .. ":" .. npcIndex)
	local timer = readData("eventTeleportNpc:" .. playerID .. ":timer:" .. npcIndex)
	local pMobile = nil

	if (npcID ~= 0) then
		pMobile = getCreatureObject(npcID)
	end

	if (pMobile ~= nil) then
		self:destroyTeleportNpc(playerID, pMobile)
		self:resetTeleportNpc(pPlayer, playerID, npcIndex)
		CreatureObject(pPlayer):sendSystemMessage(colorSysNotice .. "[NOTICE] \\#ffffffEvent Shuttle " .. colorCounter .. "#" .. npcIndex .. "\\#ffffff Destroyed")
	elseif (npcLocation ~= nil and destination ~= nil and timer ~= 0) then
		self:spawnTeleportNpc(pPlayer, playerID, npcIndex)
	else
		self:resetTeleportNpc(pPlayer, playerID, npcIndex)
		CreatureObject(pPlayer):sendSystemMessage(colorSysNotice .. "[NOTICE] \\#ffffffEvent Shuttle " .. colorCounter .. "#" .. npcIndex .. "\\#ffffff Settings Reset")
	end
end

function eventShuttleNpcScreenplay:spawnTeleportNpc(pPlayer, playerID, npcIndex)
	if (pPlayer == nil) then
		return
	end

	if (npcIndex == nil) then
		return
	end

	local npcLocation = self:getLocationTable(pPlayer, npcIndex, "npcLocation")
	local destination = readStringData("eventTeleportNpc:destinationLocation:" .. playerID .. ":" .. npcIndex)
	local timer = readData("eventTeleportNpc:" .. playerID .. ":timer:" .. npcIndex)
	local despawnTimer = self.timerOptions[timer][2]
	local npcName = readStringData("eventTeleportNpc:" .. playerID .. ":npcName:" .. npcIndex)

	if (npcLocation == nil or destination == nil or timer == 0) then
		CreatureObject(pPlayer):sendSystemMessage("Missing Criteria")
		return
	end

	local pMobile = spawnMobile(npcLocation[1], self.teleportMobile, 0, npcLocation[2], npcLocation[3], npcLocation[4], npcLocation[5], npcLocation[6])

	if (pMobile == nil) then
		return
	end

	if (despawnTimer > 0) then
		createEvent(despawnTimer * 60 * 1000, self.scriptName, "triggerNpcDespawn", pMobile, "")
	end

	if (npcName ~= "") then
		SceneObject(pMobile):setCustomObjectName(npcName .. "\n(Event Transport Shuttle)")
	end

	self:storeMobileID(pMobile)

	writeStringData("eventTeleportNpc:Destination:" .. CreatureObject(pMobile):getObjectID(), destination)
	writeData("eventTeleportNpc:PlayerCreator:" .. CreatureObject(pMobile):getObjectID(), playerID)

	writeData("eventTeleportNpc:" .. playerID .. ":npcID:" .. npcIndex, CreatureObject(pMobile):getObjectID())
	writeData("eventTeleportNpc:" .. playerID .. ":npcIndex:" .. CreatureObject(pMobile):getObjectID(), npcIndex)

	CreatureObject(pPlayer):sendSystemMessage(colorSysNotice .. "[NOTICE] \\#ffffffEvent Shuttle " .. colorCounter .. "#" .. npcIndex .. "\\#ffffff Spawned")
end

function eventShuttleNpcScreenplay:resetTeleportNpc(pPlayer, playerID, npcIndex)
	deleteData("eventTeleportNpc:" .. playerID .. ":timer:" .. npcIndex)
	deleteData("eventTeleportNpc:" .. playerID .. ":npcID:" .. npcIndex)

	deleteStringData("eventTeleportNpc:" .. playerID .. ":npcName:" .. npcIndex)
	deleteStringData("eventTeleportNpc:npcLocation:" .. playerID .. ":" .. npcIndex)
	deleteStringData("eventTeleportNpc:destinationLocation:" .. playerID .. ":" .. npcIndex)

	writeData("eventTeleportNpc:Setup:" .. playerID .. ":" .. npcIndex, 0)
end

function eventShuttleNpcScreenplay:destroyTeleportNpc(playerID, pMobile)
	if (pMobile == nil) then
		return
	end

	self:removeMobileID(pMobile)

	local pMobileID = CreatureObject(pMobile):getObjectID()

	deleteData("eventTeleportNpc:" .. playerID .. ":npcIndex:" .. pMobileID)
	deleteData("eventTeleportNpc:PlayerCreator:" .. pMobileID)
	deleteStringData("eventTeleportNpc:Destination:" .. pMobileID)

	SceneObject(pMobile):destroyObjectFromWorld()
end

function eventShuttleNpcScreenplay:triggerNpcDespawn(pMobile)
	if (pMobile == nil) then
		return
	end

	local pMobileID = CreatureObject(pMobile):getObjectID()
	local playerID = readData("eventTeleportNpc:PlayerCreator:" .. pMobileID)

	if (playerID == 0) then
		return
	end

	local npcIndex = readData("eventTeleportNpc:" .. playerID .. ":npcIndex:" .. pMobileID)

	if (npcIndex == 0) then
		return
	end

	self:resetTeleportNpc(getCreatureObject(playerID), playerID, npcIndex)
	self:destroyTeleportNpc(playerID, pMobile)
end

function eventShuttleNpcScreenplay:getAllTeleportNPCs(pPlayer)
	if (pPlayer == nil) then
		return
	end

	local spawnedMobiles = readStringData("eventTeleportNpc:spawnedMobiles")

	if (spawnedMobiles == "") then
		CreatureObject(pPlayer):sendSystemMessage(colorSysNotice .. "[NOTICE] \\#ffffffThere are currently no Event Shuttles spawned.")
		self:openEventTeleportNPCWindow(pPlayer)
		return
	end

	local mobilesTable = HelperFuncs:splitString(spawnedMobiles, ",")

	if (mobilesTable == nil) then
		return
	end

	local msg = colorGrey .. "Below is a list of currently spawned Event Shuttles across all staff members.\n\nSelect the " .. colorEmphasis .. "Delete All" .. colorGrey .. " button to delete them or " .. colorEmphasis .. "Cancel" .. colorGrey .. " to close this window and return to the Event Shuttle selection screen.\n\n\\#ffffff"

	for i, mobileID in ipairs(mobilesTable) do
		local pMobile = getCreatureObject(mobileID)
		if (pMobile ~= nil) then
			msg = msg .. self:formatTeleportNpcMessage(pMobile, mobileID)
		else
			msg = msg .. "Error Getting Object: " .. mobileID .. "\n"
		end
	end

	local sui = SuiMessageBox.new(self.scriptName, "getAllTeleportNPCsCallback")
	sui.setTitle(self.windowPrefix .. " Event Shuttle Listing")
	sui.setPrompt("\\#ffffff" .. msg)
	if (pPlayer == nil) then
		sui.setTargetNetworkId(0)
	else
		sui.setTargetNetworkId(SceneObject(pPlayer):getObjectID())
	end
	sui.setOkButtonText("Delete All")
	sui.sendTo(pPlayer)
end

function eventShuttleNpcScreenplay:formatTeleportNpcMessage(pMobile, mobileID)
	local mobileCreatorID = readData("eventTeleportNpc:PlayerCreator:" .. mobileID)

	if (mobileCreatorID == nil) then
		return "Error Getting Event Shuttle Creator ID\n"
	end

	local pMobileCreator = getCreatureObject(mobileCreatorID)

	if (pMobileCreator == nil) then
		return "Error Getting Event Shuttle Creator\n"
	end

	local npcIndex = readData("eventTeleportNpc:" .. mobileCreatorID .. ":npcIndex:" .. mobileID)

	local npcLocation = self:getLocationTable(pMobileCreator, npcIndex, "npcLocation")
	local destination = self:getLocationTable(pMobileCreator, npcIndex, "destinationLocation")
	local timer = readData("eventTeleportNpc:" .. mobileCreatorID .. ":timer:" .. npcIndex)
	local npcName = SceneObject(pMobile):getDisplayedName()
	npcName = string.gsub(npcName, "\n", " ")

	local msg = colorCounter .. CreatureObject(pMobileCreator):getFirstName() .. " \\#ffffff- " .. colorEmphasis .. "Event Shuttle " .. colorCounter .. "#" .. npcIndex .. "\n"
	msg = msg .. "\t" .. colorSlate .. "Event Shuttle Name: \\#ffffff" .. npcName .. "\n"
	msg = msg .. "\t" .. colorSlate .. "Location: \\#ffffff" .. npcLocation[1] .. ", " .. colorSlate .. "X:\\#ffffff " .. npcLocation[2] .. ", " .. colorSlate .. "Y:\\#ffffff " .. npcLocation[4] .. ", " .. colorSlate .. "Z:\\#ffffff " .. npcLocation[3] .. ", " .. colorSlate .. "Rot:\\#ffffff " .. npcLocation[5] .. ", " .. colorSlate .. "Cell:\\#ffffff " .. npcLocation[6] .. "\n"
	msg = msg .. "\t" .. colorSlate .. "Destination: \\#ffffff" .. destination[1] .. ", " .. colorSlate .. "X:\\#ffffff " .. destination[2] .. ", " .. colorSlate .. "Y:\\#ffffff " .. destination[4] .. ", " .. colorSlate .. "Z:\\#ffffff " .. destination[3] .. ", " .. colorSlate .. "Cell:\\#ffffff " .. destination[6] .. "\n"
	msg = msg .. "\t" .. colorSlate .. "Timer: \\#ffffff" .. self.timerOptions[timer][1] .. "\n\n"
	return msg
end

function eventShuttleNpcScreenplay:getAllTeleportNPCsCallback(pPlayer, pSui, eventIndex, args)
	local cancelPressed = (eventIndex == 1)

	if (pPlayer == nil) then
		return
	end

	if (cancelPressed) then
		self:openEventTeleportNPCWindow(pPlayer)
		return
	end

	if (args == "-1") then
		return
	end

	local sui = SuiMessageBox.new(self.scriptName, "deleteAllTeleportNpcsCallback")
	sui.setTitle(self.windowPrefix .. " Delete All")
	sui.setPrompt(colorGrey .. "Are you sure that you want to " .. colorRedWarn .. "permanently delete" .. colorGrey .. " every Event Shuttle for all staff?\n\nThere is no undo.")
	
	if (pPlayer == nil) then
		sui.setTargetNetworkId(0)
	else
		sui.setTargetNetworkId(SceneObject(pPlayer):getObjectID())
	end
	
	sui.setOkButtonText("Delete All")
	sui.sendTo(pPlayer)
end

function eventShuttleNpcScreenplay:deleteAllTeleportNpcsCallback(pPlayer, pSui, eventIndex, args)
	local cancelPressed = (eventIndex == 1)

	if (pPlayer == nil) then
		return
	end

	if (cancelPressed) then
		self:openEventTeleportNPCWindow(pPlayer)
		return
	end

	local spawnedMobiles = readStringData("eventTeleportNpc:spawnedMobiles")

	if (spawnedMobiles == "") then
		return
	end

	local mobilesTable = HelperFuncs:splitString(spawnedMobiles, ",")

	if (mobilesTable == nil) then
		return
	end

	for i, mobileID in ipairs(mobilesTable) do
		local pMobile = getCreatureObject(mobileID)
		if (pMobile ~= nil) then
			local mobileCreatorID = readData("eventTeleportNpc:PlayerCreator:" .. mobileID)

			if (mobileCreatorID == nil) then
				break
			end

			local pMobileCreator = getCreatureObject(mobileCreatorID)

			if (pMobileCreator == nil) then
				break
			end

			local npcIndex = readData("eventTeleportNpc:" .. mobileCreatorID .. ":npcIndex:" .. mobileID)

			self:destroyTeleportNpc(mobileCreatorID, pMobile)
			self:resetTeleportNpc(pMobileCreator, mobileCreatorID, npcIndex)
		end
	end
	CreatureObject(pPlayer):sendSystemMessage(colorSysNotice .. "[NOTICE] \\#ffffffAll Event Shuttles have been deleted")
end

function eventShuttleNpcScreenplay:storeMobileID(pMobile)
	if (pMobile == nil) then
		return
	end

	local mobileID = CreatureObject(pMobile):getObjectID()
	local spawnedMobiles = readStringData("eventTeleportNpc:spawnedMobiles")

	if (spawnedMobiles ~= "") then
		spawnedMobiles = spawnedMobiles .. ","
	end

	writeStringData("eventTeleportNpc:spawnedMobiles", spawnedMobiles .. mobileID)
end

function eventShuttleNpcScreenplay:removeMobileID(pMobile)
	if (pMobile == nil) then
		return
	end

	local mobileID = CreatureObject(pMobile):getObjectID()

	if (mobileID == nil or mobileID == 0) then
		return
	end

	local spawnedMobiles = readStringData("eventTeleportNpc:spawnedMobiles")

	if (spawnedMobiles == "") then
		return
	end

	local mobilesTable = HelperFuncs:splitString(spawnedMobiles, ",")
	local mobilesTableNew = ""

	if (mobilesTable == "") then
		return
	end

	for i = 1, #mobilesTable do
		if (tonumber(mobilesTable[i]) ~= mobileID) then
			mobilesTableNew = mobilesTableNew .. mobilesTable[i] .. ","
		end
	end

	if (mobilesTableNew ~= "") then
		mobilesTableNew = mobilesTableNew:sub(1, -2)
	end

	writeStringData("eventTeleportNpc:spawnedMobiles", mobilesTableNew)
end
