#include "RunnerCommon.as"
#include "Help.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "Requirements.as";
#include "MakeDustParticle.as";

const string[] titles = 
{ 
	"Radical",
	"Anarchist",
	"Extremist",
	"Total",
	"Rebel",
	"Rambler",
	"Rover",
	"Pummeler"
};

const string[] firstnames = 
{ 
	"Kev",
	"Eugh",
	"Lar",
	"Mac",
	"Jon",
	"Stev",
	"Syd",
	"Jet",
	"Nel",
	"Bob",
	"Har",
	"Bar",
	"Jer",
	"Gar"
};

const string[] surnames = 
{ 
	"Gorilla",
	"Killslayer",
	"Rocket",
	"Deathkill",
	"Criminal",
	"Murderer",
	"Snotter",
	"Torpedo",
	"Defiler",
	"Killer",
	"Eliminator",
	"Boi"
};

const string[] textsIdle = 
{ 
	"oof",
	"rip",
	"hmm",
	"ugh",
	"foof",
	"fug",
	"fusk",
	"fusg",
	"fff"
};

const string[] textsDanger = 
{ 
	"hi"
};

const string[] textsWon = 
{
	"bye"
};


const string[] sounds_idle = 
{ 
	"Hoob_Wheeze_0.ogg",
	"Hoob_Wheeze_1.ogg",
	"Hoob_Cough_0.ogg",
	"Hoob_Cough_1.ogg"
};

const string[] sounds_pain = 
{ 
	"Hoob_Pain_0.ogg",
	"Hoob_Pain_1.ogg",
	"Hoob_Cough_1.ogg"
};

const string[] sounds_laugh = 
{ 
	"Hoob_Laugh_0.ogg",
	"Hoob_Laugh_1.ogg",
	"Hoob_Laugh_2.ogg",
	"Hoob_Laugh_3.ogg"
};

void onInit(CBlob@ this)
{
	Random@ rand = Random(this.getNetworkID());
	string name = titles[rand.NextRanged(titles.length)] + " " + firstnames[rand.NextRanged(firstnames.length)] + " the " + surnames[rand.NextRanged(surnames.length)];
	this.set_string("trader name", name);
	this.setInventoryName(name);

	this.getShape().SetRotationsAllowed(false);
	this.set_f32("gib health", -20.0f);
	this.set_f32("crak_effect", 2.00f);
	this.set_f32("drunk_effect", 8.00f);
	this.Tag("flesh");
	this.Tag("migrant");
	this.Tag("human");
	this.getBrain().server_SetActive(true);

	this.set_u32("nextTalk", getGameTime() + XORRandom(60));

	this.set_u32("nextAttack", 0);
	this.set_u32("nextJumpStomp", 0);

	this.set_f32("minDistance", 8);
	this.set_f32("chaseDistance", 300);
	this.set_f32("maxDistance", 600);

	this.set_f32("inaccuracy", 0.01f);
	this.set_u8("reactionTime", 20);
	this.set_u8("attackDelay", 0);

	this.set_f32("voice pitch", 0.60f);

	this.addCommandID("traderChat");
	this.set_u32("lastDanger", 0);

	if (getNet().isServer())
	{
		this.server_setTeamNum(-1);
	}
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null) player.SetScoreboardVars("ScoreboardIcons.png", 20, Vec2f(16, 16));
}

