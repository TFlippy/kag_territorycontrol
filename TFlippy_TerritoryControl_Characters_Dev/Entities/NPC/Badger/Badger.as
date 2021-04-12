#include "AnimalConsts.as";

const u8 DEFAULT_PERSONALITY = AGGRO_BIT;

void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0); //always blue
	this.addSpriteLayer("isOnScreen","NoTexture.png",1,1);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (!blob.hasTag("dead"))
	{
		if(!this.getSpriteLayer("isOnScreen").isOnScreen()){
			return;
		}

		Vec2f vel=blob.getVelocity();
		if(vel.x!=0.0f)
		{
			this.SetFacingLeft(vel.x < 0.0f ? true : false);
		}
		f32 x = blob.getVelocity().x;
		if (Maths::Abs(x) > 0.2f)
		{
			this.SetAnimation("walk");
		}
		else
		{
			this.SetAnimation("idle");
		}
	}
	else
	{
		this.SetAnimation("dead");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

void onInit(CBlob@ this)
{
	//for EatOthers
	string[] tags = {"player"};
	this.set("tags to eat", tags);

	this.set_f32("bite damage", 0.05f);

	//brain
	this.set_u8(personality_property, DEFAULT_PERSONALITY);
	this.set_u8("random move freq", 5);
	this.set_f32(target_searchrad_property, 320.0f);
	this.set_f32(terr_rad_property, 85.0f);
	this.set_u8(target_lose_random, 34);

	this.set_u32("next growl", 0);
	this.set_u32("next bite", 0);

	this.addCommandID("write");

	if (!this.exists("voice_pitch")) this.set_f32("voice pitch", 0.90f);

	// this.getCurrentScript().removeIfTag = "dead";

	this.getBrain().server_SetActive(true);

	//for shape
	this.getShape().SetRotationsAllowed(false);

	//for flesh hit
	this.set_f32("gib health", -0.0f);

	this.Tag("flesh");
	this.Tag("badger");
	this.Tag("dangerous");

	this.set_u8("number of steaks", 3);

	this.getShape().SetOffset(Vec2f(0, 0));

	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 320.0f;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	//movement
	AnimalVars@ vars;
	if (!this.get("vars", @vars))
		return;
	vars.walkForce.Set(43.0f, -4.4f);
	vars.runForce.Set(96.0f, -43.0f);
	vars.slowForce.Set(12.0f, 0.0f);
	vars.jumpForce.Set(0.0f, -200.0f);
	vars.maxVelocity = 1.8f;

	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			ap.offsetZ = 10.0f;
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.getHealth() < 5.0f; 
}

void onTick(CBlob@ this)
{
	if (!this.hasTag("dead"))
	{
		if (isClient())
		{
			if (this.get_u32("next growl") < getGameTime() && XORRandom(100) < 10) 
			{
				this.set_u32("next growl", getGameTime() + 100);
				this.getSprite().PlaySound("badger_growl" + (1 + XORRandom(6)), 1, (1 + XORRandom(100) / 400.0f) * this.get_f32("voice pitch"));
			}
		}

		if (this.getHealth() < 3.0)
		{
			this.Tag("dead");
			this.setInventoryName("A Mangled Badger");
		}

		Vec2f vel = this.getVelocity();
		if (vel.x != 0.0f)
		{
			this.SetFacingLeft(vel.x < 0.0f);
		}

		if (this.isOnGround() && (this.isKeyPressed(key_left) || this.isKeyPressed(key_right)))
		{
			if ((this.getNetworkID() + getGameTime()) % 9 == 0)
			{
				f32 volume = Maths::Min(0.1f + Maths::Abs(vel.x) * 0.1f, 1.0f);
				TileType tile = this.getMap().getTile(this.getPosition() + Vec2f(0.0f, this.getRadius() + 4.0f)).type;
				if(isClient())
				{
					if (this.getMap().isTileGroundStuff(tile))
					{
						this.getSprite().PlaySound("/EarthStep", volume, 0.75f);
					}
					else
					{
						this.getSprite().PlaySound("/StoneStep", volume, 0.75f);
					}
				}
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	this.set_u8(personality_property, AGGRO_BIT);
	MadAt(this, hitterBlob);
	return damage;
}

void MadAt(CBlob@ this, CBlob@ hitterBlob)
{
	if (hitterBlob is null) return;

	this.set_u8(personality_property, DEFAULT_PERSONALITY | AGGRO_BIT);
	this.set_u8(state_property, MODE_TARGET);

	if (hitterBlob !is this && hitterBlob.getName() != this.getName()) this.set_netid(target_property, hitterBlob.getNetworkID());
}

#include "Hitters.as";

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !blob.hasTag("flesh");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob is null) return;
	if (this.hasTag("dead")) return;
	if (this.get_u32("next bite") > getGameTime()) return;

	if (blob.getName() != this.getName() && blob.hasTag("flesh"))
	{
		const f32 vellen = this.getShape().vellen;
		if (vellen > 0.1f)
		{
			Vec2f pos = this.getPosition();
			Vec2f vel = this.getVelocity();
			Vec2f other_pos = blob.getPosition();
			// Vec2f direction = other_pos - pos;

			// direction.Normalize();
			vel.Normalize();

			this.getSprite().PlaySound("ZombieBite.ogg", 1.0f, 1.2f);
			this.getSprite().PlaySound("badger_pissed.ogg", 1, (1 + XORRandom(100) / 400.0f) * this.get_f32("voice pitch"));
			this.server_Hit(blob, point1, vel, 0.70f, Hitters::bite, false);

			MadAt(this, blob);

			this.set_u32("next bite", getGameTime() + 30);
			this.set_u32("next growl", getGameTime() + 100);
		}
	}
	else if (blob.getName() == "mat_mithril" && blob.getQuantity() > 25)
	{
		if (isServer())
		{
			CBlob@ bagel = server_CreateBlob("bagel", this.getTeamNum(), this.getPosition());
			this.server_Die();
		}
		else
		{
			ParticleZombieLightning(this.getPosition());
			this.getSprite().PlaySound("/badger_pissed", 1.5f, 0.5f);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("write"))
	{
		if (isServer())
		{
			CBlob @caller = getBlobByNetworkID(params.read_u16());
			CBlob @carried = getBlobByNetworkID(params.read_u16());

			if (caller !is null && carried !is null)
			{
				this.set_string("text", carried.get_string("text"));
				this.Sync("text", true);
				carried.server_Die();
			}
		}
		if (isClient())
		{
			this.setInventoryName(this.get_string("text") + " the badger");
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller is null) return;
	if (!this.isOverlapping(caller)) return;

	//rename the badger
	CBlob@ carried = caller.getCarriedBlob();
	if(carried !is null && carried.getName() == "paper")
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(carried.getNetworkID());

		CButton@ buttonWrite = caller.CreateGenericButton("$icon_paper$", Vec2f(0, 0), this, this.getCommandID("write"), "Rename", params);
	}
}
