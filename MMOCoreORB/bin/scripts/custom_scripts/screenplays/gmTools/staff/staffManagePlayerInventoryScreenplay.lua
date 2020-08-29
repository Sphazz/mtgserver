-- Written by Tyclo | 2020-08-23
-- https://github.com/Sphazz
--[[
	Give credit to all assets and custom content in your repo and files or don't use this.
	Pretending to be ignorant doesn't count.
]]
staffManagePlayerInventoryScreenplay = ScreenPlay:new {
	screenplayName = "staffManagePlayerInventoryScreenplay",
	maxChar = 120,
	windowPrefix = "[Manage Inventory]",
	givePrefix = "[Give Item]",
	retrievePrefix = "[Retrieve Item]",
}
registerScreenPlay("staffManagePlayerInventoryScreenplay", false)


function staffManagePlayerInventoryScreenplay:openManageInventoryWindow(pPlayer)
	local sui = SuiListBox.new(self.screenplayName, "manageInventoryCallback")
	if (pPlayer == nil) then
		sui.setTargetNetworkId(0)
	else
		sui.setTargetNetworkId(SceneObject(pPlayer):getObjectID())
	end
	sui.setTitle(self.windowPrefix .. " Select Option")
	sui.setPrompt(colorGrey .. "Select an option.\n\nAfter" .. colorImportant .. " Giving" .. colorGrey .. " or " .. colorTealCnf .. "Retrieving" .. colorGrey .. " an item, close and open your inventory if you are out of range of your target to see the transfer.")

	sui.add(colorImportant .. "[Give]\t\t" .. colorGrey .. "Item to Player", "")
	sui.add(colorTealCnf .. "[Retrieve]\t" .. colorGrey .. "Item from Player", "")
	sui.setOkButtonText("Next")
	sui.sendTo(pPlayer)
end

function staffManagePlayerInventoryScreenplay:manageInventoryCallback(pPlayer, pSui, eventIndex, args)
	local cancelPressed = (eventIndex == 1)

	if (cancelPressed or pPlayer == nil) then return end

	if (args == nil or args == "-1") then 
		CreatureObject(pPlayer):sendSystemMessage(colorSysWarning .. "[WARNING] " .. colorWhite .. "Please select an option from the list.")
		self:openManageInventoryWindow(pPlayer)
		return
	end

	local selectedOption = tonumber(args) + 1

	if (selectedOption == 1) then
		self:openGiveItemWindow(pPlayer)
	elseif (selectedOption == 2) then
		self:openRetrieveItemWindow(pPlayer)
	end
end

function staffManagePlayerInventoryScreenplay:openGiveItemWindow(pPlayer)
	local sui = SuiListBox.new(self.screenplayName, "listAdminItemsCallback")
	sui.setTargetNetworkId(0)
	sui.setTitle(self.givePrefix .. " Your Inventory")
	local message = "Select an item from your inventory to " .. colorImportant .. "give" .. colorGrey .. " to a player."
	sui.setPrompt(colorGrey .. " " .. message)

	local pInventory = CreatureObject(pPlayer):getSlottedObject("inventory")
	if (pInventory == nil) then
		return
	end

	for i = 0, SceneObject(pInventory):getContainerObjectsSize() - 1, 1 do
		local pObject = SceneObject(pInventory):getContainerObject(i)
		if (pObject ~= nil) then
			local tano = TangibleObject(pObject)
			local option = colorGrey .. self:getObjectName(pObject)
			if (SceneObject(pObject):getContainerObjectsSize() > 0) then
				option = option .. " - " .. colorSlate .. "Items: " .. colorCounter .. math.floor(SceneObject(pObject):getContainerObjectsSize()) .. colorWhite .. " -"
			end
			if (tano:isNoTrade()) then
				option = option .. colorRedWarn .. " (No Trade)"
			end
			option = option .. colorCounter .. " (" .. SceneObject(pObject):getObjectID() .. ")"
			sui.add(option, SceneObject(pObject):getObjectID())
		end
	end

	sui.setOkButtonText("Next")
	sui.sendTo(pPlayer)
end

