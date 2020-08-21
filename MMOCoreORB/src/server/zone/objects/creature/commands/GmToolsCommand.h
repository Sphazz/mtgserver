/*
				Copyright <SWGEmu>
		See file COPYING for copying conditions.
		Developed by Tyclo (https://github.com/Sphazz): 2020 07-31 
*/

#ifndef GMTOOLSCOMMAND_H_
#define GMTOOLSCOMMAND_H_

#include "server/zone/managers/director/DirectorManager.h"

class GmToolsCommand : public QueueCommand {
public:

	GmToolsCommand(const String& name, ZoneProcessServer* server)
		: QueueCommand(name, server) {
	}

	int doQueueCommand(CreatureObject* creature, const uint64& target, const UnicodeString& arguments) const {

		if (!checkStateMask(creature))
			return INVALIDSTATE;

		if (!checkInvalidLocomotions(creature))
			return INVALIDLOCOMOTION;

		PlayerObject* ghost = creature->getPlayerObject();
		if (ghost == nullptr)
			return GENERALERROR;

		if (!ghost->isStaff())
			return INSUFFICIENTPERMISSION;

		Lua* lua = new Lua();
		lua->init();

		// Get menu options from Lua
		if (!lua->runFile("custom_scripts/screenplays/gmTools/gmToolsMenuOptions.lua")) {
			error("Unable to fetch GM Tools menu options");
			return checkFailReason(GENERALERROR, creature, lua);
		}

		LuaObject gmToolsMenuOptions = lua->getGlobalObject("gmToolsMenuOptions");

		if (!gmToolsMenuOptions.isValidTable() && gmToolsMenuOptions.getTableSize() <= 0) {
			error("GM Tools menu options invalid");
			return checkFailReason(GENERALERROR, creature, lua);
		}

		UnicodeTokenizer tokenizer(arguments);

		tokenizer.setDelimeter(" ");
		String menuCommand, commandOption;
		String optionScreenplay = "gmToolsCommandScreenplay"; // Default Window
		String optionFunction = "openDefaultWindow"; // Default Window

		if (tokenizer.hasMoreTokens()) {
			UnicodeString arg;
			tokenizer.getUnicodeToken(arg);
			String Sarg = arg.toString();

			// First argument should beign with a dash because I said so.
			if (!Sarg.beginsWith("-"))
				return checkFailReason(INVALIDPARAMETERS, creature, lua);

			// Remove the dash, why do I require a dash?....
			Sarg = Sarg.replaceFirst("-", "");
			LuaObject menuOption = gmToolsMenuOptions.getObjectField(Sarg);

			// If table is invalid, there is no corresponding sui.
			if (!menuOption.isValidTable())
				return checkFailReason(INVALIDSYNTAX, creature, lua);

			// Check for more tokens to run direct screenplay
			if (tokenizer.hasMoreTokens()) {
				tokenizer.getStringToken(commandOption);

				if (!commandOption.isEmpty()) {
					LuaObject optionObject = menuOption.getObjectField("options");

					// If options aren't defined, something went wrong, die horribly. (but softly)
					if (!optionObject.isValidTable())
						return checkFailReason(GENERALERROR, creature, lua);
					
					LuaObject selectedOption = optionObject.getObjectField(commandOption);

					// No matching sui to argument.
					if (!selectedOption.isValidTable())
						return checkFailReason(INVALIDSYNTAX, creature, lua);

					// Get screenplay and function, need to do it before getting permissions, otherwise it clears selectedOption
					optionScreenplay = selectedOption.getStringField("screen");
					optionFunction = selectedOption.getStringField("func");

					LuaObject perms = selectedOption.getObjectField("perms");

					// If permissions not set on selection option, use parent menu permissions
					if (!perms.isValidTable())
						perms = menuOption.getObjectField("perms");
					
					if (!isPermitted(creature, perms))
						return checkFailReason(INSUFFICIENTPERMISSION, creature, lua);
				}
			} else {
				// Get second level menu
				optionFunction = menuOption.getStringField("func");
				LuaObject perms = menuOption.getObjectField("perms");

				if (!isPermitted(creature, perms))
					return checkFailReason(INSUFFICIENTPERMISSION, creature, lua);
			}
		}

		// Make sure things are set. It'd be weird if they weren't.
		if (creature == nullptr || optionScreenplay.isEmpty() || optionFunction.isEmpty()) {
			error("Failed to run screenplay: [" + optionScreenplay + "] function: [" + optionFunction + "]");
			return checkFailReason(GENERALERROR, creature, lua);
		}
		
		Lua* directorManager = DirectorManager::instance()->getLuaInstance();
		Reference<LuaFunction*> gmToolsCommandScreenplay = directorManager->createFunction(optionScreenplay, optionFunction, 0);
		*gmToolsCommandScreenplay << creature;
		gmToolsCommandScreenplay->callFunction();

		delete lua, directorManager;
		return SUCCESS;
	}

	bool isPermitted(CreatureObject* creature, LuaObject perms) const {
		if (!perms.isValidTable() || perms.getTableSize() < 1) {
			error("Permissions datatable invalid");
			return false;
		}

		PlayerObject* ghost = creature->getPlayerObject();
		int playerLevel = ghost->getAdminLevel();
		int permLevel;
		
		for (int i = 1; i <= perms.getTableSize(); ++i) {
			permLevel = perms.getIntAt(i);

			if (permLevel != 0 && permLevel == playerLevel)
				return true;
		}
		perms.pop();

		return false;
	}

	// This is gross, return errors, delete lua. Don't judge me.
	int checkFailReason(int reason, CreatureObject* creature, Lua* lua) const {
		if (creature != nullptr) {
			switch (reason) {
				case GENERALERROR:
					creature->sendSystemMessage(" \\#ff4444[GmToolsCommand]\\#ffffff The command has failed critically. You should report this to someone...");
					break;
				case INVALIDPARAMETERS:
					creature->sendSystemMessage(" \\#f6d53b[GmToolsCommand]\\#ffffff Invalid argument. Following commands are valid:\n" + getCommandSyntax(creature, lua));
					break;
				case INVALIDSYNTAX:
					creature->sendSystemMessage(" \\#f6d53b[GmToolsCommand]\\#ffffff There is no function which matches your entry.");
					break;
				case INSUFFICIENTPERMISSION:
					creature->sendSystemMessage(" \\#f6d53b[GmToolsCommand]\\#ffffff You lack the permissions to use this function.");
					break;
				default:
					break;
			}
		}

		delete lua;
		return GENERALERROR;
	}

	// Get the syntax dynamically from lua.
	String getCommandSyntax(CreatureObject* creature, Lua* lua) const {
		Lua* directorManager = DirectorManager::instance()->getLuaInstance();
		Reference<LuaFunction*> gmToolsGetCommandSyntax = directorManager->createFunction("gmToolsCommandScreenplay", "getCommandSyntax", 1);
		*gmToolsGetCommandSyntax << creature;
		gmToolsGetCommandSyntax->callFunction();

		String syntax = lua_tostring(directorManager->getLuaState(), -1);

		return syntax;
	}

};

#endif //GMTOOLSCOMMAND_H_