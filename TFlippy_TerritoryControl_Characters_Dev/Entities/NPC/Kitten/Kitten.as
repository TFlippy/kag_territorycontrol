#include "AnimalConsts.as";
#include "Hitters.as";

const string[] names = 
{ 
	"Thor",
	"Loki",
	"Buttface",
	"Toby",
	"Ginger",
	"Fluffy",
	"Shite",
	"Fitz",
	"Cheeder",
	"Blaze",
	"Marmalade",
	"Orange",
	"TFlippy",
	"Apricot",
	"Cheetah",
	"Cheeto",
	"Tigger",
	"Luna",
	"Mojo",
	"Oscar",
	"Bengie",
	"Oatmeal"
};

const string[] surnames = {
	"kitty",
	"kitten",
	"kat",
	"cat",
	"fluff",
	"feline",
	"small tiger",
	"pussy",
	"puss"
};

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
		
		if (blob.get_u32("next meow") < getGameTime() && XORRandom(100) < 30) 
		{
			blob.set_u32("next meow", getGameTime() + 120);
			this.PlaySound("Kitten_Meow_" + XORRandom(5), 0.75f, 1);
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
	
	//for shape
	this.getShape().SetRotationsAllowed(false);
	
	//for flesh hit
	this.set_f32("gib health", -2.0f);	  	
	this.Tag("flesh");

	this.getShape().SetOffset(Vec2f(0, 2));

	this.set_u8( "maxStickiedTime", 40 );
	
	AnimalVars@ vars;
	if (!this.get( "vars", @vars )) return;
		
	vars.walkForce.Set(25.0f, -0.1f);
	vars.runForce.Set(40.0f, -1.0f);
	vars.slowForce.Set(10.0f, 0.0f);
	vars.jumpForce.Set(0.0f, -30.0f);
	vars.maxVelocity = 3.2f;
	
	this.set_u8("number of steaks", 2);
	this.set_u32("next meow", getGameTime());
	this.set_u32("next screech", getGameTime());
	
	if (!this.exists("voice_pitch")) this.set_f32("voice pitch", 1.70f);

	Random@ rand = Random(this.getNetworkID());
	string name = names[rand.NextRanged(names.length)] + " the " + surnames[rand.NextRanged(surnames.length)];
	this.setInventoryName(name);
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
			this.getSprite().PlaySound("Kitten_Death_0", 1.00f, 1.0f);
			this.Tag("dead");
			// this.getCurrentScript().removeIfTag = "dead";
		}
		
		if (this.isInInventory())
		{
			CBlob@ inventoryBlob = this.getInventoryBlob();
			if (inventoryBlob !is null)
			{
				if (this.getTickSinceCreated() % 10 == 0)
				{
					if (isServer()) this.server_Hit(inventoryBlob, inventoryBlob.getPosition(), Vec2f(0, 0), 0.15f, Hitters::bite, true);
					if (isClient()) 
					{
						if (XORRandom(3) == 0) 
						{	
							this.getSprite().PlaySound("Kitten_Hit_" + XORRandom(4), 1.00f, 1.0f);
							this.set_u32("next screech", getGameTime() + 40);
						}
						if (inventoryBlob.hasTag("flesh"))
						{
							this.getSprite().PlaySound("Pus_Attack_" + XORRandom(3), 1.1f, 1.00f);
							ParticleBloodSplat(inventoryBlob.getPosition(), true);
						}
					}
				}
			}
		}
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	inv.doTickScripts = true;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (!this.hasTag("dead") && getGameTime() > this.get_u32("next screech"))
	{
		this.getSprite().PlaySound("Kitten_Hit_" + XORRandom(4), 1.00f, 1.0f);
		this.set_u32("next screech", getGameTime() + 30);
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

	if (blob.getName() == "mat_mithril" && blob.getQuantity() > 50)
	{
		
		
		if (isServer())
		{
			CBlob@ bagel = server_CreateBlob("pus", this.getTeamNum(), this.getPosition());
			this.server_Die();
		}
		else
		{
			ParticleZombieLightning(this.getPosition());
		}
	}
}