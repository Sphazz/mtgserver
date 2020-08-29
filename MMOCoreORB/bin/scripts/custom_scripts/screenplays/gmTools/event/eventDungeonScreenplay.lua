eventDungeonScreenplay = ScreenPlay:new {
	screenplayName = "eventDungeonScreenplay",
	windowPrefix = "[Event Dungeon]",
	maxDungeons = 5, -- Keep less than 22
	planet = "dungeon2",
	offset = 512,
	confirmOptions = {
		{ "Yes", 1 },
		{ "No", 2 },
	}
}

registerScreenPlay("eventDungeonScreenplay", false)

function eventDungeonScreenplay:openEventDungeonInitialWindow(pPlayer)
	local playerID = SceneObject(pPlayer):getObjectID()
	local sui = SuiListBox.new(self.screenplayName, "eventDungeonMainCallback")
	sui.setTargetNetworkId(0)
	sui.setTitle(self.windowPrefix .. " Main Menu")
	
	local message = colorGrey .. "Choose an Event Dungeon to" .. colorFail .. " [Setup]" .. colorGrey .. " or " .. colorSuccess .. "[Manage]" .. colorGrey .. ".\n\n"
	message = message .. colorGrey .. "You may have up to " .. colorCounter .. self.maxDungeons .. colorGrey .. " active Event Dungeons, this is set server wide and not per Administrator. Other admins will be able to manage your event dungeons. \n\nSelect a slot and choose an option."
	sui.setPrompt(message)

	for i = 1, self.maxDungeons do
		local setupStep = readData("eventDungeon:Step:" .. i)

		if (setupStep > 0) then
			sui.add(colorSuccess .. "[Manage]\t " .. colorEmphasis .. "Event Dungeon " .. colorCounter .. "#" .. i, i)
		else
			sui.add(colorFail .. "[Setup]\t\t " .. colorEmphasis .. "Event Dungeon " .. colorCounter .. "#" .. i, i)
		end
	end

	sui.sendTo(pPlayer)
end

function eventDungeonScreenplay:eventDungeonMainCallback(pPlayer, pSui, eventIndex, args)
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

	if (playerID == 0) then
		return
	end

	local selectedOption = tonumber(args) + 1

	local setupStep = readData("eventDungeon:Step:" .. selectedOption)

	if (setupStep >= 2) then
		self:openEventDungeonManageWindow(pPlayer, selectedOption)
	else
		self:openEventDungeonIntialSetupWindow(pPlayer, playerID, setupStep, selectedOption)
	end
end

function eventDungeonScreenplay:openEventDungeonIntialSetupWindow(pPlayer, playerID, setupStep, selectedOption)
	-- Check to see if another admin is setting up a dungeon in this slot
	local dungeonAdminSetup = readData("eventDungeon:Setup:" .. selectedOption .. ":AdminID")

	if ((dungeonAdminSetup ~= 0 and setupStep < 2) and (playerID ~= dungeonAdminSetup)) then
		CreatureObject(pPlayer):sendSystemMessage(colorSysWarning .. " [WARNING] " .. colorWhite .. "Another Admin is currently setting up an event in this slot. Please use another slot or wait 1 minute for their session to expire.")
		return
	end

	writeData("eventDungeon:Setup:" .. selectedOption .. ":AdminID", playerID)
	if (setupStep < 2) then
		createEvent(1 * 60 * 1000, self.screenplayName, "cleanUpAbandonedSetup", playerID, selectedOption)
	end

	local message = "Select a dungeon type."
	writeData("eventDungeon:Step:" .. selectedOption, 1)

	self:openSetupUIWindow(pPlayer, "Select Dungeon Type", message, eventDungeonSpawnMap, selectedOption)
end

function eventDungeonScreenplay:cleanUpAbandonedSetup(pPlayer, selectedOption)
	local slot = tonumber(selectedOption)
	local dungeonID = readData("eventDungeon:DungeonID:" .. slot)

	if (dungeonID ~= 0) then -- Dungeon is active
		return
	end

	deleteData("eventDungeon:Setup:" .. slot .. ":AdminID")
	deleteData("eventDungeon:DungeonID:" .. slot)
	deleteData("eventDungeon:Step:" .. slot)
end

