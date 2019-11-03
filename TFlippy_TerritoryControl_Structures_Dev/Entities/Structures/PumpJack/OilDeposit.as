// A script by TFlippy & Pirate-Rob

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";
#include "BuilderHittable.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetAnimation("default");
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions=false;
	
	//this.set_Vec2f("nobuild extend",Vec2f(0.0f, 8.0f));
	this.Tag("oil_deposit");

	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png",6,Vec2f(8,8));
	this.SetMinimapRenderAlways(true);
	
	AddIconToken("$icon_upgrade$", "InteractionIcons.png", Vec2f(32, 32), 21);
	
	this.set_Vec2f("shop offset",Vec2f(0,0));
	this.set_Vec2f("shop menu size",Vec2f(2,2));
	this.set_string("shop description", "");
	this.set_u8("shop icon",15);
	
	{
		ShopItem@ s = addShopItem(this, "Build a Pumpjack", "$icon_upgrade$", "pumpjack", "Build a Pumpjack.");
		AddRequirement(s.requirements,"blob","mat_stone","Stone",100);
		AddRequirement(s.requirements,"blob","mat_wood","Wood",350);
		s.customButton = true;
		s.buttonwidth = 2;	
		s.buttonheight = 2;
		
		s.spawnNothing = true;
	}
}
void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item)) return;
		
		CBlob@ buyer=getBlobByNetworkID(caller);
		
		string data = params.read_string();
		
		if (data == "pumpjack")
		{
			Vec2f pos = this.getPosition();
		
			this.getSprite().PlaySound("/Construct.ogg");
			this.getSprite().getVars().gibbed = true;
			
			if (isServer())
			{
				this.server_Die();
				CBlob@ newBlob = server_CreateBlob("pumpjack", buyer.getTeamNum(), pos);
			}
		}
	}
}
