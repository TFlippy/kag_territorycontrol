// Trader logic

#include "RunnerCommon.as"
#include "Help.as";
#include "Hitters.as";
#include "Requirements.as";
#include "ShopCommon.as";

//trader methods

//blob

string[] firstnames = 
{ 
	"Kevin",
	"Eughene",
	"Lawrence",
	"Macaulay",
	"Johnny",
	"Steve",
	"Sid",
	"Johnny",
	"Jethro",
	"Nelson",
	"Bobby",
	"Harry",
	"Barry",
	"Jerry",
	"Garry"
};

string[] surnames = 
{ 
	"Bobington",
	"Culkin",
	"Stud",
	"Garbel",
	"Bud",
	"Nelson",
	"Snot",
	"Aqualung",
	"Ugh",
	"Dump"
};

string[] soundsTalk = 
{ 
	"MigrantHmm.ogg",
	"drunk_fx2.ogg",
	"drunk_fx3.ogg",
	"drunk_fx4.ogg"
};

string[] soundsDanger = 
{ 
	"trader_scream_0.ogg",
	"trader_scream_1.ogg",
	"trader_scream_2.ogg"
};

string[] textsIdle = 
{ 
	"give me ya money 'itch",
	"c'mere here ya shit",
	"oi ya shit",
	"ay give me ya stuff",
	"did ya brin' the wine",
	"let's 'eat up 'arry tomorra",
	"aye, we'll fuck him up",
	"hav ya seen garry lately?",
	"gnarly",
	"yar",
	"arrrr",
	"*gurgle*",
	"ayy shit!",
	"psftush",
	"ohoho",
	"ya bloody idiot",
	"damn right innit?",
	"wanna fight ya cunt?",
	"sit on ya arse",
	"ill bash ye fookin 'ead in i sware on me mum"
};

string[] textsDanger = 
{ 
	"ya weenie 'lil shit",
	"i'll get ya asshole",
	"kill yarself",
	"get out of here ya weenie 'lil shit",
	"so wanna fight huh?",
	"give me ya money 'itch",
	"c'mere here ya shit",
	"oi ya shit",
	"aye, we'll fuck him up",
	"yar",
	"arrrr",
	"ayy shit!",
	"ya bloody idiot",
	"damn right innit?",
	"wanna fight ya cunt?",
	"sit on ya arse",
	"ill bash ye fookin ead in i sware on me mum"
};

string[] textsWon = 
{
	"put me 'ack ya shitbag",
	"go to hell",
	"scrub",
	"na give me ya money",
	"oi ya shit",
	"ay give me ya stuff",
	"aye, we did fuck him up",
	"yar",
	"arrrr",
	"*gurgle*",
	"ayy shit!",
	"ya bloody idiot",
	"damn right innit?",
	"wanna fight ya cunt?",
	"sit on ya arse"
};

void onInit(CBlob@ this)
{
	Random@ rand = Random(this.getNetworkID());
	string name = firstnames[rand.NextRanged(firstnames.length)] + " " + surnames[rand.NextRanged(surnames.length)];
	this.set_string("trader name", name);
	
	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.set_f32("gib health", -2.0f);
	this.Tag("flesh");
	this.Tag("migrant");
	this.Tag("human");
	this.getBrain().server_SetActive(true);

	//this.getCurrentScript().runFlags |= Script::tick_not_attached;
	//this.getCurrentScript().runFlags |= Script::tick_moving;

	this.set_u32("nextTalk", getGameTime() + XORRandom(60));
	this.set_u32("nextFood", 0);
	
	this.addCommandID("traderChat");

	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 2));
	this.set_string("shop description", name + " the Hobo");
	this.setInventoryName(name + " the Hobo");
	this.set_u8("shop icon", 25);
	
	this.set_u32("lastDanger", 0);

	if (rand.NextRanged(100) < 50)
	{
		ShopItem@ s = addShopItem(this, "Honking Shite", "$klaxon$", "klaxon", "throw it away");
		AddRequirement(s.requirements, "coin", "", "Coins", 417);
		s.spawnNothing = true;
	}
	
	if (rand.NextRanged(100) < 50)
	{
		ShopItem@ s = addShopItem(this, "Big Cuffs", "$shackles$", "shackles", "tie that fool up");
		AddRequirement(s.requirements, "coin", "", "Coins", 170);
		s.spawnNothing = true;
	}
	
	if (rand.NextRanged(100) < 50)
	{
		ShopItem@ s = addShopItem(this, "Sticky Stick", "$nightstick$", "nightstick", "a stick for beating up");
		AddRequirement(s.requirements, "coin", "", "Coins", 90);
		s.spawnNothing = true;
	}
	
	if (rand.NextRanged(100) < 50)
	{
		ShopItem@ s = addShopItem(this, "Firework", "$icon_firework$", "firework", "popping flying shit");
		AddRequirement(s.requirements, "coin", "", "Coins", 140);
		s.spawnNothing = true;
	}
	
	if (rand.NextRanged(100) < 50)
	{
		ShopItem@ s = addShopItem(this, "Firejob", "$icon_firejob$", "firejob", "fucking tie it to your neck and launch it ya cunt");
		AddRequirement(s.requirements, "coin", "", "Coins", 1500);
		s.spawnNothing = true;
	}
}

