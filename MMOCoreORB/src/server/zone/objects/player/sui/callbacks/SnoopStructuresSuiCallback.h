/*
				Copyright <SWGEmu>
		See file COPYING for copying conditions.
		Developed by Tyclo (https://github.com/Sphazz): 2020 08-23
*/

#ifndef SNOOPSTRUCTURESSUICALLBACK_H_
#define SNOOPSTRUCTURESSUICALLBACK_H_

#include "server/zone/objects/player/sui/SuiCallback.h"
#include "server/zone/objects/creature/CreatureObject.h"
#include "server/zone/objects/player/PlayerObject.h"
#include "server/zone/objects/scene/SceneObject.h"
#include "server/zone/objects/tangible/TangibleObject.h"
#include "server/zone/objects/building/BuildingObject.h"
#include "server/zone/Zone.h"
#include "server/zone/objects/installation/harvester/HarvesterObject.h"
#include "server/zone/objects/installation/InstallationObject.h"
#include "server/zone/managers/stringid/StringIdManager.h"
#include "client/zone/managers/objectcontroller/ObjectController.h"

class SnoopStructuresSuiCallback : public SuiCallback {
	ManagedReference<CreatureObject*> target;
	int suiType;

public:
	SnoopStructuresSuiCallback(ZoneServer* server, CreatureObject* target, int suiType)
		: SuiCallback(server) {

		this->target = target;
		this->suiType = suiType;
	}

	void run(CreatureObject* player, SuiBox* suiBox, uint32 eventIndex, Vector<UnicodeString>* args) {
		bool cancelPressed = (eventIndex == 1);

		if (cancelPressed || !suiBox->isListBox() || args->size() < 1)
			return;

		int index = 0;
		bool otherPressed = false;

		if (args->size() == 2) {
			index = Integer::valueOf(args->get(0).toString());
		} else if (args->size() > 2) {
			otherPressed = Bool::valueOf(args->get(0).toString());
			index = Integer::valueOf(args->get(1).toString());
		}

		if (index == -1 && suiType == 3) {
			if (otherPressed)
				player->sendSystemMessage(" \\#f6d53b[NOTICE] \\#ffffffNo item selected to retrieve. Returning to main menu.");
			else
				player->sendSystemMessage(" \\#f6d53b[NOTICE] \\#ffffffNo item selected to view info. Returning to main menu.");
			
			player->executeObjectControllerAction(STRING_HASHCODE("snoop"), 0, target->getFirstName() + " structures");
			return;
		}

		uint64 selection = 0;

		SuiListBox* listBox = cast<SuiListBox*>(suiBox);
		
		if (index < 0 || index > listBox->getMenuSize())
			return;
		
		selection = listBox->getMenuObjectID(index);

		if (suiType <= 0 || player == nullptr || target == nullptr)
			return;

		if (!player->isPlayerCreature() || !target->isPlayerCreature())
			return;

		switch (suiType) {
			case 1: 
				handleListStructures(player, target, selection);
				break;
			case 2: 
				if (otherPressed)
					handleTeleport(player, target, selection);
				else
					handleListItems(player, target, selection);
				break;
			case 3: 
				if (otherPressed)
					handleTransferItem(player, target, selection);
				else
					handleItemInfo(player, target, selection);
				break;
			default:
				break;
		}
	}

