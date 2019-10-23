#include "Hitters.as";
#include "HittersTC.as";
#include "MakeMat.as";
#include "Knocked.as";
#include "Explosion.as";

const f32 maxDistance = 192;
const u32 delay = 3;

void onInit(CBlob@ this)
{
	this.Tag("no shitty rotation reset");
	this.Tag("no explosion particles");

	this.set_f32("mining_multiplier", 3.00f);
	
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1);
	}

	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("/ForceRay_Shoot_Loop.ogg");
	CSpriteLayer@ zap = sprite.addSpriteLayer("zap", "ForceBolt.png", 128, 12);

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
		UpdateAngle(this);

		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if(point is null){return;}
		CBlob@ holder = point.getOccupied();

		if (holder is null) {return;}

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
								
				bool hit = getMap().rayCastSolid(startPos, endPos, hitPos);
				
				
				length = (hitPos - startPos).Length() + 8;
				
				if (hit)
				{
					CMap@ map = getMap();
					
					f32 len = (startPos - hitPos).getLength();
					f32 mod = -Maths::Pow(len / maxDistance, 3) + 1;
					
					// print("mod: " + mod + "; len: " + len);
					
					this.server_HitMap(hitPos, dir, 5.00f * mod, Hitters::drill);
					// map.server_DestroyTile(hitPos, 12.00f * mod);
				}
				
				this.set_u32("nextShoot", getGameTime() + delay);

				ShakeScreen(64, 32, startPos);
				Vec2f force = aimDir * 200.00f;
				holder.AddForce(-force * 0.60f);
				
				HitInfo@[] blobs;
				if (getMap().getHitInfosFromRay(startPos, angle + (flip ? 180 : 0), maxDistance, holder, blobs))
				{
					for (int i = 0; i < blobs.length; i++)
					{
						CBlob@ b = blobs[i].blob;
						if (b !is null && b.getTeamNum() != holder.getTeamNum() && b.isCollidable())
						{
							f32 len = (startPos - b.getPosition()).getLength();
							f32 mod = -Maths::Pow(len / maxDistance, 3) + 1;
						
							// print("mod: " + mod + "; len: " + len);
						
							if (isServer())
							{
								this.server_Hit(b, b.getPosition(), Vec2f(0, 0), 5.00f * mod, Hitters::crush, true);
							}
							
							b.AddForce(force * 1.50f * mod);
							ShakeScreen(80 * mod, 32 * mod, b.getPosition());
							SetKnocked(b, 300 * mod);
							length = blobs[i].distance + 8;
							
							break;
						}
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
						zap.TranslateBy(Vec2f((length / 2) + (16 * (flip ? 1 : -1)), 0));
						zap.RotateBy((flip ? 180 : 0), Vec2f());
						zap.SetVisible(true);
						zap.SetFacingLeft(false);
					}

					if (holder.isKeyJustPressed(key_action1) || point.isKeyJustPressed(key_action1))
					{
						sprite.PlaySound("/ForceRay_Shoot.ogg", 1.00f, 1.20f);
					}
					
					sprite.SetEmitSoundPaused(false);
					sprite.SetEmitSoundSpeed(1.5f);
					sprite.SetEmitSoundVolume(0.4f);
					
					// sprite.PlaySound("ForceRay_Shoot.ogg", 1.00f, 1.00f);
				}
			}
			else if ((holder.isKeyJustReleased(key_action1) || point.isKeyJustReleased(key_action1)))
			{
				sprite.PlaySound("/ForceRay_Shoot.ogg", 1.00f, 0.80f);
				sprite.SetEmitSoundPaused(true);
				sprite.SetEmitSoundVolume(0.0f);
				sprite.RewindEmitSound();
				
				CSpriteLayer@ beam = this.getSprite().getSpriteLayer("beam");

				if (beam !is null)
				{
					beam.SetVisible(false);
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
			if(itemName == "mat_mithril")
			{
				u32 quantity = item.getQuantity();
				bool has = true;
				if (has)
				{
					if (take && XORRandom(100) < 25)
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

void onHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	getMap().server_DestroyTile(worldPoint, damage, this);
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
	CPlayer@ player = attached.getPlayer();
	if (player !is null) this.SetDamageOwnerPlayer(player);

	attached.Tag("noLMB");
	attached.Tag("noShielding");
}