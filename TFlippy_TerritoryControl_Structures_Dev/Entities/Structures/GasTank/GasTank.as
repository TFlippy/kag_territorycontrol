// A script by TFlippy & Pirate-Rob

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	this.Tag("change team on fort capture");
	this.Tag("gas_tank");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob.getTeamNum() == this.getTeamNum());
	{
		CBlob@ carried = forBlob.getCarriedBlob();
		if (carried !is null) return carried.hasTag("mat_gas");
		else return true;
	}
}
