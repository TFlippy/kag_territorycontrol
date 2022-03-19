#include "MakeMat.as";
#include "Requirements.as";
#include "AssemblerCommonHooks.as";

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-50);

	this.SetEmitSound("assembler_loop.ogg");
	this.SetEmitSoundVolume(1.0f);
	this.SetEmitSoundSpeed(0.5f);
	this.SetEmitSoundPaused(false);

	{
		this.RemoveSpriteLayer("gear1");
		CSpriteLayer@ gear = this.addSpriteLayer("gear1", "Assembler.png" , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

		if (gear !is null)
		{
			Animation@ anim = gear.addAnimation("default", 0, false);
			anim.AddFrame(6);
			gear.SetOffset(Vec2f(-13.0f, -7.0f));
			gear.SetAnimation("default");
			gear.SetRelativeZ(-60);
		}
	}

	{
		this.RemoveSpriteLayer("gear2");
		CSpriteLayer@ gear = this.addSpriteLayer("gear2", "Assembler.png" , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

		if (gear !is null)
		{
			Animation@ anim = gear.addAnimation("default", 0, false);
			anim.AddFrame(6);
			gear.SetOffset(Vec2f(13.0f, -10.0f));
			gear.SetAnimation("default");
			gear.SetRelativeZ(-60);
		}
	}

	{
		this.RemoveSpriteLayer("gear3");
		CSpriteLayer@ gear = this.addSpriteLayer("gear3", "Assembler.png" , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

		if (gear !is null)
		{
			Animation@ anim = gear.addAnimation("default", 0, false);
			anim.AddFrame(6);
			gear.SetOffset(Vec2f(2.0f, -4.0f));
			gear.SetAnimation("default");
			gear.SetRelativeZ(-60);
			gear.RotateBy(-22, Vec2f(0.0f,0.0f));
		}
	}
}

void onTick(CSprite@ this)
{
	if(this.getSpriteLayer("gear1") !is null){
		this.getSpriteLayer("gear1").RotateBy(-5, Vec2f(0.0f,0.0f));
	}
	if(this.getSpriteLayer("gear2") !is null){
		this.getSpriteLayer("gear2").RotateBy(-5, Vec2f(0.0f,0.0f));
	}
	if(this.getSpriteLayer("gear3") !is null){
		this.getSpriteLayer("gear3").RotateBy(5, Vec2f(0.0f,0.0f));
	}
}



void onInit(CBlob@ this)
{
	AssemblerItem[] items;
	{
		AssemblerItem i("ammo_lowcal", 50, "Low Caliber Bullets (50)",0);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(i.reqs, "blob", "mat_copperingot", "Copper Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 25);
		items.push_back(i);
	}
	{
		AssemblerItem i("ammo_highcal", 30, "High Caliber Bullets (30)",1);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_copperingot", "Copper Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 15);
		items.push_back(i);
	}
	{
		AssemblerItem i("ammo_gatling", 50, "Machine Gun Ammo (50)",2);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_copperingot", "Copper Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 25);
		items.push_back(i);
	}
	{
		AssemblerItem i("ammo_shotgun", 20, "Shotgun Shells (20)",3);
		AddRequirement(i.reqs, "blob", "mat_copperingot", "Copper Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 10);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_tankshell", 4, "Artillery Shells (4)",4);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_howitzershell", 4, "Howitzer Shells (4)",5);
		AddRequirement(i.reqs, "blob", "mat_copperingot", "Copper Ingot", 2);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 30);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_smallbomb", 4, "Small Bombs (4)",6);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_incendiarybomb", 4, "Incendiary Bombs (4)",7);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(i.reqs, "blob", "mat_oil", "Oil", 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("foodcan", 2, "Scrub's Chow (2)",8);
		AddRequirement(i.reqs, "blob", "mat_meat", "Mystery Meat", 20);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		items.push_back(i);
	}	
	{
		AssemblerItem i("bigfoodcan", 1, "Scrub's Chow XL (1)",9);
		AddRequirement(i.reqs, "blob", "mat_meat", "Mystery Meat", 40);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 5);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_smallrocket", 4, "Small Rocket (4)",10);
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 40);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 20);
		AddRequirement(i.reqs, "blob", "mat_coal", "Coal", 4);
		items.push_back(i);
	}
	{
		AssemblerItem i("rocket", 1, "Rocket of Doom (1)",11);
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 20);
		AddRequirement(i.reqs, "blob", "mat_coal", "Coal", 2);
		items.push_back(i);
	}
	{
		AssemblerItem i("mine", 2, "Mine (2)",12);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("fragmine", 1, "Fragmentation Mine (1)",13);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_sammissile", 1, "SAM Missile (1)",14);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(i.reqs, "blob", "mat_methane", "Methane", 25);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_grenade", 4, "Grenade (4)",15);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 25);
		items.push_back(i);
	}
	{
		AssemblerItem i("revolver", 1, "Revolver (1)",16);
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 40);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		items.push_back(i);
	}
	{
		AssemblerItem i("rifle", 1, "Rifle (1)",17);
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 60);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		items.push_back(i);
	}
	{
		AssemblerItem i("shotgun", 1, "Shotgun (1)",18);
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 60);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		items.push_back(i);
	}	
	//{
		//AssemblerItem i("guidedrocket", 1, "Guided Missile (1)");
		//AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 4);
		//AddRequirement(i.reqs, "blob", "mat_methane", "Methane", 20);
		//items.push_back(i);
	//}
	{
		AssemblerItem i("mat_sulphur", 50, "Sulphur (50)",19);
		AddRequirement(i.reqs, "blob", "mat_dirt", "Dirt", 100);
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 75);
		AddRequirement(i.reqs, "blob", "mat_coal", "Coal", 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_dynamite", 2, "Dynamite (2)",20);
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 25);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 40);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_fraggrenade", 2, "Fragmentation Grenade (2)",21);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 20);
		items.push_back(i);
	}
	this.set("items", items);

	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 60;

	this.Tag("builder always hit");
	this.Tag("change team on fort capture");
	this.addCommandID("set");

	this.set_u8("crafting",0);
}
