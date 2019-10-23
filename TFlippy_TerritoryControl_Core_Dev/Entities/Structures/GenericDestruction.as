#include "MakeDustParticle.as";

void onHealthChange(CBlob@ this, f32 health_old)
{
	CSprite@ sprite = this.getSprite();
	if(sprite is null) return;

	Animation@ animation = sprite.getAnimation("destruction");
	if(animation is null) return;

	
	u8 lastFrame = sprite.animation.frame;
	u8 newFrame = u8((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
	
	sprite.animation.frame = newFrame;
	
	if (isClient())
	{
		if (lastFrame != newFrame && this.hasTag("building"))
		{		
			this.getSprite().PlaySound("/BuildingExplosion", 0.8f, 0.8f);
			
			Vec2f pos = this.getPosition() - Vec2f((this.getWidth() / 2) - 8, (this.getHeight() / 2) - 8);
			
			for (int y = 0; y < this.getHeight(); y += 16)
			{
				for (int x = 0; x < this.getWidth(); x += 16)
				{
					if (XORRandom(100) < 75) 
					{
						// MakeDustParticle(pos + Vec2f(x + (8 - XORRandom(16)), y + (8 - XORRandom(16))), "woodparts.png");
						ParticleAnimated("Smoke.png", pos + Vec2f(x + (8 - XORRandom(16)), y + (8 - XORRandom(16))), Vec2f((100 - XORRandom(200)) / 100.0f, 0.5f), 0.0f, 1.5f, 3, 0.0f, true);
					}
				}
			}
		}
	}
}