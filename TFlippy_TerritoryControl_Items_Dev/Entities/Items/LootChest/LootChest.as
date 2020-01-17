#include "LootSystem.as";
#include "DeityCommon.as";

const LootItem@[] c_items =
{
	// Resources
	LootItem("mat_stone", 0, 1000, 500),
	LootItem("mat_wood", 0, 1000, 500),
	LootItem("mat_copperingot", 0, 16, 400),
	LootItem("mat_ironingot", 0, 64, 500),
	LootItem("mat_goldingot", 0, 64, 100),
	LootItem("mat_steelingot", 0, 64, 400),
	LootItem("mat_concrete", 200, 300, 700),
	LootItem("mat_mithrilingot", 0, 32, 50),
	LootItem("mat_mithril", 0, 100, 250),
	
	// Ammo
	LootItem("mat_rifleammo", 0, 40, 400),
	LootItem("mat_pistolammo", 0, 60, 400),
	LootItem("mat_shotgunammo", 0, 30, 400),
	LootItem("mat_battery", 0, 100, 100),
	LootItem("mat_grenade", 0, 8, 16),
	
	// Weapons
	LootItem("amr", 1, 1, 100),
	LootItem("sniper", 1, 1, 200),
	LootItem("silencedrifle", 1, 1, 250),
	LootItem("taser", 1, 1, 500),
	LootItem("assaultrifle", 1, 0, 750),
	LootItem("fuger", 1, 2, 250),
	LootItem("uzi", 1, 1, 198),
	LootItem("pdw", 1, 1, 400),
	LootItem("sar", 1, 1, 300),
	LootItem("carbine", 1, 1, 400),
	LootItem("beagle", 1, 1, 400),
	LootItem("autoshotgun", 1, 0, 197),
	LootItem("sgl", 1, 0, 100),
	LootItem("rpg", 1, 0, 150),
	LootItem("raygun", 0, 1, 179),
	LootItem("rekt", 1, 0, 15),
	LootItem("zatniktel", 1, 0, 20),
	LootItem("blaster", 1, 0, 25),
	
	// Misc
	LootItem("foodcan", 2, 5, 500),
	LootItem("bp_automation_advanced", 1, 0, 1000),
	LootItem("bp_energetics", 1, 0, 500),
	LootItem("phone", 1, 0, 750),
	LootItem("scubagear", 1, 0, 400),
	LootItem("ninjascroll", 1, 1, 250),
	LootItem("flashlight", 1, 1, 400),
	LootItem("juggernauthammer", 1, 1, 50),
	LootItem("gyromat", 1, 1, 300)
};

void onInit(CBlob@ this)
{
	this.addCommandID("chest_open");

	AddIconToken("$chest_open$", "InteractionIcons.png", Vec2f(32, 32), 20);

	CSprite@ sprite = this.getSprite();
	if(sprite !is null)
	{
		u8 team_color = XORRandom(5);
		this.set_u8("team_color", team_color);

		sprite.SetZ(-10.0f);
		sprite.ReloadSprites(team_color, 0);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getTeamNum() != 250 && !this.hasTag("opened") && caller.get_u8("deity_id") != Deity::foghorn)
	{
		CButton@ button = caller.CreateGenericButton("$chest_open$", Vec2f(0, 0), this, this.getCommandID("chest_open"), "Open");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("chest_open"))
	{
		if (isServer())
		{
			this.server_Die();
		}
	}
}

void onDie(CBlob@ this)
{
	
	if (isServer())
	{
		if (this.hasTag("opened")) return;

		for(int i = 0; i < 3; i++)
		{
			server_SpawnRandomItem(this, @c_items);
		}

		server_SpawnCoins(this, 250 + XORRandom(500));
	}
	else
	{
		CSprite@ sprite = this.getSprite();
		if (sprite !is null)
		{
			sprite.PlaySound("ChestOpen.ogg", 3.0f);
			sprite.Gib();

			makeGibParticle(
			sprite.getFilename(),               // file name
			this.getPosition(),                 // position
			getRandomVelocity(90, 2, 360),      // velocity
			0,                                  // column
			3,                                  // row
			Vec2f(16, 16),                      // frame size
			1.0f,                               // scale?
			0,                                  // ?
			"",                                 // sound
			this.get_u8("team_color"));         // team number
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic() && blob.isCollidable();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}