	void handleListStructures(CreatureObject* player, CreatureObject* target, uint64 type) {
		if (type == 5) {
			ManagedReference<CellObject*> cell = player->getParent().get().castTo<CellObject*>();
			if (cell == nullptr) {
				player->sendSystemMessage(" \\#f6d53b[NOTICE] \\#ffffffYou must be inside of a building to use this option.");
				return;
			}

			ManagedReference<SceneObject*> building = cell->getParent().get();
			ManagedReference<StructureObject*> structure = building.castTo<StructureObject*>();

			if (structure->isBuildingObject()) {
				ManagedReference<SceneObject*> ownerObject = server->getObject(structure->getOwnerObjectID());
				if (ownerObject == nullptr || !ownerObject->isCreatureObject())
					return;
				
				CreatureObject* owner = cast<CreatureObject*>(ownerObject.get());
				handleListItems(player, owner, structure->getObjectID());
			}
			
			return;
		}

		ManagedReference<PlayerObject*> targetGhost = target->getPlayerObject();
		ManagedReference<PlayerObject*> ghost = player->getPlayerObject();

		if (targetGhost == nullptr || ghost == nullptr)
			return;

		ManagedReference<SuiListBox*> listBox = new SuiListBox(player, 0, SuiListBox::HANDLETHREEBUTTON);
		StringIdManager* sidman = StringIdManager::instance();

		StringBuffer message;
		StringBuffer emptyStructures;
		String name = "";
		int count = 0;
		int emptyStructureCount = 1;

		for (int i = 0; i < targetGhost->getTotalOwnedStructureCount(); i++) {
			ManagedReference<StructureObject*> structure = target->getZoneServer()->getObject(targetGhost->getOwnedStructure(i)).castTo<StructureObject*>();

			name = structure->getCustomObjectName().toString();
			if (name == "")
				name = structure->getDisplayedName();
			name = "\\#ffffff" + name;
			if (structure->isBuildingObject()) {
				ManagedReference<BuildingObject*> building = structure.castTo<BuildingObject*>();
				name += " - \\#cee5e5Items:\\#ffe254 " +  String::valueOf(building->getCurrentNumberOfPlayerItems()) + " \\#ffffff-";
			}
			name += " \\#ffe254(" + String::valueOf(structure->getObjectID()) + ")";

			if (type == 4 && structure->isFactory()) {
				if (structure->isFactory()) {
					listBox->addMenuItem(name, structure->getObjectID());
					count++;
				} else {
					emptyStructures << getStructuresWithoutStorage(structure, sidman, emptyStructureCount);
					emptyStructureCount++;
				}
			} else if (type == 3 && structure->isGCWBase()) {
				if (structure->isBuildingObject()) {
					listBox->addMenuItem(name, structure->getObjectID());
					count++;
				} else {
					emptyStructures << getStructuresWithoutStorage(structure, sidman, emptyStructureCount);
					emptyStructureCount++;
				}
			} else if (type == 2 && structure->isCivicStructure()) {
				if (structure->isBuildingObject()) {
					listBox->addMenuItem(name, structure->getObjectID());
					count++;
				} else {
					emptyStructures << getStructuresWithoutStorage(structure, sidman, emptyStructureCount);
					emptyStructureCount++;
				}
			} else if (type == 1 && (!structure->isFactory() && !structure->isGCWBase() && !structure->isCivicStructure() && !structure->isHarvesterObject() && !structure->isGeneratorObject())) {
				if (structure->isBuildingObject()) {
					listBox->addMenuItem(name, structure->getObjectID());
					count++;
				} else {
					emptyStructures << getStructuresWithoutStorage(structure, sidman, emptyStructureCount);
					emptyStructureCount++;
				}
			}
		}

		if (count == 0) {
			player->sendSystemMessage(" \\#ffa500[WARNING] \\#ffffffNo structures were found. Returning to main menu.");
			player->executeObjectControllerAction(STRING_HASHCODE("snoop"), 0, target->getFirstName() + " structures");
			return;
		}

		String category;

		switch (type) {
			case 1:
				category = "Buildings";
				break;
			case 2:
				category = "Civic Structures";
				break;
			case 3:
				category = "GCW Bases";
				break;
			case 4:
				category = "Factories";
				break;
			default:
				break;
		}

		message << "\\#eeeeeeItem counts for buildings include items inside of containers. Example: If a building shows \\#ffd27f5\\#eeeeee items in this window but the \\#pcontrast3 Items \\#eeeeee menu only shows \\#ffd27f3\\#eeeeee then there are \\#ffd27f2\\#eeeeee items inside of containers." << endl << endl;
		message << "\\#cee5e5" <<  category << ":\t\\#ffe254" << String::valueOf(count) << endl;
		if (emptyStructures.length() > 0) {
			message << endl << "\\#fff1bcStructures Without Storage:" << endl;
			message << emptyStructures;
		}

		listBox->setPromptTitle("[Snoop] " + target->getFirstName() + "'s " + category);
		listBox->setPromptText(message.toString());

		listBox->setForceCloseDisabled();
		listBox->setUsingObject(player);

		listBox->setOkButton(true, "@ui_auc:page_text_prefix");
		listBox->setOtherButton(true, "@ui:go");
		listBox->setCancelButton(true, "@cancel");
		
		listBox->setCallback(new SnoopStructuresSuiCallback(player->getZoneServer(), target, 2));
		
		ghost->addSuiBox(listBox);
		player->sendMessage(listBox->generateMessage());
	}

