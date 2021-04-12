// A script by TFlippy & Pirate-Rob

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	this.Tag("change team on fort capture");
	this.Tag("oil_tank");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return ((this.getTeamNum() > 100 ? true : forBlob.getTeamNum() == this.getTeamNum()));
}
