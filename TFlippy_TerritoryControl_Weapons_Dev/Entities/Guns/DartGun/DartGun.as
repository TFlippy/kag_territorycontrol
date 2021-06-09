#include "Hitters.as";
#include "MakeMat.as";
#include "Knocked.as";
#include "GunCommon.as";

const f32 maxDistance = 500;
const f32 damage = 0.125f;
const u32 delay = 90;

void onInit(CBlob@ this)
{
	this.Tag("no shitty rotation reset");
	this.Tag("dangerous");
	this.Tag("weapon");

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1);
	}

	this.getCurrentScript().tickFrequency = 1;
	this.getCurrentScript().runFlags |= Script::tick_attached;
}

void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (point is null) return;

		CBlob@ holder = point.getOccupied();
		if (holder is null) return;

		this.setAngleDegrees(getAimAngle(this, holder));

		bool error = false;

		if (getKnocked(holder) <= 0)
		{
			CSprite@ sprite = this.getSprite();

			const bool lmb = holder.isKeyJustPressed(key_action1) || point.isKeyJustPressed(key_action1);
			if (lmb)
			{
				if (getGameTime() >= this.get_u32("nextShoot"))
				{
					CBlob@ ammoBlob = GetAmmoBlob(this);
					if (ammoBlob !is null)
					{
						Vec2f aimDir = holder.getAimPos() - this.getPosition();
						aimDir.Normalize();

						Vec2f hitPos;
						f32 length;
						bool flip = this.isFacingLeft();
						f32 angle =	this.getAngleDegrees();
						Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
						Vec2f startPos = this.getPosition();
						Vec2f endPos = startPos + dir * maxDistance;

						getMap().rayCastSolid(startPos, endPos, hitPos);

						length = (hitPos - startPos).Length() + 8;
						this.set_u32("nextShoot", getGameTime() + delay);

						HitInfo@[] blobs;
						if (getMap().getHitInfosFromRay(startPos, angle + (flip ? 180 : 0), maxDistance, holder, blobs))
						{
							for (int i = 0; i < blobs.length; i++)
							{
								CBlob@ b = blobs[i].blob;
								if (b !is null && b !is holder && b.hasTag("flesh"))
								{
									if (isServer())
									{
										this.server_Hit(b, b.getPosition(), dir, damage, Hitters::arrow, true);

										CBitStream stream;
										stream.write_u16(b.getNetworkID());
										ammoBlob.SendCommand(ammoBlob.getCommandID("consume"), stream);
									}

									if (isClient())
									{
										Sound::Play("DartGun_Hit.ogg", b.getPosition(), 1.00f, 1.00f);
									}

									SetKnocked(b, 90);
									length = blobs[i].distance + 8;

									break;
								}
							}
						}

						if (isClient())
						{
							sprite.PlaySound("DartGun_Shoot", 1.00f, 1.00f);
						}
					}
					else error = true;
				}
				else error = true;
			}
		}

		if (error)
		{
			if (isClient())
			{
				if (holder.isMyPlayer())
				{
					this.getSprite().PlaySound("NoAmmo.ogg", 1, 1);
				}
			}
		}
	}
}

CBlob@ GetAmmoBlob(CBlob@ this)
{
	CInventory@ inv = this.getInventory();
	s32 size = inv.getItemsCount();
	for (s32 i = 0; i < size; i++)
	{
		CBlob@ item = inv.getItem(i);
		if (item !is null)
		{
			if (item.hasTag("forcefeedable"))
			{
				return item;
			}
		}
	}
	return null;
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
