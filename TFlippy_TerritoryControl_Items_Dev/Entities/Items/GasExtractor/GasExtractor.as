#include "Hitters.as";
#include "MakeMat.as";
#include "Knocked.as";

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
		UpdateAngle(this);
	
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if(point is null) {return;}
		CBlob@ holder = point.getOccupied();
		
		if (holder is null) {return;}

		if (getKnocked(holder) <= 0)
		{
			CSprite@ sprite = this.getSprite();
		
			bool lmb = point.isKeyPressed(key_action1);
			bool rmb = point.isKeyPressed(key_action2);
		
			if ((!rmb && point.isKeyJustPressed(key_action1)) || (!lmb && point.isKeyJustPressed(key_action2)))
			{
				this.getSprite().PlaySound("/gasextractor_start.ogg");
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
							blob.AddForce(dir * (Maths::Clamp(maxDistance - dist, 0, maxDistance) * 0.80f));
							
							if (lmb)
							{
								if (dist < 16 && blob.canBePutInInventory(holder))
								{
									if (blob.hasTag("gas") && !holder.getInventory().isFull())
									{
										if (isServer())
										{
											blob.server_Die();
											MakeMat(holder, this.getPosition(), "mat_" + blob.getName(), 1 + XORRandom(5));
										}
									
										sprite.PlaySound("/gasextractor_load.ogg");
									}
									else if (blob.canBePickedUp(holder) && !holder.getInventory().isFull())
									{
										sprite.PlaySound("/gasextractor_load.ogg");
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

void UpdateAngle(CBlob@ this)
{
	AttachmentPoint@ point=this.getAttachments().getAttachmentPointByName("PICKUP");
	if(point is null) {return;}
	
	CBlob@ holder=point.getOccupied();
	
	if(holder is null) {return;}
	
	Vec2f aimpos=holder.getAimPos();
	Vec2f pos=holder.getPosition();
	
	Vec2f aim_vec =(pos - aimpos);
	aim_vec.Normalize();
	
	f32 mouseAngle=aim_vec.getAngleDegrees();
	if(!holder.isFacingLeft()) mouseAngle += 180;

	this.setAngleDegrees(-mouseAngle);
	
	point.offset.x=0 +(aim_vec.x*2*(holder.isFacingLeft() ? 1.0f : -1.0f));
	point.offset.y=-(aim_vec.y);
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