#include "Hitters.as"
#include "HittersTC.as"

//Does the good old "red screen flash" when hit - put just before your script that actually does the hitting

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    if (this.isMyPlayer() && damage > 0)
    {
		// CPlayer@ ply = this.getPlayer();
	
		switch (customData)
		{
			case HittersTC::radiation:
				SetScreenFlash(25, 50, 255, 125);
				break;
		
			case HittersTC::forcefield:
			case HittersTC::electric:
				SetScreenFlash(200, 255, 255, 255);
				break;
		
			case Hitters::fall:
			case HittersTC::staff:
				SetScreenFlash(90, 120, 0, 0);
				Sound::Play("falldamage_hit", this.getPosition(), 1.00f, 1.00f);
				ShakeScreen2(Maths::Min(damage * 10, 50), 15, this.getPosition());
				break;
		
			case HittersTC::poison:
			
				break;
		
			default:
				SetScreenFlash(90, 120, 0, 0);
				ShakeScreen(15, 5, this.getPosition());
				break;
		}
		
		Vec2f dir = hitterBlob.getPosition() - this.getPosition();
		f32 angle = ((dir.x > 0 ? 1 : -1) * (dir.y > 0 ? -1 : 1)) * damage * 25.00f;

		this.set_f32("new camera angle", Maths::Clamp(this.get_f32("new camera angle") + angle, -20, 20));
    }

    return damage;
}

f32 shortAngleDist(f32 a0, f32 a1) 
{
    // const f32 max = 3.14159265359f * 2;
    const f32 max = 360.00f;
    f32 da = (a1 - a0) % max;
    return 2 * da % max - da;
}

f32 angleLerp(f32 a0, f32 a1, f32 t) 
{
    return a0 + shortAngleDist(a0, a1) * t;
}

void onTick(CBlob@ this)
{
	if (this.isMyPlayer())
	{
		CCamera@ cam = getCamera();
	
		f32 oldAngle = this.get_f32("old camera angle");
		f32 newAngle = this.get_f32("new camera angle");

		f32 fAngle = angleLerp(oldAngle, newAngle, 0.10f);
		
		cam.setRotation(fAngle);
		
		this.set_f32("old camera angle", fAngle);
		if (Maths::Abs(fAngle - newAngle) < 15.00f) 
		{
			this.set_f32("new camera angle", 0);
		}
	}
}