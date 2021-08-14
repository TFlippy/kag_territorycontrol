#include "Hitters.as";
#include "HittersTC.as";
#include "MakeMat.as";
#include "MaterialCommon.as";

// A script by TFlippy

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.SetEmitSound("MithrilReactor_Loop.ogg");
		sprite.SetEmitSoundVolume(0.25f);
		sprite.SetEmitSoundSpeed(1.0f);
		sprite.SetEmitSoundPaused(false);
	}
	
	this.getCurrentScript().tickFrequency = 10;
	this.getSprite().SetZ(-10.0f);
	
	this.set_f32("irradiation", 0.00f);
	this.set_f32("upgrade", 0.00f);

	this.addCommandID("upgrade");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller) //Mutate button
{
	CBlob@ carried = caller.getCarriedBlob();

	if (carried != null && carried.getName() == "mat_mithrilingot")
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton(23, Vec2f(0, -6), this, this.getCommandID("upgrade"), "Upgrade Reactor", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) //Mutate command
{
	if (cmd == this.getCommandID("upgrade"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			CBlob@ carried = caller.getCarriedBlob();
			if (carried !is null && carried.getName() == "mat_mithrilingot")
			{
				if (carried.getQuantity() >= 1)
				{
					
					int remain = carried.getQuantity() - 1;
					if (remain > 0)
					{
						carried.server_SetQuantity(remain);
					}
					else
					{
						carried.Tag("dead");
						carried.server_Die();
					}
					this.add_f32("upgrade", 1000.00f);
				}
			}
		}
	}
}

void onTick(CBlob@ this)
{
	CInventory@ inv = this.getInventory();
	if (inv !is null)
	{
		const bool water = this.isInWater();
		
		f32 modifier = 1.00f;
		const f32 mithril_count = inv.getCount("mat_mithril");
		const f32 e_mithril_count = inv.getCount("mat_mithrilenriched");
		const f32 gold_count = inv.getCount("mat_gold");
		const f32 upgrade = this.get_f32("upgrade");
		
		const f32 irradiation = Maths::Pow((mithril_count * 3.00f) + (e_mithril_count * 15.00f), 2) / 400.00f;
		const f32 max_irradiation = water ? 30000.00f + upgrade : 9000.00f + (upgrade / 4);
		
		this.set_f32("irradiation", irradiation);
		
		this.setInventoryName("Mithril Reactor\nIrradiation: " + Maths::Round(irradiation) + " / " + max_irradiation);
		
		if (irradiation > max_irradiation * 0.50f)
		{
			const f32 rmod = (irradiation - (max_irradiation * 0.50f)) / (max_irradiation * 0.50f);
			// print("" + rmod);
		
			if (isServer()) 
			{
				server_Irradiate(this, irradiation / max_irradiation * rmod, irradiation / 100.00f * rmod);
			}
			
			if (isClient()) 
			{
				ShakeScreen(20 * rmod, 100 * rmod, this.getPosition());	
			}
		}

		if (irradiation > max_irradiation)
		{
			this.Tag("dead");
			if (isServer())
			{	
				this.server_Die();
			}
		}
		
		if (isClient())
		{
			CSprite@ sprite = this.getSprite();
			if (sprite !is null)
			{
				sprite.SetEmitSoundVolume(0.25f);
				sprite.SetEmitSoundSpeed(0.25f + irradiation / 5000.00f);
			}
		}
		
		if (isServer())
		{
			f32 count = (mithril_count / 75) + (e_mithril_count / 25);
			// print("" + count);
		
			this.set_u8("boom_end", u8(count)); // Hack
		
			if (irradiation / 50.00f > XORRandom(100))
			{	
				CBlob@ mithril_blob = inv.getItem("mat_mithril");
				CBlob@ e_mithril_blob = inv.getItem("mat_mithrilenriched");
				CBlob@ gold_blob = inv.getItem("mat_gold");

				if (e_mithril_blob !is null)
				{ 
					if (gold_blob !is null)
					{
						const u32 gold_quantity = gold_blob.getQuantity();
						const f32 amount = e_mithril_count / 100.00f;

						Material::createFor(this, "mat_mithril", Maths::Ceil(amount * 1.50f));
						gold_blob.server_SetQuantity(Maths::Max(gold_quantity - Maths::Ceil(amount), 0));
					}
				}
				
				if (mithril_blob !is null)
				{
					const u32 mithril_quantity = mithril_blob.getQuantity();
					const f32 amount = mithril_count / 250.00f;
				
					if (irradiation / 1500.00f > XORRandom(100)) 
					{
						const f32 amount_em = irradiation / 2500.0f;
					
						Material::createFor(this, "mat_mithrilenriched", Maths::Ceil(amount_em));
						mithril_blob.server_SetQuantity(Maths::Max(mithril_quantity - Maths::Ceil(amount_em * 4.00f), 0));
					}
					
					if (gold_blob !is null)
					{
						const u32 gold_quantity = gold_blob.getQuantity();
						
						Material::createFor(this, "mat_mithril", Maths::Ceil(amount * 0.50f));
						gold_blob.server_SetQuantity(Maths::Max(gold_quantity - Maths::Ceil(amount), 0));
					}
				}
			}
		}
	}
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		boom.setPosition(this.getPosition());
		boom.set_u8("boom_start", 0);
		boom.set_u8("boom_end", this.get_u8("boom_end"));
		boom.set_f32("mithril_amount", 25);
		boom.set_f32("flash_distance", 1000);
		// boom.Tag("no mithril");
		boom.Init();
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return !this.getMap().rayCastSolid(forBlob.getPosition(), this.getPosition());
}

void server_Irradiate(CBlob@ this, const f32 damage, const f32 radius)
{
	if (isServer())
	{
		// print("radius: " + radius + "; damage: " + damage);
	
		CBlob@[] blobsInRadius;
		if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius))
		{
			for (int i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ blob = blobsInRadius[i];
				if ((blob.hasTag("flesh") || blob.hasTag("nature")) && !blob.hasTag("dead"))
				{
					Vec2f pos = this.getPosition();
					Vec2f dir = blob.getPosition() - pos;
					f32 len = dir.Length();
					dir.Normalize();

					int counter = 1;

					for(int i = 0; i < len; i += 8)
					{
						if (getMap().isTileSolid(pos + dir * i)) counter++;
					}
					
					f32 distMod = Maths::Max(0, (1.00f - ((this.getPosition() - blob.getPosition()).Length() / radius)));
					
					if (XORRandom(100) < 100.0f * distMod) 
					{
						this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), damage / counter, HittersTC::radiation, true);
					}
				}
			}
		}
	}
}

void onAddToInventory( CBlob@ this, CBlob@ blob )
{
	if(blob.getName() != "gyromat") return;

	this.getCurrentScript().tickFrequency = 10 / (this.exists("gyromat_acceleration") ? this.get_f32("gyromat_acceleration") : 1);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	if(blob.getName() != "gyromat") return;
	
	this.getCurrentScript().tickFrequency = 10 / (this.exists("gyromat_acceleration") ? this.get_f32("gyromat_acceleration") : 1);
}