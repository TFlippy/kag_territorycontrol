// A script by TFlippy & Pirate-Rob

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";
#include "BuilderHittable.as";
#include "Hitters.as";

const string[] resources = 
{
	"mat_iron",
	"mat_copper",
	"mat_stone",
	"mat_gold",
	"mat_coal",
	"mat_dirt"
};

const u8[] resourceYields = 
{
	3,
	3,
	7,
	2,
	3,
	4
};

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	this.getCurrentScript().tickFrequency = 60;
	
	this.set_bool("isActive", false);
	this.addCommandID("sv_toggle");
	this.addCommandID("cl_toggle");
	
	// SetState(this, this.get_bool("isActive"));
}

void onInit(CSprite@ this)
{
	this.SetEmitSound("Drill.ogg");
	this.SetEmitSoundVolume(0.1f);
	this.SetEmitSoundSpeed(0.5f);
	
	this.SetEmitSoundPaused(!this.getBlob().get_bool("isActive"));
}

void onTick(CBlob@ this)
{
	if (isServer())
	{
		if (!this.get_bool("isActive")) return;
	
		CMap@ map = getMap();
		
		f32 depth = XORRandom(48);
		Vec2f pos = Vec2f(this.getPosition().x + (XORRandom(32) - 16) * (1 - depth / 48), Maths::Min(this.getPosition().y + 16 + depth, (map.tilemapheight * map.tilesize) - 8));

		this.server_HitMap(pos, Vec2f(0, 0), 1.3f, Hitters::drill);
	}
}

void onHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	if (isServer())
	{
		TileType tile = getMap().getTile(worldPoint).type;
		
		if (tile == CMap::tile_bedrock)
		{
			u8 index = XORRandom(resources.length);
			MakeMat(this, worldPoint, resources[index], XORRandom(resourceYields[index]*2));
			
			// this.server_Hit(this, this.getPosition(), Vec2f(0, 0), 0.02f, Hitters::drill, true);
			
			// print("ore: " + resources[XORRandom(index)] + " yield: " + XORRandom(resourceYields[index]));
		}
	}
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		server_CreateBlob("drill", this.getTeamNum(), this.getPosition());
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (isServer())
	{
		if (cmd == this.getCommandID("sv_toggle"))
		{
			bool active = params.read_bool();
			
			this.set_bool("isActive", active);

			// print("sv: " + active);
			
			CBitStream stream;
			stream.write_bool(active);
			this.SendCommand(this.getCommandID("cl_toggle"), stream);
		}
	}
	
	if (isClient())
	{
		if (cmd == this.getCommandID("cl_toggle"))
		{		
			bool active = params.read_bool();
		
			// print("cl: " + active);
		
			this.set_bool("isActive", active);
		
			CSprite@ sprite = this.getSprite();
		
			sprite.PlaySound("LeverToggle.ogg");
			sprite.SetEmitSoundPaused(!active);
			sprite.SetAnimation(active ? "active" : "inactive");
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!this.isOverlapping(caller)) return;
	
	CBitStream params;
	params.write_bool(!this.get_bool("isActive"));
	
	CButton@ buttonEject = caller.CreateGenericButton(11, Vec2f(0, -8), this, this.getCommandID("sv_toggle"), (this.get_bool("isActive") ? "Turn Off" : "Turn On"), params);
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

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob.getName() == "extractor" || forBlob.getName() == "filterextractor" || forBlob.isOverlapping(this));
}