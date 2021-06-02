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
	this.set_TileType("background tile", CMap::tile_castle_back);

	//this.Tag("upkeep building");
	//this.set_u8("upkeep cap increase", 0);
	//this.set_u8("upkeep cost", 5);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	this.Tag("change team on fort capture");

	this.getCurrentScript().tickFrequency = 150;

}

void onChangeTeam(CBlob@ this, const int oldTeam)
{
	// reset shop colors
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBlob@ held = caller.getCarriedBlob();

	if (held != null)
	{
		CButton@ button = caller.CreateGenericButton(
			23,                                						 // icon token
			Vec2f(0.0f, 0.0f),                                       // button offset
			this,                                                    // shop blob
			createMenu,                                              // func callback
			getTranslatedString("Modify " + held.getName()) 		 // description
		);     
	}
}

void createMenu(CBlob@ this, CBlob@ caller)
{
	CBlob@ held = caller.getCarriedBlob();
	
	BuildShopMenu(this, caller, held, Vec2f(4.0f, 4.0f)); //Always sized at 4x4 if you want to add more than 16 modifiers for a single item change this
}

void BuildShopMenu(CBlob@ this, CBlob @caller, CBlob@ target, Vec2f size)
{
	if (caller is null || !caller.isMyPlayer())
		return;

	ShopItem[]@ shopitems;

	//if (!this.get(SHOP_ARRAY, @shopitems)) { return; }


	CControls@ controls = caller.getControls();
	CGridMenu@ menu = CreateGridMenu(caller.getScreenPos(), this, size, "Modifying " + target.getName());

	if (menu !is null)
	{
		if (!this.hasTag(SHOP_AUTOCLOSE))
			menu.deleteAfterClick = false;
		//addShopItemsToMenu(this, menu, caller);
	}

}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("ConstructShort");

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

				MakeMat(callerBlob, this.getPosition(), spl[0], parseInt(spl[1]));

				// CBlob@ mat = server_CreateBlob(spl[0]);

				// if (mat !is null)
				// {
					// mat.Tag("do not set materials");
					// mat.server_SetQuantity(parseInt(spl[1]));
					// if (!callerBlob.server_PutInInventory(mat))
					// {
						// mat.setPosition(callerBlob.getPosition());
					// }
				// }
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());

				if (blob is null) return;

				if (callerBlob.getPlayer() !is null ) blob.SetDamageOwnerPlayer(callerBlob.getPlayer());
				
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
