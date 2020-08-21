-- Written by Tyclo | 2019 / 05 / 10
-- https://github.com/Sphazz
--[[
	Give credit to all assets and custom content in your repo and files or don't use this.
	Pretending to be ignorant doesn't count.
]]

eventShuttleNeutralConvoTemplate = ConvoTemplate:new {
	initialScreen = "init",
	templateType = "Lua",
	luaClassHandler = "eventShuttleNeutralConvoHandler",
	screens = {}
}

--Intro First
eventShuttleNeutral_initial = ConvoScreen:new {
	id = "init",
	leftDialog = "",
	customDialogText = "Looking for a ride?\n\nWhere are we going? No idea. I've been chartered for an event. I don't get paid to ask questions, only fly.\n\nSo what will it be?",
	stopConversation = "false",
	options = {
		{"Let's go!", "teleport"},
		{"I think I'll pass...", "deny"}
	}
}
eventShuttleNeutralConvoTemplate:addScreen(eventShuttleNeutral_initial);

--teleport
eventShuttleNeutral_teleport = ConvoScreen:new {
	id = "teleport",
	leftDialog = "",
	customDialogText = "Fine choice.",
	stopConversation = "true",
	options = {}
}
eventShuttleNeutralConvoTemplate:addScreen(eventShuttleNeutral_teleport);

--deny
eventShuttleNeutral_deny = ConvoScreen:new {
	id = "deny",
	leftDialog = "",
	customDialogText = "Your loss...",
	stopConversation = "true",
	options = {}
}
eventShuttleNeutralConvoTemplate:addScreen(eventShuttleNeutral_deny);

addConversationTemplate("eventShuttleNeutralConvoTemplate", eventShuttleNeutralConvoTemplate);
