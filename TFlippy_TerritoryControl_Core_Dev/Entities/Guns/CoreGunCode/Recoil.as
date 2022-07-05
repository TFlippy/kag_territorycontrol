//////////////////////////////////////////////////////
//
//  Recoil.as - Vamist (old code)
//
//  To disable recoil on a gun, set  
//  G_RECOIL to 0, G_RANDOMY & X to false
//
//  To enable set
//  G_RECOIL to -10, G_RANDOMX and or Y to true
//

class Recoil
{
	CBlob@ Blob;
	CBlob@ Gun;
	CControls@ BlobControls;
	u16 TimeToNormal;
	u16 ReturnTime;
	float xTick;
	float yTick;
	bool RX;
	bool RY;
	s16 DecayRate;

	Recoil(CBlob@ blob, s16 velocity, u16 TimeToEnd, u16 returnTime, bool randomX, bool randomY)
	{
		if (blob is null || blob.getControls() is null)
		{
			return;
		}

		@Blob = blob;
		@Gun = Blob.getCarriedBlob();
		@BlobControls = Blob.getControls();
		RX = randomX;
		RY = randomY;
		ReturnTime = returnTime;
		TimeToNormal = TimeToEnd + returnTime;
		DecayRate = velocity / TimeToEnd;
		xTick = 0;
		yTick = velocity;
	}

	void onTick()
	{
		if (TimeToNormal < 1)
		{
			return;
		}

		if (Blob is null || Gun is null)
		{
			TimeToNormal == 0;
			return;
		}

		TimeToNormal--;
		yTick -= DecayRate;
		//print(yTick + ' ');
		if (RX && ReturnTime < TimeToNormal)
		{
			int rNum = XORRandom(-DecayRate * 2);
			if (XORRandom(2) == 0)
			{
				xTick -= rNum;
			}
			else
			{
				xTick += rNum;
			}
		}

		Vec2f recoil = Vec2f(xTick, yTick);

		if(Gun.get_bool("mouse_recoil_mode")){
			BlobControls.setMousePosition(BlobControls.getMouseScreenPos() + recoil);
		} else {
			recoil.RotateByDegrees(Gun.getAngleDegrees());
			Vec2f aim = Gun.get_Vec2f("aim");
			if(aim.AngleDegrees() > 90 && aim.AngleDegrees() < 270){
				if((aim+recoil).AngleDegrees() > 90)Gun.set_Vec2f("aim",aim+recoil);
			} else {
				if((aim+recoil).AngleDegrees() < 90 || (aim+recoil).AngleDegrees() > 270)Gun.set_Vec2f("aim",aim+recoil);
			}
		}
		ShakeScreen(Vec2f(xTick, yTick), 150, Blob.getInterpolatedPosition());
	}
}
