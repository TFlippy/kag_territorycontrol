#include "Hitters.as";
#include "MakeMat.as";
#include "Knocked.as";
#include "Explosion.as";
#include "GunCommon.as";

const f32 maxDistance = 40000;
const u32 delay = 15;
const f32 radius = 128.0f;

void onInit(CBlob@ this)
{
	this.Tag("no shitty rotation reset");
	this.Tag("no explosion particles");
	this.Tag("medium weight");
	this.Tag("weapon");

	this.set_string("ammoBlob", "mat_meat");

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1);
	}

	CSprite@ sprite = this.getSprite();

	sprite.SetEmitSound("DemonicLoop.ogg");
	sprite.RewindEmitSound();
	sprite.SetEmitSoundPaused(true);

	CSpriteLayer@ zap = sprite.addSpriteLayer("zap", "Mithrios_Bolt.png", 128, 6);
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
	// this.getCurrentScript().runFlags |= Script::tick_attached;

	if (isServer())
	{
		server_CreateBlob("lightningbolt", -1, this.getPosition());
	}

	client_AddToChat("A Mithrios Device has been summoned.", SColor(255, 255, 0, 0));
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (hitBlob !is null && hitBlob.getTeamNum() != this.getTeamNum() && hitBlob.hasTag("flesh") && damage >= hitBlob.getHealth())
	{
		f32 amount;

		if (hitBlob.hasTag("human")) amount = 1.00f;
		else amount = 0.25f; // piglets have souls too

		this.add_f32("kill_count", amount);
	}
}

