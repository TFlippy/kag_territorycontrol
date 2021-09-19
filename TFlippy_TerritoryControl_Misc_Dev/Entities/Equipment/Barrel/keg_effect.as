#include "Explosion.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

void onInit(CBlob@ this)
{
	this.set_f32("keg_explode", 0.0f);
	if (this.get_string("reload_script") != "keg")
		UpdateScript(this);
}

void UpdateScript(CBlob@ this)
{
	CSpriteLayer@ barrel = this.getSprite().addSpriteLayer("keg", "KegTorso.png", 16, 16);

	if (barrel !is null)
	{
		barrel.SetVisible(true);
		barrel.SetRelativeZ(3);
		barrel.SetOffset(Vec2f(0, 2));
		
		if (this.getSprite().isFacingLeft())
			barrel.SetFacingLeft(true);
	}
}

void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "keg")
	{
		UpdateScript(this);
		this.set_string("reload_script", "");
	}

	if (this.get_f32("keg_health") >= 10.0f)
	{
        this.getSprite().PlaySound("woodheavyhit1");
        this.set_string("equipment_head", "");
        this.set_f32("keg_health", 9.9f);
        if (this.getSprite().getSpriteLayer("keg") !is null) this.getSprite().RemoveSpriteLayer("keg");
        this.RemoveScript("keg_effect.as");
    }
    
    if (getGameTime() >= this.get_f32("keg_explode") && this.get_f32("keg_explode") != 0.0f)
    	this.server_Die();
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
	if (isServer() && (this.get_f32("keg_explode") == 0.0f))
	{
		CBlob@ item = server_CreateBlob("keg", this.getTeamNum(), this.getPosition());
		if (item !is null) item.set_f32("health", this.get_f32("keg_health"));
	}
	this.RemoveScript("keg_effect.as");
}

void DoExplosion(CBlob@ this)
{
	CRules@ rules = getRules();
	if (!shouldExplode(this, rules))
	{
		addToNextTick(this, rules, DoExplosion);
		return;
	}
	
	if (this.get_f32("keg_explode") == 0.0f) return;
	f32 random = XORRandom(16);
	f32 modifier = 2 + Maths::Log(this.getQuantity());
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

		this.getSprite().Gib();
		this.getSprite().PlaySound("Sulphur_Explode.ogg", 1.00f, 1.00f);
	}
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
}