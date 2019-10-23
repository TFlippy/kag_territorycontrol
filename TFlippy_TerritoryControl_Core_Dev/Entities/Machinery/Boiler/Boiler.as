// TFlippy's Steam Power

#include "MakeDustParticle.as";
#include "Explosion.as";

const string fuel = "mat_wood";
const u8 baseTickRate = 30;

const f32 boostBase = 50;
const f32 boostMax = 2.5f;
const f32 boostMin = 0.25f; 

const u16 waterMax = 50000; // Mililitres, each bucket is 6000ml

const f32 searchRadius = 60.0f;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	AddIconToken("$store_inventory$", "InteractionIcons.png", Vec2f(32, 32), 28);
	this.inventoryButtonPos = Vec2f(0, 6);
	this.getCurrentScript().tickFrequency = baseTickRate;
	
	this.addCommandID("addwater");
	this.set_u16("water_amount", 0);
	
	UpdateInfo(this);
}

void onTick(CBlob@ this)
{
	CBlob@ blob = this.getInventory().getItem(0);
	if (blob is null) return;
	
	u16 fuelAmount = blob.getQuantity() * blob.get_u8("fuel_energy");

	if (fuelAmount > 0 && this.get_u16("water_amount") > 0)
	{
		f32 boost = Maths::Max(boostMin, Maths::Min(boostMax, fuelAmount / boostBase));
		boost = boost * Maths::Max(1, this.getInventory().getCount("gyromat") * 1.10f);
		
		u16 consumedWater = 120 + (this.getInventory().getCount("gyromat") * 1.2f);
		
		this.getCurrentScript().tickFrequency = baseTickRate / boost;
		
		this.getSprite().PlaySound("ProduceSound.ogg", 0.6f + (boost / 20.0f), 0.4f + (boost / 15.0f));
		// MakeDustParticle(this.getPosition(), "Smoke.png");

		makeSteamParticle(this, this.getPosition() + Vec2f(0, -8), Vec2f(), "SmallSteam");
		
		this.set_u16("water_amount", Maths::Round(Maths::Max(0, Maths::Min(waterMax, this.get_u16("water_amount") - consumedWater))));
		this.getInventory().server_RemoveItems(fuel, 1 + (1 * this.getInventory().getCount("gyromat")));
				
		this.SetLight(true);
		this.SetLightRadius(24.0f * boost);
		this.SetLightColor(SColor(255, 255, 128, 0));
				
		UpdateInfo(this);
		GenerateSteam(this, 75);
	}
	else
	{
		this.SetLight(false);
	}
}

void UpdateInfo(CBlob@ this)
{
	this.setInventoryName("Boiler\n\nWater: " + this.get_u16("water_amount") / 1000 + "l\nFuel: " + this.getInventory().getCount(fuel) +  " units\nOutput: " + 75 / this.getCurrentScript().tickFrequency + " Steam/t");
}

void GenerateSteam(CBlob@ this, u16 inAmount)
{
	CBlob@[] blobsInRadius;
	this.getMap().getBlobsInRadius(this.getPosition(), searchRadius, @blobsInRadius);
	
	for (uint i = 0; i < blobsInRadius.length; i++)
	{
		CBlob @b = blobsInRadius[i];
		if (b.getName() == "steamtank")
		{
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBlob@ carried = caller.getCarriedBlob();

	CBitStream params;
	params.write_u16(caller.getNetworkID());

	if (carried !is null && carried.getName() == "bucket")
	{
		params.write_u8(carried.get_u8("filled"));
	
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this, this.getCommandID("addwater"), "Fill with water.", params);
		if (carried.get_u8("filled") > 0) button.SetEnabled(true); else button.SetEnabled(false);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("addwater"))
	{
	    CBlob@ caller = getBlobByNetworkID(params.read_u16());
		CBlob@ carried = caller.getCarriedBlob();
		
		if (caller !is null && carried !is null && carried.getName() == "bucket")
		{
			this.set_u16("water_amount", Maths::Round(Maths::Max(0, Maths::Min(waterMax, this.get_u16("water_amount") + params.read_u8() * 2000))));
			carried.set_u8("filled", 0);
			carried.getSprite().SetAnimation("empty");
			
			UpdateInfo(this);
		}
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	onTick(this);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{

}

void onDie(CBlob@ this)
{
	Explode(this, 10.0f, 2.0f);
	CMap@ map = getMap();
	
	this.getSprite().PlaySound("Steam.ogg", 1.7f, 1.1f);
	
	for (int i = 0; i < 8; i++)
	{
		Vec2f pos = this.getPosition() + Vec2f(this.getPosition().x + (XORRandom(4) - 2), this.getPosition().y + (XORRandom(4) - 2));

		makeSteamParticle(this, pos, Vec2f(), "MediumSteam");
		map.server_setFireWorldspace(pos, false);
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	CBlob@ carried = forBlob.getCarriedBlob();
	return (forBlob.isOverlapping(this) && (carried is null) || (carried !is null && (carried.exists("fuel_energy") || carried.getName() == "gyromat")));
}

void makeSteamParticle(CBlob@ this, Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	const f32 rad = this.getRadius();
	ParticleAnimated(filename, pos, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}