void onTick(CBlob@ this)
{
	if (!this.hasTag("dead"))
	{
		bool client = isClient();
		bool server = isServer();

		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 2.00f;
			moveVars.jumpFactor *= 6.00f;
		}

		uint time = getGameTime();
		if (this.getPlayer() is null && time >= this.get_u32("nextTalk"))
		{
			this.set_u32("nextTalk", time + (30 * 5) + XORRandom(30 * 10));

			u32 lastDanger = this.get_u32("lastDanger");
			bool danger = time < (lastDanger + (30 * 5));

			string text = "";
			if (danger)
			{
				text = textsDanger[XORRandom(textsDanger.size())];
				this.getSprite().PlaySound(sounds_idle[XORRandom(sounds_idle.size())], 0.75f, 0.75f);
			}
			else
			{
				if (time - this.get_u32("lastDanger") < 30 * 60)
				{
					text = textsWon[XORRandom(textsWon.size())];
					this.getSprite().PlaySound(sounds_laugh[XORRandom(sounds_laugh.size())], 0.75f, 1.00f);
				}
				else
				{
					text = textsIdle[XORRandom(textsIdle.size())];
					this.getSprite().PlaySound(sounds_idle[XORRandom(sounds_idle.size())], 0.75f, 1.00f);
				}
			}

			if (getNet().isServer())
			{
				CBitStream stream;
				stream.write_string(text);
				this.SendCommand(this.getCommandID("traderChat"), stream);
			}
		}

		if (this.isOnGround())
		{
			if ((time % 10 == 0) && (this.isKeyPressed(key_left) || this.isKeyPressed(key_right)))
			{
				Stomp(this, 4, 1.00f);
			}
			else if (!this.wasOnGround() && time > this.get_u32("nextJumpStomp"))
			{
				Stomp(this, 20, 4.00f);
				this.set_u32("nextJumpStomp", getGameTime() + 15);
			}
		}

		if (getGameTime() > this.get_u32("next attack"))
		{
			if (this.isKeyPressed(key_action1))
			{
				Vec2f dir = this.getAimPos() - this.getPosition();
				dir.Normalize();

				AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("CORPSE");
				if (point !is null)
				{
					CBlob@ carried = point.getOccupied();
					if (carried is null)
					{
						CBlob@ blob = getMap().getBlobAtPosition(this.getAimPos());
						if (blob !is null && blob !is this && !blob.hasTag("dead") && blob.hasTag("human") && this.getDistanceTo(blob) < 32.00f && !getMap().rayCastSolid(this.getPosition(), blob.getPosition())) 
						{
							if (client)
							{
								this.getSprite().PlaySound("TraderScream.ogg", 0.8f, this.getSexNum() == 0 ? 1.0f : 2.0f);
							}

							if (server)
							{
								this.server_AttachTo(blob, point);
							}

							this.set_u32("next attack", getGameTime() + 20);
						}
					}
					else if (carried !is null)
					{
						if (carried.getConfig() != "hoobballer")
						{
							if (client)
							{
								this.getSprite().PlaySound("Pus_Attack_2", 1.00f, 0.80f);
								carried.getSprite().Gib();
							}

							if (server)
							{
								CBlob@ baller = server_CreateBlob("hoobballer", carried.getTeamNum(), carried.getPosition());
								this.server_AttachTo(baller, point);
								carried.server_Die();
							}

							this.set_u32("next attack", getGameTime() + 20);
						}
						else
						{
							if (client)
							{
								this.getSprite().PlaySound("nightstick_hit2", 1.00f, 0.90f);
							}

							if (server)
							{
								this.server_DetachAll();
							}

							Vec2f dir = this.getAimPos() - this.getPosition();
							dir.Normalize();

							carried.setVelocity(dir * 10.00f);

							this.set_u32("next attack", getGameTime() + 20);
						}
					}
				}
			}

			if (this.isKeyPressed(key_action2))
			{
				Vec2f dir = this.getAimPos() - this.getPosition();
				f32 length = dir.getLength();
				dir.Normalize();

				Vec2f hitPos = this.getPosition() + (dir * Maths::Min(16.00f, length));
				getMap().rayCastSolid(this.getPosition(), hitPos, hitPos);

				MegaHit(this, hitPos, dir, 4, Hitters::crush);
				this.set_u32("next attack", getGameTime() + 10);
			}
		}
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (blob.hasTag("dead"))
	{
		if (!this.isAnimation("dead")) this.PlaySound("Hoob_Death.ogg", 1.50f, 1.00f);
		this.SetAnimation("dead");

		return;
	}

	Vec2f pos = blob.getPosition();
	Vec2f aimpos = blob.getAimPos();

	if (blob.isOnGround())
	{
		if ((blob.isKeyPressed(key_left) || blob.isKeyPressed(key_right)) || (blob.isOnLadder() && (blob.isKeyPressed(key_up) || blob.isKeyPressed(key_down))))
		{
			this.SetAnimation("walk");
		}
		else
		{
			this.SetAnimation("default");
		}
	}
	else
	{
		this.SetAnimation("inair");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("traderChat"))
	{
		this.Chat(params.read_string());
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case HittersTC::radiation:
			return 0;
			break;
	}

	if (!this.hasTag("dead"))
	{
		if (isClient())
		{
			if (getGameTime() > this.get_u32("next sound"))
			{
				this.getSprite().PlaySound(sounds_pain[XORRandom(sounds_pain.size())], 0.75f, 1.00f);
				this.set_u32("next sound", getGameTime() + 150);
			}
		}

		if (isServer())
		{
			CBrain@ brain = this.getBrain();
			if (brain !is null && hitterBlob !is null)
			{
				if (hitterBlob.getTeamNum() != this.getTeamNum()) brain.SetTarget(hitterBlob);
			}
		}

		this.set_u32("lastDanger", getGameTime());
	}

	return damage;
}