	void handleTeleport(CreatureObject* player, CreatureObject* target, uint64 structureID) {
		ManagedReference<StructureObject*> structure = server->getObject(structureID).castTo<StructureObject*>();

		if (structure == nullptr)
			return;

		if (!structure->isBuildingObject()) {
			player->sendSystemMessage(" \\#f6d53b[NOTICE] \\#ffffffUnable to teleport to structure.");
			player->executeObjectControllerAction(STRING_HASHCODE("snoop"), 0, target->getFirstName() + " structures");
			return;
		}

		ManagedReference<BuildingObject*> building = structure.castTo<BuildingObject*>();

		if (building == nullptr)
			return;

		Vector3 ejectionPoint = building->getEjectionPoint();

		Zone* zone = building->getZone();

		if (zone == nullptr)
			return;
		
		player->switchZone(zone->getZoneName(), ejectionPoint.getX(), ejectionPoint.getZ(), ejectionPoint.getY(), 0, true);
	
		ObjectController* controller = player->getZoneServer()->getObjectController();
		StringBuffer log;
		log << "(" << player->getObjectID() << ") used '/snoop' to teleport to ";
		log << structure->getDisplayedName() << " (" << structureID << ") building owned by ";
		log << target->getFirstName() << " (" << target->getObjectID() << ")";
		controller->logAdminMessage(player, log.toString());
	}

