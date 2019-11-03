// Fireplace

#include "FireParticle.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	// this.getShape().getConsts().mapCollisions = false;
	this.getShape().getConsts().rotates = true;
	this.getCurrentScript().tickFrequency = 9;
	this.getSprite().SetEmitSound("CampfireSound.ogg");
	this.getSprite().SetAnimation("fire");
	this.getSprite().SetFacingLeft(XORRandom(2) == 0);

	this.SetLight(true);
	this.SetLightRadius(164.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));

	this.getSprite().SetZ(-20.0f);
}

void onTick(CBlob@ this)
{
	if(!isClient()){return;}

	if (this.getSprite().isAnimation("fire"))
	{
		makeFireParticle(this.getPosition() + getRandomVelocity(90.0f, 3.0f, 90.0f));
	}
}

void onInit(CSprite@ this)
{
	this.SetZ(-50); //background

	//init flame layer
	CSpriteLayer@ fire = this.addSpriteLayer("fire_animation_large", "Entities/Effects/Sprites/LargeFire.png", 16, 16, -1, -1);

	if (fire !is null)
	{
		fire.SetRelativeZ(1);
		fire.SetOffset(Vec2f(-2.0f, -4.0f));
		{
			Animation@ anim = fire.addAnimation("fire", 6, true);
			anim.AddFrame(1);
			anim.AddFrame(2);
			anim.AddFrame(3);
		}
		fire.SetVisible(true);
	}
}
