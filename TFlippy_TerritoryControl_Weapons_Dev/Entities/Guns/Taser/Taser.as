#include "Hitters.as";
#include "HittersTC.as";
#include "MakeMat.as";
#include "Knocked.as";

const f32 maxDistance = 128;
const f32 damage = 1.00f;
const u32 delay = 90;

void onInit(CBlob@ this)
{
	this.Tag("no shitty rotation reset");
	this.Tag("dangerous");
	
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1);
	}

	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ zap = sprite.addSpriteLayer("zap", "Zapper_Lightning.png", 128, 12);

	if(zap !is null)
	{
		Animation@ anim = zap.addAnimation("default", 1, false);
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		anim.AddFrame(4);
		anim.AddFrame(5);
		anim.AddFrame(6);
		anim.AddFrame(7);
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
		UpdateAngle(this);

		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if(point is null){return;}
		CBlob@ holder = point.getOccupied();

		if (holder is null) return;

		if (getKnocked(holder) <= 0)
		{
			CSprite@ sprite = this.getSprite();

			const bool lmb = holder.isKeyPressed(key_action1) || point.isKeyPressed(key_action1);

			if (lmb && this.get_u32("nextShoot") <= getGameTime() && HasAmmo(holder, true))
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
						if (b is null)
						{
							continue;
						}

						if(b.getName() == "methane")
						{
							b.Tag("lit");
							b.server_Die();
						}
						else if (!b.hasTag("flesh") || b.hasTag("dead"))
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

bool HasAmmo(CBlob@ this, bool take)
{
	CInventory@ inv = this.getInventory();
	int size = inv.getItemsCount();
	for(int i = 0; i < size; i++)
	{
		CBlob@ item = inv.getItem(i);
		if( !(item is null) )
		{
			string itemName = item.getName();
			if(itemName == "mat_battery")
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

void UpdateAngle(CBlob@ this)
{
	AttachmentPoint@ point=this.getAttachments().getAttachmentPointByName("PICKUP");
	if(point is null) return;

	CBlob@ holder=point.getOccupied();

	if(holder is null) return;

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
