--[[
	Developed by Tyclo (https://github.com/Sphazz): 2020 07-31
	Staff Levels:
		15 = admin
		14 = dev
		13 = cc
		12 = csr
		11 = ec
		10 = eci
		9 = csi
		8 = ct
		7 = qa
]]

gmToolsCommandScreenplay = ScreenPlay:new {
	scriptName = "gmToolsCommandScreenplay",
}

registerScreenPlay("gmToolsCommandScreenplay", false)

function gmToolsCommandScreenplay:openStaffWindow(pPlayer)
	self:openSubWindow(pPlayer, gmToolsMenuOptions.staff)
end

function gmToolsCommandScreenplay:openEventWindow(pPlayer)
	self:openSubWindow(pPlayer,  gmToolsMenuOptions.event)
end

function gmToolsCommandScreenplay:openDevWindow(pPlayer)
	self:openSubWindow(pPlayer,  gmToolsMenuOptions.dev)
end

function gmToolsCommandScreenplay:staffWindowCallback(pPlayer, pSui, eventIndex, args)
	self:subWindowCallback(pPlayer, pSui, eventIndex, args, gmToolsMenuOptions.staff)
end

function gmToolsCommandScreenplay:eventWindowCallback(pPlayer, pSui, eventIndex, args)
	self:subWindowCallback(pPlayer, pSui, eventIndex, args,  gmToolsMenuOptions.event)
end

function gmToolsCommandScreenplay:devWindowCallback(pPlayer, pSui, eventIndex, args)
	self:subWindowCallback(pPlayer, pSui, eventIndex, args,  gmToolsMenuOptions.dev)
end

function gmToolsCommandScreenplay:gmToolsSyntax(pPlayer)
	CreatureObject(pPlayer):sendSystemMessage("Command Syntax: \n" .. self:getCommandSyntax(pPlayer))
end

-- Sui Windows

function gmToolsCommandScreenplay:openDefaultWindow(pPlayer)
	local sui = SuiListBox.new("gmToolsCommandScreenplay", "defaultCallback")
	if (pPlayer == nil) then
		sui.setTargetNetworkId(0)
	else
		sui.setTargetNetworkId(SceneObject(pPlayer):getObjectID())
	end

	local playerLevel = getAdminLevel(pPlayer)
	if (playerLevel < 7) then
		CreatureObject(pPlayer):sendSystemMessage("\\#f6d53b[GmToolsCommand]\\#ffffff You lack the permissions to use this command.")
		return
	end

	sui.setTitle("Game Management Tools")
	local message = "Command Syntax:\n" .. self:getCommandSyntax(pPlayer)
	sui.setPrompt(message)

	-- Put into integer table, then sort alphabetically. 
	-- The order of pairs() is arbitary, cannot use ipairs() with table of objects
	local sortedOptions = {}
	
	for k,v in pairs(gmToolsMenuOptions) do
		table.insert(sortedOptions, k)
	end

	table.sort(sortedOptions)

	for k,v in ipairs(sortedOptions) do
		sui.add(gmToolsMenuOptions[v].name, gmToolsMenuOptions[v].func)
	end

	sui.add("Help", "gmToolsSyntax")

	sui.sendTo(pPlayer)
end

function gmToolsCommandScreenplay:openSubWindow(pPlayer, selectedOption)
	local sui = SuiListBox.new("gmToolsCommandScreenplay", selectedOption.callback)
	if (pPlayer == nil) then
		sui.setTargetNetworkId(0)
	else
		sui.setTargetNetworkId(SceneObject(pPlayer):getObjectID())
	end

	if (not self:isPermitted(pPlayer, selectedOption.perms)) then
		CreatureObject(pPlayer):sendSystemMessage(" \\#f6d53b[GmToolsCommand]\\#ffffff You lack the permissions to use this function.")
		return
	end

	sui.setTitle(selectedOption.name)
	sui.setPrompt(selectedOption.desc)

	local sortedOptions = {}
	
	for k,v in pairs(selectedOption.options) do
		table.insert(sortedOptions, k)
	end

	table.sort(sortedOptions)
	
	for k,v in ipairs(sortedOptions) do
		sui.add(selectedOption.options[v].name, v)
	end
	sui.sendTo(pPlayer)
end

-- Callbacks

function gmToolsCommandScreenplay:defaultCallback(pPlayer, pSui, eventIndex, args)
	local cancelPressed = (eventIndex == 1)

	if (cancelPressed or args == nil or tonumber(args) < 0) then
		return
	end

	local pPageData = LuaSuiBoxPage(pSui):getSuiPageData()

	if (pPageData == nil) then
		return
	end

	local suiPageData = LuaSuiPageData(pPageData)
	local menuOption = suiPageData:getStoredData(tostring(args))

	createEvent(10, self.scriptName, menuOption, pPlayer, 0)
end

function gmToolsCommandScreenplay:subWindowCallback(pPlayer, pSui, eventIndex, args, selectedOption)
	local cancelPressed = (eventIndex == 1)

	if (cancelPressed or args == nil or tonumber(args) < 0) then
		return
	end

	local pPageData = LuaSuiBoxPage(pSui):getSuiPageData()

	if (pPageData == nil) then
		return
	end

	local suiPageData = LuaSuiPageData(pPageData)
	local menuOption = suiPageData:getStoredData(tostring(args))

	if (not self:isPermitted(pPlayer, selectedOption.options[menuOption].perms)) then
		CreatureObject(pPlayer):sendSystemMessage(" \\#f6d53b[GmToolsCommand]\\#ffffff You lack the permissions to use this function.")
		return
	end

	createEvent(10, selectedOption.options[menuOption].screen, selectedOption.options[menuOption].func, pPlayer, 0)
end

-- Check permissions
function gmToolsCommandScreenplay:isPermitted(pPlayer, perms)
	local playerLevel = getAdminLevel(pPlayer)

	for k,permLevel in ipairs(perms) do
		if (permLevel ~= 0 and permLevel == playerLevel) then
			return true
		end
	end

	return false
end

-- Help syntax function
function gmToolsCommandScreenplay:getCommandSyntax(pPlayer)
	local syntax = ""

	local sortedOptions = {}
	local sortedSubOptions = {}
	
	for k,v in pairs(gmToolsMenuOptions) do
		table.insert(sortedOptions, k)
	end

	table.sort(sortedOptions)
	
	for k,v in ipairs(sortedOptions) do
		syntax = syntax .. "/gmTools -" .. v .. "\n"

		for k,v in pairs(gmToolsMenuOptions[v].options) do
			table.insert(sortedSubOptions, k)
		end

		table.sort(sortedSubOptions)

		for ko,vo in ipairs(sortedSubOptions) do
			syntax = syntax .. "/gmTools -" .. v .. " " .. vo .. "\n"
		end

		syntax = syntax .. "\n"
		sortedSubOptions = {}
	end

	return syntax
end