// Drill.as

#include "Hitters.as";
#include "Knocked.as";
#include "BuilderHittable.as";
#include "ParticleSparks.as";

const f32 speed_thresh = 2.4f;
const f32 speed_hard_thresh = 2.6f;

const string buzz_prop = "drill timer";

const string heat_prop = "drill heat";
const u8 heat_max = 200;

const u8 heat_add = 2;
const u8 heat_add_constructed = 1;
const u8 heat_add_blob = 1;
const u8 heat_cool_amount = 5;

const u8 heat_cooldown_time = 10;
const u8 heat_cooldown_time_water = u8(heat_cooldown_time / 3);

const string required_class = "builder";

void onInit(CSprite@ this)
{
	CSpriteLayer@ heat = this.addSpriteLayer("heat", this.getFilename(), 32, 16);

	if (heat !is null)
	{
		Animation@ anim = heat.addAnimation("default", 0, true);
		{
			int[] frames = {4, 5, 6, 7};
			anim.AddFrames(frames);
		}
		heat.SetAnimation(anim);
		heat.SetRelativeZ(0.1f);
		heat.SetVisible(false);
		heat.setRenderStyle(RenderStyle::light);
	}
	this.SetEmitSound("/Drill.ogg");
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	bool buzz = blob.get_bool(buzz_prop);
	if (buzz)
	{
		this.SetAnimation("buzz");
	}
	else if (this.isAnimationEnded())
	{
		this.SetAnimation("default");
	}
	CSpriteLayer@ heatlayer = this.getSpriteLayer("heat");
	if (heatlayer !is null)
	{
		f32 heat = Maths::Min(blob.get_u8(heat_prop), heat_max);
		f32 heatPercent = heat / float(heat_max);
		if (heatPercent > 0.1f)
		{
			heatlayer.setRenderStyle(RenderStyle::light);
			blob.SetLight(true);
			blob.SetLightRadius(heatPercent * 24.0f);
			SColor lightColor = SColor(255, 255, Maths::Min(255, 128 + int(heatPercent * 128)), 64);
			blob.SetLightColor(lightColor);
			heatlayer.SetVisible(true);
			heatlayer.animation.frame = heatPercent * 3;
			if (heatPercent > 0.7f && getGameTime() % 3 == 0)
			{
				makeSteamParticle(blob, Vec2f());
			}
		}
		else
		{
			blob.SetLight(false);
			heatlayer.SetVisible(false);
		}
	}
}

void makeSteamParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * rad;
	ParticleAnimated(filename, this.getPosition() + random, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void makeSteamPuff(CBlob@ this, const f32 velocity = 1.0f, const int smallparticles = 10, const bool sound = true)
{
	if(!isClient()){return;}
	
	if (sound)
	{
		this.getSprite().PlaySound("Steam.ogg");
	}

	makeSteamParticle(this, Vec2f(), "MediumSteam");
	for (int i = 0; i < smallparticles; i++)
	{
		f32 randomness = (XORRandom(32) + 32) * 0.015625f * 0.5f + 0.75f;
		Vec2f vel = getRandomVelocity(-90, velocity * randomness, 360.0f);
		makeSteamParticle(this, vel);
	}
}

void onInit(CBlob@ this)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2 | key_action3);
	}

	this.set_u32("hittime", 0);
	this.Tag("place45");
	this.set_s8("place45 distance", 1);
	this.Tag("place45 perp");
	this.set_u8(heat_prop, 0);
}

