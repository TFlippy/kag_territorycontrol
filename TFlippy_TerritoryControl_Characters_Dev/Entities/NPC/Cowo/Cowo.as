
//script for a bison

#include "AnimalConsts.as";
#include "HittersTC.as";


const u8 DEFAULT_PERSONALITY = TAMABLE_BIT | DONT_GO_DOWN_BIT;
const s16 MAD_TIME = 600;

//sprite

const string[] screams = 
{
	"WraithDie.ogg",
	"ScaredChicken03",
	"GregCry",
	"TraderScream",
	"man_scream",
	"BisonBoo",
	"BisonMad"
};

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
		this.PlaySound("CowoDie.ogg");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

//blob

void onInit(CBlob@ this)
{
	//for EatOthers
	string[] tags = {"player", "flesh"};
	this.set("tags to eat", tags);

	this.set_f32("bite damage", 0.50f);

	//brain
	this.set_u8(personality_property, AGGRO_BIT);
	this.set_u8("random move freq", 20);
	this.set_f32(target_searchrad_property, 320.0f);
	this.set_f32(terr_rad_property, 85.0f);
	this.set_u8(target_lose_random, 34);

	this.getBrain().server_SetActive(true);

	//for steaks
	this.set_u8("number of steaks", 8);

	//for shape
	this.getShape().SetRotationsAllowed(false);

	//for flesh hit
	this.set_f32("gib health", -0.0f);

	this.Tag("flesh");

	this.set_s16("mad timer", 0);

	this.getShape().SetOffset(Vec2f(0, 6));

	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 320.0f;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	// AttachmentPoint@[] aps;
	// if (this.getAttachmentPoints(@aps))
	// {
		// for (uint i = 0; i < aps.length; i++)
		// {
			// AttachmentPoint@ ap = aps[i];
			// ap.offsetZ = 10.0f;
		// }
	// }
	
	if (!this.exists("voice_pitch")) this.set_f32("voice pitch", 0.50f);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false; //maybe make a knocked out state? for loading to cata?
}

void onTick(CBlob@ this)
{
	if(!this.hasTag("dead")){
		if(isClient()){
			if(!this.getSprite().getSpriteLayer("isOnScreen").isOnScreen()){
				return;
			}
		}
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

		// relax the madness

		if (getGameTime() % 50 == 0)
		{
			s16 mad = this.get_s16("mad timer");
			if (mad > 0)
			{
				mad -= 50;
				if (mad < 0)
				{
					this.set_u8(personality_property, DEFAULT_PERSONALITY);
					this.getSprite().PlaySound(screams[XORRandom(screams.length)], 1, 0.5f);
				}
				this.set_s16("mad timer", mad);
			}

			if (XORRandom(mad > 0 ? 2 : 4) == 0)
				this.getSprite().PlaySound(screams[XORRandom(screams.length)], 1, 0.5f);
		}

		// footsteps

		if (this.isOnGround() && (this.isKeyPressed(key_left) || this.isKeyPressed(key_right)))
		{
			if ((this.getNetworkID() + getGameTime()) % 9 == 0)
			{
				f32 volume = Maths::Min(0.1f + Maths::Abs(this.getVelocity().x) * 0.1f, 1.0f);
				TileType tile = this.getMap().getTile(this.getPosition() + Vec2f(0.0f, this.getRadius() + 4.0f)).type;

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
	
	if(this.getHealth() < 4.0){
		this.Tag("dead");
	}
}

void MadAt(CBlob@ this, CBlob@ hitterBlob)
{
	const u16 damageOwnerId = (hitterBlob.getDamageOwnerPlayer() !is null && hitterBlob.getDamageOwnerPlayer().getBlob() !is null) ?
	                          hitterBlob.getDamageOwnerPlayer().getBlob().getNetworkID() : 0;

	const u16 friendId = this.get_netid(friend_property);
	if (friendId == hitterBlob.getNetworkID() || friendId == damageOwnerId) // unfriend
		this.set_netid(friend_property, 0);
	else // now I'm mad!
	{
		if (this.get_s16("mad timer") <= MAD_TIME / 8)
			this.getSprite().PlaySound(screams[XORRandom(screams.length)], 0, 0.5f + (XORRandom(100) / 100.0f));
		this.set_s16("mad timer", MAD_TIME);
		this.set_u8(personality_property, DEFAULT_PERSONALITY | AGGRO_BIT);
		this.set_u8(state_property, MODE_TARGET);
		if (hitterBlob.hasTag("player"))
			this.set_netid(target_property, hitterBlob.getNetworkID());
		else if (damageOwnerId > 0)
		{
			this.set_netid(target_property, damageOwnerId);
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(!this.hasTag("dead"))MadAt(this, hitterBlob);
	
	switch (customData)
	{
		case HittersTC::radiation:
			damage *= -0.5f;
			break;
	}
	
	return damage;
}

#include "Hitters.as";

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob.hasTag("dead"))
		return false;
	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob is null)
		return;

	if(this.hasTag("dead"))return;
		
	const u16 friendId = this.get_netid(friend_property);
	CBlob@ friend = getBlobByNetworkID(friendId);
	if ((friend is null || blob.getTeamNum() != friend.getTeamNum()) && blob.getName() != this.getName() && blob.hasTag("flesh"))
	{
		const f32 vellen = this.getShape().vellen;
		if (vellen > 0.1f)
		{
			Vec2f pos = this.getPosition();
			Vec2f vel = this.getVelocity();
			Vec2f other_pos = blob.getPosition();
			Vec2f direction = other_pos - pos;
			direction.Normalize();
			vel.Normalize();
			if (vel * direction > 0.33f)
			{
				f32 power = Maths::Max(0.25f, 1.0f * vellen);
				this.server_Hit(blob, point1, vel, power, Hitters::flying, false);
			}
		}

		MadAt(this, blob);
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (hitBlob !is null && customData == Hitters::flying)
	{
		Vec2f force = velocity * this.getMass() * 0.75f ;
		force.y *= 0.1f;
		hitBlob.AddForce(force);
	}
}