void onTick(CBlob@ this)
{
	const bool server = isServer();
	const bool client = isClient();

	const f32 kill_count = this.get_f32("kill_count");

	this.setInventoryName("Mithrios\n" + "(" + (100 + kill_count + (XORRandom(1000) * 0.001f) + "% evil)"));

	CBlob@ playerBlob = getLocalPlayerBlob();
	if (playerBlob !is null)
	{
		CSprite@ sprite = this.getSprite();
		sprite.SetFrameIndex(0);
		sprite.SetEmitSoundPaused(false);

		Vec2f diff = playerBlob.getPosition() - this.getPosition();
		f32 dist = diff.getLength();

		if (dist < radius)
		{
			f32 invFactor = (dist / radius);
			f32 factor = 1.00f - invFactor;

			sprite.SetEmitSoundVolume(factor);
			sprite.SetEmitSoundSpeed(0.50f + (0.50f * invFactor) + Maths::Min(kill_count * 0.02f, 0.35f));

			CCamera@ cam = getCamera();
			// cam.setRotation((XORRandom(1000) - 500) / 1000.00f * factor, (XORRandom(1000) - 500) / 1000.00f * factor, 0);
			// cam.setRotation(0, 1.00f * factor, 0);

			f32 angle = diff.Angle();
			cam.setRotation(diff.y * factor * 0.002f * (XORRandom(200) * 0.01f), diff.x * factor * 0.002f * (XORRandom(200) * 0.01f), XORRandom(200) * factor * 0.01f);

			SetScreenFlash(Maths::Clamp((50 * factor) + XORRandom(10 + (kill_count * 2)) + (kill_count * 0.50f), 0, 255), 64, 0, 0);
			ShakeScreen((25 * factor) + (kill_count * 1.50f), 30, this.getPosition());

			if (!this.isAttached() && playerBlob !is this && !this.isInInventory())
			{
				CControls@ controls = getControls();
				Driver@ driver = getDriver();
				if(isWindowActive() || isWindowFocused())
				{
					Vec2f spos = driver.getScreenPosFromWorldPos(this.getPosition());
					Vec2f dir = (controls.getMouseScreenPos() - spos);

					Vec2f move_to = dir * 0.25f * factor;
					if(move_to.x < 0) move_to.x--;
					if(move_to.y < 0) move_to.y--;

					controls.setMousePosition(controls.getMouseScreenPos() - move_to);
				}
			}

			if (getGameTime() > this.get_u32("next_whisper"))
			{
				if (XORRandom(100 * (invFactor)) == 0)
				{
					this.set_u32("next_whisper", getGameTime() + 30 * 5);
					this.getSprite().PlaySound("dem_whisper_" + XORRandom(6), 0.75f * factor, 0.75f);
				}
			}
		}
	}

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
				bool hit = getMap().rayCastSolid(startPos, endPos, hitPos);

				f32 mod = 1.00f;

				if (map.getHitInfosFromRay(startPos, angle + (flip ? 180 : 0), maxDistance, this, @hitInfos))
				{
					for (int i = 0; i < hitInfos.length; i++)
					{
						if (hitInfos[i].blob !is null)
						{
							CBlob@ blob = hitInfos[i].blob;
							// print("" + hitInfos[i].distance);

							if (hitInfos[i].distance > 16 && !blob.hasTag("invincible")) 
							{
								hitBlobs = true;
								blob.AddForce(aimDir * 3.00f * blob.getMass());

								if (server)
								{
									this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), (3.00f + (kill_count * 0.25f)) * mod, Hitters::explosion, true);
								}

								if (client)
								{
									ParticleAnimated("SmallExplosion.png", blob.getPosition() + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4), getRandomVelocity(0, 2, 360), 0, 1.00f + XORRandom(5) * 0.10f, 4, 0.1, false);
								}

								mod /= 2.00f;
							}
						}
					}
				}
				
				if (hit)
				{
					if (server)
					{
						for (int i = 0; i < 8 + kill_count; i++)
						{
							map.server_DestroyTile(hitPos + (dir * i * 8), (10.00f + kill_count) * mod);
							mod /= 1.50f;
						}
					}

					u32 size = 24 + kill_count;

					for (int i = 0; i < 4 + kill_count; i++)
					{
						Vec2f bpos = hitPos + Vec2f(XORRandom(size) - (size * 0.50f), XORRandom(size) - (size * 0.50f));
						TileType t = map.getTile(bpos).type;

						if (t != CMap::tile_castle_d0 && t != CMap::tile_ground_d0 && (XORRandom(100) < 50 ? true : t != CMap::tile_ground_d1))
						{
							if (server)
							{
								map.server_DestroyTile(bpos, 1, this);
							}

							if (client)
							{
								ParticleAnimated("SmallExplosion.png", bpos + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4), getRandomVelocity(0, 2, 360), 0, 1.00f + XORRandom(5) * 0.10f, 4, 0.1, false);
							}
						}

						if (server)
						{
							map.server_setFireWorldspace(bpos, true);
						}
					}

					sprite.PlaySound("Missile_Explode", 1, 1);

					if (server) 
					{
						CBlob@[] blobs;
						if (map.getBlobsInRadius(hitPos, 12.0f, @blobs))
						{
							for (int i = 0; i < blobs.length; i++)
							{
								CBlob@ blob = blobs[i];
								if (blob !is null) 
								{
									map.server_setFireWorldspace(blob.getPosition(), true);
									blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 1.5f, Hitters::fire);
								}
							}
						}

						map.server_setFireWorldspace(hitPos, true);
					}
				}

				// if (!hitBlobs)
				// {
					// if (getMap().rayCastSolid(startPos, endPos, hitPos))
					// {
						// CMap@ map = getMap();

						// if (isServer())
						// {
							// // SpawnBoom(this, hitPos);
						// }
					// }
				// }

				length = (hitPos - startPos).Length() + 8;

				this.set_u32("nextShoot", getGameTime() + delay);

				ShakeScreen(64, 32, startPos);
				holder.AddForce(-aimDir * 100.00f);

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

					Sound::Play("/Mithrios_Shoot.ogg", this.getPosition(), 1.00f, 1.00f);
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
				bool has = quantity >= 10;
				if (has)
				{
					if (take)
					{
						if (quantity >= 10) item.server_SetQuantity(quantity - 10);
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

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();
	if (inv is null) return;

	this.doTickScripts = true;
	inv.doTickScripts = true;
}
