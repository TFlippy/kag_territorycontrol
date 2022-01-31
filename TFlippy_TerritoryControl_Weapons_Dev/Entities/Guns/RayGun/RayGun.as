#include "Hitters.as";
#include "MakeMat.as";
#include "Knocked.as";
#include "GunCommon.as";

f32 maxDistance = 400;
const int mothrildelay = 6; //less value -> faster
f32 damage = 1.00f / 16.00f;

void onInit(CBlob@ this)
{
	this.Tag("no shitty rotation reset");
	this.Tag("weapon");

	this.set_u8("timer", 0);
	this.set_string("ammoBlob", "mat_mithril");

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1);
	}

	CSpriteLayer@ gammalaser = this.getSprite().addSpriteLayer("gammalaser", "GammaLaser.png", 32, 8);
	if (gammalaser !is null)
	{
		gammalaser.SetRelativeZ(-1.0f);
		gammalaser.SetVisible(false);
		gammalaser.setRenderStyle(RenderStyle::additive);
		gammalaser.SetOffset(Vec2f(-18.0f, 1.5f));
	}

	this.getCurrentScript().tickFrequency = 1;
	//this.getCurrentScript().runFlags |= Script::tick_attached;
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

			if ((holder.isKeyJustPressed(key_action1) || point.isKeyJustPressed(key_action1)) && HasAmmo(holder, false, this.get_string("ammoBlob")))
			{
				this.getSprite().PlaySound("/RayGun_Start.ogg");
			}
			else if (lmb)
			{
				int ticks = this.get_u8("timer");
				bool timer = ticks % mothrildelay == 0 ? true : false;

				if (HasAmmo(holder, timer, this.get_string("ammoBlob")))
				{
					this.set_u8("timer", ticks + 1);

					sprite.SetEmitSound("/RayGun_Loop.ogg");
					sprite.SetEmitSoundPaused(false);
					sprite.SetEmitSoundSpeed(1.0f);
					sprite.SetEmitSoundVolume(0.4f);

					Vec2f aimDir = holder.getAimPos() - this.getPosition();
					aimDir.Normalize();

					Vec2f hitPos;
					f32 length;
					bool flip = this.isFacingLeft();
					f32 angle = this.getAngleDegrees();
					Vec2f dir = Vec2f((flip ? -1 : 1), 0.0f).RotateBy(angle);
					Vec2f startPos = this.getPosition();
					Vec2f endPos = startPos + dir * maxDistance;

					getMap().rayCastSolid(startPos, endPos, hitPos);

					length = (hitPos - startPos).Length();

					CSpriteLayer@ gammalaser = sprite.getSpriteLayer("gammalaser");
					if (isClient())
					{
						if (gammalaser !is null)
						{
							gammalaser.ResetTransform();
							gammalaser.ScaleBy(Vec2f((length-8) / 32.0f, 1.0f));
							gammalaser.TranslateBy(Vec2f((length / 2) - 14, 2.0f * (flip ? 1 : -1)));
							gammalaser.RotateBy((flip ? 180 : 0), Vec2f());
							gammalaser.SetVisible(true);
						}
					}

					if (isServer())
					{
						HitInfo@[] blobs;
						getMap().getHitInfosFromRay(startPos, angle + (flip ? 180 : 0), maxDistance, holder, blobs);

						f32 counter = 1;

						for (int i = 0; i < blobs.length; i++)
						{
							CBlob@ b = blobs[i].blob;
							if (b !is null && (b.hasTag("flesh") || b.hasTag("nature")) && !b.hasTag("dead") && this.getTeamNum() != b.getTeamNum())
							{
								this.server_Hit(b, b.getPosition(), Vec2f(0, 0), damage / counter, HittersTC::radiation, true);

								if (b.hasTag("human") && !b.hasTag("transformed") && b.getHealth() <= 0.125f && XORRandom(3) == 0)
								{
									CBlob@ man = server_CreateBlob("mithrilman", b.getTeamNum(), b.getPosition());
									if (b.getPlayer() !is null) man.server_SetPlayer(b.getPlayer());
									b.Tag("transformed");
									b.server_Die();
								}

								counter += 0.25f;
							}
						}

						CBlob@[] blobsInRadius;
						if (this.getMap().getBlobsInRadius(hitPos, 100, @blobsInRadius))
						{
							for (int i = 0; i < blobsInRadius.length; i++)
							{
								CBlob@ blob = blobsInRadius[i];
								// if (!blob.hasTag("flesh") || blob.hasTag("dead")) continue;

								if (!(blob.hasTag("flesh") || blob.hasTag("nature")) || blob.hasTag("dead") || this.getTeamNum() == blob.getTeamNum()) continue;

								Vec2f pos = hitPos;
								Vec2f dir = blob.getPosition() - pos;
								f32 len = dir.Length();
								dir.Normalize();

								for (int i = 0; i < len; i += 8)
								{
									if (getMap().isTileSolid(pos + dir * i)) counter++;
								}

								f32 distMod = Maths::Max(0, (1.00f - ((hitPos - blob.getPosition()).Length() / 100)));

								if (XORRandom(100) < 100.0f * distMod) 
								{
									this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), damage / counter / 2, HittersTC::radiation, true);

									if (blob !is null && blob.hasTag("human") && !blob.hasTag("transformed") && blob.getHealth() <= 0.125f && XORRandom(3) == 0)
									{
										CBlob@ man = server_CreateBlob("mithrilman", blob.getTeamNum(), blob.getPosition());
										if (blob.getPlayer() !is null) man.server_SetPlayer(blob.getPlayer());
										blob.Tag("transformed");
										blob.server_Die();
									}
								}
							}
						}
					}
				}
				else
				{
					sprite.SetEmitSoundPaused(true);

					CSpriteLayer@ gammalaser = this.getSprite().getSpriteLayer("gammalaser");
					if (gammalaser !is null)
					{
						gammalaser.SetVisible(false);
					}
				}
			}

			if ((holder.isKeyJustReleased(key_action1) || point.isKeyJustReleased(key_action1)))
			{
				sprite.PlaySound("/RayGun_Stop.ogg");
				sprite.SetEmitSoundPaused(true);
				sprite.SetEmitSoundVolume(0.0f);
				sprite.RewindEmitSound();

				CSpriteLayer@ gammalaser = this.getSprite().getSpriteLayer("gammalaser");
				if (gammalaser !is null)
				{
					gammalaser.SetVisible(false);
				}
			}
		}
	}
	else
	{
		CSpriteLayer@ gammalaser = this.getSprite().getSpriteLayer("gammalaser");
		if (gammalaser !is null)
		{
			gammalaser.SetVisible(false);
		}

		this.getCurrentScript().runFlags |= Script::tick_not_sleeping;
	}
}

bool HasAmmo(CBlob@ this, bool take, string ammoBlob)
{
	CInventory@ inv = this.getInventory();
	int size = inv.getItemsCount();
	for (int i = 0; i < size; i++)
	{
		CBlob@ item = inv.getItem(i);
		if(item !is null)
		{
			string itemName = item.getName();
			if (itemName == ammoBlob)
			{
				u32 quantity = item.getQuantity();
				if (take)
				{
					if (quantity >= 1) item.server_SetQuantity(quantity-1);
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

	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
}
