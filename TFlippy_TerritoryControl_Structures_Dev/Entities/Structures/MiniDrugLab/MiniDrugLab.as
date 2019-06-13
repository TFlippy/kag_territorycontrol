
void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	this.Tag("heavy weight");
	
	this.set_f32("pressure_max", 50000.00f);
	this.set_string("inventory_name", "Crackhead's Chemistry Kit");
	
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.SetEmitSound("DrugLab_Loop.ogg");
		sprite.SetEmitSoundVolume(0.10f);
		sprite.SetEmitSoundSpeed(1.0f);
		sprite.SetEmitSoundPaused(false);
	}
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return false;
}