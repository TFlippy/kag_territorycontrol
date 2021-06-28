// A script by TFlippy

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	this.getCurrentScript().tickFrequency = 5;
	
	this.set_u8("detector_state", 0);
}

void onTick(CBlob@ this)
{
	bool detected = false;
	bool foundBlobs = false;

	CBlob@[] blobs;
	if (getMap().getBlobsInBox(this.getPosition() + Vec2f(-6, 6), this.getPosition() + Vec2f(6, -6), @blobs))
	{
		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ blob = blobs[i];
			if (blob !is null && blob !is this && !blob.getShape().isStatic())
			{
				foundBlobs = true;
				u8 team = blob.getTeamNum();

				if (team != this.getTeamNum() || team >= 100)
				{
					if (isDangerous(blob) || blob.get_string("equipment_torso") == "suicidevest")
					{
						detected = true;
						break;
					}

					CInventory@ inv = blob.getInventory();
					if (inv !is null)
					{
						s32 count = inv.getItemsCount();
						for (s32 i = 0; i < count; i++)
						{
							CBlob@ item = inv.getItem(i);
							if (item !is null)
							{
								if (isDangerous(item)) detected = true;
							}
						}
					}

					CBlob@ carried = blob.getCarriedBlob();
					if (carried !is null)
					{
						if (isDangerous(carried)) detected = true;
					}
				}
			}
		}
	}

	u8 state = foundBlobs ? 1 : 0;
	if (detected) state++;

	CSprite@ sprite = this.getSprite();
	if (this.get_u8("detector_state") != state)
	{
		switch (state)
		{
			case 0:
				this.SetLight(false);
				sprite.SetAnimation("default");
			break;

			case 1:
				this.SetLightColor(SColor(255, 50, 255, 0));
				this.SetLightRadius(96.0f);
				this.SetLight(true);
				sprite.SetAnimation("undetected");
				sprite.PlaySound("MetalDetector_Undetected");
			break;

			case 2:
				this.SetLightColor(SColor(255, 255, 50, 0));
				this.SetLightRadius(96.0f);
				this.SetLight(true);
				sprite.SetAnimation("detected");
				sprite.PlaySound("MetalDetector_Detected");
			break;
		}
	}

	this.set_u8("detector_state", state);
}

bool isDangerous(CBlob@ blob)
{
	return blob.hasTag("explosive") || blob.hasTag("weapon") || blob.hasTag("dangerous");
}