void onDie(CBlob@ this)
{
	if (getNet().isServer())
	{
		server_DropCoins(this.getPosition(), XORRandom(1500));
	}
}

void Stomp(CBlob@ this, int count, f32 magnitude)
{
	bool client = isClient();
	bool server = isServer();
	CMap@ map = getMap();

	Vec2f worldPoint = this.getPosition() + Vec2f(0, 24);

	for (int i = 0; i < count; i++)
	{
		Vec2f pos = worldPoint + Vec2f(24 - XORRandom(48), -XORRandom(16));

		if (client && XORRandom(100) < 50)
		{
			MakeDustParticle(pos, "dust2.png");
		}

		if (server)
		{
			map.server_DestroyTile(pos, 1);
		}
	}

	if (client)
	{
		this.getSprite().PlaySound("FallBig" + (XORRandom(5) + 1), 1.00f, 1.00f);
		ShakeScreen(100.0f, 30.00f, this.getPosition());
	}

	if (server)
	{
		CBlob@[] blobsInRadius;
		if (this.getMap().getBlobsInRadius(worldPoint, 24, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ hitBlob = blobsInRadius[i];
				AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("CORPSE");
				if (point !is null)
				{
					if (hitBlob !is null && hitBlob !is this && hitBlob !is point.getOccupied())
					{
						this.server_Hit(hitBlob, worldPoint, this.getVelocity(), 5.00f, Hitters::crush, true);
					}
				}
			}
		}
	}
}

void MegaHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{

	bool client = isClient();
	bool server = isServer();

	Vec2f dir = worldPoint - this.getPosition();
	f32 len = dir.getLength();
	dir.Normalize();
	f32 angle = dir.Angle();

	int count = 20;

	for (int i = 0; i < count; i++)
	{
		Vec2f offset = getRandomVelocity(0, XORRandom(len * 2), 90);
		// offset.y *= 3.00f;
		offset = offset.RotateBy(-angle);

		Vec2f pos = worldPoint - offset - (dir * 8.00f);

		if (client && XORRandom(100) < 10)
		{
			MakeDustParticle(pos, "dust2.png");
		}

		if (server)
		{
			 getMap().server_DestroyTile(pos, damage);
			// this.server_HitMap(pos, dir, damage, Hitters::crush);
		}
	}

	if (client)
	{
		f32 magnitude = damage;
		this.getSprite().PlaySound("FallBig" + (XORRandom(5) + 1), 1.00f, 1.00f);
		ShakeScreen(magnitude * 10.0f, magnitude * 8.0f, this.getPosition());
	}
}
