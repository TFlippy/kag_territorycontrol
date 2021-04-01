#include "Hitters.as";
#include "Explosion.as";
#include "Knocked.as"
#include "FireworkPatterns.as"

const f32 max_distance = 150.00f;

void onInit(CBlob@ this)
{
	this.Tag("explosive");

	this.set_f32("bomb angle", 90);
	this.addCommandID("offblast");

	this.set_f32("map_damage_ratio", 0.5f);
	this.set_f32("map_damage_radius", 48.0f);

	this.set_string("custom_explosion_sound", "");

	this.Tag("map_damage_dirt");
	this.Tag("no explosion particles");

	if (!this.exists("velocity")) this.set_f32("velocity", 5.0f);
	if (!this.exists("direction")) this.set_Vec2f("direction", Vec2f(0, -1));

	this.set_u8("pattern", this.getNetworkID() % 13);

	this.getShape().SetRotationsAllowed(true);
}

void onTick(CBlob@ this)
{
	if (this.hasTag("offblast"))
	{
		Vec2f dir = Vec2f((XORRandom(200) - 100) / 100.00f, -1);
		const f32 ratio = 0.50f;

		Vec2f nDir = (this.get_Vec2f("direction") * (1.00f - ratio)) + (dir * ratio);
		nDir.Normalize();

		this.SetFacingLeft(false);

		this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.2f, 10.0f));
		this.setAngleDegrees(-nDir.getAngleDegrees() + 90);
		this.setVelocity(nDir * this.get_f32("velocity"));
		this.set_Vec2f("direction", nDir);

		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if(point !is null)
		{
			CBlob@ holder = point.getOccupied();

			if (holder !is null)
			{
				holder.setVelocity(nDir * this.get_f32("velocity"));
			}
		}

		if (isServer())
		{
			if (getGameTime() >= this.get_u32("explosion_timer") || this.getPosition().y < 64)
			{
				this.server_Die();
			}
		}

		if (isClient())
		{
			MakeParticle(this, -nDir, XORRandom(100) < 30 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallFire" + (1 + XORRandom(2)));
		}
	}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return false;
}

const u32[] teamcolours = {0xff0000ff, 0xffff0000, 0xff00ff00, 0xffff00ff, 0xffff6600, 0xff00ffff, 0xff6600ff, 0xff647160};

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}

	if (this.hasTag("dead")) return;

	f32 random = XORRandom(16);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = -this.get_f32("bomb angle");
	// print("Modifier: " + modifier + "; Quantity: " + this.getQuantity());

	this.set_f32("map_damage_radius", (40.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.25f);

	Explode(this, 40.0f + random, 10.0f);

	for (int i = 0; i < 4 * modifier; i++)
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();

		LinearExplosion(this, dir, 8.0f + XORRandom(16) + (modifier * 8), 8 + XORRandom(24), 3, 0.125f, Hitters::explosion);
	}

	if (isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();

		u32 color = this.getTeamNum() < teamcolours.length ? teamcolours[this.getTeamNum()] : teamcolours[XORRandom(teamcolours.length)];

		switch (this.get_u8("pattern"))
		{
			case 0:
			{
				Explode_Generic(this, 100, color);
				Explode_InnerCircles(this, 200, color);
			}
			break;

			case 1:
			{
				Explode_Generic(this, 100, color);
				Explode_Circle(this, 100, color);
			}
			break;

			case 2:
			{
				Explode_Generic(this, 100, color);
				Explode_Helix(this, 100, color);
			}
			break;

			case 3:
			{
				Explode_Generic(this, 100, color);
				Explode_Spiral(this, 150, color);
			}
			break;

			case 4:
			{
				Explode_Generic(this, 100, color);
				Explode_Ovals(this, 50, color);
			}
			break;

			case 5:
			{
				Explode_Generic(this, 100, color);
				Explode_Flower(this, 200, color);
			}
			break;

			case 6:
			{
				Explode_Generic(this, 100, color);
				Explode_Flower_Two(this, 150, color);
			}
			break;

			case 7:
			{
				Explode_Generic(this, 100, color);
				Explode_Flower_Three(this, 250, color);
			}
			break;

			case 8:
			{
				Explode_Generic(this, 100, color);
				Explode_Star(this, 100, color);
			}
			break;

			case 9:
			{
				Explode_Generic(this, 100, color);
				Explode_Pattern(this, @doge, color);
			}
			break;

			case 10:
			{
				Explode_Generic(this, 100, color);
				Explode_Pattern(this, @gg, color);
			}
			break;

			case 11:
			{
				Explode_Generic(this, 100, color);
				Explode_Pattern(this, @jebb, color);
			}
			break;

			case 12:
			{
				Explode_Generic(this, 100, color);
				Explode_Pattern(this, @cat, color);
			}
			break;

			default:
			{
				Explode_Generic(this, 500, color);
			}
			break;
		}

		CBlob@ localBlob = getLocalPlayerBlob();
		if (localBlob !is null)
		{
			if (Maths::Abs(localBlob.getPosition().x - pos.x) < max_distance)
			{
				SColor c = SColor(color) + SColor(255, XORRandom(255), XORRandom(255), XORRandom(255));
				SetScreenFlash(100, c.getRed(), c.getGreen(), c.getBlue());

				f32 distance = (this.getPosition() - localBlob.getPosition()).getLength();
				Sound::Play("Firework_Boom" + XORRandom(3), localBlob.getPosition(), 1.00f, 0.80f);
			}
		}
	}

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (point !is null)
	{
		CBlob@ holder = point.getOccupied();
		if (holder !is null)
		{
			SetKnocked(holder, 90);
		}
	}

	this.Tag("dead");
	this.getSprite().Gib();
}

