#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "Descriptions.as";

// AngelScript and C++ are assholes, thank god for C#
// string[] icons = 
// {
	// "$symbol_gear$",
	// "$symbol_steam$",
	// "$symbol_stone$", 
	// "$symbol_fire$",
	// "$symbol_water$",
	// "$symbol_holy$",
	// "$symbol_death$",
	// "$symbol_chaos$",
	// "$symbol_nature$",
	// "$symbol_reset$",
	// "$symbol_submit$"
// };

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("change team on fort capture");
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(3, 4));
	this.set_string("shop description", "Write a book.");
	this.set_u8("shop icon", 25);

	this.set_string("bookdata", "");
	this.Tag(SHOP_AUTOCLOSE);
	
	AddIconToken("$symbol_gear$", "LibrarySymbols.png", Vec2f(16, 16), 3);
	AddIconToken("$symbol_steam$", "LibrarySymbols.png", Vec2f(16, 16), 4);
	AddIconToken("$symbol_stone$", "LibrarySymbols.png", Vec2f(16, 16), 5);
	AddIconToken("$symbol_fire$", "LibrarySymbols.png", Vec2f(16, 16), 6);
	AddIconToken("$symbol_water$", "LibrarySymbols.png", Vec2f(16, 16), 7);
	AddIconToken("$symbol_holy$", "LibrarySymbols.png", Vec2f(16, 16), 8);
	AddIconToken("$symbol_death$", "LibrarySymbols.png", Vec2f(16, 16), 9);
	AddIconToken("$symbol_chaos$", "LibrarySymbols.png", Vec2f(16, 16), 10);
	AddIconToken("$symbol_nature$", "LibrarySymbols.png", Vec2f(16, 16), 11);
	AddIconToken("$symbol_reset$", "LibrarySymbols.png", Vec2f(16, 16), 2);
	AddIconToken("$symbol_submit$", "LibrarySymbols.png", Vec2f(32, 16), 0);
	
	{
		ShopItem@ s = addShopItem(this, "Bomb Bolt Upgrade", "$symbol_gear$", "upgradebolts", "For Ballista\nTurns its piercing bolts into a shaped explosive charge.", false);
		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		// AddRequirement(s.requirements, "blob", "mat_gold", "Gold", cost_ballista_ammo_upgrade_gold);
		AddRequirement(s.requirements, "not tech", "tech_rocketry", "Bomb Bolt", 1);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		u16 caller, item;
		
		if(!params.saferead_netid(caller) || !params.saferead_netid(item)) return;
		
		string data = params.read_string();
		
		if (data == "upgradebolts")
		{
			GiveFakeTech(getRules(), "tech_rocketry", this.getTeamNum());
		}
	}
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		Animation@ destruction = sprite.getAnimation("destruction");
		if (destruction !is null)
		{
			f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			sprite.animation.frame = frame;
		}
	}
}