//bf_piglet
#include "AnimalConsts.as";
#include "PixelOffsets.as"
#include "RunnerTextures.as"
#include "Hitters.as"
#include "HittersTC.as"

//sprite
void onInit(CSprite@ this)
{
    this.ReloadSprites(0,0);
	this.SetZ(-20.0f);
	this.addSpriteLayer("isOnScreen","NoTexture.png",1,1);
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
		if(!this.getSpriteLayer("isOnScreen").isOnScreen()){
			return;
		}
		f32 x = Maths::Abs(blob.getVelocity().x);

		if (Maths::Abs(x) > 0.2f)
		{
			this.SetAnimation("walk");
		}
		else
		{
			this.SetAnimation("idle");
		}
		
		if (blob.get_u32("next succ") < getGameTime() && XORRandom(100) < 30) 
		{
			blob.set_u32("next succ", getGameTime() + 100);
			this.PlaySound("Pigger_Succ_" + XORRandom(3), 0.50f, 0.75f + (XORRandom(50) / 100.00f));
		}
	}
}

void onThisRemoveFromInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.set_u32("next attach", getGameTime() + 90);
}

void onInit(CBlob@ this)
{
	this.set_f32("bite damage", 0.1f);
	
	//brain
	this.set_u8(personality_property, AGGRO_BIT);
	this.getBrain().server_SetActive(true);
	this.set_f32(target_searchrad_property, 30.0f);
	this.set_f32(terr_rad_property, 75.0f);
	this.set_u8(target_lose_random, 14);
	
	//for shape
	this.getShape().SetRotationsAllowed(false);
	
	//for flesh hit
	this.set_f32("gib health", -2.0f);	  	
	this.Tag("flesh");
	this.Tag("dangerous");

	this.getShape().SetOffset(Vec2f(0, 2));

	this.set_u8( "maxStickiedTime", 40 );
	this.set_u32("next attach", 0);
	
	AnimalVars@ vars;
	if (!this.get( "vars", @vars )) return;

	vars.walkForce.Set(15.0f, -0.1f);
	vars.runForce.Set(15.0f, -1.0f);
	vars.slowForce.Set(10.0f, 0.0f);
	vars.jumpForce.Set(0.0f, -100.0f);
	vars.maxVelocity = 10.00f;
	
	// vars.walkForce.Set(5.0f, -0.1f);
	// vars.runForce.Set(5.0f, -1.0f);
	// vars.slowForce.Set(10.0f, 0.0f);
	// vars.jumpForce.Set(0.0f, 0.0f);
	// vars.maxVelocity = 1.00f;
	
	this.set_u8("number of steaks", 2);
	this.set_u32("next succ", getGameTime());
	this.set_u32("next squeal", getGameTime());
}

void onTick(CBlob@ this)
{
	if (!this.hasTag("dead"))
	{
		if(isClient()){
			if(!this.getSprite().getSpriteLayer("isOnScreen").isOnScreen()){
				return;
			}
		}	
		bool succ = false;
	
		u16 netid = this.get_u16("succ netid");
		if (netid != 0)
		{
			CBlob@ blob = getBlobByNetworkID(this.get_u16("succ netid"));
			if (blob !is null && !blob.hasTag("dead"))
			{
				succ = true;
				bool left = blob.isFacingLeft();
				
				CSprite@ sprite = this.getSprite();
				this.SetFacingLeft(left);
				this.getSprite().SetZ(-20.0f);
				
				Vec2f head = getHeadOffset(blob, -1, 0);
				this.setPosition(blob.getPosition() + Vec2f(4 * (left ? 1 : -1), head.y - 20));
				
				if (this.getTickSinceCreated() % 15 == 0) 
				{
					blob.set_u16("pigger_bite_counter", blob.get_u16("pigger_bite_counter") + 1);
					if (blob.get_u16("pigger_bite_counter") > 7)
					{
						if (!blob.hasTag("pigger_pregnant")) 
						{
							blob.Tag("pigger_pregnant");
							blob.AddScript("Pigger_Pregnant.as");
						}
					}
				
					if (isServer()) this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.025f, Hitters::bite, true);
				}
				
				// if (isServer() && !blob.hasTag("transformed") && blob.hasTag("pigger_pregnant"))
				// {
					// if (blob.getHealth() < 0.125f)
					// {
						// CPlayer@ ply = blob.getPlayer();
					
						// blob.Tag("transformed");
						// blob.server_Die();
						
						// for (int i = 0; i < 2; i++)
						// {
							// CBlob@ pigger = server_CreateBlob("pigger", this.getTeamNum(), this.getPosition());
							// pigger.setVelocity(getRandomVelocity(90, 5, 90));
						// }
						
						// CBlob@ man = server_CreateBlob("mithrilman", this.getTeamNum(), this.getPosition());
						// if (ply !is null) man.server_SetPlayer(ply);
					// }
				// }
			}
		}
		
		if (!succ)
		{
			this.set_u16("succ netid", 0);
		
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
		}
		
		if (this.getHealth() < 0)
		{
			this.getSprite().PlaySound("Pigger_Die.ogg", 1.00f, 1.00f);
			this.getSprite().SetAnimation("dead");
			this.Tag("dead");
			// this.getCurrentScript().removeIfTag = "dead";
		}
	}
	else
	{
		this.set_u16("succ netid", 0);
	}
		
	if (isServer())
	{
		if (XORRandom(500) == 0)
		{
			CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());
			blob.server_SetQuantity(2 + XORRandom(10));
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case HittersTC::radiation:
			damage = 0;
			break;
	}
		

	if (damage > 0.10f && !this.hasTag("dead") && getGameTime() > this.get_u32("next succ"))
	{
		this.getSprite().PlaySound("Pigger_Succ_" + XORRandom(3), 1.00f, 1.0f);
		this.set_u32("next succ", getGameTime() + 90);
	}
	
	return damage;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob !is null && (blob.isCollidable() && !blob.hasTag("flesh"));
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null && getGameTime() >= this.get_u32("next attach") && this.get_u16("succ netid") == 0 && blob.hasTag("human") && !blob.hasTag("dead") && !this.hasTag("dead") && blob.getName() != "hazmat")
	{
		this.set_u16("succ netid", blob.getNetworkID());
		this.getSprite().PlaySound("Pigger_Pop_" + XORRandom(2), 1.00f, 1.00f);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (getGameTime() >= this.get_u32("next attach"))
	{
		this.set_u16("succ netid", 0);
		this.getSprite().PlaySound("Pigger_Pop_" + XORRandom(2), 1.00f, 1.00f);
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @attachedPoint)
{
	if (getGameTime() >= this.get_u32("next attach"))
	{
		this.set_u32("next attach", getGameTime() + 15);
	}
}