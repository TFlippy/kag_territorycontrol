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
	"John",
	"Harry",
	"Jack",
	"Charlie",
	"Thomas",
	"William",
	"Henry",
	"Arthur",
	"Ben",
	"Stanley",
	"Bobby",
	"Todd",
	"Toot"
};

string[] surnames = 
{ 
	"Bobington",
	"Goldman",
	"Coin",
	"Smith",
	"Jones",
	"Wilson",
	"Brown",
	"Harrison",
	"Jackson",
	"Thomason",
	"Bobb",
	"Todd",
	"Toot",
	"Doot",
	"Dent",
	"Buckman"
};

string[] soundsTalk = 
{ 
	"MigrantSayHello.ogg",
	"MigrantSayFriend.ogg"
};

string[] soundsDanger = 
{ 
	"trader_scream_0.ogg",
	"trader_scream_1.ogg",
	"trader_scream_2.ogg"
};

string[] textsIdle = 
{ 
	"Good morning!",
	"What a nice day!",
	"Hello!",
	"What's on your mind?",
	"What can I do for you?",
	"Greetings!",
	"Need something?",
	"Safe travels!",
	"Can I help you?",
	"A fine day, is it?",
	"Are you a wizard?"
};

string[] textsDanger = 
{ 
	"I'm too young to die!",
	"This is a nightmare!",
	"HELP ME!",
	"SAVE ME!",
	"I'M GOING TO DIE!",
	"What did I do to deserve this??",
	"I don't want to die!",
	"Don't hurt me!",
	"OH MY GOD WE'RE DOOMED!",
	"Shit, he's going to kill me!",
	"THINK OF MY WIFE!",
	"This world is too cruel, I'm outta here!",
	"GET ME OUT OF HERE!",
	"AAAAAAA!",
	"Oh nooo!",
	"RUN FOR YOUR LIVES!",
	"SHIIIIIIIIIT"
};