void Explode_Flower(CBlob@ this, int count, SColor color)
{
	Vec2f pos = this.getPosition();
	const f32 seg = 2.00f * Maths::Pi / count;

	for (int i = 0; i < count; i++)
	{
		Vec2f dir = Vec2f(Maths::Cos(i * seg), Maths::Sin(i * seg));
		Vec2f ppos = pos + dir * 4.00f;
		f32 vel = Maths::Abs(Maths::Sin(f32(i)))*3;

		CParticle@ p = ParticlePixel(ppos, dir * vel, SColor(color) + SColor(255, XORRandom(255), XORRandom(255), XORRandom(255)), true, 30 + XORRandom(45));
		if (p !is null)
		{
			p.gravity = Vec2f(0, 0.01f + (XORRandom(100) * 0.0001f));
			p.scale = 3.00f + (XORRandom(100) / 20.00f);
			p.growth = -0.10f + (XORRandom(100) * 0.0001f);
		}
	}
}

void Explode_Pattern(CBlob@ this, Vec2f[]@ pattern, SColor color)
{
	Vec2f pos = this.getPosition();

	for (int i = 0; i < pattern.size(); i++)
	{
		Vec2f dir = pattern[i];
		Vec2f ppos = pos;
		f32 vel = 0.1;

		CParticle@ p = ParticlePixelUnlimited(ppos, dir * vel, SColor(color) + SColor(255, XORRandom(255), XORRandom(255), XORRandom(255)), true);
		if (p !is null)
		{
			p.gravity = Vec2f(0, 0.01f + (XORRandom(100) * 0.0001f));
			p.scale = 3.00f + (XORRandom(100) / 20.00f);
			p.growth = -0.10f + (XORRandom(100) * 0.0001f);
			p.damping = 0.95;
			p.timeout = 30 + XORRandom(45);
		}
	}
}

void Explode_Flower_Two(CBlob@ this, int count, SColor color)
{
	Vec2f pos = this.getPosition();
	const f32 seg = 2.00f * Maths::Pi / count;
	const f32 shape_seg = 6.00f * Maths::Pi / count;

	for (int i = 0; i < count; i++)
	{
		Vec2f dir = Vec2f(Maths::Cos(i * seg), Maths::Sin(i * seg));
		Vec2f ppos = pos + dir * 4.00f;
		f32 vel = Maths::Abs(Maths::Sin(f32(i*shape_seg)))*3;

		CParticle@ p = ParticlePixel(ppos, dir * vel, SColor(color) + SColor(255, XORRandom(255), XORRandom(255), XORRandom(255)), true, 30 + XORRandom(45));
		if (p !is null)
		{
			p.gravity = Vec2f(0, 0.01f + (XORRandom(100) * 0.0001f));
			p.scale = 3.00f + (XORRandom(100) / 20.00f);
			p.growth = -0.10f + (XORRandom(100) * 0.0001f);
		}
	}
}

void Explode_Flower_Three(CBlob@ this, int count, SColor color)
{
	Vec2f pos = this.getPosition();
	const f32 seg = 2.00f * Maths::Pi / count;
	const f32 shape_seg = 8.00f * Maths::Pi / count;

	for (int i = 0; i < count; i++)
	{
		Vec2f dir = Vec2f(Maths::Cos(i * seg), Maths::Sin(i * seg));
		Vec2f ppos = pos + dir * 4.00f;
		f32 vel = -3*(1-Maths::Abs(Maths::Cos(i*shape_seg)));

		CParticle@ p = ParticlePixel(ppos, dir * vel, SColor(color) + SColor(255, XORRandom(255), XORRandom(255), XORRandom(255)), true, 30 + XORRandom(45));
		if (p !is null)
		{
			p.gravity = Vec2f(0, 0.01f + (XORRandom(100) * 0.0001f));
			p.scale = 3.00f + (XORRandom(100) / 20.00f);
			p.growth = -0.10f + (XORRandom(100) * 0.0001f);
		}
	}
}

