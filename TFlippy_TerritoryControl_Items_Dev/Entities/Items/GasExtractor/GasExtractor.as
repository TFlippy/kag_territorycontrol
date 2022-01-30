#include "MakeMat.as";
#include "Knocked.as";
#include "GunCommon.as";

f32 maxDistance = 80;

void onInit(CBlob@ this)
{
	this.Tag("no shitty rotation reset");

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2);
	}

	this.getCurrentScript().tickFrequency = 1;
	this.getCurrentScript().runFlags |= Script::tick_attached;
}

void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (point is null) {return;}

		CBlob@ holder = point.getOccupied();
		if (holder is null) {return;}

		this.setAngleDegrees(getAimAngle(this, holder));

		if (getKnocked(holder) <= 0)
		{
			CSprite@ sprite = this.getSprite();

			bool lmb = point.isKeyPressed(key_action1);
			bool rmb = point.isKeyPressed(key_action2);

			if ((!rmb && point.isKeyJustPressed(key_action1)) || (!lmb && point.isKeyJustPressed(key_action2)))
			{
				this.getSprite().PlaySound("/gasextractor_start.ogg", 0.2f);
			}
			else if (lmb || rmb)
			{
				sprite.SetEmitSound("/gasextractor_loop.ogg");
				sprite.SetEmitSoundPaused(false);
				sprite.SetEmitSoundSpeed(1.0f);
				sprite.SetEmitSoundVolume(0.4f);

				Vec2f aimDir = holder.getAimPos() - this.getPosition();
				aimDir.Normalize();

				// if (getGameTime() % 2 == 0) 
				// {
					// if (lmb) makeSteamParticle(this, this.getPosition() + aimDir * 100, -aimDir * 8);
					// else makeSteamParticle(this, this.getPosition(), aimDir * 8);
				// }

				HitInfo@[] hitInfos;
				if (getMap().getHitInfosFromArc(this.getPosition(), -(aimDir).Angle(), 35, maxDistance, this, @hitInfos))
				{
					for (uint i = 0; i < hitInfos.length; i++)
					{
						CBlob@ blob = hitInfos[i].blob;
						if (blob !is null)
						{
							Vec2f dir = this.getPosition() - blob.getPosition();
							f32 dist = dir.Length();
							dir.Normalize();

							if (rmb) dir = -dir;

							// print("" + blob.getMass());
							blob.AddForce(dir * Maths::Min(50, blob.getMass()) * ((maxDistance - dist) / maxDistance * 0.80f));

							

							if (lmb)
							{
								if (dist < 16 && blob.canBePutInInventory(holder))
								{
									if (blob.hasTag("gas") && !holder.getInventory().isFull())
									{
										if (isServer())
										{
											if (blob.getName() == "falloutgas")
											{
												MakeMat(holder, this.getPosition(), "mat_" + "mithril", 3 + XORRandom(5));
											}
											else
											{
												MakeMat(holder, this.getPosition(), "mat_" + blob.getName().replace("gas" , ""), 1 + XORRandom(3));
											}
											blob.server_Die();
										}

										sprite.PlaySound("/gasextractor_load.ogg", 0.2f);
									}
									else if (blob.canBePickedUp(holder) && !holder.getInventory().isFull())
									{
										sprite.PlaySound("/gasextractor_load.ogg", 0.2f);
										if (isServer()) holder.server_PutInInventory(blob);
									}
								}
							}
						}
					}
				}
			}

			if ((!rmb && point.isKeyJustReleased(key_action1)) || (!lmb && point.isKeyJustReleased(key_action2)))
			{
				sprite.PlaySound("/gasextractor_end.ogg");
				sprite.SetEmitSoundPaused(true);
				sprite.SetEmitSoundVolume(0.0f);
				sprite.RewindEmitSound();
			}
		}
	}
}

void makeSteamParticle(CBlob@ this, Vec2f pos, const Vec2f vel)
{
	if (!isClient()){ return;}

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.04 * rad;
	ParticleAnimated("MediumSteam", pos + random, vel, float(XORRandom(360)), 1.0f, 2, 0, false);
}

void onDetach(CBlob@ this,CBlob@ detached,AttachmentPoint@ attachedPoint)
{
	detached.Untag("noLMB");
	detached.Untag("noShielding");

	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSoundPaused(true);
	sprite.SetEmitSoundVolume(0.0f);
	sprite.RewindEmitSound();
}

void onAttach( CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint )
{
	attached.Tag("noLMB");
	attached.Tag("noShielding");
}
