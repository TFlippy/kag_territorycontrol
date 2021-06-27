#include "PixelOffsets.as"
#include "RunnerTextures.as"
#include "Explosion.as";
#include "RunnerCommon.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

void onInit(CBlob@ this)
{
	this.addCommandID("vest_explode");
	if (this.get_string("reload_script") != "suicidevest")
		UpdateScript(this);
}

void UpdateScript(CBlob@ this)
{
	CSpriteLayer@ svest = this.getSprite().addSpriteLayer("suicidevest", "SuicideVest.png", 16, 16);

	if (svest !is null)
	{
		svest.SetVisible(true);
		svest.SetRelativeZ(2);
		svest.SetOffset(Vec2f(0, 2));
		
		if (this.getSprite().isFacingLeft())
			svest.SetFacingLeft(true);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	CBlob@ carried = caller.getCarriedBlob();
	
	if (caller is this && !this.exists("vest_explode"))
	{
		caller.CreateGenericButton(11, Vec2f(0.0f, 0.0f), this, this.getCommandID("vest_explode"), "Blow yourself up!", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("vest_explode"))
	{
		this.getSprite().PlaySound("SuicideVest_Detonate.ogg", 1.00f, 1.00f);
		this.getSprite().PlaySound("MigrantScream1.ogg", 1.00f, this.getSexNum() == 0 ? 1.0f : 2.0f);

		this.set_u32("vest_explode", getGameTime() + (30.00f * 1.50f));
	}
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "suicidevest")
	{
		UpdateScript(this);
		this.set_string("reload_script", "");
	}
	
	CSpriteLayer@ svest = this.getSprite().getSpriteLayer("suicidevest");
	
	if (svest !is null)
	{
		Vec2f headoffset(this.getSprite().getFrameWidth() / 2, -this.getSprite().getFrameHeight() / 2);
		Vec2f head_offset = getHeadOffset(this, -1, 0);
		
		headoffset += this.getSprite().getOffset();
		headoffset += Vec2f(-head_offset.x, head_offset.y);
		headoffset += Vec2f(0, 7);
		svest.SetOffset(headoffset);
	}
		
	// if (this.getHealth() <= 0.0f || (this.exists("vest_explode") && getGameTime() >= this.get_u32("vest_explode"))) DoExplosion(this);
	
	if (this.exists("vest_explode")) 
	{	
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 1.50f;
			moveVars.jumpFactor *= 1.20f;
		}
	
		if (isServer() && getGameTime() >= this.get_u32("vest_explode")) this.server_Die();
	}
}

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}
	
	if (!this.exists("vest_explode")) return;

	f32 random = XORRandom(16);
	f32 modifier = 1 + Maths::Log(this.getQuantity());
	f32 angle = 0.0f;

	this.set_f32("map_damage_radius", (40.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.50f);
	
	Explode(this, 40.0f + random, 25.0f);
	
	for (int i = 0; i < 10 * modifier; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 120);
		dir.x *= 2;
		dir.Normalize();
		
		LinearExplosion(this, dir, 16.0f + XORRandom(16) + (modifier * 8), 16 + XORRandom(24), 3, 2.00f, Hitters::explosion);
	}

	if (isClient())
	{
		Vec2f pos = this.getPosition();
		CMap@ map = getMap();
		
		for (int i = 0; i < 35; i++)
		{
			MakeParticle(this, Vec2f( XORRandom(64) - 32, XORRandom(80) - 60), getRandomVelocity(-angle, XORRandom(220) * 0.01f, 90), particles[XORRandom(particles.length)]);
		}
		
		// this.Tag("exploded");
		this.getSprite().Gib();
		this.getSprite().PlaySound("Sulphur_Explode.ogg", 1.00f, 1.00f);
	}
	
	
	// if (isServer()) this.server_Die();
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
}