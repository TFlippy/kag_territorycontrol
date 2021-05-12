void onInit(CBlob@ this)
{
	this.getShape().SetOffset(Vec2f(6, 0));

	this.set_string("required class", "juggernaut");
	this.set_Vec2f("class offset", Vec2f(0, 0));

	this.Tag("kill on use");
	this.Tag("dangerous");
	this.Tag("heavy weight");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	bool canChangeClass = caller.getName() != "juggernaut";

	if (canChangeClass) this.Untag("class button disabled");
	else this.Tag("class button disabled");
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0;
}