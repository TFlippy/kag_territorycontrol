#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";

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
	this.add_f32("propeskoed", 0.001f);
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
	if (isServer())
	{
		CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		if (boom !is null)
		{
			boom.setPosition(this.getPosition());
			boom.set_u8("boom_start", 0);
			boom.set_u8("boom_end", Maths::Ceil(Maths::Sqrt(this.get_f32("propeskoed")) * 2.00f));
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