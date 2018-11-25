// #include "Hitters.as";
// #include "HittersTC.as";
// #include "Explosion.as";

// void onInit(CBlob@ this)
// {
	// this.SetLight(true);
	// this.SetLightRadius(24.0f);
	// this.SetLightColor(SColor(255, 25, 255, 100));
	
	// this.getCurrentScript().tickFrequency = 1;
	// this.getCurrentScript().runFlags |= Script::tick_not_inwater | Script::tick_not_ininventory;
// }

// void onTick(CBlob@ this)
// {	
	// if (this.getQuantity() < 30) return;

	// this.getCurrentScript().tickFrequency = (125 / Maths::Max(1, (this.getQuantity() / 2))) * 10.0f;
	
	// // print("Freq: " + this.getCurrentScript().tickFrequency + "; Quantity: " + this.getQuantity());
	
	// f32 radius = 256 *  this.getQuantity() / 250.0f;
	// this.SetLightRadius(radius * 0.35f);
	
	// if (this.getQuantity() < 60) return;
	
	// if (XORRandom(100) < 50) 
	// {	
		// if (getNet().isServer())
		// {
			// this.server_SetQuantity(this.getQuantity() - 1);
		
			// CBlob@[] blobsInRadius;
			// if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius))
			// {
				// for (int i = 0; i < blobsInRadius.length; i++)
				// {
					// CBlob@ blob = blobsInRadius[i];
					// if (!blob.hasTag("flesh") || blob.hasTag("dead")) continue;

					// Vec2f pos = this.getPosition();
					// Vec2f dir = blob.getPosition() - pos;
					// f32 len = dir.Length();
					// dir.Normalize();

					// int counter = 1;

					// for(int i = 0; i < len; i += 8)
					// {
						// if (getMap().isTileSolid(pos + dir * i)) counter++;
					// }
					
					// f32 distMod = Maths::Max(0, (1.00f - ((this.getPosition() - blob.getPosition()).Length() / radius)));
					
					// if (XORRandom(100) < 100.0f * distMod) 
					// {
						// this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.125f / counter, HittersTC::radiation, true);
					// }
				// }
			// }
		// }
	// }
// }