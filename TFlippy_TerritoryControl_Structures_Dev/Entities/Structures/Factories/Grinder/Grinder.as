#include "MakeMat.as";
#include "Hitters.as"
#include "ParticleSparks.as";

const int MAX_GRINDABLE_AT_ONCE = 5;

void onInit(CSprite@ this)
{
	this.SetZ(10);

	this.SetEmitSound("Grinder_Loop.ogg");
	this.SetEmitSoundVolume(0.3f);
	this.SetEmitSoundSpeed(0.9f);
	this.SetEmitSoundPaused(false);
	this.getCurrentScript().tickFrequency = 2;
	CSpriteLayer@ chop_left = this.addSpriteLayer("chop_left", "/Saw.png", 16, 16);

	if (chop_left !is null)
	{
		Animation@ anim = chop_left.addAnimation("default", 0, false);
		anim.AddFrame(3);
		anim.AddFrame(7);
		chop_left.SetAnimation(anim);
		chop_left.SetRelativeZ(-1.0f);
		chop_left.SetOffset(Vec2f(5.0f, -1.0f));
	}

	CSpriteLayer@ chop_right = this.addSpriteLayer("chop_right", "/Saw.png", 16, 16);

	if (chop_right !is null)
	{
		Animation@ anim = chop_right.addAnimation("default", 0, false);
		anim.AddFrame(3);
		anim.AddFrame(7);
		chop_right.SetAnimation(anim);
		chop_right.SetRelativeZ(-1.0f);
		chop_right.SetOffset(Vec2f(-5.0f, -2.0f));
	}
}
void onInit(CBlob@ this)
{
	this.Tag("builder always hit");

	this.getShape().SetOffset(Vec2f(0, 4));

	{
		Vec2f offset(-24, 8);

		Vec2f[] shape =
		{
			Vec2f(0.0f, 0.0f) - offset,
			Vec2f(8.0f, 0.0f) - offset,
			Vec2f(8.0f, 23.0f) - offset,
			Vec2f(0.0f, 23.0f) - offset
		};
		this.getShape().AddShape(shape);
	}

	{
		Vec2f offset(8, 8);

		Vec2f[] shape =
		{
			Vec2f(0.0f, 0.0f) - offset,
			Vec2f(8.0f, 0.0f) - offset,
			Vec2f(8.0f, 23.0f) - offset,
			Vec2f(0.0f, 23.0f) - offset
		};
		this.getShape().AddShape(shape);
	}

	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 5;
	this.getShape().SetStatic(true);
}

void onTick(CBlob@ this)
{
	if (this.getTickSinceCreated() > 30)
	{
		ShapeConsts@ consts = this.getShape().getConsts();
		consts.collidable = true;
	}

	CBlob@[] blobs;
	if (getMap().getBlobsInRadius(this.getPosition()+Vec2f(0,-2) ,6.4f, @blobs))
	{
		int length = (blobs.length > MAX_GRINDABLE_AT_ONCE ? MAX_GRINDABLE_AT_ONCE : blobs.length);

		for (uint i = 0; i < length; i++)
		{
			CBlob@ blob = blobs[i];
			if (blob is null) { continue; }

			if (canSaw(this, blob))
			{
				Blend(this, blob);
				if (isServer())
				{ 
					this.server_Hit(blob, blob.getPosition(), Vec2f(0, -2), 2.00f, Hitters::saw, true); 
				}
			}
			else if (blob.hasTag("material") ? !this.server_PutInInventory(blob) : true)
			{
				blob.setVelocity(Vec2f(4 - XORRandom(8), -4));

				if (blobs.length > length) // lets increase the length if its a useless item
				{
					length += 1;
				}
			}
		}
	}
}