	void handleListItems(CreatureObject* player, CreatureObject* target, uint64 structureID) {
		ManagedReference<PlayerObject*> ghost = player->getPlayerObject();
		ManagedReference<StructureObject*> structure = server->getObject(structureID).castTo<StructureObject*>();

		if (structure == nullptr || ghost == nullptr) {
			player->sendSystemMessage(" \\#f6d53b[NOTICE] \\#ffffffNo structure selected. Returning to main menu.");
			player->executeObjectControllerAction(STRING_HASHCODE("snoop"), 0, target->getFirstName() + " structures");
			return;
		}

		if (structure->isFactory()) {
			ManagedReference<FactoryObject*> factoryObj = structure.castTo<FactoryObject*>();
			player->sendSystemMessage(" \\#f6d53b[NOTICE] \\#ffffffSending factory Ingredient and Output hopper windows.");
			factoryObj->sendIngredientHopper(player);
			factoryObj->sendOutputHopper(player);
			return;
		}

		if (!structure->isBuildingObject())
			return;
		
		ManagedReference<BuildingObject*> building = structure.castTo<BuildingObject*>();

		StringBuffer message;
		String objectName = "";
		bool foundContainer = false;

		Locker block(building, player);

		ManagedReference<SuiListBox*> listBox = new SuiListBox(player, 0, SuiListBox::HANDLETHREEBUTTON);
		for (uint32 i = 1; i <= building->getTotalCellNumber(); ++i) {
			ManagedReference<CellObject*> cellObject = building->getCell(i);

			if (cellObject == nullptr)
				continue;
			
			int childObjects = cellObject->getContainerObjectsSize();

			if (childObjects <= 0)
				continue;

			for (int j = childObjects - 1; j >= 0; --j) {
				ManagedReference<SceneObject*> obj = cellObject->getContainerObject(j);

				if (obj == nullptr || obj->isPlayerCreature() || obj->isPet() || obj->isVendor() || 
					obj->isCreatureObject() || structure->containsChildObject(obj))
					continue;

				objectName = "\\#ffffff" + obj->getDisplayedName();

				if (obj->isContainerObject() && obj->getContainerObjectsSize() > 0) {
					objectName += " - \\#cee5e5Contents:\\#ffe254 " + String::valueOf(obj->getContainerObjectsSize()) + " \\#ffffff-";
					foundContainer = true;
				}

				if (obj->isNoTrade())
					objectName += " \\#ff4444(No Trade)";
				
				objectName += " \\#ffe254(" + String::valueOf(obj->getObjectID()) + ")";
				listBox->addMenuItem(objectName, obj->getObjectID());
			}
		}
		StringIdManager* sidman = StringIdManager::instance();
		String name = structure->getCustomObjectName().toString();
		if (name == "")
			name = sidman->getStringId("@" + structure->getObjectNameStringIdFile() + ":" + structure->getObjectNameStringIdName()).toString();
		message << "\\#cee5e5Structure ID:\t\\#ffe254" << structure->getObjectID() << endl;
		message << "\\#cee5e5Owner:\t\t\t\\#ffffff" << target->getFirstName() << endl;
		message << "\\#cee5e5Name:\t\t\t\\#ffffff" << name << endl;
		message << "\\#cee5e5Type:\t\t\t\\#ffffff" << structure->getObjectTemplate()->getFullTemplateString() << endl;
		message << "\\#cee5e5Items:\t\t\t\\#ffe254" << building->getCurrentNumberOfPlayerItems() << endl;
		message << "\\#cee5e5Lots:\t\t\t\\#ffe254" << String::valueOf(structure->getLotSize()) << endl;
		message << "\\#cee5e5Maintenance:\t\\#ffe254" << String::valueOf(structure->getSurplusMaintenance()) << " \\#fff1bccredits" << endl;
		message << "\\#cee5e5Zone:\t\t\t\\#ffffff";
		
		Zone* zone = structure->getZone();
		if (zone == nullptr)
			message << "\\#ffffffUnknown" << endl;
		else {
			message << zone->getZoneName() << endl;
			message << "\\#cee5e5Location:\t\t\\#ffffffX: \\#ffe254" << structure->getWorldPositionX() << "\\#cee5e5, \\#ffffffY: \\#ffe254" << structure->getWorldPositionY() << endl;
		}

		if (foundContainer)
			message << endl << "\\#eeeeeeSelecting the \\#pcontrast3 Info\\#eeeeee menu on a container will open the container's contents." << endl;

		listBox->setPromptTitle("[Snoop] " + name);
		listBox->setPromptText(message.toString());

		listBox->setUsingObject(player);
		listBox->setForceCloseDisabled();

		listBox->setOkButton(true, "@ui:examine_info");
		listBox->setOtherButton(true, "@ui_auc:retrieve");
		listBox->setCancelButton(true, "@cancel");

		listBox->setCallback(new SnoopStructuresSuiCallback(player->getZoneServer(), target, 3));
		
		ghost->addSuiBox(listBox);
		player->sendMessage(listBox->generateMessage());
	}