function staffManagePlayerInventoryScreenplay:listAdminItemsCallback(pPlayer, pSui, eventIndex, args)
	local cancelPressed = (eventIndex == 1)

	if (cancelPressed or pPlayer == nil or args == nil) then return end

	local pPageData = LuaSuiBoxPage(pSui):getSuiPageData()

	if (pPageData == nil) then return end

	local suiPageData = LuaSuiPageData(pPageData)
	local objectID = suiPageData:getStoredData(tostring(args))

	if (objectID == nil or objectID == "" or objectID == 0) then
		CreatureObject(pPlayer):sendSystemMessage(colorSysWarning .. "[WARNING] " .. colorWhite .. "Please select an item from the list.")
		self:openGiveItemWindow(pPlayer)
	else
		self:enterTargetPlayerNameSui(pPlayer, objectID)
	end
end

function staffManagePlayerInventoryScreenplay:enterTargetPlayerNameSui(pPlayer, objectID)
	local sui = SuiInputBox.new("staffManagePlayerInventoryScreenplay", "enterTargetPlayerNameCallback")
	sui.setTargetNetworkId(objectID)

	sui.setTitle(self.givePrefix .. " Enter Player Target's Name")

	local pObject = getSceneObject(objectID)
	local tano = TangibleObject(pObject)

	local objectName = colorMobile .. self:getObjectName(pObject)
	if (tano:isNoTrade()) then
		objectName = objectName .. colorRedWarn .. " (No Trade)"
	end
	objectName = objectName .. colorCounter .. " (" .. SceneObject(pObject):getObjectID() .. ")"

	local suiBody = colorGrey .. "Enter a name for the player you would like to " .. colorImportant .. "give" .. colorGrey .. " the item " .. objectName  
	if (SceneObject(pObject):getContainerObjectsSize() > 0) then
		suiBody = suiBody .. colorGrey .. " containing " .. colorCounter .. math.floor(SceneObject(pObject):getContainerObjectsSize()) .. colorGrey .. " items"
	end
	suiBody = suiBody .. colorGrey .. " to."
	sui.setPrompt(suiBody)
	sui.setOkButtonText("Give Item")

	sui.sendTo(pPlayer)
end

function staffManagePlayerInventoryScreenplay:enterTargetPlayerNameCallback(pPlayer, pSui, eventIndex, args)
	local cancelPressed = (eventIndex == 1)

	if (cancelPressed or pPlayer == nil) then return end

	local pPageData = LuaSuiBoxPage(pSui):getSuiPageData()

	if (pPageData == nil) then return end

	local suiPageData = LuaSuiPageData(pPageData)
	local objectID = suiPageData:getTargetNetworkId()

	if (args == nil or args == "") then
		CreatureObject(pPlayer):sendSystemMessage(colorSysWarning .. "[WARNING] " .. colorWhite .. " Please enter a player name.")
		self:enterTargetPlayerNameSui(pPlayer, objectID)
		return
	end

	local pTarget = getPlayerByName(args)

	if (pTarget == nil) then
		CreatureObject(pPlayer):sendSystemMessage(colorSysWarning .. "[WARNING] " .. colorWhite .. " A player with the name " .. colorMobile .. args .. colorWhite .. " could not be found.")
		self:enterTargetPlayerNameSui(pPlayer, objectID)
		return
	end

	local pObject = getSceneObject(objectID)
	if (pObject == nil) then return	end

	local pTargetInventory = CreatureObject(pTarget):getSlottedObject("inventory")
	if (pTargetInventory == nil) then return end

	local pPlayerInventory = CreatureObject(pPlayer):getSlottedObject("inventory")
	if (pPlayerInventory == nil) then return end

	SceneObject(pTargetInventory):transferObject(pObject, -1, true)
	SceneObject(pTargetInventory):broadcastObject(pObject, true)
	SceneObject(pPlayerInventory):broadcastObject(pObject, true)
end

function staffManagePlayerInventoryScreenplay:openRetrieveItemWindow(pPlayer)
	local sui = SuiInputBox.new("staffManagePlayerInventoryScreenplay", "enterRetrievePlayerNameCallback")

	sui.setTitle(self.retrievePrefix .. " Enter Player Target's Name")

	local suiBody = colorGrey .. "Enter a name for the player you would like to " .. colorTealCnf .. "retrieve" .. colorGrey .. " an item from."  
	sui.setPrompt(suiBody)
	sui.setOkButtonText("Next")

	sui.sendTo(pPlayer)
