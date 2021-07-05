#include "Hitters.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

const u32 wagon_count = 4;
const f32 wagon_offset = 1.5f;
const f32 speed = 4.00f;
// const f32 speed = 0.10f;
// Vec2f smokeOffset = Vec2f(-28, -17);
Vec2f smokeOffset = Vec2f(-28, -28);

void onInit(CBlob@ this)
{
	UpdateMinimap(this);

	this.getShape().SetGravityScale(0.0f);
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().transports = true;

	this.SetMapEdgeFlags(CBlob::map_collide_none | CBlob::map_collide_nodeath);

	// this.setPosition(Vec2f(this.getPosition().x, yPos));

	this.Tag("train");
	this.Tag("invincible");

	this.SetLight(true);
	this.SetLightRadius(96.0f);
	this.SetLightColor(SColor(255, 255, 150, 50));

	this.addCommandID("reset train");

	if (isClient())
	{
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSoundVolume(10.0f);
		sprite.SetEmitSound("Train_Loop.ogg");
		sprite.SetEmitSoundPaused(false);
		sprite.RewindEmitSound();
	}

	if (isServer())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();

		map.server_AddSector(Vec2f(0, pos.y + 12), Vec2f(map.tilemapwidth * 8, pos.y - 36), "no build", "", this.getNetworkID());

		for (int i = 0; i < wagon_count; i++)
		{
			CBlob@ wagon = server_CreateBlob("wagon", this.getTeamNum(), this.getPosition());
			if (wagon != null)
			{
				//UpdateMinimap(wagon, 22);
				this.set_u16("wagon_" + i, wagon.getNetworkID());
			}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer() && blob !is null && !blob.hasTag("train") && !blob.hasTag("nature"))
	{
		if (blob.getPosition().x > this.getPosition().x + 24)
		{
			this.server_Hit(blob, this.getPosition(), Vec2f(speed, 0), 10000.0f, Hitters::crush, true);
		}
	}
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	CSprite@ sprite = this.getSprite();
	const bool server = isServer();
	const bool client = isClient();

	if (this.getPosition().x > (map.tilemapwidth + 50) * 8)
	{
		if (!this.hasTag("stop train"))
		{
			UpdateMinimap(this, 25);
			sprite.SetEmitSoundPaused(true);
			// this.setPosition(Vec2f(0, this.getPosition().y));

			for (int i = 0; i < wagon_count; i++)
			{
				CBlob@ wagon = getBlobByNetworkID(this.get_u16("wagon_" + i));
				if (wagon !is null)
				{
					//UpdateMinimap(wagon, 25);
					wagon.getSprite().SetEmitSoundPaused(true);
					wagon.setPosition(this.getPosition());
				}
			}
		}

		if (!this.hasTag("stop train")) this.Tag("stop train");

		this.getCurrentScript().tickFrequency = 30;

		if (server)
		{
			if (XORRandom(300) == 0) this.SendCommand(this.getCommandID("reset train"));
		}
	}
	else if (!this.hasTag("stop train"))
	{
		this.getCurrentScript().tickFrequency = 1;

		if (!this.exists("train_y")) this.set_f32("train_y", this.getPosition().y);

		Vec2f pos = Vec2f(this.getPosition().x + speed, this.get_f32("train_y"));

		this.setVelocity(Vec2f(0, 0));
		this.setPosition(pos);

		for (int i = 0; i < wagon_count; i++)
		{
			CBlob@ wagon = getBlobByNetworkID(this.get_u16("wagon_" + i));
			if (wagon !is null)
			{
				wagon.setVelocity(Vec2f(0, 0));
				wagon.setPosition(pos + Vec2f(-80 * (1 + i), wagon_offset + Maths::Sin(((getGameTime() + (60 * i)) * 0.50f) % 180) * 0.50f));
				wagon.getSprite().SetEmitSoundPaused(false);

				if (client) ShakeScreen(80, 50, wagon.getPosition());
			}
		}

		if (client) 
		{
			ShakeScreen(80, 50, this.getPosition());

			sprite.SetEmitSoundPaused(false);
			MakeParticle(this, "LargeSmoke");
		}
	}
}

void UpdateMinimap(CBlob@ this, int frame = 23)
{
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", frame, Vec2f(16, 8));
	this.SetMinimapRenderAlways(true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !blob.hasTag("train");
}

void MakeParticle(CBlob@ this, const string filename = "SmallSteam")
{
	ParticleAnimated(filename, this.getPosition() + smokeOffset, Vec2f(0, 0), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

const string[] loot_guns = 
{ 
	"amr",
	"sniper",
	"uzi",
	"assaultrifle",
	"autoshotgun",
	"fuger"
};

const string[] loot_building_resources = 
{ 
	"mat_stone",
	"mat_concrete",
	"mat_dirt",
	"mat_wood",
	"mat_ironingot"
};

const string[] loot_ores = 
{ 
	"mat_iron",
	"mat_gold",
	"mat_mithril",
	"mat_sulphur",
	"mat_copper",
	"mat_coal"
};

const string[] loot_explosives = 
{ 
	"mat_smallbomb",
	"mat_mininuke",
	"mat_incendiarybomb",
	"mat_tankshell"
};

const string[] loot_bling = 
{ 
	"mat_goldingot",
	"mat_mithrilenriched"
};

const string[] loot_food = 
{ 
	"mat_meat"
};

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("reset train"))
	{
		const bool server = isServer();
		const bool client = isClient();

		this.Untag("stop train");

		UpdateMinimap(this);

		this.setPosition(Vec2f(0, this.get_f32("train_y")));

		if (client)
		{
			client_AddToChat("A UPF Freight Train is passing through the valley!", SColor(255, 255, 0, 0));
			Sound::Play("Train_Horn_Distant.ogg");
		}

		if (server)
		{
			for (int i = 0; i < wagon_count; i++)
			{
				CBlob@ wagon = getBlobByNetworkID(this.get_u16("wagon_" + i));
				if (wagon !is null)
				{
					//UpdateMinimap(wagon, 22);

					CInventory@ inv = wagon.getInventory();
					if (inv !is null)
					{
						u16 type = XORRandom(10);

						for (int i = 0; inv.getItemsCount() < 8; i++)
						{
							string item_config;
							u32 quantity = 0;
							bool skip = false;

							switch (type)
							{
								case 0:
									item_config = loot_guns[XORRandom(loot_guns.length)];
								break;

								case 1:
								case 2: 
								case 3: 
								case 4: 
									item_config = loot_building_resources[XORRandom(loot_building_resources.length)];
									quantity = XORRandom(250);
								break;

								case 5:
								case 6:
									item_config = loot_ores[XORRandom(loot_ores.length)];
									quantity = XORRandom(250);
								break;

								case 7:
									item_config = loot_explosives[XORRandom(loot_explosives.length)];
									quantity = XORRandom(2);
								break;

								case 8:
									item_config = loot_bling[XORRandom(loot_bling.length)];
									quantity = XORRandom(16);
								break;

								case 9:
									item_config = loot_food[XORRandom(loot_food.length)];
									quantity = XORRandom(250);
								break;

								default:
									skip = true;
								break;
							}

							if (!skip)
							{
								CBlob@ item = server_CreateBlob(item_config, 250, this.getPosition());
								if (item !is null)
								{
									if (quantity > 0) item.server_SetQuantity(quantity);
									wagon.server_PutInInventory(item);
								}
							}
						}
					}
				}
			}
		}
	}
}
