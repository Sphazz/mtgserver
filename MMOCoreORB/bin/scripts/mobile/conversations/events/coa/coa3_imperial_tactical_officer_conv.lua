coa3ImperialTacticalOfficerConvoTemplate = ConvoTemplate:new {
	initialScreen = "",
	templateType = "Lua",
	luaClassHandler = "coa3ImperialTacticalOfficerConvoHandler",
	screens = {}
}

init_default = ConvoScreen:new {
	id = "init_default",
	leftDialog = "@conversation/coa3ltactofficer:s_f64d217f", -- I'm sorry I can't talk right now. I'm very busy. This Dead Eye situation is getting out of control and I have my hands full. Rather then chit-chatting, how about you lend a hand already? Go and talk to the coordinator and make yourself useful.
	stopConversation = "true",
	options = {}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(init_default);

init_has_main_mission = ConvoScreen:new {
	id = "init_has_main_mission",
	leftDialog = "@conversation/coa3ltactofficer:s_3c57b03", -- Why haven't you destroyed that warehouse? Is something the matter?
	stopConversation = "false",
	options = {
		{"@conversation/coa3ltactofficer:s_ba1a3080", "work_to_be_done"}, -- Nothing's wrong, never mind.
		{"@conversation/coa3ltactofficer:s_8d1b9304", "maybe_took_care"}, -- I wasn't able to find the warehouse.
		{"@conversation/coa3ltactofficer:s_2e791c9d", "moisture_farmer"}, -- I can't complete this mission.
	}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(init_has_main_mission);

moisture_farmer = ConvoScreen:new {
	id = "moisture_farmer",
	leftDialog = "@conversation/coa3ltactofficer:s_6a582260", -- Are you a moisture farmer or something? I guess we all can't be soldiers. Well I appreciate the offer of help anyway. If you want to try it again later, come back and let me know.
	stopConversation = "true",
	options = {}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(moisture_farmer);

work_to_be_done = ConvoScreen:new {
	id = "work_to_be_done",
	leftDialog = "@conversation/coa3ltactofficer:s_e40779f7", -- Well quit standing around! There's work to be done!
	stopConversation = "true",
	options = {}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(work_to_be_done);

init_sent_by_coordinator = ConvoScreen:new {
	id = "init_sent_by_coordinator",
	leftDialog = "@conversation/coa3ltactofficer:s_1c693828", -- I hear that you've been working with the coordinator lately to try to put a stop to this whole Dead Eye thing. Good for you! Another way we can hamper the production of Dead Eye is by attacking their store houses directly. The more Alderaanian Flora we can keep out of their hands, the better. Would you be willing to help us out in this matter?
	stopConversation = "false",
	options = {
		{"@conversation/coa3ltactofficer:s_f96e5eed", "jabba_warehouses"}, -- I'd be happy to help.
		{"@conversation/coa3ltactofficer:s_e4daff30", "stomach_for_it"}, -- I'm not going to be able to help you right now.
	}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(init_sent_by_coordinator);

jabba_warehouses = ConvoScreen:new {
	id = "jabba_warehouses",
	leftDialog = "@conversation/coa3ltactofficer:s_1b5eac32", -- Good! Jabba has warehouses of that flora all over the Galaxy. As we find them, we are sending volunteers out to destroy them and confiscate the flora. I've added a waypoint to your datapad for a warehouse we've located close by. Go destroy it and confiscate any flora you find. I'll reward you for any Alderaanian Flora that you turn in.
	stopConversation = "true",
	options = {}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(jabba_warehouses);

stomach_for_it = ConvoScreen:new {
	id = "stomach_for_it",
	leftDialog = "@conversation/coa3ltactofficer:s_83258fb0", -- What? Don't have the stomach for it? Come back when you've had a chance to settle your nerves.
	stopConversation = "true",
	options = {}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(stomach_for_it);

init_completed_flora = ConvoScreen:new {
	id = "init_completed_flora",
	leftDialog = "@conversation/coa3ltactofficer:s_2c01da39", -- If you haven't completed the Coordinator's tasks, you should return to him. If you have, we know of more warehouses you can assault. Either way, you can hand me any Alderaanian Flora you have and I will happily reward you for it.
	stopConversation = "false",
	options = {
		{"@conversation/coa3ltactofficer:s_1cb2157b", "go_destroy_warehouse"}, -- I'm ready to take out another warehouse
		{"@conversation/coa3ltactofficer:s_4e9f338", "come_back_any_time"}, -- I need to take care of other things right now.
	}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(init_completed_flora);

go_destroy_warehouse = ConvoScreen:new {
	id = "go_destroy_warehouse",
	leftDialog = "@conversation/coa3ltactofficer:s_ed0f23a8", -- Excellent! I've uploaded another waypoint to your datapad. Go destroy the warehouse and collect the flora.
	stopConversation = "true",
	options = {}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(go_destroy_warehouse);

come_back_any_time = ConvoScreen:new {
	id = "come_back_any_time",
	leftDialog = "@conversation/coa3ltactofficer:s_18c581cc", -- Ok, suit yourself then. Come back any time you feel like helping me get rid of these stores of Alderaanian Flora.
	stopConversation = "true",
	options = {}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(come_back_any_time);

init_completed_everything = ConvoScreen:new {
	id = "init_completed_main",
	leftDialog = "@conversation/coa3ltactofficer:s_958a6a44", -- You've been a real hero lately, people have been buzzing about your work. If you're looking for something to do, there's plenty more warehouses to take care of! And I'm still offering a reward for turning in any Alderaanian Flora you come across.
	stopConversation = "false",
	options = {
		{"@conversation/coa3ltactofficer:s_1cb2157b", "go_get_it"}, -- I'm ready to take out another warehouse
		{"@conversation/coa3ltactofficer:s_5166bfb2", "suit_yourself"}, -- I'm not interested in that right now.
	}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(init_completed_main);

go_get_it = ConvoScreen:new {
	id = "go_get_it",
	leftDialog = "@conversation/coa3ltactofficer:s_1f281089", -- That's what I like to hear. There's a waypoint in your datapad for another warehouse we've found. Go get it!
	stopConversation = "true",
	options = {}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(go_get_it);

suit_yourself = ConvoScreen:new {
	id = "suit_yourself",
	leftDialog = "@conversation/coa3ltactofficer:s_18c581cc", -- Ok, suit yourself then. Come back any time you feel like helping me get rid of these stores of Alderaanian Flora.
	stopConversation = "true",
	options = {}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(suit_yourself);

init_has_extra_mission = ConvoScreen:new {
	id = "init_has_extra_mission",
	leftDialog = "@conversation/coa3ltactofficer:s_743c9f18", -- You still haven't destroyed that warehouse. Why is that?
	stopConversation = "false",
	options = {
		{"@conversation/coa3ltactofficer:s_688721b0", "quit_standing_around"}, -- Sorry, I'll get right now it.
		{"@conversation/coa3ltactofficer:s_f2fe6350", "maybe_took_care"}, -- I was not able to find the warehouse.
		{"@conversation/coa3ltactofficer:s_2e791c9d", "appreciate_the_offer"}, -- I can't complete this mission.
	}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(init_has_extra_mission);

quit_standing_around = ConvoScreen:new {
	id = "quit_standing_around",
	leftDialog = "@conversation/coa3ltactofficer:s_38f00205", -- Quit standing around then and move it.
	stopConversation = "true",
	options = {}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(quit_standing_around);

maybe_took_care = ConvoScreen:new {
	id = "maybe_took_care",
	leftDialog = "@conversation/coa3ltactofficer:s_268282e6", -- Hmm, that's odd. Maybe we already took care of that one. Here, I've given you a waypoint for another warehouse we need taken out. Good luck to you!
	stopConversation = "true",
	options = {}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(maybe_took_care);

appreciate_the_offer = ConvoScreen:new {
	id = "appreciate_the_offer",
	leftDialog = "@conversation/coa3ltactofficer:s_3d82703f", -- Well I appreciate the offer of help anyway. If you want to try it again later, come back and let me know.
	stopConversation = "true",
	options = {}
}
coa3ImperialTacticalOfficerConvoTemplate:addScreen(appreciate_the_offer);

addConversationTemplate("coa3ImperialTacticalOfficerConvoTemplate", coa3ImperialTacticalOfficerConvoTemplate);