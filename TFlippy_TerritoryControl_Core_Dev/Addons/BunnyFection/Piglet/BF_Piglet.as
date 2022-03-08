//bf_piglet
#include "AnimalConsts.as";
#include "Knocked.as";

//sprite
void onInit(CSprite@ this)
{
	this.ReloadSprites(0,0);
	this.SetZ(-20.0f);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob.hasTag("dead")) 
	{
		this.getCurrentScript().removeIfTag = "dead";
		return;
	}
	else
	{
		f32 x = Maths::Abs(blob.getVelocity().x);

		if (Maths::Abs(x) > 0.2f)
		{
			this.SetAnimation("walk");
		}
		else
		{
			this.SetAnimation("idle");
		}
		
		if (blob.get_u32("next oink") < getGameTime() && XORRandom(100) < 30) 
		{
			blob.set_u32("next oink", getGameTime() + 200);
			this.PlaySound("BF_PigOink" + (1 + XORRandom(3)), 1, 1);
		}
	}
}

void onInit(CBlob@ this)
{
	this.set_f32("bite damage", 0.1f);

	//brain
	this.set_u8(personality_property, SCARED_BIT);
	this.getBrain().server_SetActive(true);
	this.set_f32(target_searchrad_property, 30.0f);
	this.set_f32(terr_rad_property, 75.0f);
	this.set_u8(target_lose_random, 14);

	this.addCommandID("write");

	//for shape
	this.getShape().SetRotationsAllowed(false);

	//for flesh hit
	this.set_f32("gib health", -2.0f);	  	
	this.Tag("flesh");
	this.Tag("passive");

	this.getShape().SetOffset(Vec2f(0, 2));

	this.set_u8( "maxStickiedTime", 40 );

	AnimalVars@ vars;
	if (!this.get( "vars", @vars )) return;

	vars.walkForce.Set(15.0f, -0.1f);
	vars.runForce.Set(30.0f, -1.0f);
	vars.slowForce.Set(10.0f, 0.0f);
	vars.jumpForce.Set(0.0f, -20.0f);
	vars.maxVelocity = 2.2f;

	this.set_u8("number of steaks", 3);
	this.set_u32("next oink", getGameTime());
	this.set_u32("next squeal", getGameTime());

	if (!this.exists("voice_pitch")) this.set_f32("voice pitch", 1.50f);
}

void onTick(CBlob@ this)
{
	if (!this.hasTag("dead"))
	{
		f32 x = this.getVelocity().x;
		if (Maths::Abs(x) > 1.0f)
		{
			this.SetFacingLeft(x < 0);
		}
		else
		{
			if (this.isKeyPressed(key_left)) 
			{
				this.SetFacingLeft(true);
			}
			if (this.isKeyPressed(key_right)) 
			{
				this.SetFacingLeft(false);
			}
		}

		if (this.getHealth() < 0)
		{
			this.getSprite().SetAnimation("dead");

			this.Tag("dead");
			// this.getCurrentScript().removeIfTag = "dead";
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (!this.hasTag("dead") && getGameTime() > this.get_u32("next squeal"))
	{
		this.getSprite().PlaySound("BF_PigSqueal" + (1 + XORRandom(2)), 1.00f, 1.0f);
		this.set_u32("next squeal", getGameTime() + 90);
		this.AddForce(Vec2f(0.0f, -180.0f));
	}

	return damage;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob !is null && (blob.isCollidable() && !blob.hasTag("player"));
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob is null) return;
	if (this.hasTag("dead")) return;

	if (blob.getName() == "mat_mithril" && blob.getQuantity() > 25)
	{
		if (isServer())
		{
			CBlob@ bagel = server_CreateBlob("pigger", this.getTeamNum(), this.getPosition());
			this.server_Die();
		}
		else
		{
			ParticleZombieLightning(this.getPosition());
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
			this.setInventoryName(this.get_string("text") + " the piglet");
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller is null) return;
	if (!this.isOverlapping(caller)) return;

	//rename the piglet
	CBlob@ carried = caller.getCarriedBlob();
	if(carried !is null && carried.getName() == "paper")
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(carried.getNetworkID());

		CButton@ buttonWrite = caller.CreateGenericButton("$icon_paper$", Vec2f(0, 0), this, this.getCommandID("write"), "Rename", params);
	}
}