void Explode_Star(CBlob@ this, int count, SColor color)
{
	Vec2f pos = this.getPosition();
	const f32 seg = 2.00f * Maths::Pi / count;
	const f32 shape_seg = 5.00f * Maths::Pi / count;

	for (int i = 0; i < count; i++)
	{
		Vec2f dir = Vec2f(Maths::Cos(i * seg), Maths::Sin(i * seg));
		Vec2f ppos = pos + dir * 4.00f;
		f32 vel = 3-(Maths::Abs(Maths::Cos(i*shape_seg))*1.8f);

		CParticle@ p = ParticlePixel(ppos, dir * vel, SColor(color) + SColor(255, XORRandom(255), XORRandom(255), XORRandom(255)), true, 30 + XORRandom(45));
		if (p !is null)
		{
			p.gravity = Vec2f(0, 0.01f + (XORRandom(100) * 0.0001f));
			p.scale = 3.00f + (XORRandom(100) / 20.00f);
			p.growth = -0.10f + (XORRandom(100) * 0.0001f);
		}
	}
}

void Explode_Generic(CBlob@ this, int count, SColor color)
{
	Vec2f pos = this.getPosition();
	const f32 seg = 360.00f / count;

	for (int i = 0; i < count; i++)
	{
		Vec2f dir = Vec2f(Maths::Cos(i * seg), Maths::Sin(i * seg));
		Vec2f ppos = pos + dir * 4.00f;
		f32 vel = XORRandom(100) / 25.00f;

		CParticle@ p = ParticlePixelUnlimited(ppos, dir * vel, SColor(color) + SColor(255, XORRandom(255), XORRandom(255), XORRandom(255)), true);
		if (p !is null)
		{
			p.gravity = Vec2f(0, 0.02f);
			p.scale = 2.00f + (XORRandom(100) / 25.00f);
			p.growth = -0.10f;
			p.timeout = 15 + XORRandom(30);
		}
	}
}

void Explode_Helix(CBlob@ this, int count, SColor color)
{
	Vec2f pos = this.getPosition();
	const f32 seg = 2.00f * Maths::Pi / count;

	for (int i = 0; i < count; i++)
	{
		Vec2f dir = Vec2f(Maths::Cos(i * seg), Maths::Sin(i * seg));
		Vec2f ppos = pos + dir * 4.00f;
		f32 vel = i * 0.02f;

		CParticle@ p = ParticlePixelUnlimited(ppos, dir * vel, SColor(color) + SColor(255, XORRandom(255), XORRandom(255), XORRandom(255)), true);
		if (p !is null)
		{
			p.gravity = Vec2f(0, 0.01f + (XORRandom(100) * 0.0001f));
			p.scale = 3.00f + (XORRandom(100) / 20.00f);
			p.growth = -0.10f + (XORRandom(100) * 0.0001f);
			p.timeout =  30 + XORRandom(45);
		}
	}
}

void Explode_Circle(CBlob@ this, int count, SColor color)
{
	Vec2f pos = this.getPosition();
	const f32 seg = 2.00f * Maths::Pi / count;

	for (int i = 0; i < count; i++)
	{
		Vec2f dir = Vec2f(Maths::Cos(i * seg), Maths::Sin(i * seg));
		Vec2f ppos = pos + dir * 4.00f;
		f32 vel = 3;

		CParticle@ p = ParticlePixelUnlimited(ppos, dir * vel, SColor(color) + SColor(255, XORRandom(255), XORRandom(255), XORRandom(255)), true);
		if (p !is null)
		{
			p.gravity = Vec2f(0, 0.01f + (XORRandom(100) * 0.0001f));
			p.scale = 3.00f + (XORRandom(100) / 20.00f);
			p.growth = -0.10f + (XORRandom(100) * 0.0001f);
			p.timeout = 30 + XORRandom(45);
		}
	}
}

