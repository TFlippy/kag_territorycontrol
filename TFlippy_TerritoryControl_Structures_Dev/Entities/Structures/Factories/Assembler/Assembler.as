#include "MakeMat.as";
#include "Requirements.as";

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
			anim.AddFrame(3);
			gear.SetOffset(Vec2f(-10.0f, -4.0f));
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
			anim.AddFrame(3);
			gear.SetOffset(Vec2f(17.0f, -10.0f));
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
			anim.AddFrame(3);
			gear.SetOffset(Vec2f(6.0f, -4.0f));
			gear.SetAnimation("default");
			gear.SetRelativeZ(-60);
			gear.RotateBy(-22, Vec2f(0.0f,0.0f));
		}
	}
}

void onTick(CSprite@ this)
{
	if(this.getSpriteLayer("gear1") !is null){
		this.getSpriteLayer("gear1").RotateBy(5, Vec2f(0.0f,0.0f));
	}
	if(this.getSpriteLayer("gear2") !is null){
		this.getSpriteLayer("gear2").RotateBy(-5, Vec2f(0.0f,0.0f));
	}
	if(this.getSpriteLayer("gear3") !is null){
		this.getSpriteLayer("gear3").RotateBy(5, Vec2f(0.0f,0.0f));
	}
}

class AssemblerItem
{
	string resultname;
	u32 resultcount;
	string title;
	CBitStream reqs;

	AssemblerItem(string resultname, u32 resultcount, string title)
	{
		this.resultname = resultname;
		this.resultcount = resultcount;
		this.title = title;
	}
}

void onInit(CBlob@ this)
{
	AssemblerItem[] items;
	{
		AssemblerItem i("mat_pistolammo", 50, "Low Caliber Bullets (50)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(i.reqs, "blob", "mat_copperingot", "Copper Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 25);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_rifleammo", 30, "High Caliber Bullets (30)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_copperingot", "Copper Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 15);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_gatlingammo", 50, "Machine Gun Ammo (50)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_copperingot", "Copper Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 25);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_shotgunammo", 20, "Shotgun Shells (20)");
		AddRequirement(i.reqs, "blob", "mat_copperingot", "Copper Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 10);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_tankshell", 4, "Artillery Shells (4)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_howitzershell", 4, "Howitzer Shells (4)");
		AddRequirement(i.reqs, "blob", "mat_copperingot", "Copper Ingot", 2);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 30);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_smallbomb", 4, "Small Bombs (4)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_incendiarybomb", 4, "Incendiary Bombs (4)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(i.reqs, "blob", "mat_oil", "Oil", 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("foodcan", 2, "Scrub's Chow (2)");
		AddRequirement(i.reqs, "blob", "mat_meat", "Mystery Meat", 20);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		items.push_back(i);
	}	
	{
		AssemblerItem i("bigfoodcan", 1, "Scrub's Chow XL (1)");
		AddRequirement(i.reqs, "blob", "mat_meat", "Mystery Meat", 40);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 5);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_smallrocket", 4, "Small Rocket (4)");
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 40);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 20);
		AddRequirement(i.reqs, "blob", "mat_coal", "Coal", 4);
		items.push_back(i);
	}
	{
		AssemblerItem i("rocket", 1, "Rocket of Doom (1)");
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 20);
		AddRequirement(i.reqs, "blob", "mat_coal", "Coal", 2);
		items.push_back(i);
	}
	{
		AssemblerItem i("mine", 2, "Mine (2)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("fragmine", 1, "Fragmentation Mine (1)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_sammissile", 1, "SAM Missile (1)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(i.reqs, "blob", "mat_methane", "Methane", 25);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_grenade", 4, "Grenade (4)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 25);
		items.push_back(i);
	}
	{
		AssemblerItem i("revolver", 1, "Revolver (1)");
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 40);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		items.push_back(i);
	}
	{
		AssemblerItem i("rifle", 1, "Rifle (1)");
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 60);
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		items.push_back(i);
	}
	{
		AssemblerItem i("shotgun", 1, "Shotgun (1)");
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
		AssemblerItem i("mat_sulphur", 50, "Sulphur (50)");
		AddRequirement(i.reqs, "blob", "mat_dirt", "Dirt", 100);
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 75);
		AddRequirement(i.reqs, "blob", "mat_coal", "Coal", 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_dynamite", 2, "Dynamite (2)");
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 25);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 40);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_fraggrenade", 2, "Fragmentation Grenade (2)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", "Sulphur", 20);
		items.push_back(i);
	}
	this.set("items", items);


	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 60;

	this.Tag("builder always hit");
	this.Tag("change team on fort capture");
	this.addCommandID("set");

	this.set_u8("crafting",0);
	
	this.Tag("ignore extractor");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	CButton@ button = caller.CreateGenericButton(15, Vec2f(0,-8), this, AssemblerMenu, "Set Item");
}