function eventDungeonScreenplay:eventDungeonSetupMenuCallback(pPlayer, pSui, eventIndex, args)
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

	local pPageData = LuaSuiBoxPage(pSui):getSuiPageData()
	if (pPageData == nil) then
		return
	end

	local suiPageData = LuaSuiPageData(pPageData)
	local slot = suiPageData:getTargetNetworkId()

	if (slot == 0) then
		return
	end

	local selectedOption = tonumber(args) + 1

	local step = readData("eventDungeon:Step:" .. slot)

	if (step == 0) then
		return
	end

	local message

	if (step == 1) then
		self:spawnDungeon(pPlayer, slot, selectedOption)
		message = "Would you like to teleport to the dungeon " .. colorEmphasis .. eventDungeonSpawnMap[selectedOption][1] .. colorGrey .. "?"
		writeData("eventDungeon:Step:" .. slot, 2)
		self:openSetupUIWindow(pPlayer, "Teleport", message, self.confirmOptions, slot)
	elseif (step == 2) then
		writeData("eventDungeon:Step:" .. slot, 3)
		self:teleportToDungeon(pPlayer, slot, selectedOption)
		deleteData("eventDungeon:Setup:" .. slot .. ":AdminID")
	else
		return
	end
end

function eventDungeonScreenplay:openSetupUIWindow(pPlayer, title, message, options, slot)
	local sui = SuiListBox.new(self.screenplayName, "eventDungeonSetupMenuCallback")
	sui.setTargetNetworkId(slot)
	sui.setTitle(self.windowPrefix .. " " .. title)
	sui.setPrompt(colorGrey .. "" .. message)
	for i,option in pairs(options) do
		sui.add(colorGrey .. "" .. option[1], "")
	end
	sui.sendTo(pPlayer)
end

function eventDungeonScreenplay:spawnDungeon(pPlayer, slot, dungeonSelection)
	if (slot == nil or dungeonSelection == nil) then
		return
	end

	local xCord = (self.offset * slot) - 6000
	CreatureObject(pPlayer):sendSystemMessage(colorSysNotice.. "[NOTICE] " .. colorWhite .. "Spawning Dungeon " .. colorEmphasis .. eventDungeonSpawnMap[dungeonSelection][1] .. colorWhite .. " in slot " .. colorCounter .. "#" .. slot .. colorWhite .. ".")
	local pSceneObject = spawnSceneObject(self.planet, eventDungeonSpawnMap[dungeonSelection][2], xCord, 100, -6000, 0, 0)
	
	if (pSceneObject == nil) then
		return
	end

	local dungeonID = SceneObject(pSceneObject):getObjectID()

	writeData("eventDungeon:DungeonID:" .. slot, dungeonID)
	writeData("eventDungeon:DungeonIndex:" .. dungeonID, dungeonSelection)
end

function eventDungeonScreenplay:teleportToDungeon(pPlayer, slot, selectedOption)
	if (selectedOption == 2) then
		return
	end

	local dungeonID = readData("eventDungeon:DungeonID:" .. slot)
	if (dungeonID == 0) then -- remove
		deleteData("eventDungeon:DungeonID:" .. slot)
		deleteData("eventDungeon:Step:" .. slot)
		return
	end

	local pSceneObject = getSceneObject(dungeonID)
	local pCell = BuildingObject(pSceneObject):getCell(1)
	local pCellID = SceneObject(pCell):getObjectID()
	local dungeonIndex = readData("eventDungeon:DungeonIndex:" .. dungeonID)
	local entryPoint = eventDungeonSpawnMap[dungeonIndex].entryPoint

	SceneObject(pPlayer):switchZone(self.planet, entryPoint[1], entryPoint[2], entryPoint[3], pCellID)
end

function eventDungeonScreenplay:openEventDungeonManageWindow(pPlayer, selectedOption)
	local dungeonID = readData("eventDungeon:DungeonID:" .. selectedOption)
	local dungeonName = "Unknown Dungeon"
	if (dungeonID ~= 0) then
		dungeonName = eventDungeonSpawnMap[readData("eventDungeon:DungeonIndex:" .. dungeonID)][1]
	end

	local sui = SuiListBox.new(self.screenplayName, "eventDungeonManageCallback")
	sui.setTargetNetworkId(selectedOption)
	sui.setTitle(self.windowPrefix .. " Manage")
	sui.setPrompt(colorGrey .. "Manage dungeon: " .. colorEmphasis .. dungeonName .. "\n\n" .. colorGrey .. "Teleporting to a dungeon may not put you at the start of the dungeon.\n\nAlso, do not forget to block off exits or give players a way out.")
	sui.add(colorGrey .. "Teleport to Dungeon", "")
	sui.add(colorGrey .. "Destroy Dungeon", "")
	sui.showOtherButton()
	sui.setOtherButtonText("Back")
	sui.setProperty("btnRevert", "OnPress", "RevertWasPressed=1\r\nparent.btnOk.press=t")
	sui.subscribeToPropertyForEvent(SuiEventType.SET_onClosedOk, "btnRevert", "RevertWasPressed")
	sui.sendTo(pPlayer)
