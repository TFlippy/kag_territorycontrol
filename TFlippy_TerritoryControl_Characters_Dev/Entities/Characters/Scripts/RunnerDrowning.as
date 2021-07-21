//drowning for all characters

#include "/Entities/Common/Attacks/Hitters.as"

//config vars

const int FREQ = 6; //must be >2 or breathing at top of water breaks
const u8 default_aircount = 180; //6s, remember to update runnerhoverhud.as

void onInit(CBlob@ this)
{
	this.set_u8("air_count", default_aircount);
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().tickFrequency = FREQ; // opt
}

void onTick(CBlob@ this)
{
	// TEMP: don't drown migrants, its annoying
	if (this.getShape().isStatic())
		return;
		
	Vec2f pos = this.getPosition();
	
	bool gassed = false;
	f32 toxicity = 0.00f;
	
	CMap@ map = this.getMap();
	
	if (map is null) return;
	
	if (!this.hasTag("scubagear") && !this.hasTag("no drown"))
	{
		CBlob@[] blobs;
		map.getBlobsInRadius(this.getPosition(), 12, @blobs);
	
		for (int i = 0; i < blobs.length; i++)
		{
			if (blobs[i].hasTag("gas"))
			{
				gassed = true;
				toxicity += blobs[i].get_f32("toxicity");
			}
		}
	}
			
	u8 aircount = this.get_u8("air_count");

	this.getCurrentScript().tickFrequency = FREQ;

	const bool inWater = this.isInWater() && this.getMap().isInWater(pos + Vec2f(0.0f, -this.getRadius() * 0.66f)) && !this.hasTag("scubagear") && !this.hasTag("no drown");
	bool canBreathe = !inWater && !gassed;
	
	const bool server = isServer();				
	const bool client = isClient();				

	if (!canBreathe)
	{
		if (aircount >= FREQ)
		{
			aircount -= FREQ;
		}

		//drown damage
		if (aircount < FREQ)
		{	
			if (server)
			{
				// Toxicity is the sum of all nearby gases' "toxicity" variable
				this.server_Hit(this, pos, Vec2f(0, 0), gassed ? toxicity : 0.5f, Hitters::drown, true);
				// print("" + toxicity);
			}
			
			if (client)
			{
				if (inWater)
				{
					Sound::Play("Gurgle", pos, 2.0f);
				}
				else if (gassed && getGameTime() >= this.get_u32("next_cough")) 
				{
					Sound::Play("cough" + XORRandom(5), pos, 2.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
					this.set_u32("next_cough", getGameTime() + 70);
				}
			}
			
			aircount += 30;
		}
	}
	else
	{
		if (aircount < default_aircount/2)
		{
			Sound::Play("Sounds/gasp.ogg", pos, 3.0f);
			aircount = default_aircount/2;
		}
		else if (aircount < default_aircount)
		{
			if (this.isOnGround() || this.isOnLadder())
			{
				aircount += FREQ * 2;
			}
			else
			{
				aircount += FREQ;
			}
		}
		else
		{
			aircount = default_aircount;
		}
	}

	this.set_u8("air_count", aircount);
	this.Sync("air_count", true);
}

// SPRITE renders in party indicator
