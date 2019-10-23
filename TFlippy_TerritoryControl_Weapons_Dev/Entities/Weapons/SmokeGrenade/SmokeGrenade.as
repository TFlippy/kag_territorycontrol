void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 8;

	this.getSprite().PlaySound("grenade_pinpull.ogg");
	this.getSprite().SetEmitSound("/SmokeGrenadeFizz.ogg");

	this.getSprite().SetEmitSoundPaused(false);
	this.SetLight(true);
	this.SetLightRadius(48.0f);

	this.Tag("projectile");
	
	//this.server_SetTimeToDie(20);
}

void onTick(CBlob@ this)
{
	if(this.hasTag("dead")) return;

	if(isServer())
	{
		server_CreateBlob("smokegas", -1, this.getPosition());
	}

	if(this.getTickSinceCreated() >= 600)
	{
		this.Tag("dead");
		this.server_Die();
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	//special logic colliding with players
	if (blob.hasTag("player"))
	{
		//collide with shielded enemies
		return (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("shielded"));
	}

	string name = blob.getName();

	if (name == "fishy" || name == "food" || name == "steak" || name == "grain" || name == "heart")
	{
		return false;
	}

	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!solid)
	{
		return;
	}

	const f32 vellen = this.getOldVelocity().Length();
	if (vellen > 1.7f)
	{
		Sound::Play("/BombBounce.ogg", this.getPosition(), Maths::Min(vellen / 8.0f, 1.1f), 1.2f);
	}
}

void onDie(CBlob@ this)
{
	this.getSprite().SetEmitSoundPaused(true);
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	inv.doTickScripts = true;
}