end

function eventDungeonScreenplay:eventDungeonManageCallback(pPlayer, pSui, eventIndex, selectedOption, otherPressed)
	if (pPlayer == nil) then
		return
	end

	local cancelPressed = (eventIndex == 1)

	if (cancelPressed) then
		return
	end

	if (otherPressed == "true") then
		self:openEventDungeonInitialWindow(pPlayer)
		return
	end

	if (selectedOption == "-1") then
		return
	end

	local pPageData = LuaSuiBoxPage(pSui):getSuiPageData()
	if (pPageData == nil) then
		return
	end

	local suiPageData = LuaSuiPageData(pPageData)
	local slot = suiPageData:getTargetNetworkId()

	if (slot == 0) then
		return
	end

	local selectedOption = tonumber(selectedOption) + 1

	if (selectedOption == 1) then
		self:teleportToDungeon(pPlayer, slot, selectedOption)
	elseif (selectedOption == 2) then
		local dungeonID = readData("eventDungeon:DungeonID:" .. slot)
		local dungeonName = "Unknown Dungeon"
		if (dungeonID ~= 0) then
			dungeonName = eventDungeonSpawnMap[readData("eventDungeon:DungeonIndex:" .. dungeonID)][1]
		end

		local sui = SuiListBox.new(self.screenplayName, "eventDungeonDestroyCallback")
		sui.setTargetNetworkId(slot)
		sui.setTitle(self.windowPrefix .. " Destroy Dungeon")
		sui.setPrompt(colorGrey .. "Are you sure you want to destroy the dungeon " .. colorEmphasis .. dungeonName .. colorGrey .. "?\n\nThere is no undo.")
		sui.add(colorRedWarn .. "Yes" .. colorGrey .. " - Destroy the dungeon", "")
		sui.add(colorGrey .. "No", "")
		sui.sendTo(pPlayer)
	end
end

function eventDungeonScreenplay:eventDungeonDestroyCallback(pPlayer, pSui, eventIndex, args)
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

	local pPageData = LuaSuiBoxPage(pSui):getSuiPageData()
	if (pPageData == nil) then
		return
	end

	local suiPageData = LuaSuiPageData(pPageData)
	local slot = suiPageData:getTargetNetworkId()

	if (slot == 0) then
		return
	end

	local selectedOption = tonumber(args) + 1

	if (selectedOption == 1) then
		local dungeonID = readData("eventDungeon:DungeonID:" .. slot)
		if (dungeonID ~= 0) then
			local pDungeon = getSceneObject(dungeonID)
			local cellTotal = BuildingObject(pDungeon):getTotalCellNumber()

			for i = 1, cellTotal, 1 do
				local pCell = BuildingObject(pDungeon):getCell(i)

				if (pCell ~= nil) then
					for j = SceneObject(pCell):getContainerObjectsSize() - 1, 0, -1 do
						local pObject = SceneObject(pCell):getContainerObject(j)

						if pObject ~= nil and not SceneObject(pObject):isPlayerCreature() and SceneObject(pObject):isAiAgent() then
							if (SceneObject(pObject):isCreatureObject()) then
								CreatureObject(pObject):setPvpStatusBitmask(0)
								forcePeace(pObject)
								createEvent(3000, self.screenplayName, "removeObject", pObject, "")
							else
								createEvent(3000, self.screenplayName, "removeObject", pObject, "")
							end
						elseif (SceneObject(pObject):isPlayerCreature()) then
							SceneObject(pObject):switchZone("naboo", -4870, 0, 4147, 0)
						end
					end
				end
			end
			createEvent(6000, self.screenplayName, "removeObject", pDungeon, "")
			local dungeonIndex = readData("eventDungeon:DungeonIndex:" .. dungeonID)
			CreatureObject(pPlayer):sendSystemMessage(colorSysNotice.. "[NOTICE] " .. colorWhite .. "Dungeon " .. colorEmphasis .. eventDungeonSpawnMap[dungeonIndex][1] .. colorWhite .. " Destroyed in slot " .. colorCounter .. "#" .. slot .. colorWhite .. ".")
			deleteData("eventDungeon:DungeonIndex:" .. dungeonID)
			deleteData("eventDungeon:DungeonID:" .. slot)
			deleteData("eventDungeon:Step:" .. slot)
		end
	elseif (selectedOption == 2) then
		self:openEventDungeonManageWindow(pPlayer, slot)
		return
	end
end

function eventDungeonScreenplay:removeObject(pObject)
	if (pObject) == nil then return end
	SceneObject(pObject):destroyObjectFromWorld()
end