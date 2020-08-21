--Conversation handler
eventShuttleNeutralConvoHandler = Object:new {}

function eventShuttleNeutralConvoHandler:getNextConversationScreen(conversationTemplate, conversingPlayer, selectedOption)
	local pPlayer = LuaCreatureObject(conversingPlayer)
	local pGhost = CreatureObject(conversingPlayer):getPlayerObject()
	local credits = pPlayer:getCashCredits()
	local convosession = CreatureObject(conversingPlayer):getConversationSession()
	local lastConversationScreen = nil
	local conversation = LuaConversationTemplate(conversationTemplate)
	local nextConversationScreen

	if (conversation ~= nil) then
		if (convosession ~= nil) then
			local session = LuaConversationSession(convosession)
			if (session ~= nil) then
				lastConversationScreen = session:getLastConversationScreen()
			end
		end

		if (lastConversationScreen == nil) then
			nextConversationScreen = conversation:getInitialScreen()
		else
			local luaLastConversationScreen = LuaConversationScreen(lastConversationScreen)
			local optionLink = luaLastConversationScreen:getOptionLink(selectedOption)
			nextConversationScreen = conversation:getScreen(optionLink)
		end
	end
	return nextConversationScreen
end

function eventShuttleNeutralConvoHandler:runScreenHandlers(pConversationTemplate, pConversingPlayer, pConversingNpc, selectedOption, pConversationScreen)
  local screen = LuaConversationScreen(pConversationScreen)
  local screenID = screen:getScreenID()
  local player = LuaSceneObject(pConversingPlayer)

  if (screenID == "teleport") then
	local pConversingNpcID = CreatureObject(pConversingNpc):getObjectID()
	local destinationLocation = readStringData("eventTeleportNpc:Destination:" .. pConversingNpcID)

	if (destinationLocation == nil) then
		return
	end

	local destination = HelperFuncs:splitString(destinationLocation, ",")

	if (destination == nil) then
		return
	end

	if (tonumber(destination[6]) ~= 0) then
		local pCell = getSceneObject(destination[6])
		if (pCell ~= nil) then
			local pParent = SceneObject(pCell):getParent()
			player:switchZone(destination[1], destination[2], destination[3], destination[4], destination[6]) -- planet, x, z, y, cell
		else
			CreatureObject(pConversingPlayer):sendSystemMessage("The location you were attempting to reach is no longer available.")
		end
	else
		player:switchZone(destination[1], destination[2], destination[3], destination[4], destination[6]) -- planet, x, z, y, cell
	end
  end

  return pConversationScreen
end