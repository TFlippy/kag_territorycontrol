// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	// this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(500); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
		
	this.getCurrentScript().tickFrequency = 300;
			
	this.getShape().SetOffset(Vec2f(0, 4));
	
	AddIconToken("$ratburger$", "RatBurger.png", Vec2f(16, 16), 0);
	AddIconToken("$ratfood$", "Rat.png", Vec2f(16, 16), 0);
	AddIconToken("$faultymine$", "FaultyMine.png", Vec2f(16, 16), 0);
	AddIconToken("$badger$", "Badger.png", Vec2f(32, 16), 0);
	AddIconToken("$icon_banditpistol$", "BanditPistol.png", Vec2f(16, 8), 0);
	
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 1));
	this.set_string("shop description", "Badger Den");
	this.set_u8("shop icon", 25);

	{
		ShopItem@ s = addShopItem(this, "Sell a Steak (1)", "$steak$", "coin-100", "Groo. <3");
		AddRequirement(s.requirements, "blob", "steak", "Steak", 1);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy a Friend (1)", "$heart$", "friend", "Moo. >:(");
		AddRequirement(s.requirements, "coin", "", "Coins", 6666);
		AddRequirement(s.requirements, "blob", "steak", "Steak", 3);
		AddRequirement(s.requirements, "blob", "heart", "Heart", 2);
		AddRequirement(s.requirements, "blob", "cake", "Cinnamon bun",1);
		
		s.spawnNothing = true;
	}
}

void onTick(CBlob@ this)
{
	if (isServer())
	{
		if (XORRandom(100) > 5) return;
	
		// getMap().getBlobsInBox(this.getPosition() + Vec2f(96, -96), this.getPosition() + Vec2f(-64, 64), @blobs);
	
		CBlob@[] blobs;
		getBlobsByTag("badger", @blobs);
		
		if (blobs.length < 20) server_CreateBlob("badger", this.getTeamNum(), this.getPosition() + getRandomVelocity(0, XORRandom(16), 360));
	
	
	
		// int counter = 0;
	
		// for (int i = 0; i < blobs.length; i++) if (blobs[i].hasTag("badger")) counter++;

		// if (counter < 5)
		// {
			// CBlob@ blob = server_CreateBlob("badger", this.getTeamNum(), this.getPosition() + getRandomVelocity(0, XORRandom(16), 360));
		// }
	}

	// if (!isServer() || XORRandom(100)>=50) {
		// return;
	// }
	
	// CBlob@[] spawnedBlobs;
	// this.get("blobList",spawnedBlobs);
	// int offset=0;
	// for(int i=0;i<spawnedBlobs.length;i++){
		// if(spawnedBlobs[i] is null || spawnedBlobs[i].hasTag("dead")){
			// this.removeAt("blobList",i-offset);
			// offset++;
		// }
	// }
	
	// this.get("blobList",spawnedBlobs);
	// if(spawnedBlobs.length<3) {
		// CBlob@ blob=server_CreateBlob("badger",-1,this.getPosition());
		// if(blob !is null){
			// this.push("blobList",@blob);
		// }
	// }
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	// print("" + (caller.getPosition() - this.getPosition()).Length());
	this.set_bool("shop available", (caller.getPosition() - this.getPosition()).Length() < 40.0f);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("badger_growl" + (XORRandom(6) + 1) + ".ogg");
		
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
			else if (spl[0] == "friend")
			{
				string friend = spl[0].replace("rien", "sche").replace("f", "").replace("ch", "cy").replace("d", "er").replace("ee", "the");
				CBlob@ blob = server_CreateBlob(friend, callerBlob.getTeamNum(), this.getPosition());
			}
			else if (name.findFirst("mat_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;
				
				CBlob@ mat = server_CreateBlob(spl[0]);
							
				if (mat !is null)
				{
					mat.Tag("do not set materials");
					mat.server_SetQuantity(parseInt(spl[1]));
					if (!callerBlob.server_PutInInventory(mat))
					{
						mat.setPosition(callerBlob.getPosition());
					}
				}
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());
				
				if (blob is null && callerBlob is null) return;
			   
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
}