void onTick(CBlob@ this)
{
	if (!this.hasTag("dead"))
	{
		if (this.getHealth() <= 0)
		{
			this.Tag("dead");			
			return;
		}
	
		if (getNet().isServer() && getGameTime() % 150 == 0)
		{
			const u8 myTeam = this.getTeamNum();

			int count = getPlayerCount();
			for (uint i = 0; i < count; i++)
			{
				CPlayer@ ply = getPlayer(i);
				if (ply.getTeamNum() == myTeam)
				{
					if (ply !is null) ply.server_setCoins(ply.getCoins() + 3);
				}
			}
		}
	
		if (getGameTime() >= this.get_u32("nextTalk"))
		{
			this.set_u32("nextTalk", getGameTime() + (30 * 10) + XORRandom(30 * 20));
			
			u32 lastDanger = this.get_u32("lastDanger");
			u16 dangerBlobNetID = this.get_u16("danger blob");
			
			bool danger = dangerBlobNetID > 0 && getGameTime() < (lastDanger + (30 * 30));
			
			string text = "";
			if (danger)
			{
				// this.set_u32("lastDanger", getGameTime());
				
				text = textsDanger[XORRandom(textsDanger.length())];
				this.getSprite().PlaySound(soundsDanger[XORRandom(soundsDanger.length())], 0.75f, 0.75f);
			}
			else
			{
				if (getGameTime() - this.get_u32("lastDanger") < 30 * 60)
				{
					text = textsWon[XORRandom(textsWon.length())];
				}
				else
				{
					text = textsIdle[XORRandom(textsIdle.length())];
					this.getSprite().PlaySound(soundsTalk[XORRandom(soundsTalk.length())], 0.75f, 1.00f);
				}
			}

			if (getNet().isServer())
			{
				CBitStream stream;
				stream.write_string(text);
				this.SendCommand(this.getCommandID("traderChat"), stream);
			}
		}
		
		// if (getNet().isServer())
		{
			CBlob@[] blobs;
			getMap().getBlobsInRadius(this.getPosition(), 96, @blobs);
			
			int index = -1;
			f32 s_dist = 900000.00f;
			u8 myTeam = this.getTeamNum();

			for (int i = 0; i < blobs.length; i++)
			{
				CBlob@ b = blobs[i];
				u8 team = b.getTeamNum();
				
				f32 dist = (b.getPosition() - this.getPosition()).LengthSquared();
				
				if (team != myTeam && dist < s_dist && b.hasTag("flesh") && !b.hasTag("dead"))
				{
					s_dist = dist;
					index = i;
				}
			}
			
			if (index != -1)
			{
				CBlob@ target = blobs[index];
				
				if (target !is null)
				{
					if (this.get_u32("nextThrow") < getGameTime())
					{
						if (XORRandom(100) < 2)
						{
							this.set_u32("nextTalk", 0);
						
							Vec2f dir = target.getPosition() - this.getPosition();						
							this.SetFacingLeft(dir.x < 0);
						
							if (getNet().isServer())
							{			
								f32 dist = dir.Length();
								dir.Normalize();
							
								CBlob@ rock = server_CreateBlob("hobo_junk", this.getTeamNum(), this.getPosition());
								if (rock !is null)
								{
									rock.setVelocity((dir * 6.00f) + Vec2f(0, -3));
									this.set_u32("nextThrow", getGameTime() + 30 + XORRandom(90));
								}
							}
						}
					}
				}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("traderChat"))
	{
		this.Chat(params.read_string());
	}
	else if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("ChaChing.ogg", 1.00f, 0.75f);
		
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item)) return;
		
		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);
		
		if (callerBlob is null) return;
		
		if (getNet().isServer())
		{
			string[] spl = name.split("-");
			
			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;
				
				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
			else if (name.findFirst("mat_") != -1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;
				
				CBlob@ mat = server_CreateBlob(spl[0]);
							
				if (mat !is null)
				{
					mat.Tag("do not set materials");
					mat.server_SetQuantity(parseInt(spl[1]));
					if (!callerBlob.server_PutInInventory(mat))
					{
						mat.setPosition(callerBlob.getPosition());
					}
				}
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());
				
				if (blob is null) return;
			   
				if (!blob.canBePutInInventory(callerBlob))
				{
					callerBlob.server_Pickup(blob);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
		}
	}
}