	void handleTransferItem(CreatureObject* player, CreatureObject* target, uint64 objectID) {
		ManagedReference<PlayerObject*> ghost = player->getPlayerObject();
		if (ghost->getAdminLevel() < 14) {
			player->sendSystemMessage(" \\#ffa500[WARNING] \\#ffffffYou lack the permissions to use this option.");
			handleListItems(player, target, objectID);
			return;
		}

		ManagedReference<SceneObject*> inventory = player->getSlottedObject("inventory");

		if (inventory == nullptr || inventory->isContainerFullRecursive()) {
			player->sendSystemMessage("@error_message:inv_full");
			handleListItems(player, target, objectID);
			return;
		}

		ManagedReference<SceneObject*> pObject = server->getObject(objectID).castTo<SceneObject*>();

		if (pObject == nullptr) {
			player->sendSystemMessage(" \\#f6d53b[NOTICE] \\#ffffffNo item selected to retrieve.");
			handleListItems(player, target, objectID);
			return;
		}

		Locker tlock(pObject, player);
		inventory->transferObject(pObject, -1, true);
		inventory->broadcastObject(pObject, true);

		ObjectController* controller = player->getZoneServer()->getObjectController();
		StringBuffer message;
		message << "(" << player->getObjectID() << ") used '/snoop' to retrieve ";
		message << pObject->getDisplayedName() << " (" << objectID << ") item owned by ";
		message << target->getFirstName() << " (" << target->getObjectID() << ")";
		controller->logAdminMessage(player, message.toString());
	}

	void handleItemInfo(CreatureObject* player, CreatureObject* target, uint64 objectID) {
		ManagedReference<SceneObject*> pObject = server->getObject(objectID).castTo<SceneObject*>();

		if (pObject->isContainerObject() && pObject->getContainerObjectsSize() > 0) {
			listContainerItems(player, target, pObject);
		} else {
			ManagedReference<PlayerObject*> ghost = player->getPlayerObject();

			if (pObject == nullptr || ghost == nullptr) {
				player->sendSystemMessage(" \\#f6d53b[NOTICE] \\#ffffffNo item selected.");
				handleListItems(player, target, objectID);
				return;
			}
			StringBuffer message = getItemInfo(player, pObject);

			ManagedReference<SuiMessageBox*> box = new SuiMessageBox(player, 0);
			box->setPromptTitle("[Snoop] " + pObject->getDisplayedName());
			box->setPromptText(message.toString());
			box->setOkButton(true, "@close");
			box->setUsingObject(pObject);
			box->setForceCloseDisabled();

			box->setCallback(new SnoopStructuresSuiCallback(player->getZoneServer(), target, 4));

			ghost->addSuiBox(box);
			player->sendMessage(box->generateMessage());

			ObjectController* controller = player->getZoneServer()->getObjectController();
			StringBuffer log;
			log << "(" << player->getObjectID() << ") used '/snoop' to snoop ";
			log << pObject->getDisplayedName() << " (" << objectID << ") item owned by ";
			log << target->getFirstName() << " (" << target->getObjectID() << ")";
			controller->logAdminMessage(player, log.toString());
		}
	}

	void listContainerItems(CreatureObject* player, CreatureObject* target, SceneObject* pContainer) {
		ManagedReference<PlayerObject*> ghost = player->getPlayerObject();

		String objectName = "";

		Locker clock(pContainer, player);

		ManagedReference<SuiListBox*> listBox = new SuiListBox(player, 0, SuiListBox::HANDLETHREEBUTTON);

		int childObjects = pContainer->getContainerObjectsSize();

		if (childObjects <= 0) {
			player->sendSystemMessage(" \\#f6d53b[NOTICE] \\#ffffffContainer has no contents. Show container information.");
			handleItemInfo(player, target, pContainer->getObjectID());
			return;
		}

		bool foundContainer = false;

		for (int j = childObjects - 1; j >= 0; --j) {
			ManagedReference<SceneObject*> obj = pContainer->getContainerObject(j);

			if (obj == nullptr)
				continue;

			objectName = "\\#ffffff" + obj->getDisplayedName();

			if (obj->isContainerObject() && obj->getContainerObjectsSize() > 0) {
				objectName += " - \\#cee5e5Contents:\\#ffe254 " + String::valueOf(obj->getContainerObjectsSize()) + " \\#ffffff-";
				foundContainer = true;
			}

			if (obj->isNoTrade())
				objectName += " \\#ff4444(No Trade)";
			
			objectName += " \\#ffe254(" + String::valueOf(obj->getObjectID()) + ")";
			listBox->addMenuItem(objectName, obj->getObjectID());
		}

		StringBuffer message = getItemInfo(player, pContainer);

		if (foundContainer)
			message << endl << "\\#eeeeeeSelecting the \\#pcontrast3 Info\\#eeeeee menu on a container will open the container's contents." << endl;

		listBox->setPromptTitle("[Snoop] " + pContainer->getDisplayedName());
		listBox->setPromptText(message.toString());

		listBox->setUsingObject(player);
		listBox->setForceCloseDisabled();

		listBox->setOkButton(true, "@ui:examine_info");
		listBox->setOtherButton(true, "@ui_auc:retrieve");
		listBox->setCancelButton(true, "@cancel");

		listBox->setCallback(new SnoopStructuresSuiCallback(player->getZoneServer(), target, 3));
		
		ghost->addSuiBox(listBox);
		player->sendMessage(listBox->generateMessage());
	}

