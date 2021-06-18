#include "Hitters.as";
#include "MakeMat.as";
#include "Knocked.as";
#include "GunCommon.as";

const f32 maxDistance = 128;
const f32 damage = 1.00f;
const u32 delay = 90;

void onInit(CBlob@ this)
{
	this.Tag("no shitty rotation reset");
	this.Tag("dangerous");
	this.Tag("weapon");

	this.set_string("ammoBlob", "mat_battery");

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1);
	}

	CSprite@ sprite = this.getSprite();

	CSpriteLayer@ zap = sprite.addSpriteLayer("zap", "Zapper_Lightning.png", 128, 12);
	if (zap !is null)
	{
		Animation@ anim = zap.addAnimation("default", 1, false);
		int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
		anim.AddFrames(frames);
		zap.SetRelativeZ(-1.0f);
		zap.SetVisible(false);
		zap.setRenderStyle(RenderStyle::additive);
		zap.SetOffset(Vec2f(-15.0f, 0));
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

		if (getKnocked(holder) <= 0)
		{
			CSprite@ sprite = this.getSprite();

			const bool lmb = holder.isKeyPressed(key_action1) || point.isKeyPressed(key_action1);

			if (lmb && this.get_u32("nextShoot") <= getGameTime() && HasAmmo(holder, true, this.get_string("ammoBlob")))
			{
				Vec2f aimDir = holder.getAimPos() - this.getPosition();
				aimDir.Normalize();

				Vec2f hitPos;
				f32 length;
				bool flip = this.isFacingLeft();
				f32 angle = this.getAngleDegrees();
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
						if (b is null)
						{
							continue;
						}

						if (b.getName() == "methane")
						{
							b.Tag("lit");
							b.server_Die();
						}
						else if (!b.hasTag("flesh") || b.hasTag("dead") || b.getTeamNum() == holder.getTeamNum())
						{
							continue;
						}

						if (isServer())
						{
							this.server_Hit(b, b.getPosition(), Vec2f(0, 0), damage, HittersTC::electric, true);
						}

						SetKnocked(b, 150);
						length = blobs[i].distance + 8;

						break;
					}
				}

				if (isClient())
				{
					CSpriteLayer@ zap = this.getSprite().getSpriteLayer("zap");
					if (zap !is null)
					{
						zap.ResetTransform();
						zap.SetFrameIndex(0);
						zap.ScaleBy(Vec2f(length / 128.0f - 0.1f, 1.0f));
						zap.TranslateBy(Vec2f((length / 2) - 14, 2.0f * (flip ? 1 : -1)));
						zap.RotateBy((flip ? 180 : 0), Vec2f());
						zap.SetVisible(true);
					}

					sprite.PlaySound("Zapper_Zap" + XORRandom(3), 1.00f, 1.00f);
				}
			}
		}
	}
}

bool HasAmmo(CBlob@ this, bool take, string ammoBlob)
{
	CInventory@ inv = this.getInventory();
	int size = inv.getItemsCount();
	for (int i = 0; i < size; i++)
	{
		CBlob@ item = inv.getItem(i);
		if (item !is null)
		{
			string itemName = item.getName();
			if (itemName == ammoBlob)
			{
				u32 quantity = item.getQuantity();
				bool has = true;
				if (has)
				{
					if (take)
					{
						if (quantity >= 5) item.server_SetQuantity(quantity - 5);
						else
						{
							item.server_SetQuantity(0);
							item.server_Die();
						}
					}
					return true;
				}
			}
		}
	}
	return false;
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
