// Princess brain

#include "Hitters.as";
#include "HittersTC.as";
#include "Knocked.as";

const f32 radius = 128.0f;

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");

	this.set_f32("pickup_priority", 16.00f);
	this.getShape().SetRotationsAllowed(false);
	
	this.getCurrentScript().tickFrequency = 3;
	this.getCurrentScript().runFlags |= Script::tick_not_ininventory | Script::tick_not_attached;
}

void onInit(CSprite@ this)
{
	this.SetEmitSound("fieldgenerator_loop.ogg");
	this.SetEmitSoundVolume(0.0f);
	this.SetEmitSoundSpeed(0.0f);
	
	this.SetEmitSoundPaused(false);
					
	CSpriteLayer@ shield = this.addSpriteLayer("shield", "Shield.png" , 16, 64, this.getBlob().getTeamNum(), 0);

	if (shield !is null)
	{
		Animation@ anim = shield.addAnimation("default", 3, false);
		
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		anim.AddFrame(4);
		anim.AddFrame(5);
		anim.AddFrame(6);
		anim.AddFrame(7);
		
		shield.SetRelativeZ(-1.0f);
		shield.SetVisible(false);
		shield.setRenderStyle(RenderStyle::outline_front);
		shield.SetIgnoreParentFacing(true);
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.getTeamNum() == this.getTeamNum() && GetFuel(this) == 0;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	CBlob@ carried = forBlob.getCarriedBlob();
	return (carried is null ? true : carried.getName() == "mat_mithril");
}

u8 GetFuel(CBlob@ this)
{
	CInventory@ inv = this.getInventory();
	if (inv != null)
	{
		if (inv.getItem(0) != null) return inv.getItem(0).getQuantity();
	}
	
	return 0;
}

void SetFuel(CBlob@ this, u8 amount)
{
	CInventory@ inv = this.getInventory();
	if (inv != null)
	{
		if (inv.getItem(0) != null) inv.getItem(0).server_SetQuantity(amount);
	}
}

void onTick(CBlob@ this)
{
	u8 fuel = GetFuel(this);
	f32 modifier = f32(fuel) / 250.0f;
	
	this.getSprite().SetEmitSoundVolume(0.20f + modifier * 0.2f);
	this.getSprite().SetEmitSoundSpeed(0.75f + modifier * 0.35f);
	
	if (fuel == 0) return;
	
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius))
	{
		int index = -1;
		f32 s_dist = 1337;
		u8 myTeam = this.getTeamNum();
	
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			u8 team = b.getTeamNum();
			
			if (team != myTeam && (((b.hasTag("explosive") && b.getVelocity().y > 5) || b.hasTag("flesh") || b.getName() == "nanobot")))
			{
				f32 dist = (b.getPosition() - this.getPosition()).Length();
				if (dist < s_dist)
				{
					s_dist = dist;
					index = i;
				}
			}
		}
		
		if (index < 0) return;
		
		CBlob@ target = blobsInRadius[index];
		Zap(this, target);
		
		// print("" + target.getName());	
	}
}

void Zap(CBlob@ this, CBlob@ target)
{
	if (target.get_u32("next zap") > getGameTime()) return;

	u8 fuel = GetFuel(this);
	
	Vec2f dir = target.getPosition() - this.getPosition();
	f32 dist = Maths::Abs(dir.Length());
	dir.Normalize();
	
	target.setVelocity(Vec2f(dir.x, dir.y) * 7.0f);
	SetKnocked(target, 90);
	target.set_u32("next zap", getGameTime() + 5);
	
	if (isServer())
	{
		f32 damage = target.getInitialHealth() * 0.75f;
		this.server_Hit(target, target.getPosition(), dir, damage * (target.hasTag("explosive") ? 16.00f : 1.00f) , HittersTC::forcefield);
		
		if (target.getName() == "nanobot") target.server_Die();
		
		// print("damage: " + u8(Maths::Ceil(damage)));
		SetFuel(this, fuel - u8(Maths::Ceil(damage)));
	}
	
	if (isClient())
	{
		this.getSprite().PlaySound("energy_disintegrate_" + XORRandom(2) + ".ogg");
		
		CSpriteLayer@ shield = this.getSprite().getSpriteLayer("shield");
		shield.SetVisible(true);
		shield.setRenderStyle(RenderStyle::outline_front);
		
		// shield.SetIgnoreParentFacing(true);
		shield.SetFrameIndex(0);
		shield.SetAnimation("default");
		
		shield.ResetTransform();
		
		// bool left = this.getSprite().isFacingLeft();
		
		shield.RotateBy(dir.Angle() * -1.00f, Vec2f());
		shield.TranslateBy(dir * (radius - 8.0f));
		
		// shield.RotateBy((left ? 0 : 0) + dir.Angle() * (left ? 1 : -1), Vec2f());
		// shield.TranslateBy(dir * dist * (left ? -1 : 1));
		// shield.RotateBy((left ? 0 : -45) + dir.Angle(), Vec2f());
	}
}