void onTick(CSprite@ this)
{
	if (this.getBlob().getTickSinceCreated() < 90) { return; }

	CSpriteLayer@ chop_left = this.getSpriteLayer("chop_left");
	CSpriteLayer@ chop_right = this.getSpriteLayer("chop_right");

	if (chop_left !is null) chop_left.RotateBy(10.0f, Vec2f(0.5f, -0.5f));
	if (chop_right !is null) chop_right.RotateBy(-10.0f, Vec2f(0.5f, -0.5f));
}

bool canSaw(CBlob@ this, CBlob@ blob)
{
	string name = blob.getName();
    bool mat_check = (name == "mat_stone" || name == "mat_dirt" || name == "mat_coal" ? false : blob.hasTag("invincible"));

    if (this.getTickSinceCreated() < 90 || blob.hasTag("sawed") || 
        blob.getShape().isStatic() || name == "grinder" || mat_check) 
    {
            return false;
    }

	if (blob.hasTag("flesh") && isClient() && !g_kidssafe)
	{
		CSprite@ sprite = this.getSprite();
		CSpriteLayer@ chop_left = sprite.getSpriteLayer("chop_left");
		CSpriteLayer@ chop_right = sprite.getSpriteLayer("chop_right");

		if (chop_left !is null) chop_left.animation.frame = 1;
		if (chop_right !is null) chop_right.animation.frame = 1;

		sprite.SetAnimation("blood");
	}

	return true;
}

