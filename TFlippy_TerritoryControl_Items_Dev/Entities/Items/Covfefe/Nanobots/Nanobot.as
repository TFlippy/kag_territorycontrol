#include "Hitters.as";
#include "HittersTC.as";
#include "Explosion.as";

const f32 reproduce_threshold = 50.0f;

void onInit(CBlob@ this)
{
	this.Tag("invincible");
	this.getShape().SetGravityScale(0);
	this.getSprite().SetZ(10.0f);
	
	this.set_f32("fill", reproduce_threshold / 2);
	this.set_u16("target", 0);

	// this.server_SetTimeToDie(60);
	// this.getShape().getConsts().mapCollisions = false;
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("/Nanobot_Loop.ogg");
	sprite.SetEmitSoundPaused(false);
	sprite.SetEmitSoundSpeed(1.0f);
	sprite.SetEmitSoundVolume(1.0f);
}

CBlob@ GetTarget(CBlob@ this)
{
	Vec2f myPos = this.getPosition();
	
	CBlob@[] blobs;
	if (this.getMap().getBlobsInBox(myPos + Vec2f(-256, -256), myPos + Vec2f(256, 256), @blobs))
	{
		// print("" + blobs.length);
	
		f32 dist = 1337;
		uint index = 0;
	
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			f32 d = (b.getPosition() - this.getPosition()).Length();
			
			if (d < dist && !b.hasTag("invincible")) // Damaged or injured blobs
			{
				dist = d;
				index = i;
			}
		}
		
		this.getSprite().PlaySound("/Nanobot_Ping.ogg", 1.00f, 0.50f + XORRandom(100) * 0.01f);
		
		return blobs[index];
	}
	
	return null;
}

void onTick(CBlob@ this)
{
	bool controlled = false;

	CBlob@ remote = getBlobByNetworkID(this.get_u16("remote_netid"));
	if (remote !is null && remote.getName() == "covfefe")
	{
		controlled = true;
	
		Vec2f dir = this.get_Vec2f("tpos") - this.getPosition();
		f32 len = dir.Length();
		dir.Normalize();
		
		this.setVelocity(dir * Maths::Clamp(len * 0.125f, -4, 4));
	}
	else
	{
		CBlob@ tar = getBlobByNetworkID(this.get_u16("target"));	
		if (tar !is null)
		{
			Vec2f dir = tar.getPosition() - this.getPosition();
			f32 len = dir.Length();
			dir.Normalize();
			
			// getMap().server_DestroyTile(this.getPosition() + dir, 0.0625f);

			this.setVelocity(dir * Maths::Clamp(len * 0.125f, -4, 4));
			this.set_u8("mode", 0);
			
			if (isServer())
			{
				if (this.get_f32("fill") >= reproduce_threshold)
				{
					this.set_f32("fill", this.get_f32("fill") - reproduce_threshold);
					CBlob@ swarm = server_CreateBlob("nanobot", -1, this.getPosition());
				}
				
				if (this.getTeamNum() != 255) this.server_setTeamNum(255);
			}
		}
		else
		{
			CBlob@ t = GetTarget(this);
			if (t !is null) this.set_u16("target", t.getNetworkID());
		}
	}
	
	// if (this.get_u8("mode") != 1) getMap().server_DestroyTile(this.getPosition(), 0.0625f);
	
	u8 mode = this.get_u8("mode");
	
	if (mode == 0)
	{
		if (isServer())
		{
			for (int x = 0; x < 3; x++)
			{
				getMap().server_DestroyTile(this.getPosition() + Vec2f(2 - XORRandom(4), 2 -XORRandom(4)) * 8, 0.125f);
			}
		}
	}

	if (getGameTime() % 5 == 0)
	{
		bool hit = false;

		CBlob@[] blobs;
		if (this.getMap().getBlobsInRadius(this.getPosition(), 8.0f, @blobs))
		{
			for (uint i = 0; i < blobs.length; i++)
			{
				CBlob@ b = blobs[i];
				
				if (b.hasTag("invincible")) continue;
				
				f32 damage = b.getInitialHealth() / 8.0f;

				switch (mode)
				{
					case 0:
						if (isServer()) 
						{
							this.server_Hit(b, b.getPosition(), Vec2f(0, 0), damage * (b.hasTag("flesh") ? 4.00f : 1.00f), HittersTC::nanobot, true);
						}
						this.set_f32("fill", this.get_f32("fill") + damage);
						hit = true;
						break;
						
					case 1:
						break;
						
					case 2:
						if (b.hasTag("flesh") || b.hasTag("nature"))
						{
							if (isServer()) this.server_Hit(b, b.getPosition(), Vec2f(0, 0), damage * 4.00f, HittersTC::nanobot, true);
							this.set_f32("fill", this.get_f32("fill") + damage);
							hit = true;
						}
						else
						{
							if (b.getHealth() >= b.getInitialHealth()) break;
						
							if (isServer()) b.server_Heal(damage);
							this.set_f32("fill", this.get_f32("fill") - damage);
							hit = true;
						}
					
						break;
				}
			}
		}
		
		if (hit) this.getSprite().PlaySound("/Nanobot_Attack.ogg", 0.50f, 0.50f + XORRandom(100) * 0.01f);
	}
}

void onDie(CBlob@ this)
{
	 this.getSprite().PlaySound("/Nanobot_Die.ogg", 0.75f, 0.50f + XORRandom(100) * 0.01f);
	 this.getSprite().Gib();
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getName() == "nanobot";
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0;
}