void Explode_InnerCircles(CBlob@ this, int count, SColor color)
{
	Vec2f pos = this.getPosition();
	const f32 seg = 2.00f * Maths::Pi / count;

	for (int i = 0; i < count; i++)
	{
		Vec2f dir = Vec2f(Maths::Cos(i * seg), Maths::Sin(i * seg));
		Vec2f ppos = pos + dir * 4.00f;
		f32 vel = ((i * 0.50f) % 2) * 2.00f;

		CParticle@ p = ParticlePixelUnlimited(ppos, dir * vel, SColor(color) + SColor(255, XORRandom(255), XORRandom(255), XORRandom(255)), true);
		if (p !is null)
		{
			p.gravity = Vec2f(0, 0.01f + (XORRandom(100) * 0.0001f));
			p.scale = 3.00f + (XORRandom(100) / 20.00f);
			p.growth = -0.10f + (XORRandom(100) * 0.0001f);
			p.timeout = 30 + XORRandom(45);
		}
	}
}

void Explode_Spiral(CBlob@ this, int count, SColor color)
{
	Vec2f pos = this.getPosition();
	const f32 seg = 360.00f / count;

	for (int i = 0; i < count; i++)
	{
		Vec2f dir = Vec2f(Maths::Cos(i * seg), Maths::Sin(i * seg));
		Vec2f ppos = pos + dir * 4.00f;
		f32 vel = i * 0.012f;

		CParticle@ p = ParticlePixelUnlimited(ppos, dir * vel, SColor(color) + SColor(255, XORRandom(255), XORRandom(255), XORRandom(255)), true);
		if (p !is null)
		{
			p.gravity = Vec2f(0, 0.01f + (XORRandom(100) * 0.0001f));
			p.scale = 3.00f + (XORRandom(100) / 20.00f);
			p.growth = -0.10f + (XORRandom(100) * 0.0001f);
			p.timeout = 30 + XORRandom(45);
		}
	}
}

void Explode_Ovals(CBlob@ this, int count, SColor color)
{
	Vec2f pos = this.getPosition();
	const f32 seg = 2.00f * Maths::Pi / count;

	for (int i = 0; i < count; i++)
	{
		Vec2f dir = Vec2f(Maths::Cos(i * seg) * 0.50f, Maths::Sin(i * seg));
		Vec2f ppos = pos + dir * 4.00f;
		f32 vel = 3.00f;

		CParticle@ p = ParticlePixelUnlimited(ppos, dir * vel, SColor(color) + SColor(255, XORRandom(255), XORRandom(255), XORRandom(255)), true);
		if (p !is null)
		{
			p.gravity = Vec2f(0, 0.01f + (XORRandom(100) * 0.0001f));
			p.scale = 3.00f + (XORRandom(100) / 20.00f);
			p.growth = -0.10f + (XORRandom(100) * 0.0001f);
			p.timeout = 30 + XORRandom(45);
		}
	}

	for (int i = 0; i < count; i++)
	{
		Vec2f dir = Vec2f(Maths::Cos(i * seg), Maths::Sin(i * seg) * 0.50f);
		Vec2f ppos = pos + dir * 4.00f;
		f32 vel = 3.00f;

		CParticle@ p = ParticlePixel(ppos, dir * vel, SColor(color) + SColor(255, XORRandom(255), XORRandom(255), XORRandom(255)), true, 30 + XORRandom(45));
		if (p !is null)
		{
			p.gravity = Vec2f(0, 0.01f + (XORRandom(100) * 0.0001f));
			p.scale = 3.00f + (XORRandom(100) / 20.00f);
			p.growth = -0.10f + (XORRandom(100) * 0.0001f);
		}
	}
}

void MakeExplosionParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(8), 0, true);
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	Vec2f offset = Vec2f(0, 16).RotateBy(this.getAngleDegrees());
	ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (isServer() && this.getOldVelocity().y < -6 && this.hasTag("offblast") && blob is null && solid) this.server_Die();
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!this.hasTag("offblast"))
	{
		CBitStream params;
		caller.CreateGenericButton(11, Vec2f(0.0f, 0.0f), this, this.getCommandID("offblast"), "Off blast!", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("offblast"))
	{
		if (this.hasTag("offblast")) return;
		this.setAngleDegrees(0);
		Vec2f pos = this.getPosition();

		this.Tag("offblast");
		this.Tag("projectile");
		this.set_u32("explosion_timer", getGameTime() + 30 + XORRandom(5));

		CSprite@ sprite = this.getSprite();
		sprite.PlaySound("Firework_Launch.ogg", 1.00f, 0.90f);

		this.SetLight(true);
		this.SetLightRadius(128.0f);
		this.SetLightColor(SColor(255, 255, 100, 0));
		if (this.isInInventory())
		{
			DoExplosion(this);
			return;
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasTag("offblast");
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return !this.hasTag("offblast");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.hasTag("offblast"))
	{
		damage = 0;
	}

	return damage;
}
