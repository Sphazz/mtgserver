/*
 *	server/zone/objects/area/FsVillageArea.h generated by engine3 IDL compiler 0.60
 */

#ifndef FSVILLAGEAREA_H_
#define FSVILLAGEAREA_H_

#include "engine/core/Core.h"

#include "engine/core/ManagedReference.h"

#include "engine/core/ManagedWeakReference.h"

namespace server {
namespace zone {
namespace objects {
namespace scene {

class SceneObject;

} // namespace scene
} // namespace objects
} // namespace zone
} // namespace server

using namespace server::zone::objects::scene;

namespace server {
namespace zone {
namespace objects {
namespace creature {

class CreatureObject;

} // namespace creature
} // namespace objects
} // namespace zone
} // namespace server

using namespace server::zone::objects::creature;

#include "engine/core/ManagedObject.h"

#include "server/zone/objects/area/ActiveArea.h"

namespace server {
namespace zone {
namespace objects {
namespace area {

class FsVillageArea : public ActiveArea {
public:
	FsVillageArea();

	void notifyEnter(SceneObject* player);

	DistributedObjectServant* _getImplementation();

	void _setImplementation(DistributedObjectServant* servant);

protected:
	FsVillageArea(DummyConstructorParameter* param);

	virtual ~FsVillageArea();

	friend class FsVillageAreaHelper;
};

} // namespace area
} // namespace objects
} // namespace zone
} // namespace server

using namespace server::zone::objects::area;

namespace server {
namespace zone {
namespace objects {
namespace area {

class FsVillageAreaImplementation : public ActiveAreaImplementation {

public:
	FsVillageAreaImplementation();

	FsVillageAreaImplementation(DummyConstructorParameter* param);

	void notifyEnter(SceneObject* player);

	WeakReference<FsVillageArea*> _this;

	operator const FsVillageArea*();

	DistributedObjectStub* _getStub();
	virtual void readObject(ObjectInputStream* stream);
	virtual void writeObject(ObjectOutputStream* stream);
protected:
	virtual ~FsVillageAreaImplementation();

	void finalize();

	void _initializeImplementation();

	void _setStub(DistributedObjectStub* stub);

	void lock(bool doLock = true);

	void lock(ManagedObject* obj);

	void rlock(bool doLock = true);

	void wlock(bool doLock = true);

	void wlock(ManagedObject* obj);

	void unlock(bool doLock = true);

	void runlock(bool doLock = true);

	void _serializationHelperMethod();
	bool readObjectMember(ObjectInputStream* stream, const String& name);
	int writeObjectMembers(ObjectOutputStream* stream);

	friend class FsVillageArea;
};

class FsVillageAreaAdapter : public ActiveAreaAdapter {
public:
	FsVillageAreaAdapter(FsVillageArea* impl);

	void invokeMethod(sys::uint32 methid, DistributedMethod* method);

	void notifyEnter(SceneObject* player);

};

class FsVillageAreaHelper : public DistributedObjectClassHelper, public Singleton<FsVillageAreaHelper> {
	static FsVillageAreaHelper* staticInitializer;

public:
	FsVillageAreaHelper();

	void finalizeHelper();

	DistributedObject* instantiateObject();

	DistributedObjectServant* instantiateServant();

	DistributedObjectAdapter* createAdapter(DistributedObjectStub* obj);

	friend class Singleton<FsVillageAreaHelper>;
};

} // namespace area
} // namespace objects
} // namespace zone
} // namespace server

using namespace server::zone::objects::area;

#endif /*FSVILLAGEAREA_H_*/
