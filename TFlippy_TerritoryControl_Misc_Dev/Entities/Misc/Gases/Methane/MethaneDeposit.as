#include "Hitters.as";
#include "Explosion.as";

#include "Requirements.as";
#include "ShopCommon.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 100 + XORRandom(50);
	this.getSprite().SetZ(-10.0f);
	
	this.getShape().SetStatic(true);
	
	this.set_u8("gas_left", 30 + XORRandom(30));
	
	
	AddIconToken("$icon_upgrade$", "InteractionIcons.png", Vec2f(32, 32), 21);
	
	this.set_Vec2f("shop offset",Vec2f(0,0));
	this.set_Vec2f("shop menu size",Vec2f(2,2));
	this.set_string("shop description", "");
	this.set_u8("shop icon", 15);
	this.set_u8("shop button radius", 32);
	this.Tag(SHOP_AUTOCLOSE);
	
	{
		ShopItem@ s = addShopItem(this, "Build a Methane Collector", "$icon_upgrade$", "methanecollector", "Build a methane collector that will automatically harvest methane and deposit it into constructed gas tanks.");
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 8);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.customButton = true;
		s.buttonwidth = 2;	
		s.buttonheight = 2;
		
		s.spawnNothing = true;
	}
}

void onTick(CBlob@ this)
{
	if (isServer())
	{
		CBlob@[] blobs;
		getMap().getBlobsInBox(this.getPosition() + Vec2f(48, -48), this.getPosition() + Vec2f(-48, 48), @blobs);
	
		int counter = 0;
	
		for (int i = 0; i < blobs.length; i++) if (blobs[i].getName() == "methane") counter++;

		if (counter < 8)
		{
			CBlob@ blob = server_CreateBlob("methane", this.getTeamNum(), this.getPosition() + getRandomVelocity(0, XORRandom(16), 360));
			this.set_u8("gas_left", this.get_u8("gas_left") - 1);
			
			if (this.get_u8("gas_left") <= 0)
			{
				this.server_Die();
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item)) return;
		
		CBlob@ buyer = getBlobByNetworkID(caller);
		string data = params.read_string();
		
		if (data == "methanecollector")
		{
			Vec2f pos = this.getPosition();
		
			this.getSprite().PlaySound("/Construct.ogg");
			this.getSprite().getVars().gibbed = true;
			
			if (isServer())
			{
				this.server_Die();
				CBlob@ newBlob = server_CreateBlob("methanecollector", buyer.getTeamNum(), pos);
			}
		}
	}
}