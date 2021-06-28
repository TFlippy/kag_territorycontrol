const u32 lifetime = 20;

void onInit(CBlob@ this)
{
	CMap@ map = getMap();

	float x = this.getPosition().x;
	Vec2f strikePos;
	if (map.rayCastSolid(Vec2f(x, 0.0f), Vec2f(x, map.tilemapheight * map.tilesize), strikePos))
	{
		this.setPosition(Vec2f(x, strikePos.y - 256.0f));
	}

	this.set_Vec2f("strike pos", strikePos);

	if (isServer())
	{
		for (int i = 0; i < 4 + XORRandom(4); i++)
		{
			CBlob@ blob = server_CreateBlob("flame", -1, strikePos + Vec2f(0.0f, -map.tilesize));
			blob.setVelocity(Vec2f(XORRandom(40) / 10.0f - 2.0f, -XORRandom(20) / 10.0f));
			blob.server_SetTimeToDie(4 + XORRandom(6));
		}

		CBlob@[] blobs;
		map.getBlobsInRadius(strikePos, 48.0f, @blobs);
		for (int i = 0; i < blobs.length; i++)
		{
			map.server_setFireWorldspace(blobs[i].getPosition(), true);
		}

		CBlob@ soundBlob = server_CreateBlob("lightningboltsound", this.getTeamNum(), strikePos);
	}

	// if (isClient())
	// {
		// Vec2f pos = getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos());
		// f32 distance = Maths::Abs(strikePos.x - pos.x) / 8.0f;
		// this.set_f32("distance", distance);

		// soundBlob.set_f32("distance", distance);
	// }
}

void onInit(CSprite@ this)
{
	this.animation.frame = XORRandom(4);
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;

	CSprite@ sprite = this.getSprite();

	int time = this.getTickSinceCreated();
	u8 flashAlpha = 0;

	if (isClient())
	{
		f32 distance = this.get_f32("distance");
		flashAlpha = XORRandom(128) + 128;
		flashAlpha -= int(Maths::Min(flashAlpha, distance));
	}

	if (time == lifetime)
	{
		sprite.SetAnimation("fade");
	}

	if (time >= lifetime)
	{
		this.Tag("dead");
		this.server_Die();
	}
	else if (getGameTime() % (XORRandom(2) + 1) == 0)
	{
		sprite.animation.frame = XORRandom(4);

		if (isClient())
		{
			SetScreenFlash(flashAlpha, 255, 255, 255);
			ShakeScreen(200.0f, 50.0f, this.get_Vec2f("strike pos"));
		}
	}
}
