#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";

const f32 max_time = 3.00f;

void onInit(CBlob@ this)
{

}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	this.add_f32("propeskoed", 0.0005f);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if (blob !is null ? !blob.isCollidable() : !solid)
	{
		return;
	}
	
	f32 vellen = this.getOldVelocity().Length();
	if (vellen > 3.00f)
	{
		f32 level = Maths::Sqrt(this.get_f32("propeskoed"));
		// print("" + vellen + " > " + (25.00f / level));
		
		if (vellen > (25.00f / level)) 
		{
			if (isServer())
			{
				this.server_Die();
			}
		}
	}
}

void DoExplosion(CBlob@ this)
{
	if (getNet().isServer())
	{
		CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		if (boom !is null)
		{
			boom.setPosition(this.getPosition());
			boom.set_u8("boom_start", 0);
			boom.set_u8("boom_end", Maths::Ceil(Maths::Sqrt(this.get_f32("propeskoed"))));
			boom.set_u8("boom_frequency", 1);
			boom.set_u32("boom_delay", 0);
			boom.set_u32("flash_delay", 0);
			boom.Tag("no fallout");
			boom.Tag("no flash");
			boom.Tag("no mithril");
			boom.Init();
		}
	}
}