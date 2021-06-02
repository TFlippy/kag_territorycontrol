//////////////////////////////////////////////////////
//
//  BulletParticles.as - Vamist
//
//  Particles that come out of your gun when you shoot
//  

class PrettyParticle
{
	CParticle@ Particle = ParticleRaw();
	u16 ttl;
	SColor col;

	PrettyParticle(CParticle@ p, const u8 pattern)
	{
		if (p is null) { return; }

		switch(pattern)
		{
			case 0://muzzle flash
			{
				p.bounce = 0;
				p.fastcollision = true;
				p.collides = false;
				p.timeout = 10;
				p.resting = true;   
				p.gravity = Vec2f(0,0);     

				p.Z = -20;
				p.colour = SColor(255,254,202,56);
				p.forcecolor = SColor(255,254,202,56);
				p.fadeout = true;

				//p.gravity = Vec2f(0,0);
				ttl = 20;
				col = p.colour;
				@Particle = p;
				FakeTick();
			}
			break;

			case 1: // never got round to adding more apparently
			{

			}
			break;
		}
	}

	void FakeTick()
	{
		if (ttl == 1)
		{
			col.setAlpha(0);
			Particle.forcecolor = col;
			ttl--;
			return;
		}

		ttl--;

		col.setAlpha(col.getAlpha() - 24);
		col.setRed(col.getRed() - 20);
		col.setGreen(col.getGreen() - 15);
		col.setBlue(col.getBlue() - 4);

		Particle.forcecolor = col;
		//Particle.gravity = Vec2f(0,0.001);
	}
}