end

function staffManagePlayerInventoryScreenplay:enterRetrievePlayerNameCallback(pPlayer, pSui, eventIndex, args)
	local cancelPressed = (eventIndex == 1)

	if (cancelPressed or pPlayer == nil) then return end

	if (args == nil or args == "") then
		CreatureObject(pPlayer):sendSystemMessage(colorSysWarning .. "[WARNING] " .. colorWhite .. " Please enter a player name.")
		self:openRetrieveItemWindow(pPlayer)
		return
	end
	
	local pTarget = getPlayerByName(args)

	if (pTarget == nil) then
		CreatureObject(pPlayer):sendSystemMessage(colorSysWarning .. "[WARNING] " .. colorWhite .. " A player with the name " .. colorMobile .. args .. colorWhite .. " could not be found.")
		self:openRetrieveItemWindow(pPlayer)
		return
	end

	local targetsName = CreatureObject(pTarget):getFirstName()

	local sui = SuiListBox.new(self.screenplayName, "retrieveItemCallback")

	sui.setTargetNetworkId(SceneObject(pTarget):getObjectID())
	sui.setTitle(self.retrievePrefix .. " " .. targetsName .. "'s Inventory")
	local message = "Select an item from " .. colorMobile .. targetsName .. colorGrey .. "'s inventory to retrieve."
	sui.setPrompt(colorGrey .. " " .. message)

	local pInventory = CreatureObject(pTarget):getSlottedObject("inventory")
	if (pInventory == nil) then
		return
	end

	for i = 0, SceneObject(pInventory):getContainerObjectsSize() - 1, 1 do
		local pObject = SceneObject(pInventory):getContainerObject(i)
		if (pObject ~= nil) then
			local tano = TangibleObject(pObject)
			local option = colorGrey .. self:getObjectName(pObject) 
			if (SceneObject(pObject):getContainerObjectsSize() > 0) then
				option = option .. " - " .. colorSlate .. "Items: " .. colorCounter .. math.floor(SceneObject(pObject):getContainerObjectsSize()) .. colorWhite .. " -"
			end
			if (tano:isNoTrade()) then
				option = option .. colorRedWarn .. " (No Trade)"
			end
			option = option .. colorCounter .. " (" .. SceneObject(pObject):getObjectID() .. ")"
			sui.add(option, SceneObject(pObject):getObjectID())
		end
	end

	sui.setOkButtonText("Retrieve Item")
	sui.sendTo(pPlayer)
end

function staffManagePlayerInventoryScreenplay:retrieveItemCallback(pPlayer, pSui, eventIndex, args)
	local cancelPressed = (eventIndex == 1)

	if (cancelPressed or pPlayer == nil) then return end

	local pPageData = LuaSuiBoxPage(pSui):getSuiPageData()
	if (pPageData == nil) then return end

	local suiPageData = LuaSuiPageData(pPageData)

	if (targetID == 0 or objectID == 0) then return end
	local targetID = suiPageData:getTargetNetworkId()

	local pTarget = getCreatureObject(targetID)
	if (pTarget == nil) then return	end

	if (args == nil or args == "-1") then
		CreatureObject(pPlayer):sendSystemMessage(colorSysWarning .. "[WARNING] " .. colorWhite .. " No item selected.")
		self:enterRetrievePlayerNameCallback(pPlayer, pSui, 0, CreatureObject(pTarget):getFirstName())
		return
	end

	local objectID = suiPageData:getStoredData(tostring(args))
	if (objectID == 0) then return end

	local pObject = getSceneObject(objectID)
	if (pObject == nil) then return	end

	if (SceneObject(pObject):getContainerObjectsSize() > 0) then
		self:openContainerContentsWindow(pPlayer, pObject, pTarget)
	else
		self:retrieveItemFromTarget(pPlayer, pObject, pTarget)
	end
end

function staffManagePlayerInventoryScreenplay:retrieveItemFromTarget(pPlayer, pObject, pTarget)
	local pPlayerInventory = CreatureObject(pPlayer):getSlottedObject("inventory")
	if (pPlayerInventory == nil) then return end

	local pTargetInventory = CreatureObject(pTarget):getSlottedObject("inventory")
	if (pTargetInventory == nil) then return end
	
	SceneObject(pPlayerInventory):transferObject(pObject, -1, true)
	SceneObject(pPlayerInventory):broadcastObject(pObject, true)
	SceneObject(pTargetInventory):broadcastObject(pObject, true)
