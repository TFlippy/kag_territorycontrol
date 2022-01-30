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

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");

	// getMap().server_SetTile(this.getPosition(), CMap::tile_castle_back);

	AddIconToken("$mat_copperwire$", "Material_CopperWire.png", Vec2f(9, 11), 0);
	AddIconToken("$mat_copperingot$", "Material_CopperIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_ironingot$", "Material_IronIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_steelingot$", "Material_SteelIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_goldingot$", "Material_GoldIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$mat_mithrilingot$", "Material_MithrilIngot.png", Vec2f(16, 16), 1);

	this.set_Vec2f("shop offset", Vec2f(0,1));
	this.set_Vec2f("shop menu size", Vec2f(5, 3));
	this.set_string("shop description", "Forge");
	this.set_u8("shop icon", 15);

	for (u8 i = 0;i<3;i++)
	{
		uint8 batch = 1;
		if (i == 1) batch = 10;
		else if (i == 2) batch = 100;
		{
			ShopItem@ s = addShopItem(this, "Copper Ingot ("+batch+")", "$mat_copperingot$", "mat_copperingot-"+batch, "A soft conductive metal.", true);
			AddRequirement(s.requirements, "blob", "mat_copper", "Copper Ore", 10*batch);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Iron Ingot ("+batch+")", "$mat_ironingot$", "mat_ironingot-"+batch, "A fairly strong metal used to make tools, equipment and such.", true);
			AddRequirement(s.requirements, "blob", "mat_iron", "Iron Ore", 10*batch);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Steel Ingot ("+batch+")", "$mat_steelingot$", "mat_steelingot-"+batch, "Much stronger than iron, but also more expensive.", true);
			AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 4*batch);
			AddRequirement(s.requirements, "blob", "mat_coal", "Coal", 1*batch);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Gold Ingot ("+batch+")", "$mat_goldingot$", "mat_goldingot-"+batch, "A fancy metal - traders' favourite.", true);
			AddRequirement(s.requirements, "blob", "mat_gold", "Gold Ore", 25*batch);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Coal ("+batch+")", "$mat_coal$", "mat_coal-"+batch, "A black rock that is used for fuel.", true);
			AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 20*batch);
			s.spawnNothing = true;
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{

	this.set_Vec2f("shop offset", Vec2f(2,0));

	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ConstructShort");

		if (isServer())
		{
			u16 caller, item;

			if (!params.saferead_netid(caller) || !params.saferead_netid(item))
				return;

			string name = params.read_string();

			if (name.findFirst("mat_") != -1)
			{
				CBlob@ callerBlob = getBlobByNetworkID(caller);

				if (callerBlob !is null)
				{
					CPlayer@ callerPlayer = callerBlob.getPlayer();
					string[] tokens = name.split("-");

					if (callerPlayer !is null)
					{
						MakeMat(callerBlob, this.getPosition(), tokens[0], parseInt(tokens[1]));

						// CBlob@ mat = server_CreateBlob(tokens[0]);

						// if (mat !is null)
						// {
							// mat.Tag("do not set materials");
							// mat.server_SetQuantity(parseInt(tokens[1]));
							// if (!callerBlob.server_PutInInventory(mat))
							// {
								// mat.setPosition(callerBlob.getPosition());
							// }
						// }
					}
				}
			}
		}
	}
}