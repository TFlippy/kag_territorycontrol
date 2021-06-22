//////////////////////////////////////////////////////
//
//  GunModule.as - Vamist
//

class GunModule
{
	// Called when gun onInit is called
	void onModuleInit(CBlob@ this) {};

	// Called every tick (Only when gun is attached & holder is not null)
	void onTick(CBlob@ this, CBlob@ holder) {};

	// Called on fire just before gun is about to create a bullet
	void onFire(CBlob@ this) {};

	// Called when reload has started
	void onReload(CBlob@ this) {};
}

class TestModule : GunModule
{
	void onTick(CBlob@ this, CBlob@ holder)
	{
		print("hi");
	}
} 
