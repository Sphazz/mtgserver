staffRenameScreenplay = ScreenPlay:new {
	screenplayName = "staffRenameScreenplay",
	maxChar = 120,
	windowPrefix = "[Rename Target]",
}
registerScreenPlay("staffRenameScreenplay", false)

function staffRenameScreenplay:openRenameObjectWindow(pPlayer)
	local targetID = CreatureObject(pPlayer):getTargetID()
	if (not self:validateTargetID(pPlayer, targetID)) then return end

	local pTarget = self:validateTargetObject(pPlayer, targetID)
	if (pTarget == false) then return end
	
	local sui = SuiInputBox.new("staffRenameScreenplay", "renameObjectMenuCallback")
	sui.setTargetNetworkId(targetID)

	sui.setTitle(self.windowPrefix .. " Enter Name")

	local suiBody = colorGrey .. "Enter a new name for " .. colorMobile .. self:getObjectName(pTarget) .. colorGrey .. ".\n\nNew names cannot be longer than " .. colorCounter .. self.maxChar .. colorGrey .. " characters.\n\nLeaving the text field " .. colorEmphasis .. "empty " .. colorGrey .. "and selecting OK will reset the name of the object back to default."  
	sui.setPrompt(suiBody)

	sui.sendTo(pPlayer)
end

function staffRenameScreenplay:renameObjectMenuCallback(pPlayer, pSui, eventIndex, args)
	local cancelPressed = (eventIndex == 1)

	if (cancelPressed) then
		return
	end

	if (args == "-1" or args == nil) then
		return
	end

	if (string.len(args) > 120) then
		CreatureObject(pPlayer):sendSystemMessage(colorSysAttention .. "[FAILED] " .. colorWhite .. "Error renaming object, name is too long. (" .. colorCounter ..  self.maxChar .. colorWhite ..  " max limit)")
		self:openRenameObjectWindow(pPlayer)
		return
	end

	local pPageData = LuaSuiBoxPage(pSui):getSuiPageData()

	if (pPageData == nil) then
		return
	end

	local suiPageData = LuaSuiPageData(pPageData)

	local targetID = suiPageData:getTargetNetworkId()

	local pTarget = self:validateTargetObject(pPlayer, targetID)
	if (pTarget == false) then return end

	local oldName = self:getObjectName(pTarget)

	SceneObject(getSceneObject(targetID)):setCustomObjectName(args)

	logAdminMessage(pPlayer, "(" .. CreatureObject(pPlayer):getTargetID() .. ") used 'renameTarget' on " .. oldName .. " (" .. targetID .. ") to '" .. args .. "'")
end

function staffRenameScreenplay:getObjectName(pTarget)
	local objectName = SceneObject(pTarget):getDisplayedName()

	if (objectName == nil or objectName == "") then
		objectName = SceneObject(pTarget):getCustomObjectName()
	end

	if (objectName == nil or objectName == "") then
		objectName = SceneObject(pTarget):getObjectName()
	end

	return objectName
end

function staffRenameScreenplay:validateTargetID(pPlayer, targetID)
	if (targetID == 0) then
		CreatureObject(pPlayer):sendSystemMessage(colorSysAttention .. "[FAILED] " .. colorWhite .. "Please select a target.")
		return false
	end

	return true
end

function staffRenameScreenplay:validateTargetObject(pPlayer, targetID)
	local pTarget = getSceneObject(targetID)

	if (pTarget == nil or SceneObject(pTarget):isPlayerCreature()) then
		CreatureObject(pPlayer):sendSystemMessage(colorSysAttention .. "[FAILED] " .. colorWhite .. "That is not a valid target to rename.")
		return false
	end

	return pTarget
end