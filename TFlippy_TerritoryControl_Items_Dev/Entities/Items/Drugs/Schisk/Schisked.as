#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "MakeDustParticle.as";

const f32 max_time = 3.00f;

string[] spooky_sounds = 
{
	"badger_pissed",
	"shell_whistle",
	"lightningboltstrike",
	"siren_loud",
	"sparkle",
	"ancientship_intro",
	"gas_leak",
	"wilhelm",
	"wilhelmshort",
	"mousetrap_snap",
	"vo_kill",
	"vo_destroy",
	"vo_fire",
	"lws_launcher",
	"sat_fire",
	"ss_order",
	"ss_hello",
	"ss_shipment",
	"bigbomb_explosion",
	"oof"
};

void onInit(CBlob@ this)
{
	this.Tag("schisked");
	this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
	if (this.isMyPlayer() && getGameTime() > this.get_u32("next_schisk"))
	{
		this.Untag("burning");
	
		if (XORRandom(10) == 0)
		{
			CBlob@ localBlob = getLocalPlayerBlob();
			if (localBlob !is null)
			{
				switch (XORRandom(5))
				{
					// Spooky sound
					case 0:
					case 1:
					case 2:
					{
						Sound::Play(spooky_sounds[XORRandom(spooky_sounds.length)], localBlob.getPosition() + getRandomVelocity(0, 200 + XORRandom(500), 360), 2.00f, 1.00f);
					}
					break;
					
					// Nuke Flash
					case 3:
					{
						Vec2f pos = localBlob.getPosition() + getRandomVelocity(0, 50 + XORRandom(100), 360);
					
						Sound::Play("Nuke_Kaboom_Big", pos, 2.00f, 0.80f);
						SetScreenFlash(255, 255, 255, 255, 5);
						ShakeScreen(512, 64, pos);
					}
					break;
					
					case 4:
					{
						this.Tag("burning");
					}
					break;
				}				
			}
			
			this.set_u32("next_schisk", getGameTime() + (30 * 10) + XORRandom(30 * 15));
		}
	}
}