end

function staffManagePlayerInventoryScreenplay:openContainerContentsWindow(pPlayer, pContainer, pTarget)
	local targetsName = CreatureObject(pTarget):getFirstName()

	local sui = SuiListBox.new(self.screenplayName, "retrieveContainerCallback")

	sui.setTargetNetworkId(SceneObject(pTarget):getObjectID())
	sui.setTitle(self.retrievePrefix .. " " .. targetsName .. "'s Inventory")
	local message = "Select an item from " .. colorMobile .. targetsName .. "'s " .. colorEmphasis .. self:getObjectName(pContainer) .. colorGrey .. " to retrieve or retrieve the container itself."
	sui.setPrompt(colorGrey .. " " .. message)

	for i = 0, SceneObject(pContainer):getContainerObjectsSize() - 1, 1 do
		local pObject = SceneObject(pContainer):getContainerObject(i)
		if (pObject ~= nil) then
			local tano = TangibleObject(pObject)
			local option = colorGrey .. self:getObjectName(pObject) 
			if (SceneObject(pObject):getContainerObjectsSize() > 0) then
				option = option .. " - " .. colorSlate .. "Items: " .. colorCounter .. math.floor(SceneObject(pObject):getContainerObjectsSize()) .. colorWhite .. " -"
			end
			if (tano:isNoTrade()) then
				option = option .. colorRedWarn .. " (No Trade)"
			end
			option = option .. colorCounter .. " (" .. SceneObject(pObject):getObjectID() .. ")"
			sui.add(option, SceneObject(pObject):getObjectID())
		end
	end

	sui.setStoredData("containerID", SceneObject(pContainer):getObjectID())
	sui.showOtherButton()
	sui.setOtherButtonText("Retrieve Container")
	sui.setOkButtonText("Retrieve Item")
	sui.setProperty("btnRevert", "OnPress", "RevertWasPressed=1\r\nparent.btnOk.press=t")
	sui.sendTo(pPlayer)
end

function staffManagePlayerInventoryScreenplay:retrieveContainerCallback(pPlayer, pSui, eventIndex, args, otherPressed)
	local cancelPressed = (eventIndex == 1)

	if (cancelPressed or pPlayer == nil) then return end

	local pPageData = LuaSuiBoxPage(pSui):getSuiPageData()
	if (pPageData == nil) then return end

	local suiPageData = LuaSuiPageData(pPageData)
	local containerID = suiPageData:getStoredData("containerID")
	local targetID = suiPageData:getTargetNetworkId()

	if (containerID == 0) then return end

	local pContainer = getSceneObject(containerID)
	if (pContainer == nil) then return	end

	if (targetID == 0) then return end

	local pTarget = getCreatureObject(targetID)
	if (pTarget == nil) then return	end

	if (otherPressed == "true") then
		self:retrieveItemFromTarget(pPlayer, pContainer, pTarget)
		return
	end

	if (args == nil or args == "-1") then
		CreatureObject(pPlayer):sendSystemMessage(colorSysWarning .. "[WARNING] " .. colorWhite .. " No item selected.")
		self:openContainerContentsWindow(pPlayer, pContainer, pTarget)
		return
	end

	local objectID = suiPageData:getStoredData(tostring(args))

	if (objectID == 0) then return end

	local pObject = getSceneObject(objectID)
	if (pObject == nil) then return	end

	if (SceneObject(pObject):getContainerObjectsSize() > 0) then
		self:openContainerContentsWindow(pPlayer, pObject, pTarget)
	else
		self:retrieveItemFromTarget(pPlayer, pObject, pTarget)
	end
end


function staffManagePlayerInventoryScreenplay:getObjectName(pObject)
	local objectName = SceneObject(pObject):getDisplayedName()

	if (objectName == nil or objectName == "") then
		objectName = SceneObject(pObject):getCustomObjectName()
	end

	if (objectName == nil or objectName == "") then
		objectName = SceneObject(pObject):getObjectName()
	end

	return objectName
end