void onDie(CBlob@ this)
{
	if (getNet().isServer())
	{
		server_DropCoins(this.getPosition(), XORRandom(50));
	}
}

void onReload(CSprite@ this)
{
	this.getConsts().filename = "Hobo.png";
}

void onGib(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	CParticle@ Gib1 = makeGibParticle("Entities/Special/WAR/Trading/TraderGibs.png", pos, vel + getRandomVelocity(90, hp, 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall");
	CParticle@ Gib2 = makeGibParticle("Entities/Special/WAR/Trading/TraderGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2, 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall");
	CParticle@ Gib3 = makeGibParticle("Entities/Special/WAR/Trading/TraderGibs.png", pos, vel + getRandomVelocity(90, hp, 80), 2, 0, Vec2f(16, 16), 2.0f, 0, "/BodyGibFall");
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	if (this.getHealth() < 1.0f && !this.hasTag("dead"))
	{
		this.Tag("dead");
		// this.server_SetTimeToDie(20);
	}

	if (this.getHealth() < 0)
	{
		this.getSprite().Gib();
		this.server_Die();
		return;
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	// if (byBlob.getTeamNum() != this.getTeamNum()) return true;

	// CBlob@[] blobsInRadius;
	// if (this.getMap().getBlobsInRadius(this.getPosition(), 0.0f, @blobsInRadius))
	// {
		// for (uint i = 0; i < blobsInRadius.length; i++)
		// {
			// CBlob @b = blobsInRadius[i];
			// if (b.getName() == "tradingpost")
			// {
				// return false;
			// }
		// }
	// }
	return false;
}

// bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
// {
	// // dont collide with people
	// return false;
// }

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	this.set_u32("lastDanger", getGameTime());
	this.set_u16("danger blob", hitterBlob.getNetworkID());
	this.set_u32("nextTalk", this.get_u32("nextTalk") - (30 * damage * 13));
	
	return damage;
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	// this.set_u32("lastDanger", getGameTime() - (30 * 30));
	this.set_u16("danger blob", 0);
}

//sprite/anim update

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	// set dead animations

	if (blob.hasTag("dead"))
	{
		if (!this.isAnimation("dead")) this.PlaySound("trader_death.ogg", 1.00f, 0.75f);

		this.SetAnimation("dead");

		if (blob.isOnGround())
		{
			this.SetFrameIndex(0);
		}
		else
		{
			this.SetFrameIndex(1);
		}
		//this.getCurrentScript().runFlags |= Script::remove_after_this;

		return;
	}

	// if (blob.hasTag("shoot wanted"))
	// {
		// this.SetAnimation("shoot");
		// return;
	// }

	// set animations
	Vec2f pos = blob.getPosition();
	Vec2f aimpos = blob.getAimPos();
	bool ended = this.isAnimationEnded();

	bool danger = getGameTime() < (blob.get_u32("lastDanger") + (30 * 30));
	
	if ((blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right)) || (blob.isOnLadder() && (blob.isKeyPressed(key_up) || blob.isKeyPressed(key_down))))
	{
		if (danger)
		{
			this.SetAnimation("dangerwalk");
		}
		else
		{
			this.SetAnimation("walk");
		}
	}
	else if (ended)
	{
		this.SetAnimation("default");
	}
}
