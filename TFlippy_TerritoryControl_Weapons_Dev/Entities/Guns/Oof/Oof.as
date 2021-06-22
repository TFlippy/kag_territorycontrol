#include "Hitters.as";
#include "MakeMat.as";
#include "Knocked.as";
#include "Explosion.as";
#include "GunCommon.as";

const f32 maxDistance = 40000;
const u32 delay = 60;

void onInit(CBlob@ this)
{
	this.Tag("no shitty rotation reset");
	this.Tag("no explosion particles");
	this.Tag("heavy weight");
	this.Tag("weapon");

	this.set_string("ammoBlob", "mat_antimatter");

	this.getShape().SetOffset(Vec2f(4, 0));

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1);
	}

	CSpriteLayer@ zap = this.getSprite().addSpriteLayer("zap", "Oof_Bolt.png", 128, 12);
	if (zap !is null)
	{
		Animation@ anim = zap.addAnimation("default", 1, false);
		int[] frames = {0, 1, 2, 3, 4, 5, 6, 7};
		anim.AddFrames(frames);
		zap.SetRelativeZ(-1.0f);
		zap.SetVisible(false);
		zap.setRenderStyle(RenderStyle::light);
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
			const bool lmb = holder.isKeyJustPressed(key_action1) || point.isKeyJustPressed(key_action1);

			if (lmb && this.get_u32("nextShoot") <= getGameTime() && HasAmmo(holder, true, this.get_string("ammoBlob")))
			{
				CMap@ map = getMap();

				Vec2f aimDir = holder.getAimPos() - this.getPosition();
				aimDir.Normalize();

				Vec2f hitPos;
				f32 length;
				bool flip = this.isFacingLeft();
				f32 angle = this.getAngleDegrees();
				Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
				Vec2f startPos = this.getPosition();
				Vec2f endPos = startPos + dir * maxDistance;

				HitInfo@[] hitInfos;
				bool hitBlobs = false;

				if (map.getHitInfosFromRay(startPos, angle + (flip ? 180 : 0), maxDistance, this, @hitInfos))
				{
					for (int i = 0; i < hitInfos.length; i++)
					{
						if (hitInfos[i].blob !is null)
						{
							CBlob@ blob = hitInfos[i].blob;
							//print("" + hitInfos[i].distance);

							if (hitInfos[i].distance > 64 && blob.getTeamNum() != this.getTeamNum() && blob.isCollidable() && !blob.hasTag("invincible")) 
							{
								hitBlobs = true;
								hitPos = hitInfos[i].hitpos;

								if (isServer())
								{
									SpawnBoom(this, hitPos);
								}

								break;
							}
						}
					}
				}

				if (!hitBlobs)
				{
					if (getMap().rayCastSolid(startPos, endPos, hitPos))
					{
						CMap@ map = getMap();

						if (isServer())
						{
							SpawnBoom(this, hitPos);
						}
					}
				}

				length = (hitPos - startPos).Length() + 8;

				this.set_u32("nextShoot", getGameTime() + delay);

				ShakeScreen(64, 32, startPos);
				holder.AddForce(-aimDir * 400.00f);

				if (isClient())
				{
					CSpriteLayer@ zap = this.getSprite().getSpriteLayer("zap");
					if (zap !is null)
					{
						zap.ResetTransform();
						zap.SetFrameIndex(0);
						zap.ScaleBy(Vec2f(length / 128.0f - 0.1f, 1.0f));
						zap.TranslateBy(Vec2f((length / 2) + (16 * (flip ? 1 : -1)), 0));
						zap.RotateBy((flip ? 180 : 0), Vec2f());
						zap.SetVisible(true);
						zap.SetFacingLeft(false);
					}

					if (holder.isKeyJustPressed(key_action1) || point.isKeyJustPressed(key_action1))
					{
						sprite.PlaySound("/Oof_Shoot.ogg", 2.00f, 1.00f);
					}
				}
			}
			else if ((holder.isKeyJustReleased(key_action1) || point.isKeyJustReleased(key_action1)))
			{
				CSpriteLayer@ beam = this.getSprite().getSpriteLayer("beam");

				if (beam !is null)
				{
					beam.SetVisible(false);
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
				bool has = quantity >= 1;
				if (has)
				{
					if (take)
					{
						if (quantity >= 1) item.server_SetQuantity(quantity - 1);
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
	CPlayer@ player = attached.getPlayer();
	if (player !is null) this.SetDamageOwnerPlayer(player);

	attached.Tag("noLMB");
	attached.Tag("noShielding");
}

void SpawnBoom(CBlob@ this, Vec2f pos)
{
	CBlob@ boom = server_CreateBlobNoInit("antimatterexplosion");
	boom.setPosition(pos);
	boom.set_u8("boom_frequency", 2);
	boom.set_f32("boom_size", 0);
	boom.set_f32("boom_increment", 10.00f);
	boom.set_f32("boom_end", 30);
	boom.set_f32("flash_distance", 128);
	boom.set_u32("boom_delay", 5);
	boom.set_u32("flash_delay", 5);
	boom.Init();
}