void AssemblerMenu(CBlob@ this, CBlob@ caller)
{
	if(caller.isMyPlayer())
	{
		CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(4, 6), "Set Assembly");
		if (menu !is null)
		{
			AssemblerItem[] items = getItems(this);
			for(uint i = 0; i < items.length; i += 1)
			{
				AssemblerItem item = items[i];

				CBitStream pack;
				pack.write_u8(i);

				int teamnum = this.getTeamNum();
				if (teamnum > 6) teamnum = 7;
				AddIconToken("$assembler_icon" + i + "$", "AssemblerIcons.png", Vec2f(16, 16), i, teamnum);

				string text = "Set to Assemble: " + item.title;
				if(this.get_u8("crafting") == i)
				{
					text = "Already Assembling: " + item.title;
				}

				CGridButton @butt = menu.AddButton("$assembler_icon" + i + "$", text, this.getCommandID("set"), pack);
				butt.hoverText = item.title + "\n" + getButtonRequirementsText(item.reqs, false);
				if(this.get_u8("crafting") == i)
				{
					butt.SetEnabled(false);
				}
			}
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("set"))
	{
		u8 setting = params.read_u8();
		this.set_u8("crafting", setting);
	}
}



void onTick(CBlob@ this)
{
	AssemblerItem item = getItems(this)[this.get_u8("crafting")];
	CInventory@ inv = this.getInventory();


	CBitStream missing;
	if (hasRequirements(inv, item.reqs, missing))
	{
		if (isServer())
		{
			CBlob @mat = server_CreateBlob(item.resultname, this.getTeamNum(), this.getPosition());
			mat.server_SetQuantity(item.resultcount);

			server_TakeRequirements(inv, item.reqs);
		}

		if(isClient())
		{
			this.getSprite().PlaySound("ProduceSound.ogg");
			this.getSprite().PlaySound("BombMake.ogg");
		}
	}
}



void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	bool isMat = false;

	AssemblerItem item = getItems(this)[this.get_u8("crafting")];
	CBitStream bs = item.reqs;
	bs.ResetBitIndex();
	string text, requiredType, name, friendlyName;
	u16 quantity = 0;

	while (!bs.isBufferEnd())
	{
		ReadRequirement(bs, requiredType, name, friendlyName, quantity);

		if(blob.getName() == name)
		{
			isMat = true;
			break;
		}
	}

	if (isMat && !blob.isAttached() && blob.hasTag("material"))
	{
		if (isServer()) this.server_PutInInventory(blob);
		if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (this.getTeamNum() >= 100 ? true : (forBlob.getTeamNum() == this.getTeamNum())) && forBlob.isOverlapping(this);
}

AssemblerItem[] getItems(CBlob@ this)
{
	AssemblerItem[] items;
	this.get("items", items);
	return items;
}


void onAddToInventory( CBlob@ this, CBlob@ blob )
{
	if(blob.getName() != "gyromat") return;

	this.getCurrentScript().tickFrequency = 60 / (this.exists("gyromat_acceleration") ? this.get_f32("gyromat_acceleration") : 1);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	if(blob.getName() != "gyromat") return;
	
	this.getCurrentScript().tickFrequency = 60 / (this.exists("gyromat_acceleration") ? this.get_f32("gyromat_acceleration") : 1);
}
