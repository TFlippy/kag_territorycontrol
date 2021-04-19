// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("change team on fort capture");
	this.addCommandID("write");
	//this.set_Vec2f("nobuild extend",Vec2f(0.0f, 8.0f));

	//this.inventoryButtonPos = Vec2f(-16, 8);
	this.getCurrentScript().tickFrequency=30*2;	//30 oil per minute

	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png",6,Vec2f(8,8));
	this.SetMinimapRenderAlways(true);

	AddIconToken("$icon_oil$","Material_Oil.png",Vec2f(16,16),0);

	//SHOP
	this.set_Vec2f("shop offset",Vec2f(5,5));
	this.set_Vec2f("shop menu size",Vec2f(1,1));
	this.set_string("shop description","Pump Jack");
	this.set_u8("shop icon", 25);
	{
		ShopItem@ s = addShopItem(this, "Buy 1 Oil Drum (50 l)", "$mat_oil$", "mat_oil-50", "Buy 50 litres of oil for 400 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 400);
		s.spawnNothing = true;
	}
}

void onInit(CSprite@ this)
{
	CSpriteLayer@ head = this.addSpriteLayer("head", this.getFilename(), 80, 48);
	if (head !is null)
	{
		head.addAnimation("default", 0, true);
		head.SetRelativeZ(-1.0f);
		head.SetOffset(Vec2f(-12, -18));
	}

	CSpriteLayer@ rod = this.addSpriteLayer("rod", "PumpJack_Rod", 4, 64);
	if (rod !is null)
	{
		rod.addAnimation("default", 0, true);
		rod.SetRelativeZ(-5.0f);
		rod.SetOffset(Vec2f(-36, 0));
	}

	this.SetEmitSound("Pumpjack_Ambient.ogg");
	this.SetEmitSoundVolume(1.2f);
	this.SetEmitSoundPaused(false);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	CSpriteLayer@ head = this.getSpriteLayer("head");

	head.ResetTransform();
	head.RotateBy(Maths::Sin((getGameTime() * 0.075f) % 180) * 20.0f, Vec2f_zero);

	CSpriteLayer@ rod = this.getSpriteLayer("rod");
	if (rod !is null)
	{
		rod.addAnimation("default", 0, true);
		rod.SetRelativeZ(-5.0f);
		rod.SetOffset(Vec2f(-36, Maths::Sin((getGameTime() * 0.075f) % 180) * 9.0f));
	}
}

void onTick(CBlob@ this)
{
	if (isServer()) 
	{
		// if (!this.getInventory().isFull()) MakeMat(this, this.getPosition(), "mat_oil", XORRandom(3));

		CBlob@ storage = FindStorage(this.getTeamNum());

		if (storage !is null)
		{
			MakeMat(storage, this.getPosition(), "mat_oil", XORRandom(3));
		}
		else if (this.getInventory().getCount("mat_oil") < 450)
		{
			MakeMat(this, this.getPosition(), "mat_oil", XORRandom(3));
		}
	}
}

CBlob@ FindStorage(u8 team)
{
	if (team >= 100) return null;

	CBlob@[] blobs;
	getBlobsByName("oiltank", @blobs);

	CBlob@[] validBlobs;

	for (u32 i = 0; i < blobs.length; i++)
	{
		if (blobs[i].getTeamNum() == team && blobs[i].getInventory().getCount("mat_oil") < 300)
		{
			validBlobs.push_back(blobs[i]);
		}
	}

	if (validBlobs.length == 0) return null;

	return validBlobs[XORRandom(validBlobs.length)];
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));

	if (caller is null) return;
	if (!this.isOverlapping(caller)) return;

	//rename the oilrig
	CBlob@ carried = caller.getCarriedBlob();
	if(carried !is null && carried.getName() == "paper" && caller.getTeamNum() == this.getTeamNum())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(carried.getNetworkID());

		CButton@ buttonWrite = caller.CreateGenericButton("$icon_paper$", Vec2f(0, -8), this, this.getCommandID("write"), "Rename the rig.", params);
	}
}

void onAddToInventory(CBlob@ this,CBlob@ blob) //i'll keep it just to be sure
{
	if(blob.getName()!="mat_oil"){
		this.server_PutOutInventory(blob);
	}
}
bool isInventoryAccessible(CBlob@ this,CBlob@ forBlob)
{
	return forBlob.isOverlapping(this) && (forBlob.getCarriedBlob() is null || forBlob.getCarriedBlob().getName()=="mat_oil");
	//return (forBlob.isOverlapping(this));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");

		u16 caller, item;

		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;

		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);

		if (callerBlob is null) return;

		if (isServer())
		{
			string[] spl = name.split("-");

			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
			else if (name.findFirst("mat_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				CBlob@ mat = server_CreateBlob(spl[0]);

				if(mat !is null) {
					mat.Tag("do not set materials");
					mat.server_SetQuantity(parseInt(spl[1]));
					if(!callerBlob.server_PutInInventory(mat)) {
						mat.setPosition(callerBlob.getPosition());
					}
				}
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());

				if (blob is null) return;

				if (!blob.canBePutInInventory(callerBlob))
				{
					callerBlob.server_Pickup(blob);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
		}
	}
	if (cmd == this.getCommandID("write"))
	{
		if (isServer())
		{
			CBlob @caller = getBlobByNetworkID(params.read_u16());
			CBlob @carried = getBlobByNetworkID(params.read_u16());

			if (caller !is null && carried !is null)
			{
				this.set_string("text", carried.get_string("text"));
				this.Sync("text", true);
				this.set_string("shop description", this.get_string("text"));
				this.Sync("shop description", true);
				carried.server_Die();
			}
		}
		if (isClient())
		{
			this.setInventoryName(this.get_string("text"));
		}
	}
}
