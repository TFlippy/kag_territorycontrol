// Lantern script

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(96.0f);
	this.SetLightColor(SColor(255, 255, 100, 50));
	this.addCommandID("light on");
	this.addCommandID("light off");
	
	AddIconToken("$lantern on$", "JackOLantern.png", Vec2f(16, 16), 0);
	AddIconToken("$lantern off$", "JackOLantern.png", Vec2f(16, 16), 1);

	this.Tag("dont deactivate");
	this.Tag("fire source");
	this.Tag("ignore_arrow");
}

void Light(CBlob@ this, bool on)
{
	if (!on)
	{
		this.SetLight(false);
		this.getSprite().SetAnimation("nofire");
	}
	else
	{
		this.SetLight(true);
		this.getSprite().SetAnimation("fire");
	}
	this.getSprite().PlaySound("SparkleShort.ogg");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate"))
	{
		Light(this, !this.isLight());
	}

}