void onTick(CBlob@ this)
{
	u8 heat = this.get_u8(heat_prop);
	const u32 gametime = getGameTime();
	bool inwater = this.isInWater();

	CSprite@ sprite = this.getSprite();

	if (heat > 0)
	{
		if (gametime % heat_cooldown_time == 0)
		{
			heat--;
		}

		if (inwater && heat >= heat_add && gametime % (Maths::Max(heat_cooldown_time_water, 1)) == 0)
		{
			u8 lim = u8(heat_max * 0.7f);
			if (heat > lim)
			{
				makeSteamPuff(this);
			}
			else
			{
				makeSteamPuff(this, 0.5f, 5, false);
			}
			heat -= heat_cool_amount;
		}
		this.set_u8(heat_prop, heat);
	}
	
	sprite.SetEmitSoundPaused(true);
	
	if (this.isAttached())
	{
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping);
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if(point is null){return;}
		CBlob@ holder = point.getOccupied();

		if (holder is null){return;}

		// cool faster if holder is moving
		if (heat > 0 && holder.getShape().vellen > 0.01f && getGameTime() % heat_cooldown_time == 0)
		{
			heat--;
		}

		this.getShape().SetRotationsAllowed(false);

		if (int(heat) >= heat_max - (heat_add * 1.5))
		{
			makeSteamPuff(this, 1.5f, 3, false);
			this.server_Hit(holder, holder.getPosition(), Vec2f(), 0.25f, Hitters::burn, true);
			this.server_DetachFrom(holder);
			sprite.PlaySound("DrillOverheat.ogg");
		}

		if (!(point.isKeyPressed(key_action1) || holder.isKeyPressed(key_action1)) || getKnocked(holder) > 0)
		{
			this.set_bool(buzz_prop, false);
			return;
		}

		//set funny sound under water
		if (inwater)
		{
			sprite.SetEmitSoundSpeed(0.8f + (getGameTime() % 13) * 0.01f);
		}
		else
		{
			sprite.SetEmitSoundSpeed(1.0f);
		}

		sprite.SetEmitSoundPaused(false);
		this.set_bool(buzz_prop, true);

		if (heat < heat_max)
		{
			heat++;
		}

		const u8 delay_amount = inwater ? 20 : 8;
		bool skip = ((gametime + this.getNetworkID()) % delay_amount) != 0;

		if (skip) return;

		// delay drill
		{
			const bool facingleft = this.isFacingLeft();
			Vec2f direction = Vec2f(1, 0).RotateBy(this.getAngleDegrees() + (facingleft ? 180.0f : 0.0f));
			const f32 sign = (facingleft ? -1.0f : 1.0f);

			const f32 attack_distance = 6.0f;
			Vec2f attackVel = direction * attack_distance;

			const f32 distance = 20.0f;
			const f32 attack_dam = 1.0f;

			bool hitsomething = false;
			bool hitblob = false;

			CMap@ map = getMap();
			if (map !is null)
			{
				HitInfo@[] hitInfos;
				if (map.getHitInfosFromArc((this.getPosition() - attackVel), -attackVel.Angle(), 30, distance, this, true, @hitInfos))
				{
					//print("dril" + hitInfos.length);
				
					bool hit_ground = false;
					for (uint i = 0; i < hitInfos.length; i++)
					{
						HitInfo@ hi = hitInfos[i];
						bool hit_constructed = false;
						CBlob@ b = hi.blob;
						if (b !is null) // blob
						{
							//detect
							const bool is_ground = b.hasTag("blocks sword") && !b.isAttached() && b.isCollidable();
							if (is_ground)
							{
								hit_ground = true;
							}

							if (b.getTeamNum() == holder.getTeamNum() || hit_ground && !is_ground)
							{
								continue;
							}
							
							

							holder.server_Hit(b, hi.hitpos, attackVel, attack_dam, Hitters::drill);
							if (int(heat) > heat_max * 0.5f)
							{
								holder.server_Hit(b, hi.hitpos, attackVel, 1.0f, Hitters::drill);   //extra burn damage
							}
							hitsomething = true;
							hitblob = true;
						}
						else // map
						{
							if (map.getSectorAtPosition(hi.hitpos, "no build") !is null)
								continue;

							TileType tile = hi.tile;
							
							if ((tile >= 384 && tile <= 393) || (tile >= 396 && tile <= 412))
							{
								this.getSprite().PlaySound("/metal_stone.ogg");
								this.server_Hit(this, this.getPosition(), attackVel, 0.25f, Hitters::drill); // Iron beats regular drill
								sparks(hi.hitpos, 1, 1);
							}
							else
							{
								this.server_HitMap(hi.hitpos, attackVel, 1.8f, Hitters::drill);
							}
							
							//only counts as hitting something if its not mats, so you can drill out veins quickly
							if (!map.isTileStone(tile) || !map.isTileGold(tile))
							{
								hitsomething = true;
								if (map.isTileCastle(tile) || map.isTileWood(tile))
								{
									hit_constructed = true;
								}
								else
								{
									hit_ground = true;
								}
							}

						}
						if (hitsomething)
						{
							if (heat < heat_max)
							{
								if (hit_constructed)
								{
									heat += heat_add_constructed;
								}
								else if (hitblob)
								{
									heat += heat_add_blob;
								}
								else
								{
									heat += heat_add;
								}
							}
							hitsomething = false;
							hitblob = false;
						}
					}
				}
			}
		}

		this.set_u8(heat_prop, heat);
	}
	else
	{
		this.getShape().SetRotationsAllowed(true);
		this.set_bool(buzz_prop, false);
		if (heat <= 0)
		{
			this.getCurrentScript().runFlags |= Script::tick_not_sleeping;
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::fire)
	{
		this.set_u8(heat_prop, heat_max);
		makeSteamPuff(this);
	}

	if (customData == Hitters::water)
	{
		this.set_u8(heat_prop, 0);
		makeSteamPuff(this);
	}

	return damage;
}

void onHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	getMap().server_DestroyTile(worldPoint, damage, this);
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
}

void onThisAddToInventory(CBlob@ this, CBlob@ blob)
{
	this.getSprite().SetEmitSoundPaused(true);
}