string[] textsWon = 
{
	"Thank god!",
	"You saved me!",
	"Hurray!",
	"Thank you!",
	"Thank you for saving me!",
	"My heroes!",
	"I am alive!"
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
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", name + " the Lawyer");
	this.setInventoryName(name + " the Lawyer");
	this.set_u8("shop icon", 25);
	
	this.set_u32("lastDanger", 0);
	
	// Resource Trader
	if (rand.NextRanged(100) < 50)
	{
		{
			ShopItem@ s = addShopItem(this, "Buy Stone (250)", "$mat_stone$", "mat_stone-250", "Buy 250 stone for 135 coins.");
			AddRequirement(s.requirements, "coin", "", "Coins", 135);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Buy Wood (250)", "$mat_wood$", "mat_wood-250", "Buy 250 wood for 100 coins.");
			AddRequirement(s.requirements, "coin", "", "Coins", 100);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Sell Stone (250)", "$COIN$", "coin-90", "Sell 250 stone for 90 coins.");
			AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Sell Wood (250)", "$COIN$", "coin-65", "Sell 250 wood for 65 coins.");
			AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
			s.spawnNothing = true;
		}
	}
	
	// Rancher
	if (rand.NextRanged(100) < 50)
	{
		{
			ShopItem@ s = addShopItem(this, "Piglet", "$piglet$", "piglet", "A baby pig! Everyone's favourite pet, please be nice to it!");
			AddRequirement(s.requirements, "coin", "", "Coins", 400);
			s.spawnNothing = true;
		}
		{
				ShopItem@ s = addShopItem(this, "Chicken", "$chicken$", "chicken", "An chicken, wait for it to lay an egg!");
			AddRequirement(s.requirements, "coin", "", "Coins", 250);
			s.spawnNothing = true;
		}
		{
				ShopItem@ s = addShopItem(this, "Fishy", "$fishy$", "fishy", "A baby fishy, a good pet!");
			AddRequirement(s.requirements, "coin", "", "Coins", 300);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Sell Piglet (1)", "$COIN$", "coin-300", "Sell 1 Piglet for 300 coins.");
			AddRequirement(s.requirements, "blob", "piglet", "Chicken", 1);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Sell Chicken (1)", "$COIN$", "coin-200", "Sell 1 Chicken for 200 coins.");
			AddRequirement(s.requirements, "blob", "chicken", "Chicken", 1);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Sell Fishy (1)", "$COIN$", "coin-250", "Sell 1 Fishy for 250 coins.");
			AddRequirement(s.requirements, "blob", "fishy", "Fishy", 1);
			s.spawnNothing = true;
		}
	}
		
	// Cook
	if (rand.NextRanged(100) < 50)
	{
		{
			ShopItem@ s = addShopItem(this, "Cinnamon Bun", "$cake$", "cake", "Pastry made with love by my wife!");
			AddRequirement(s.requirements, "coin", "", "Coins", 50);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Top Burger", "$food$", "food", "A hearty burger made with love by me!");
			AddRequirement(s.requirements, "coin", "", "Coins", 75);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Bear's Beer", "$beer$", "beer", "A spare real beer for real men I got from a nearby tavern. Good for thirst!");
			AddRequirement(s.requirements, "coin", "", "Coins", 45);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Scrub's Chow", "$foodcan$", "foodcan", "A delicious meatloaf in a can with a special ingredient!");
			AddRequirement(s.requirements, "coin", "", "Coins", 150);
			s.spawnNothing = true;
		}
		// reselling foodcans at merchant not sure if intentional
		{
			ShopItem@ s = addShopItem(this, "Sell Scrub's Chow (1)", "$COIN$", "coin-150", "Sell 1 Scrub's Chow 150 coins.");
			AddRequirement(s.requirements, "blob", "foodcan", "Scrub's Chow", 1);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Sell Scrub's Chow XL (1)", "$COIN$", "coin-800", "Sell 1 Scrub's Chow XL 800 coins.");
			AddRequirement(s.requirements, "blob", "bigfoodcan", "Scrub's Chow XL", 1);
			s.spawnNothing = true;
		}
	}
	
	// Arms dealer
	if (rand.NextRanged(100) < 30)
	{
		{
			ShopItem@ s = addShopItem(this, "Boomstick", "$icon_boomstick$", "boomstick", " You see this? A boomstick! The twelve-gauge double-barreled Bobington.");
			AddRequirement(s.requirements, "coin", "", "Coins", 500);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Shotgun Shells (4)", "$icon_shotgunammo$", "mat_shotgunammo-4", "Boomstick's food.");
			AddRequirement(s.requirements, "coin", "", "Coins", 100);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Fragmentation Grenade (1)", "$icon_fraggrenade$", "mat_fraggrenade-1", "A small hand grenade, try not to hurt yourself with it.");
			AddRequirement(s.requirements, "coin", "", "Coins", 150);
			s.spawnNothing = true;
		}
	}
	
	// Clueless idiot
	if (rand.NextRanged(100) < 2)
	{
		{
			ShopItem@ s = addShopItem(this, "Snake Statue", "$zatniktel$", "zatniktel", "A snake statue I found in a badger den!");
			AddRequirement(s.requirements, "coin", "", "Coins", 900);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Rake", "$icon_oof$", "oof", "A very fancy glowing rake I found in my grandpa's shed! Also, I'm hungry.");
			AddRequirement(s.requirements, "coin", "", "Coins", 30000);
			AddRequirement(s.requirements, "blob", "food", "Burger", 1);
			s.spawnNothing = true;
		}
		// who made this require burgers lol
		{
			ShopItem@ s = addShopItem(this, "Glittery Dust", "$mat_matter$", "mat_matter-20", "Some weird glittery dust.");
			AddRequirement(s.requirements, "coin", "", "Coins", 10);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Pipe", "$infernocannon$", "infernocannon", "A pipe, I guess one could club someone with it?");
			AddRequirement(s.requirements, "coin", "", "Coins", 500);
			s.spawnNothing = true;
		}
	}
	
	//EnsureWantedList();
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
	
		if (isServer() && getGameTime() % 150 == 0)
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
				
				text = textsDanger[XORRandom(textsDanger.size())];
				this.getSprite().PlaySound(soundsDanger[XORRandom(soundsDanger.size())]);
			}
			else
			{
				if (getGameTime() - this.get_u32("lastDanger") < 30 * 60)
				{
					text = textsWon[XORRandom(textsWon.size())];
				}
				else
				{
					text = textsIdle[XORRandom(textsIdle.size())];
					this.getSprite().PlaySound(soundsTalk[XORRandom(soundsTalk.size())]);
				}
			}

			if (isServer())
			{
				CBitStream stream;
				stream.write_string(text);
				this.SendCommand(this.getCommandID("traderChat"), stream);
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
		this.getSprite().PlaySound("ChaChing.ogg");
		
		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item)) return;
		
		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);
		
		if (callerBlob is null) return;
		
		if (isServer())
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
				
				if (blob is null && callerBlob is null) return;
			   
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
	if (isServer())
	{
		server_DropCoins(this.getPosition(), XORRandom(400));
	}
}

void onGib(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	if(!isClient()){return;}
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
	return true;
}

// bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
// {
	// // dont collide with people
	// return true;
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
		if (!this.isAnimation("dead")) this.PlaySound("trader_death.ogg");

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