void Blend(CBlob@ this, CBlob@ blob)
{
	if (this is blob || blob.hasTag("sawed")) return;

	bool kill = false;
	const string name = blob.getName();
	const int hash = name.getHash();

	switch(hash)
	{
		case 1062293841://log
		{
			if (isServer())
			{
				MakeMat(this, this.getPosition(), "mat_wood", 100 + XORRandom(40));
			}

			this.getSprite().PlaySound("SawLog.ogg", 0.8f, 0.9f);
			kill = true;
		}
		break;

		case 575725963://mat_stone
		{
			if (isServer())
			{
				u32 quantity = blob.getQuantity();

				MakeMat(this, this.getPosition(), "mat_stone", 		quantity * 0.50f + XORRandom(quantity * 0.25f));
				MakeMat(this, this.getPosition(), "mat_concrete", 	quantity * 0.125 + XORRandom(quantity * 0.125f));
				MakeMat(this, this.getPosition(), "mat_iron", 		XORRandom(quantity * 0.20f));
				MakeMat(this, this.getPosition(), "mat_copper", 	XORRandom(quantity * 0.06f));
				MakeMat(this, this.getPosition(), "mat_gold",	 	XORRandom(quantity * 0.06f));
				MakeMat(this, this.getPosition(), "mat_mithril", 	XORRandom(quantity * 0.05f));
			}

			if (isClient())
			{
				this.getSprite().PlaySound("rocks_explode" + (1 + XORRandom(2)) + ".ogg", 1.5f, 1.0f);

				if (XORRandom(100) < 75)
				{
					ParticleAnimated("Smoke.png", this.getPosition() + Vec2f(8 - XORRandom(16), 8 - XORRandom(16)), Vec2f((100 - XORRandom(200)) / 100.0f, 0.5f), 0.0f, 1.5f, 3, 0.0f, true);
				}
			}
			kill = true;
		}
		break;

		case 1074492747://mat_dirt
		{
			if (isServer())
			{
				u32 quantity = blob.getQuantity();

				MakeMat(this, this.getPosition(), "mat_dirt", 		quantity * 0.65f + XORRandom(quantity * 0.25f));
				MakeMat(this, this.getPosition(), "mat_sulphur", 	XORRandom(quantity * 0.15f));
				MakeMat(this, this.getPosition(), "mat_copper", 	XORRandom(quantity * 0.03f));
			}

			if (isClient())
			{
				this.getSprite().PlaySound("dig_dirt" + (1 + XORRandom(3)) + ".ogg", 1.5f, 1.0f);

				if (XORRandom(100) < 75)
				{
					ParticleAnimated
					(
						"DustSmall.png", 
						this.getPosition() + Vec2f(8 - XORRandom(16), 8 - XORRandom(16)), 
						Vec2f((100 - XORRandom(200)) / 100.0f, 0.5f), 
						0.0f, 
						1.5f, 
						3, 
						0.0f, 
						true
					);
				}
			}
			kill = true;
		}
		break;

		case 881918781://scythergib
		{
			if (isServer())
			{
				MakeMat(this, this.getPosition(), "mat_plasteel", 5 + XORRandom(20));
				MakeMat(this, this.getPosition(), "mat_steelingot", 1 + XORRandom(3));
			}
			kill = true;
		}
		break;

		case 336243301://steak
		{

			if (isServer())
			{
				u8 quantity = blob.getQuantity();

				MakeMat(this, this.getPosition(), "mat_meat", quantity * 20 + XORRandom(quantity * 10));
			}

			this.getSprite().PlaySound("SawLog.ogg", 0.8f, 1.0f);
			kill = true;
		}
		break;

		case -324721731://mat_coal
		{
			blob.Tag("dusted");
			blob.setInventoryName("Coal Dust");
			this.server_PutInInventory(blob);

			if (isClient())
			{
				this.getSprite().PlaySound("rocks_explode" + (1 + XORRandom(2)) + ".ogg", 1.5f, 1.0f);

				if (XORRandom(100) < 75)
				{
					ParticleAnimated
					(
						"Smoke.png", 
						this.getPosition() + Vec2f(8 - XORRandom(16), 8 - XORRandom(16)), 
						Vec2f((100 - XORRandom(200)) / 100.0f, 0.5f), 
						0.0f, 
						1.5f, 
						3, 
						0.0f, 
						true
					);
				}
			}
		}
		break;

		default:
		{
			if (blob.hasTag("flesh"))
			{
				if (isServer())
				{
					f32 amount = ((blob.getRadius() + XORRandom(blob.getMass() / 3.0f)) / blob.getInitialHealth()) * 0.35f;
					amount += XORRandom(amount) * 0.50f;

					// print("" + amount);

					blob.setVelocity(Vec2f(1 - XORRandom(2), -0.25f));

					MakeMat(this, this.getPosition(), "mat_meat", amount);
				}
			}
			else if (blob.hasTag("weapon"))
			{
				if (isServer())
				{
					MakeMat(this, this.getPosition(), "mat_ironingot", 1);
					MakeMat(this, this.getPosition(), "mat_wood", 10 + XORRandom(30));

					kill = true;
				}
			}
			else
			{
				this.getSprite().PlaySound("ShieldHit.ogg");
				sparks(blob.getPosition(), 1, 1);
				blob.setVelocity(Vec2f(4 - XORRandom(8), -5));
			}
		}
		break;
	}

	if (kill)
	{
		blob.Tag("sawed");

		CSprite@ s = blob.getSprite();
		if (s !is null)
		{
			s.Gib();
		}

		blob.server_SetHealth(-1.0f);
		blob.server_Die();
	}
}

// void onCollision(CBlob@ this, CBlob@ blob, bool solid)
// {
	// if (blob is null) return;

	// Vec2f pos = this.getPosition();
	// Vec2f bpos = blob.getPosition();

	// if ((bpos.x > pos.x + 9) || (bpos.x < pos.x - 9) || bpos.y > pos.y) return;

	// if (canSaw(this, blob))
	// {
		// Blend(this, blob);
		// this.server_Hit(blob, bpos, Vec2f(0, -2), 2.00f, Hitters::saw, true);
	// }
	// else if (blob.hasTag("material") ? !this.server_PutInInventory(blob) : true)
	// {
		// blob.setVelocity(Vec2f(4 - XORRandom(8), -4));
	// }
// }

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	// return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this));
	return forBlob !is null && (forBlob.getName() == "extractor" || forBlob.getName() == "filterextractor" || (forBlob.getPosition() - this.getPosition()).Length() <= 64);
}
