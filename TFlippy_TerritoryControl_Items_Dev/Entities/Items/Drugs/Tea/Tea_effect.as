//Script by Gingerbeard
#include "HittersTC.as";

const string[] scriptnames = 
{
	"Drunk_Effect.as",
	"Fiksed.as",
	"Dominoed.as",
	"Babbyed.as",
	"Bobonged.as",
	"Bobomaxed.as",
	"Boofed.as",
	"Crak_Effect.as",
	"Foofed.as",
	"Pooted.as",
	"Fusk_Effect.as",
	"Gooby_Effect.as",
	"Paxilon_Effect.as",
	"Propeskoed.as",
	"Radpilled.as",
	"Rippioed.as",
	"Schisked.as",
	"Stimed.as",
	"Mustardeffect.as",
	"Pigger_Pregnant.as"
};

void onTick(CBlob@ this)
{
	for (int i = 0; i < scriptnames.length; i++)
	{
		string scriptname = scriptnames[i];
		if (this.hasScript(scriptname))
		{
			if (scriptname == "Paxilon_Effect.as")
			{
				// Remove sleeping effects
				CSprite@ sprite = this.getSprite();
				sprite.SetEmitSoundPaused(true);

				CSpriteLayer@ layer = sprite.getSpriteLayer("paxilon_zzz");
				if (layer !is null) layer.SetVisible(false);
			}
			else if (scriptname == "Pigger_Pregnant.as")
			{
				// Stop pigger sequence
				this.Untag("pigger_pregnant");
			}
			else if (scriptname == "Crak_Effect.as" || scriptname == "Rippioed.as" || 
			         scriptname == "Pooted.as" || scriptname == "Gooby_Effect.as")
			{
				this.getSprite().SetEmitSoundPaused(true);

				// Reset player angle
				this.setAngleRadians(0.0f);
			}
			else if (scriptname == "Babbyed.as")
			{
				this.Untag("no_suicide");
				this.set_f32("babbyed", 0);
			}
			else if (scriptname == "Bobomaxed.as")
			{
				if (isClient()) this.getSprite().PlaySound("methane_explode");
				if (isServer()) this.server_Hit(this, this.getPosition(), Vec2f(0, 0), 50.0, HittersTC::poison, true);
			}
			else if (scriptname == "Fusk_Effect.as")
			{
				this.Tag("vaccinated");
			}

			this.RemoveScript(scriptname);
		}
	}

	if (isClient())
	{
		if (this.isMyPlayer())
		{
			if (this.hasTag("drunk_shader")) getDriver().SetShader("drunk", false);
			SetScreenFlash(40, 40, 100, 0);
			getMap().CreateSkyGradient("skygradient.png");
		}
	}

	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
