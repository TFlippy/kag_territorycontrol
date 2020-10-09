void onInit(CBlob@ this)
{
	this.getShape().SetStatic(true);
	this.server_SetTimeToDie(10);
		
	if (isClient())
	{
		CBlob@ localBlob = getLocalPlayerBlob();
		if (localBlob !is null)
		{
			Vec2f pos = this.getPosition();
			
			f32 distance = Maths::Abs(localBlob.getPosition().x - pos.x) / 8.0f;
			this.set_f32("distance", distance);
		}
	}
}

void onTick(CBlob@ this)
{
	if (this.hasTag("sound_played")) return;

	if (isClient())
	{
		int time = this.getTickSinceCreated();
		f32 distance = this.get_f32("distance");

		u32 soundDelay = int(distance / 10.0f);
		if (time > soundDelay)
		{
			this.Tag("sound_played");

			float volume = (1.5f + distance / 50.0f);
			//printFloat("lightning volume", volume);

			if(volume > 0.1f)
			{
				//Sound::Play("LightningBoltStrike.ogg", strikePos, 1.0f, 1.0f);
				Vec2f screenPos = getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos());
				Sound::Play("LightningBoltStrike.ogg", this.getPosition(), volume, Maths::Max(0.6f, 1.0f - distance / 600.0f));
			}
		}
	}
}
