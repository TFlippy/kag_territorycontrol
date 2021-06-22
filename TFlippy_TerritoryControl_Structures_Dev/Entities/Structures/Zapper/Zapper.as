#include "Hitters.as";
#include "HittersTC.as";
#include "Knocked.as";
#include "DeityCommon.as";

const f32 radius = 128.0f;
const f32 damage = 5.00f;
const u32 delay = 90;

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	this.Tag("medium weight");

	this.set_f32("pickup_priority", 16.00f);
	this.getShape().SetRotationsAllowed(false);

	this.getCurrentScript().tickFrequency = 3;
	this.getCurrentScript().runFlags |= Script::tick_not_ininventory | Script::tick_not_attached;

	this.set_bool("security_state", true);
}

void onInit(CSprite@ this)
{
	this.SetEmitSound("Zapper_Loop.ogg");
	this.SetEmitSoundVolume(0.0f);
	this.SetEmitSoundSpeed(0.0f);
	this.SetEmitSoundPaused(false);

	CSpriteLayer@ zap = this.addSpriteLayer("zap", "Zapper_Lightning.png", 128, 12);

	if (zap !is null)
	{
		Animation@ anim = zap.addAnimation("default", 1, false);
		int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
		anim.AddFrames(frames);
		zap.SetRelativeZ(-1.0f);
		zap.SetVisible(false);
		zap.setRenderStyle(RenderStyle::additive);
		zap.SetOffset(Vec2f(0, 0));
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic() && blob.isCollidable();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.getTeamNum() == this.getTeamNum() && GetFuel(this) == 0;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	if (this.getTeamNum() == forBlob.getTeamNum() || (this.getTeamNum() >= 100 && this.getTeamNum() < 200))
	{
		CBlob@ carried = forBlob.getCarriedBlob();
		return (carried is null ? true : carried.getName() == "mat_battery");
	}
	else return false;
}

u8 GetFuel(CBlob@ this)
{
	if (this.getTeamNum() == 250) return 50;

	CInventory@ inv = this.getInventory();
	if (inv != null)
	{
		if (inv.getItem(0) != null) return inv.getItem(0).getQuantity();
	}

	return 0;
}

void SetFuel(CBlob@ this, u8 amount)
{
	if (this.getTeamNum() == 250) return;

	CInventory@ inv = this.getInventory();
	if (inv != null)
	{
		if (inv.getItem(0) != null) inv.getItem(0).server_SetQuantity(amount);
	}
}

void onTick(CBlob@ this)
{
	if (this.get_bool("security_state"))
	{
		u8 fuel = GetFuel(this);
		f32 modifier = f32(fuel) / 50.0f;

		this.getSprite().SetEmitSoundVolume(0.45f);
		this.getSprite().SetEmitSoundSpeed(0.75f + modifier * 0.35f);

		if (this.get_u32("next zap") > getGameTime()) return;
		if (fuel == 0) return;

		CMap@ map = getMap();
		CBlob@[] blobsInRadius;
		if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius))
		{
			int index = -1;
			f32 s_dist = 1337;
			u8 myTeam = this.getTeamNum();

			CBlob@[] spawns;
			getBlobsByName("ruins", @spawns);
			getBlobsByTag("faction_base", @spawns);

			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				u8 team = b.getTeamNum();

				for (uint s = 0; s < spawns.length; s++)
				{
					//Anti spawn killing
					CBlob@ spawn = spawns[s];
					if (b is spawn && spawn.get_bool("isActive") && spawn.getTeamNum() != this.getTeamNum() && 
					    !map.rayCastSolid(this.getPosition(), b.getPosition())) return;
				}

				if (myTeam == 250 && b.get_u8("deity_id") == Deity::foghorn) continue;
				if (team != myTeam && b.hasTag("flesh") && !b.hasTag("dead") && !map.rayCastSolid(this.getPosition(), b.getPosition()))
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
			CPlayer@ host = this.getDamageOwnerPlayer();
			if (target !is null) 
			{
				CPlayer@ _target = target.getPlayer();
				if (host !is null && _target is host) //recognizes host and changes team
				{
					this.server_setTeamNum(_target.getTeamNum());
					return;
				}
			}
			Zap(this, target);
		}
	}
}

void onTick(CSprite@ this)
{
	this.SetFacingLeft(false);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("security_set_state"))
	{
		bool state = params.read_bool();

		CSprite@ sprite = this.getSprite();
		sprite.SetFrameIndex(state ? 0 : 1);
		sprite.SetEmitSoundPaused(!state);
		sprite.PlaySound(state ? "Security_TurnOn" : "Security_TurnOff", 0.30f, 1.00f);
		this.set_bool("security_state", state);
	}
}

void Zap(CBlob@ this, CBlob@ target)
{
	if (this.get_u32("next zap") > getGameTime()) return;

	int fuel = GetFuel(this);

	Vec2f dir = target.getPosition() - this.getPosition();
	f32 dist = Maths::Abs(dir.Length());
	dir.Normalize();

	SetKnocked(target, 60);
	this.set_u32("next zap", getGameTime() + delay);

	if (isServer())
	{
		this.server_Hit(target, target.getPosition(), Vec2f(0, 0), damage, HittersTC::electric, true);
		SetFuel(this, Maths::Max(0, fuel - 5));
	}

	if (isClient())
	{
		bool flip = this.isFacingLeft();

		CSpriteLayer@ zap = this.getSprite().getSpriteLayer("zap");
		if (zap !is null)
		{
			zap.ResetTransform();
			zap.SetFrameIndex(0);
			zap.ScaleBy(Vec2f(dist / 128.0f - 0.1f, 1.0f));
			zap.TranslateBy(Vec2f((dist / 2), 2.0f));
			zap.RotateBy(-dir.Angle(), Vec2f());
			zap.SetVisible(true);
		}

		this.getSprite().PlaySound("Zapper_Zap" + XORRandom(3), 1.00f, 1.00f);
	}
}
