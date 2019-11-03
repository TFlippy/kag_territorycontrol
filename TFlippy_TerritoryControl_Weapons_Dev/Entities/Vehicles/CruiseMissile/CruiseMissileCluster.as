
string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

void onInit(CBlob@ this)
{
	this.Tag("map_damage_dirt");
	this.set_f32("max_velocity", 10.00f);
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

void DoExplosion(CBlob@ this)
{
	Vec2f velocity = this.getVelocity();
	f32 angle = velocity.getAngleDegrees();

	if (isServer())
	{	
		for (int i = 0; i < 10 ; i++)
		{
			CBlob@ blob = server_CreateBlob("tankshell", -1, this.getPosition());
			blob.setVelocity((velocity * 1.50f) + getRandomVelocity(angle, XORRandom(10), XORRandom(50)));
		}
	}

	if (isClient())
	{
		for (int i = 0; i < 20; i++)
		{
			MakeParticle(this, Vec2f(XORRandom(64) - 32, XORRandom(80) - 60) * 1.50f, (velocity * 0.30f) + getRandomVelocity(angle, XORRandom(400) * 0.01f, 70), particles[XORRandom(particles.length)]);
		}
	}
	
	this.getSprite().Gib();
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;
	ParticleAnimated(filename, this.getPosition() + pos, vel, float(XORRandom(360)), 1 + XORRandom(200) * 0.01f, 2 + XORRandom(5), XORRandom(100) * -0.00005f, true);
}