	StringBuffer getStructuresWithoutStorage(StructureObject* structure, StringIdManager* sidman, int emptyStructureCount) {
		StringBuffer emptyStructures;
		
		String name = structure->getCustomObjectName().toString();
		if (name == "")
			name = sidman->getStringId("@" + structure->getObjectNameStringIdFile() + ":" + structure->getObjectNameStringIdName()).toString();
		emptyStructures << "\\#ffffff" << emptyStructureCount << ") \\#ffe254" << name << endl;
		emptyStructures << "\t\\#cee5e5ID:\\#ffe254\t\t\t" << structure->getObjectID() << endl;
		emptyStructures << "\t\\#cee5e5Zone:\t\t\\#ffffff";
		
		Zone* zone = structure->getZone();
		if (zone == nullptr)
			emptyStructures << "\\#ffffffUnknown" << endl;
		else {
			emptyStructures << zone->getZoneName() << endl;
			emptyStructures << "\t\\#cee5e5Location:\t\\#ffffffX: \\#ffe254" << structure->getWorldPositionX() << "\\#cee5e5, \\#ffffffY: \\#ffe254" << structure->getWorldPositionY() << endl;
		}

		emptyStructures << endl;

		return emptyStructures;
	}

	StringBuffer getItemInfo(CreatureObject* player, SceneObject* pObject) {
		StringBuffer message;
		message << "\\#cee5e5Name:\t\t\t\t\\#ffffff" << pObject->getDisplayedName() << endl;
		message << "\\#cee5e5Template:\t\t\t\\#ffffff" << pObject->getObjectTemplate()->getFullTemplateString() << endl;
		message << "\\#cee5e5Object ID:\t\t\t\\#ffe254" << pObject->getObjectID() << endl;
		message << "\\#cee5e5Object Type:\t\t\\#ffe254" << pObject->getGameObjectType() << endl;
		message << "\\#cee5e5Object CRC:\t\t\\#ffe254" << pObject->getClientObjectCRC() << endl;
		message << "\\#cee5e5Container Type:\t\t\\#ffe254" << pObject->getContainerType() << endl;
		message << "\\#cee5e5Container Limit:\t\\#ffe254" << pObject->getContainerVolumeLimit() << endl;

		TangibleObject* pTangible = cast<TangibleObject*>(pObject);

		if (pTangible != nullptr) {
			message << "\\#cee5e5Object Template:\t\\#ffffff" << pTangible->getObjectTemplate() << endl;
			message << "\\#cee5e5Max Condition:\t\t\\#ffe254" << pTangible->getMaxCondition() << endl;
			message << "\\#cee5e5Use Count:\t\t\t\\#ffe254" << pTangible->getUseCount() << endl;
			message << "\\#cee5e5OptionBitmask:\t\t\\#ffe254" << pTangible->getOptionsBitmask() << endl;
			message << "\\#cee5e5PvpBitmask:\t\t\\#ffe254" << pTangible->getPvpStatusBitmask() << endl;
		}

		return message;
	}
};

#endif /* SNOOPSTRUCTURESSUICALLBACK_H_ */